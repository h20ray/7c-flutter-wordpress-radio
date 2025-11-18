import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/progress_bar_loader.dart';
import '../../../core/constants/constants.dart';
import '../../../core/app/loading_state_provider.dart';
import '../../../core/services/palette_service.dart';

class LoadingDependencies extends ConsumerStatefulWidget {
  const LoadingDependencies({
    super.key,
  });

  @override
  ConsumerState<LoadingDependencies> createState() => _LoadingDependenciesState();
}

class _LoadingDependenciesState extends ConsumerState<LoadingDependencies> {
  Color? _textColor;
  Color? _progressBarColor;
  final PaletteService _paletteService = PaletteService();

  @override
  void initState() {
    super.initState();
    _analyzeImageColors();
  }

  /// Calculate relative luminance (brightness) of a color
  /// Returns a value between 0 (dark) and 1 (light)
  double _calculateLuminance(Color color) {
    return color.computeLuminance();
  }

  /// Determine if a color is light or dark
  bool _isLightColor(Color color) {
    return _calculateLuminance(color) > 0.5;
  }

  /// Get contrasting text color based on background brightness
  Color _getContrastingTextColor(Color backgroundColor) {
    final isLight = _isLightColor(backgroundColor);
    // Use white for dark backgrounds, dark gray for light backgrounds
    return isLight 
        ? Colors.black.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.9);
  }

  /// Get appropriate progress bar color based on background
  Color _getProgressBarColor(Color backgroundColor) {
    final isLight = _isLightColor(backgroundColor);
    // Use primary color, but adjust opacity/contrast if needed
    // For light backgrounds, use a darker/more saturated version
    // For dark backgrounds, use the standard primary color
    if (isLight) {
      // Make primary color darker for better contrast on light backgrounds
      final hsl = HSLColor.fromColor(AppColors.primary);
      return hsl.withLightness((hsl.lightness * 0.7).clamp(0.0, 1.0)).toColor();
    }
    return AppColors.primary;
  }

  Future<void> _analyzeImageColors() async {
    try {
      // Extract palette from the loading image
      final palette = await _paletteService.fetchForImage(
        const AssetImage(AppImages.loadingImage),
        cacheKey: 'loading_image',
      );

      // Use the dominant color to determine text color
      final dominantColor = palette.dominant;
      
      if (mounted) {
        setState(() {
          _textColor = _getContrastingTextColor(dominantColor);
          _progressBarColor = _getProgressBarColor(dominantColor);
        });
      }
    } catch (e) {
      // Fallback to white text if analysis fails
      if (mounted) {
        setState(() {
          _textColor = Colors.white.withValues(alpha: 0.9);
          _progressBarColor = AppColors.primary;
        });
      }
    }
  }

  String _getStatusTranslationKey(LoadingStatus status) {
    switch (status) {
      case LoadingStatus.checkingConnection:
        return 'loading_checking_connection';
      case LoadingStatus.loadingConfig:
        return 'loading_config';
      case LoadingStatus.initializingDependencies:
        return 'loading_dependencies';
      case LoadingStatus.initializingStorage:
        return 'loading_storage';
      case LoadingStatus.initializingConnectivity:
        return 'loading_connectivity';
      case LoadingStatus.initializingNotifications:
        return 'loading_notifications';
      case LoadingStatus.initializingAuth:
        return 'loading_auth';
      case LoadingStatus.initializingRadio:
        return 'loading_radio';
      case LoadingStatus.preparingApp:
        return 'loading_preparing';
      case LoadingStatus.complete:
        return 'loading_complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final loadingState = ref.watch(loadingStateProvider);
    final statusKey = _getStatusTranslationKey(loadingState.status);
    
    // Use analyzed color or fallback to white
    final textColor = _textColor ?? Colors.white.withValues(alpha: 0.9);
    final progressColor = _progressBarColor ?? AppColors.primary;
    
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fullscreen loading image
          Image.asset(
            AppImages.loadingImage,
            fit: BoxFit.cover,
            width: size.width,
            height: size.height,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to black background if image fails to load
              return Container(
                color: Colors.black,
                child: Center(
                  child: Image.asset(
                    AppImages.appLogo,
                    width: size.width * 0.4,
                  ),
                ),
              );
            },
          ),
          
          // Progress bar and status text at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status text with auto-adjusted color
                    Text(
                      statusKey.tr(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Progress bar with auto-adjusted color
                    LinearProgressBar(
                      progress: loadingState.progress,
                      height: 2.0,
                      showGlow: true,
                      progressColor: progressColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
