import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../bloc/radio_bloc.dart';
import '../bloc/radio_state.dart';
import '../bloc/radio_player_bloc.dart';
import 'dart:ui';
import 'dart:async';
import '../bloc/radio_player_state.dart';
import '../bloc/radio_player_event.dart';
// import '../../domain/repositories/radio_player_repository.dart';
import '../../../../core/services/system_volume_service.dart';
import 'dart:developer' as developer;
import '../../../../core/utils/palette_cache.dart';
import '../../../../core/services/palette_service.dart';
import '../../../../core/widgets/album_art_widget.dart';
import '../../../../core/widgets/smooth_marquee_text.dart';
import '../../../../core/models/album_art_state.dart';
import '../../../../config/radio_tujuhcahaya_config.dart';
import '../../data/services/album_art_service.dart';
import '../../../../main.dart';
import '../widgets/radio_banner_widget.dart';
import '../widgets/m3_volume_bar.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../views/view_on_web/view_on_web_page.dart';


class RadioPage extends StatelessWidget {
  const RadioPage({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('[RadioPage] Building RadioPage', name: 'RadioPage');
    
    // Ensure DI container is initialized
    try {
      getIt.allReady();
    } catch (e) {
      developer.log('[RadioPage] DI container not ready, initializing...', name: 'RadioPage');
      initDependencies();
    }
    
    
    final radioBloc = getIt<RadioBloc>();
    final radioPlayerBloc = getIt<RadioPlayerBloc>();

    developer.log('[RadioPage] Providing shared RadioBloc and RadioPlayerBloc instances', name: 'RadioPage');

    return MultiBlocProvider(
      providers: [
        BlocProvider<RadioBloc>.value(value: radioBloc),
        BlocProvider<RadioPlayerBloc>.value(value: radioPlayerBloc),
      ],
      child: const RadioPageView(key: ValueKey('radio_page_view')),
    );
  }
}

class RadioPageView extends StatefulWidget {
  const RadioPageView({super.key});

  @override
  State<RadioPageView> createState() => _RadioPageViewState();
}

class _RadioPageViewState extends State<RadioPageView> {
  Widget? _cachedBody;
  RadioState? _lastState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _BottomControlsBar(),
      body: BlocBuilder<RadioBloc, RadioState>(
        buildWhen: (previous, current) {
          // Only rebuild if the state actually changes
          return previous != current;
        },
        builder: (context, state) {
          // Cache the body widget to prevent unnecessary rebuilds
          if (_cachedBody == null || _lastState != state) {
            _lastState = state;
            _cachedBody = state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (failure) => Center(child: Text(_getErrorMessage(failure))),
              loaded: (_) => const _RadioHeroLayout(),
              orElse: () => const Center(child: CircularProgressIndicator()),
            );
          }
          return _cachedBody!;
        },
      ),
    );
  }

  String _getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'radio_network_error'.tr();
    } else if (failure is ServerFailure) {
      return 'radio_server_error'.tr();
    } else {
      return 'radio_unknown_error'.tr();
    }
  }
}

class _RadioHeroLayout extends StatefulWidget {
  const _RadioHeroLayout();

  @override
  State<_RadioHeroLayout> createState() => _RadioHeroLayoutState();
}

