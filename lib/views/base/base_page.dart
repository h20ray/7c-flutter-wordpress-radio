import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/components/mini_player.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/controllers/config/config_controllers.dart';
import '../../core/repositories/others/onboarding_local.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/ui_util.dart';
import '../auth/dialogs/consent_sheet.dart';
import '../explore/explore_page.dart';
import '../home/home_page/home_page.dart';
import '../saved/saved_page.dart';
import '../settings/settings_page.dart';
import '../../features/radio/presentation/pages/radio_page.dart';
import '../../features/radio/presentation/bloc/radio_bloc.dart';
import '../../features/radio/presentation/bloc/radio_event.dart';
import '../../features/radio/presentation/bloc/radio_player_bloc.dart';
import '../../features/radio/presentation/bloc/radio_player_event.dart';
import '../../features/radio/presentation/bloc/radio_player_state.dart';
import '../../features/radio/domain/entities/radio_entity.dart';
import '../../core/di/injection_container.dart';
import '../../core/widgets/m3_radio_fab.dart';

// Provider to watch radio configuration
final radioConfigProvider = FutureProvider<RadioEntity?>((ref) async {
  final radioBloc = getIt<RadioBloc>();

  // Check if radio config is already loaded
  final currentState = radioBloc.state;
  final alreadyLoaded = currentState.maybeWhen(
    loaded: (radioConfig) => radioConfig,
    orElse: () => null,
  );

  if (alreadyLoaded != null) {
    return alreadyLoaded;
  }

  // If not loaded, trigger the event and wait
  radioBloc.add(const RadioEvent.getRadioConfig());

  // Wait for the first loaded state
  await for (final state in radioBloc.stream) {
    return state.maybeWhen(
      loaded: (radioConfig) => radioConfig,
      orElse: () => null,
    );
  }
  return null;
});

class EntryPointUI extends HookConsumerWidget {
  const EntryPointUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = usePageController();
    final selectedIndex = useState(0);
    final currentBackPressTime = useState<DateTime?>(null);
    final canPopNow = useState(false);
    final lastPlayPauseClick = useState<DateTime?>(null);

    // Watch radio configuration
    final radioConfigAsync = ref.watch(radioConfigProvider);
    final isRadioEnabled = radioConfigAsync.when(
      data: (config) => config?.enabled ?? false,
      loading: () => false,
      error: (_, __) => false,
    );

    // State to track if we're on the radio screen
    final isOnRadioScreen = useState(false);

    // Check if we're on the radio tab based on selected index
    // Radio tab is at index 1 when enabled
    final radioTabIndex = isRadioEnabled ? 1 : -1;
    final isOnRadio = isRadioEnabled && selectedIndex.value == radioTabIndex;
    isOnRadioScreen.value = isOnRadio;

    final showConsent =
        ref.watch(configProvider).value?.showCookieConsent ?? false;

    void onTabTap(int index) {
      controller.animateToPage(
        index,
        duration: AppDefaults.duration,
        curve: Curves.ease,
      );
      selectedIndex.value = index;
    }

    void navigateToRadio() {
      // Navigate to radio tab instead of pushing a new route
      if (isRadioEnabled) {
        final radioTabIndex = 1; // Radio is at index 1 when enabled
        controller.animateToPage(
          radioTabIndex,
          duration: AppDefaults.duration,
          curve: Curves.ease,
        );
        selectedIndex.value = radioTabIndex;
      }
    }

    void handlePlayPause(BuildContext context) {
      final radioConfig = radioConfigAsync.value;
      if (radioConfig == null) return;

      // Debounce rapid clicks
      final now = DateTime.now();
      if (lastPlayPauseClick.value != null &&
          now.difference(lastPlayPauseClick.value!) <
              const Duration(milliseconds: 500)) {
        return; // Ignore rapid clicks
      }
      lastPlayPauseClick.value = now;

      final radioPlayerBloc = context.read<RadioPlayerBloc>();
      radioPlayerBloc.add(const RadioPlayerEvent.togglePlayPause());
    }

