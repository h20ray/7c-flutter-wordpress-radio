import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../config/wp_config.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/models/category.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/themes/theme_manager.dart';
import 'horizontal_app_logo.dart';

class HomeAppBarWithTab extends ConsumerWidget {
  const HomeAppBarWithTab({
    super.key,
    required this.categories,
    required this.tabController,
    required this.forceElevated,
    required this.showLogoInHome,
  });

  final List<CategoryModel> categories;
  final TabController tabController;
  final bool forceElevated;
  final bool showLogoInHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(themeModeProvider.notifier);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      elevation: 1,
      pinned: true,
      floating: true,
      automaticallyImplyLeading: false,
      forceElevated: forceElevated,
      title: showLogoInHome ? null : const Text(WPConfig.appName),
      titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
      centerTitle: false,
      leading:
          showLogoInHome ? HorizontalAppLogo(isElevated: forceElevated) : null,
      leadingWidth: showLogoInHome
          ? Responsive.isMobile(context)
              ? MediaQuery.of(context).size.width * 0.35
              : MediaQuery.of(context).size.width * 0.15
          : null,

      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
          icon: const Icon(AppIcons.search),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.notification),
          icon: const Icon(AppIcons.notification),
        ),
        IconButton(
          tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
          onPressed: () {
            if (isDark) {
              controller.changeThemeMode(AdaptiveThemeMode.light, context);
            } else {
              controller.changeThemeMode(AdaptiveThemeMode.dark, context);
            }
          },
          icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
        ),
      ],

      /// TabBar
      bottom: TabBar(
        controller: tabController,
        enableFeedback: true,
        isScrollable: true,
        padding: const EdgeInsets.only(left: AppDefaults.padding),
        tabs: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: List.generate(
            categories.length,
            (index) => Text(AppUtils.trimHtml(categories[index].name)),
          ),
        ),
      ),
    );
  }
}