class _RadioHeroLayoutState extends State<_RadioHeroLayout> {
  Widget? _cachedContent;
  Size? _lastSize;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Only rebuild if size actually changes
          final currentSize = Size(constraints.maxWidth, constraints.maxHeight);
          if (_cachedContent == null || _lastSize != currentSize) {
            _lastSize = currentSize;
            
            // Responsive hero height: ~35% of screen, clamped
            final double heroHeight = (constraints.maxHeight * 0.35).clamp(220.0, 320.0);
            final double screenH = constraints.maxHeight;
            final bool isSmall = screenH < 720;
            final bool isLarge = screenH > 840;
            
            // Calculate actual card height for precise overlap
            final double cardArtSize = isSmall ? 68 : 92;
            final double cardPadding = 8; // Container padding
            final double cardHeight = cardArtSize + (cardPadding * 2);
            final double cardOverlap = cardHeight * 0.25;
            
            _cachedContent = Stack(
              children: [
                // Full-bleed hero backdrop
                _HeroSection(
                  height: heroHeight, 
                  scale: 1.5,
                  cardOverlap: cardOverlap,
                ),

                // Foreground content below
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LayoutBuilder(
                    builder: (context, inner) {
                      // Spacing spec
                      final double gapCardToPanel = isSmall ? 16 : (isLarge ? 24 : 20);
                      final double gapPanelToControls = isSmall ? 20 : (isLarge ? 28 : 24);
                      // Sticky bottom controls moved to bottomNavigationBar

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: heroHeight),
                          FractionalTranslation(
                            translation: const Offset(0, -0.25), // lift card by 25% of its height
                            child: _NowPlayingCard(
                              compact: isSmall
                            ),
                          ),
                          SizedBox(height: gapCardToPanel),
                          // Take up remaining space, but enforce exact 5:4 aspect ratio
                          Expanded(
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 5 / 4,
                                child: BlocBuilder<RadioBloc, RadioState>(
                                  builder: (context, state) {
                                    return state.maybeWhen(
                                      loaded: (radioConfig) => RadioBannerWidget(
                                        banners: radioConfig.banners,
                                      ),
                                      orElse: () => const _FeaturePanelFlex(),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: gapPanelToControls.clamp(12.0, 24.0)),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return _cachedContent!;
        },
      ),
    );
  }
}

class _InfoButton extends StatefulWidget {
  @override
  State<_InfoButton> createState() => _InfoButtonState();
}

class _InfoButtonState extends State<_InfoButton> {
  Timer? _longPressTimer;
  bool _isLongPressing = false;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () => _showInfoDialog(context),
        onLongPressStart: (_) => _startLongPress(context),
        onLongPressEnd: (_) => _cancelLongPress(),
        onLongPressCancel: () => _cancelLongPress(),
        child: Container(
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          child: const Icon(
            Icons.info_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _startLongPress(BuildContext context) {
    _isLongPressing = true;
    _longPressTimer = Timer(const Duration(seconds: 7), () {
      if (_isLongPressing && mounted) {
        _showDebugSheet(context);
      }
    });
  }

  void _cancelLongPress() {
    _isLongPressing = false;
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  @override
  void dispose() {
    _cancelLongPress();
    super.dispose();
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _InfoDialog(),
    );
  }

  void _showDebugSheet(BuildContext context) {
    // Get the current radio configuration from the bloc
    final radioBloc = context.read<RadioBloc>();
    final currentState = radioBloc.state;
    
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _DebugInfoSheet(radioState: currentState),
    );
  }
}

class _HiddenDebugButton extends StatefulWidget {
  @override
  State<_HiddenDebugButton> createState() => _HiddenDebugButtonState();
}

class _HiddenDebugButtonState extends State<_HiddenDebugButton> {
  int _tapCount = 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1, // Minimal height to make it nearly invisible
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          _tapCount++;
          if (_tapCount >= 7) {
            _tapCount = 0;
            _showDebugSheet(context);
          }
        },
        child: Container(
          color: Colors.transparent, // Completely transparent
        ),
      ),
    );
  }

  void _showDebugSheet(BuildContext context) {
    // Get the current radio configuration from the bloc
    final radioBloc = context.read<RadioBloc>();
    final currentState = radioBloc.state;
    
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _DebugInfoSheet(radioState: currentState),
    );
  }
}

class _FeaturePanelFlex extends StatelessWidget {
  const _FeaturePanelFlex();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF625191),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10))],
      ),
    );
  }
}

class _VolumeRow extends StatefulWidget {
  const _VolumeRow();
  @override
  State<_VolumeRow> createState() => _VolumeRowState();
}

