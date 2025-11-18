import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// A modern, minimal progress bar with thin line design
/// Shows an animated progress bar that fills from left to right
class ProgressBarLoader extends StatefulWidget {
  const ProgressBarLoader({
    super.key,
    this.height = 2.0,
    this.backgroundColor,
    this.progressColor,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.showGlow = true,
  });

  /// Height of the progress bar (thin line)
  final double height;

  /// Background color of the progress bar track
  final Color? backgroundColor;

  /// Color of the progress fill
  final Color? progressColor;

  /// Duration of one complete animation cycle
  final Duration animationDuration;

  /// Whether to show a subtle glow effect
  final bool showGlow;

  @override
  State<ProgressBarLoader> createState() => _ProgressBarLoaderState();
}

class _ProgressBarLoaderState extends State<ProgressBarLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    // Progress animation: fills from 0 to 1
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Glow animation: subtle pulse effect
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bgColor = widget.backgroundColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.1));
    
    final progressColor = widget.progressColor ?? AppColors.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: Stack(
            children: [
              // Progress fill
              FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    boxShadow: widget.showGlow
                        ? [
                            BoxShadow(
                              color: progressColor.withValues(
                                alpha: 0.3 * _glowAnimation.value,
                              ),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A linear progress bar that shows actual progress (0.0 to 1.0)
class LinearProgressBar extends StatelessWidget {
  const LinearProgressBar({
    super.key,
    required this.progress,
    this.height = 2.0,
    this.backgroundColor,
    this.progressColor,
    this.showGlow = true,
  });

  /// Progress value from 0.0 to 1.0
  final double progress;

  /// Height of the progress bar
  final double height;

  /// Background color of the progress bar track
  final Color? backgroundColor;

  /// Color of the progress fill
  final Color? progressColor;

  /// Whether to show a subtle glow effect
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bgColor = backgroundColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.1));
    
    final progressColor = this.progressColor ?? AppColors.primary;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          // Progress fill
          FractionallySizedBox(
            widthFactor: clampedProgress,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: showGlow
                    ? [
                        BoxShadow(
                          color: progressColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