    void checkIfConsent(BuildContext context, WidgetRef ref) {
      if (!showConsent) return;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final isDone = OnboardingRepository().isConsentDone();
        if (!isDone) {
          UiUtil.openBottomSheet(
            context: context,
            widget: const CookieConsentSheet(),
          );
        }
      });
    }

    useEffect(() {
      checkIfConsent(context, ref);
      return null;
    }, []);

    final isLoggedEnable =
        ref.read(configProvider).value?.isLoginEnabled ?? false;

    // Build screens array with conditional radio page
    final screens = <Widget>[
      const HomePage(),
      if (isRadioEnabled) const RadioPage(),
      const ExplorePage(),
      if (isLoggedEnable) const SavedPage(),
      const SettingsPage(),
    ];

    // Build navbar items array with conditional radio item
    final navbarItems = <GButton>[
      GButton(icon: AppIcons.home, text: 'home'.tr()),
      if (isRadioEnabled) GButton(icon: Icons.radio, text: 'radio'.tr()),
      GButton(icon: AppIcons.explore, text: 'explore'.tr()),
      if (isLoggedEnable) GButton(icon: AppIcons.saved, text: 'saved'.tr()),
      GButton(icon: AppIcons.settings, text: 'settings'.tr()),
    ];

    return BlocProvider.value(
      value: getIt<RadioPlayerBloc>(),
      child: PopScope(
        canPop: canPopNow.value,
        onPopInvokedWithResult: (didPop, _) async {
          // If not on home screen, navigate to home instead of showing exit message
          if (selectedIndex.value != 0) {
            controller.animateToPage(
              0, // Navigate to home screen (index 0)
              duration: AppDefaults.duration,
              curve: Curves.ease,
            );
            selectedIndex.value = 0;
            return;
          }
          
          // Only show exit confirmation when on home screen
          final now = DateTime.now();
          if (currentBackPressTime.value == null ||
              now.difference(currentBackPressTime.value!) >
                  const Duration(seconds: 2)) {
            currentBackPressTime.value = now;
            canPopNow.value = false;
            Fluttertoast.showToast(msg: 'Press back again to exit');
          } else {
            canPopNow.value = true;
            await SystemNavigator.pop();
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: PageView(
                      allowImplicitScrolling: false,
                      physics: const NeverScrollableScrollPhysics(),
                      controller: controller,
                      children: screens,
                    ),
                  ),
                  const MiniPlayer(isOnStack: false),
                ],
              ),
              // Positioned M3 Radio FAB with smooth animations
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: (isRadioEnabled && !isOnRadioScreen.value)
                    ? 16
                    : -100, // Slide down when hidden
                left: 16,
                right: 16,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  opacity:
                      (isRadioEnabled && !isOnRadioScreen.value) ? 1.0 : 0.0,
                  child: radioConfigAsync.when(
                    data: (config) => config != null
                        ? BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
                            builder: (context, playerState) {
                              return M3RadioFab(
                                radioConfig: config,
                                onTap: navigateToRadio,
                                onPlayPause: () => handlePlayPause(context),
                                isPlaying: playerState.maybeWhen(
                                  ready: (isPlaying,
                                          currentUrl,
                                          currentArtist,
                                          currentTitle,
                                          currentAlbumArtUrl,
                                          isDucking,
                                          canAutoResume) =>
                                      isPlaying,
                                  orElse: () => false,
                                ),
                                isInitializing: playerState.maybeWhen(
                                  initializing: () => true,
                                  orElse: () => false,
                                ),
                                currentTitle: playerState.maybeWhen(
                                  ready: (isPlaying,
                                          currentUrl,
                                          currentArtist,
                                          currentTitle,
                                          currentAlbumArtUrl,
                                          isDucking,
                                          canAutoResume) =>
                                      currentTitle,
                                  orElse: () => null,
                                ),
                                currentArtist: playerState.maybeWhen(
                                  ready: (isPlaying,
                                          currentUrl,
                                          currentArtist,
                                          currentTitle,
                                          currentAlbumArtUrl,
                                          isDucking,
                                          canAutoResume) =>
                                      currentArtist,
                                  orElse: () => null,
                                ),
                                currentAlbumArtUrl: playerState.maybeWhen(
                                  ready: (isPlaying,
                                          currentUrl,
                                          currentArtist,
                                          currentTitle,
                                          currentAlbumArtUrl,
                                          isDucking,
                                          canAutoResume) =>
                                      currentAlbumArtUrl,
                                  orElse: () => null,
                                ),
                                // radioCoreV2: New state parameters
                                isConnecting: playerState.maybeWhen(
                                  connecting: () => true,
                                  orElse: () => false,
                                ),
                                isBuffering: playerState.maybeWhen(
                                  buffering: () => true,
                                  orElse: () => false,
                                ),
                                isRetrying: playerState.maybeWhen(
                                  retrying: (attempt, reason) => true,
                                  orElse: () => false,
                                ),
                                retryAttempt: playerState.maybeWhen(
                                  retrying: (attempt, reason) => attempt,
                                  orElse: () => 0,
                                ),
                                retryReason: playerState.maybeWhen(
                                  retrying: (attempt, reason) => reason,
                                  orElse: () => null,
                                ),
                              );
                            },
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: null, // We'll position it manually with Stack
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GNav(
                rippleColor: AppColors.primary.withOpacityValue(0.3),
                hoverColor: Colors.grey.shade700,
                haptic: true,
                tabBorderRadius: AppDefaults.radius,
                curve: Curves.easeIn,
                duration: AppDefaults.duration,
                gap: 8,
                padding: const EdgeInsets.all(AppDefaults.padding),
                color: Colors.grey,
                activeColor: AppColors.primary,
                iconSize: 24,
                tabBackgroundColor: AppColors.primary.withOpacityValue(0.1),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                tabs: navbarItems,
                onTabChange: onTabTap,
                selectedIndex: selectedIndex.value,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