class _VolumeRowState extends State<_VolumeRow> {
  double _volume = 1.0;
  StreamSubscription<double>? _sysSub;
  Timer? _debounce;
  bool _isMuted = false;
  double _volumeBeforeMute = 1.0;
  bool _isSettingVolume = false; // Flag to prevent feedback loop

  @override
  void initState() {
    super.initState();
    // Initialize from system volume and subscribe to updates
    final sys = getIt<SystemVolumeService>();
    sys.getVolume().then((v) => mounted ? setState(() => _volume = v) : null);
    _sysSub = sys.volumeStream.listen((v) {
      if (!mounted || _isSettingVolume) return; // Prevent feedback loop
      
      // Only update if there's a meaningful difference (tolerance for floating point)
      if ((v - _volume).abs() > 0.01) {
        setState(() {
          _volume = v;
          // Update mute state based on volume
          if (v == 0 && !_isMuted) {
            _isMuted = true;
            _volumeBeforeMute = 0.5; // default fallback
          } else if (v > 0 && _isMuted) {
            _isMuted = false;
          }
        });
      }
    });
    
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _sysSub?.cancel();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      if (_isMuted) {
        // Unmute: restore previous volume
        _volume = _volumeBeforeMute;
        _isMuted = false;
        _isSettingVolume = true;
        getIt<SystemVolumeService>().setVolume(_volume);
      } else {
        // Mute: save current volume and set to 0
        _volumeBeforeMute = _volume;
        _volume = 0.0;
        _isMuted = true;
        _isSettingVolume = true;
        getIt<SystemVolumeService>().setVolume(0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            onPressed: _toggleMute,
            icon: Icon(
              _isMuted || _volume == 0
                  ? Icons.volume_off
                  : _volume < 0.5
                      ? Icons.volume_down
                      : Icons.volume_up,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            tooltip: _isMuted ? 'Unmute' : 'Mute',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          Expanded(
            child: M3VolumeBar(
              value: _volume,
              onChanged: (v) {
                setState(() => _volume = v);
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 80), () {
                  _isSettingVolume = true;
                  getIt<SystemVolumeService>().setVolume(v);
                  // Reset flag after a short delay to allow for system response
                  Timer(const Duration(milliseconds: 100), () {
                    if (mounted) _isSettingVolume = false;
                  });
                });
              },
              steps: 21,
              enableHaptics: true,
              wavyActive: true,
              waveStrength: 0.35,
              height: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow();
  @override
  Widget build(BuildContext context) {
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewOnWebPage(
                  title: RadioTujuhCahayaConfig.requestWebViewTitle,
                  url: RadioTujuhCahayaConfig.requestWebViewUrl,
                ),
              ),
            );
          },
          iconSize: 32,
          icon: const Icon(Icons.featured_play_list_outlined),
          tooltip: 'Request Lagu',
        ),
        BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
          builder: (context, state) {
            bool isPlaying = false;
            bool isLoading = false;
            state.maybeWhen(
              initializing: () => isLoading = true,
              connecting: () => isLoading = true,
              buffering: () => isLoading = true,
              retrying: (_, __) => isLoading = true,
              ready: (playing, _, __, ___, ____, _____, ______) => isPlaying = playing,
              orElse: () {},
            );
            return Semantics(
              label: isPlaying ? 'Jeda' : 'Putar',
              button: true,
              child: ElevatedButton(
                onPressed: () => context.read<RadioPlayerBloc>().add(const RadioPlayerEvent.togglePlayPause()),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(140, 56), // 5:2 aspect ratio
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  child: isLoading
                      ? const SizedBox(
                          key: ValueKey('center-buf'),
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          key: const ValueKey('center-pp'),
                          size: 36,
                        ),
                ),
              ),
            );
          },
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.shoutbox);
          },
          iconSize: 32,
          icon: const Icon(Icons.chat_bubble_outline),
          tooltip: 'Shoutbox',
        ),
      ],
    );
  }
}



class _InfoDialog extends StatelessWidget {
  const _InfoDialog();
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Information',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Radio Station Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to UpRadio Semarang Radio!',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Station Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _InfoRow(label: 'Frequency', value: '98.5 FM'),
            _InfoRow(label: 'Location', value: 'Semarang'),
            _InfoRow(label: 'Website', value: 'upradio.id'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _InfoRow({
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenAlbumArtDialog extends StatefulWidget {
  final String? artist;
  final String? title;
  final PaletteColors? palette;
  
  const _FullScreenAlbumArtDialog({
    required this.artist,
    required this.title,
    required this.palette,
  });
  
  @override
  State<_FullScreenAlbumArtDialog> createState() => _FullScreenAlbumArtDialogState();
}

class _FullScreenAlbumArtDialogState extends State<_FullScreenAlbumArtDialog> {
  Color _fromBg = const Color(0xFF15232B);
  Color _toBg = const Color(0xFF15232B);
  Color _fromShadow = const Color(0xFF0B1216);
  Color _toShadow = const Color(0xFF0B1216);
  Color _stableTextColor = Colors.white; // Stable text color that doesn't change during animation

  @override
  void initState() {
    super.initState();
    if (widget.palette != null) {
      _toBg = widget.palette!.dominant;
      _toShadow = widget.palette!.darkVibrant;
      // Set stable text color based on initial palette
      _stableTextColor = ThemeData.estimateBrightnessForColor(widget.palette!.dominant) == Brightness.dark 
          ? Colors.white 
          : Colors.black87;
    }
  }

  @override
  void didUpdateWidget(covariant _FullScreenAlbumArtDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.palette != widget.palette && widget.palette != null) {
      setState(() {
        _fromBg = _toBg;
        _toBg = widget.palette!.dominant;
        _fromShadow = _toShadow;
        _toShadow = widget.palette!.darkVibrant;
        // Update stable text color only when palette actually changes
        _stableTextColor = ThemeData.estimateBrightnessForColor(widget.palette!.dominant) == Brightness.dark 
            ? Colors.white 
            : Colors.black87;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final maxSize = screenSize.width * 0.9; // 90% of screen width
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: TweenAnimationBuilder<Color?>(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        tween: ColorTween(begin: _fromBg, end: _toBg),
        builder: (_, color, __) {
          final bgColor = color ?? _toBg;
          
          return TweenAnimationBuilder<Color?>(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            tween: ColorTween(begin: _fromShadow, end: _toShadow),
            builder: (_, shadowColor, __) {
              final shadow = shadowColor ?? _toShadow;
              
              return Container(
                width: maxSize,
                height: maxSize,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color.lerp(Colors.black, shadow, 0.2)!.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.artist?.trim().isNotEmpty == true
                              ? widget.artist!.trim()
                              : RadioTujuhCahayaConfig.fallbackArtist,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _stableTextColor, // Use stable color that doesn't change during animation
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.title?.trim().isNotEmpty == true
                              ? widget.title!.trim()
                              : RadioTujuhCahayaConfig.fallbackTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _stableTextColor.withValues(alpha: 0.7), // Use stable color that doesn't change during animation
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: _stableTextColor.withValues(alpha: 0.1), // Use stable color that doesn't change during animation
                      foregroundColor: _stableTextColor, // Use stable color that doesn't change during animation
                    ),
                  ),
                ],
              ),
            ),
            // Album art - 1:1 aspect ratio
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0, // 1:1 aspect ratio
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color.lerp(Colors.black, shadow, 0.2)!.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _SafeAlbumArtWidget(
                        width: maxSize - 32,
                        height: maxSize - 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SafeAlbumArtWidget extends StatelessWidget {
  final double width;
  final double height;
  
  const _SafeAlbumArtWidget({
    required this.width,
    required this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AlbumArtState>(
      stream: AlbumArtService.instance.albumArtStream,
      initialData: AlbumArtService.instance.currentState,
      builder: (context, snapshot) {
        final albumArtState = snapshot.data ?? AlbumArtService.instance.currentState;
        return _buildSafeAlbumArt(albumArtState);
      },
    );
  }
  
  Widget _buildSafeAlbumArt(AlbumArtState albumArtState) {
    if (albumArtState.isLoading) {
      return _buildLoadingState();
    }

    if (albumArtState.hasUrl) {
      return _buildNetworkImage(albumArtState.url!);
    }

    return _buildFallbackImage();
  }
  
  Widget _buildLoadingState() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[900],
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white70,
          strokeWidth: 2,
        ),
      ),
    );
  }
  
  Widget _buildNetworkImage(String url) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _buildLoadingState();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage();
        },
      ),
    );
  }
  
  Widget _buildFallbackImage() {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        RadioTujuhCahayaConfig.fallbackArtworkPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          // Ultimate fallback - gradient with icon
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[800]!,
                  Colors.grey[900]!,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.music_note,
                  size: width * 0.3,
                  color: Colors.white70,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Album Art',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DebugInfoSheet extends StatelessWidget {
  final RadioState radioState;
  
  const _DebugInfoSheet({required this.radioState});
  
  @override
  Widget build(BuildContext context) {
    return radioState.maybeWhen(
      loaded: (config) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Radio Configuration', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Autoplay: ${config.autoplay}'),
              Text('Show Album Cover: ${config.showAlbumCover}'),
              Text('Text Scrolling: ${config.textScrolling}'),
              const SizedBox(height: 8),
              Text('Stream URL: ${config.streamUrl}', style: const TextStyle(fontFamily: 'monospace')),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
      orElse: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Radio configuration not loaded'),
      ),
    );
  }
}

// ===========================
// Hero + Floating NP Card
// ===========================

class _HeroSection extends StatefulWidget {
  final double height;
  final double scale;
  final double cardOverlap;
  const _HeroSection({required this.height, this.scale = 1.0, required this.cardOverlap});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> with SingleTickerProviderStateMixin, RouteAware {
  String? _cachedArtUrl;
  String? _lastGreeting;
  DateTime? _lastFadeTime;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // start faded out, then fade in after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fadeCtrl.forward(from: 0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    // another page is on top
  }

  @override
  void didPopNext() {
    // coming back to this page: re-fade
    _fadeCtrl.forward(from: 0);
  }

  void _restartFadeIn() {
    if (!_fadeCtrl.isAnimating && mounted) {
      final now = DateTime.now();
      // Debounce rapid fade restarts (minimum 500ms between fades)
      if (_lastFadeTime == null || now.difference(_lastFadeTime!).inMilliseconds > 500) {
        _lastFadeTime = now;
        _fadeCtrl.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      // Clip the *entire* hero so ImageFilter blur can't sample outside
      child: ClipRect(
        child: Container(
          // Dark background to prevent white flashing during fade transitions
          // Use theme-aware color for better dark/light mode support
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.black 
              : Colors.grey[900],
          child: FadeTransition(
            opacity: _fade,
            child: BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
            buildWhen: (previous, current) {
              String? newArtUrl;
              current.maybeWhen(
                ready: (playing, _, __, ___, currentAlbumArtUrl, ____, ______) {
                  newArtUrl = currentAlbumArtUrl;
                },
                orElse: () {},
              );
              
              // Only rebuild if the album art URL actually changed
              final changed = newArtUrl != _cachedArtUrl;
              if (changed) {
                final oldArtUrl = _cachedArtUrl;
                _cachedArtUrl = newArtUrl;
                // Only restart fade if we have a meaningful album art URL change
                if (newArtUrl != null && newArtUrl!.isNotEmpty && newArtUrl != oldArtUrl) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _restartFadeIn());
                }
              }
              return changed;
            },
            builder: (context, state) {
              String? artUrl;
              state.maybeWhen(
                ready: (playing, _, __, ___, currentAlbumArtUrl, ____, ______) => artUrl = currentAlbumArtUrl,
                orElse: () {},
              );

              _cachedArtUrl = artUrl;

              final currentGreeting = _greeting();
              if (_lastGreeting != currentGreeting) {
                _lastGreeting = currentGreeting;
              }

              return _CachedHeroContent(
                scale: widget.scale,
                greeting: _lastGreeting!,
                heroHeight: widget.height,
                cardOverlap: widget.cardOverlap,
              );
            },
          ),
          ),
        ),
      ),
    );
  }
}

class _CachedHeroContent extends StatefulWidget {
  final double scale;
  final String greeting;
  final double heroHeight;
  final double cardOverlap;

  const _CachedHeroContent({
    required this.scale,
    required this.greeting,
    required this.heroHeight,
    required this.cardOverlap,
  });

  @override
  State<_CachedHeroContent> createState() => _CachedHeroContentState();
}

class _CachedHeroContentState extends State<_CachedHeroContent> {
  // Use default colors since AlbumArtWidget handles image loading
  final Color _greetingColor = Colors.white;


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // light icons on dark bg
      child: SizedBox(
        height: widget.heroHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background with album art
            RepaintBoundary(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Transform.scale(
                  scale: widget.scale,
                  child: _buildBgImage(),
                ),
              ),
            ),
            // Top dark gradient for legibility
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment(0, 0.6),
                  colors: [Color(0xCC0B1216), Color(0x000B1216)],
                ),
              ),
            ),
            // Greeting block - centered between status bar and player card
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(left: 24, right: 24, top: MediaQuery.of(context).padding.top),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // status bar spacer is already consumed by top padding
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'radio_greeting_hi'.tr(), 
                              style: TextStyle(
                                color: _greetingColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                shadows: const [
                                  Shadow(
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                    color: Color(0x66000000),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.greeting, 
                              style: TextStyle(
                                color: _greetingColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                shadows: const [
                                  Shadow(
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                    color: Color(0x66000000),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'radio_station_name'.tr(), 
                              style: TextStyle(
                                color: _greetingColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                shadows: const [
                                  Shadow(
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                    color: Color(0x66000000),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // bottom spacer = exact amount the card lifts into the hero
                    SizedBox(height: widget.cardOverlap),
                  ],
                ),
              ),
            ),
            // Info button in top right corner
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 24,
              child: _InfoButton(),
            ),
            // Bottom fade to page background (soft dissolve)
            Positioned(
              left: 0,
              right: 0,
              bottom: -2, // slight overlap to hide seams
              height: widget.heroHeight * 0.45, // longer tail to prevent seams
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.6, 1.0],
                      colors: [
                        const Color(0x000B1216),                 // fully transparent
                        const Color(0x120B1216),                 // gentle mid fade
                        Theme.of(context).colorScheme.surface, // exact page bg
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBgImage() {
    return AlbumArtWidget.rectangle(
      width: double.infinity,
      height: double.infinity,
      filterQuality: FilterQuality.low,
      fit: BoxFit.cover,
    );
  }
}


class _NowPlayingCard extends StatefulWidget {
  final bool compact;
  const _NowPlayingCard({this.compact = false});

  @override
  State<_NowPlayingCard> createState() => _NowPlayingCardState();
}

class _NowPlayingCardState extends State<_NowPlayingCard> {
  PaletteColors? _cachedPalette;
  bool _isLoadingPalette = false;
  String? _currentAlbumArtUrl;
  final PaletteService _paletteService = PaletteService();
  static final Map<String, PaletteColors> _paletteCache = {}; // Static cache across instances

  Future<void> _generatePalette(String albumArtUrl) async {
    if (_isLoadingPalette) return;
    
    // Check cache first
    if (_paletteCache.containsKey(albumArtUrl)) {
      if (mounted) {
        setState(() {
          _cachedPalette = _paletteCache[albumArtUrl];
        });
      }
      return;
    }
    
    Log.debug('[Palette] Starting palette generation for: $albumArtUrl');
    
    setState(() {
      _isLoadingPalette = true;
    });
    
    try {
      final palette = await _paletteService.fetchForUrl(albumArtUrl);
      if (mounted) {
        Log.debug('[Palette] Generated palette: dominant=${palette.dominant}, vibrant=${palette.vibrant}');
        // Cache the palette
        _paletteCache[albumArtUrl] = palette;
        setState(() {
          _cachedPalette = palette;
          _isLoadingPalette = false;
        });
      }
    } catch (e) {
      Log.debug('[Palette] Error generating palette: $e');
      if (mounted) {
        setState(() {
          _isLoadingPalette = false;
        });
      }
    }
  }

  Future<void> _generatePaletteFromFallback() async {
    if (_isLoadingPalette) return;
    
    const fallbackKey = 'fallback_artwork';
    
    // Check cache first
    if (_paletteCache.containsKey(fallbackKey)) {
      if (mounted) {
        setState(() {
          _cachedPalette = _paletteCache[fallbackKey];
        });
      }
      return;
    }
    
    Log.debug('[Palette] Starting palette generation for fallback image');
    
    setState(() {
      _isLoadingPalette = true;
    });
    
    try {
      // Generate palette from the fallback asset image
      final palette = await _paletteService.fetchForImage(
        const AssetImage('assets/images/fallback_artwork.jpg'),
        cacheKey: fallbackKey,
      );
      if (mounted) {
        Log.debug('[Palette] Generated fallback palette: dominant=${palette.dominant}, vibrant=${palette.vibrant}');
        // Cache the palette
        _paletteCache[fallbackKey] = palette;
        setState(() {
          _cachedPalette = palette;
          _isLoadingPalette = false;
        });
      }
    } catch (e) {
      Log.debug('[Palette] Error generating fallback palette: $e');
      if (mounted) {
        setState(() {
          _isLoadingPalette = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
      buildWhen: (previous, current) {
        // Rebuild when metadata or album art changes
        String? newArtist;
        String? newTitle;
        String? newAlbumArtUrl;
        current.maybeWhen(
          ready: (playing, _, currentArtist, currentTitle, currentAlbumArtUrl, __, ___) {
            newArtist = currentArtist;
            newTitle = currentTitle;
            newAlbumArtUrl = currentAlbumArtUrl;
          },
          orElse: () {},
        );
        
        String? oldArtist;
        String? oldTitle;
        String? oldAlbumArtUrl;
        previous.maybeWhen(
          ready: (playing, _, currentArtist, currentTitle, currentAlbumArtUrl, __, ___) {
            oldArtist = currentArtist;
            oldTitle = currentTitle;
            oldAlbumArtUrl = currentAlbumArtUrl;
          },
          orElse: () {},
        );
        
        return newArtist != oldArtist || 
               newTitle != oldTitle || 
               newAlbumArtUrl != oldAlbumArtUrl;
      },
      builder: (context, state) {
        String? artist;
        String? title;
        String? albumArtUrl;
        state.maybeWhen(
          ready: (playing, _, currentArtist, currentTitle, currentAlbumArtUrl, __, ___) {
            artist = currentArtist;
            title = currentTitle;
            albumArtUrl = currentAlbumArtUrl;
          },
          orElse: () {},
        );
        
        // Generate palette when album art changes (including fallback)
        final String? currentArtUrl = albumArtUrl;
        if (currentArtUrl != _currentAlbumArtUrl) {
          _currentAlbumArtUrl = currentArtUrl;
          Log.debug('[Palette] Album art changed, triggering palette generation for: $currentArtUrl');
          // Use post-frame callback to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (currentArtUrl != null && currentArtUrl.isNotEmpty) {
                // Generate palette from network image
                _generatePalette(currentArtUrl);
              } else {
                // Generate palette from fallback image
                _generatePaletteFromFallback();
              }
            }
          });
        } else if (_currentAlbumArtUrl != null && _cachedPalette == null && !_isLoadingPalette) {
          // If we have a URL but no palette and not loading, try to load from cache or generate
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (_currentAlbumArtUrl!.isNotEmpty) {
                _generatePalette(_currentAlbumArtUrl!);
              } else {
                _generatePaletteFromFallback();
              }
            }
          });
        }
        
        final double artSize = widget.compact ? 68 : 92;

        return _CachedNowPlayingContent(
          artist: artist,
          title: title,
          artSize: artSize,
          palette: _cachedPalette,
          isLoadingPalette: _isLoadingPalette,
        );
      },
    );
  }
}

class _CachedNowPlayingContent extends StatefulWidget {
  final String? artist;
  final String? title;
  final double artSize;
  final PaletteColors? palette;
  final bool isLoadingPalette;

  const _CachedNowPlayingContent({
    required this.artist,
    required this.title,
    required this.artSize,
    required this.palette,
    required this.isLoadingPalette,
  });

  @override
  State<_CachedNowPlayingContent> createState() => _CachedNowPlayingContentState();
}

class _CachedNowPlayingContentState extends State<_CachedNowPlayingContent> {
  Color _fromBg = const Color(0xFF15232B);
  Color _toBg = const Color(0xFF15232B);
  Color _fromShadow = const Color(0xFF0B1216);
  Color _toShadow = const Color(0xFF0B1216);
  Color _stableTextColor = Colors.white; // Stable text color that doesn't change during animation

  @override
  void didUpdateWidget(covariant _CachedNowPlayingContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.palette != widget.palette && widget.palette != null) {
      setState(() {
        _fromBg = _toBg;
        _toBg = widget.palette!.dominant;
        _fromShadow = _toShadow;
        _toShadow = widget.palette!.darkVibrant;
        // Update stable text color only when palette actually changes
        _stableTextColor = ThemeData.estimateBrightnessForColor(widget.palette!.dominant) == Brightness.dark 
            ? Colors.white 
            : Colors.black87;
      });
    }
  }

  void _showFullScreenAlbumArt(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _FullScreenAlbumArtDialog(
        artist: widget.artist,
        title: widget.title,
        palette: widget.palette,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      tween: ColorTween(begin: _fromBg, end: _toBg),
      builder: (_, color, __) {
        final bgColor = color ?? _toBg;
        
        return TweenAnimationBuilder<Color?>(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          tween: ColorTween(begin: _fromShadow, end: _toShadow),
          builder: (_, shadowColor, __) {
            final shadow = shadowColor ?? _toShadow;
            
            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Color.lerp(Colors.black, shadow, 0.2)!.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _showFullScreenAlbumArt(context),
                      child: Container(
                        width: widget.artSize,
                        height: widget.artSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AlbumArtWidget.roundedRect(
                          width: widget.artSize,
                          height: widget.artSize,
                          borderRadius: 20,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Artist with scrolling text (same as FAB)
                          SmoothMarqueeAuto(
                            text: widget.artist?.trim().isNotEmpty == true
                                ? widget.artist!.trim()
                                : RadioTujuhCahayaConfig.fallbackArtist,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: _stableTextColor, // Use stable color that doesn't change during animation
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                            scrollDuration: const Duration(seconds: 12),
                            pauseDuration: const Duration(seconds: 3),
                          ),
                          const SizedBox(height: 6),
                          // Title with scrolling text (same as FAB)
                          SmoothMarqueeAuto(
                            text: widget.title?.trim().isNotEmpty == true
                                ? widget.title!.trim()
                                : RadioTujuhCahayaConfig.fallbackTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: _stableTextColor.withValues(alpha: 0.9), // Use stable color that doesn't change during animation
                              fontWeight: FontWeight.w400,
                            ),
                            scrollDuration: const Duration(seconds: 10),
                            pauseDuration: const Duration(seconds: 3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BottomControlsBar extends StatelessWidget {
  const _BottomControlsBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 200),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _VolumeRow(),
              const SizedBox(height: 12),
              _ActionRow(),
            ],
          ),
        ),
      ),
    );
  }
}
