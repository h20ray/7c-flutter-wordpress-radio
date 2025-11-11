import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../features/radio/domain/entities/radio_entity.dart';
import 'smooth_marquee_text.dart';
import 'album_art_widget.dart';
import '../../config/radio_tujuhcahaya_config.dart';

/// M3 Material Design compliant radio FAB widget
/// Follows the elongated chip design with album art, text, and action button
class M3RadioFab extends StatefulWidget {
  final RadioEntity radioConfig;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final bool isPlaying;
  final bool isInitializing;
  final String? currentTitle;
  final String? currentArtist;
  final String? currentAlbumArtUrl;

  // radioCoreV2: New state parameters
  final bool isConnecting;
  final bool isBuffering;
  final bool isRetrying;
  final int retryAttempt;
  final String? retryReason;

  const M3RadioFab({
    super.key,
    required this.radioConfig,
    required this.onTap,
    required this.onPlayPause,
    required this.isPlaying,
    this.isInitializing = false,
    this.currentTitle,
    this.currentArtist,
    this.currentAlbumArtUrl,
    this.isConnecting = false,
    this.isBuffering = false,
    this.isRetrying = false,
    this.retryAttempt = 0,
    this.retryReason,
  });

  @override
  State<M3RadioFab> createState() => _M3RadioFabState();
}

class _M3RadioFabState extends State<M3RadioFab> {
  bool _optimisticLoading = false;

  @override
  void didUpdateWidget(M3RadioFab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_optimisticLoading) return;

    final playbackChanged = widget.isPlaying != oldWidget.isPlaying;
    final busyStateChanged =
        widget.isInitializing != oldWidget.isInitializing ||
        widget.isConnecting != oldWidget.isConnecting ||
        widget.isBuffering != oldWidget.isBuffering ||
        widget.isRetrying != oldWidget.isRetrying;

    if (playbackChanged || busyStateChanged || (!_isBusy && !widget.isPlaying)) {
      setState(() {
        _optimisticLoading = false;
      });
    }
  }

  bool get _isBusy =>
      widget.isInitializing ||
      widget.isConnecting ||
      widget.isBuffering ||
      widget.isRetrying;


  Widget _buildTextContent() {
    final title = widget.currentTitle?.trim().isNotEmpty == true
        ? widget.currentTitle!.trim()
        : RadioTujuhCahayaConfig.fallbackTitle;
    final subtitle = widget.currentArtist?.trim().isNotEmpty == true
        ? widget.currentArtist!.trim()
        : RadioTujuhCahayaConfig.fallbackArtist;

    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 2, bottom: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Title with professional marquee and visible fade
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SmoothMarqueeAuto(
                text: title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  height: 1.25,
                    ),
                scrollDuration: const Duration(seconds: 12),
                pauseDuration: const Duration(seconds: 3),
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Subtitle with professional marquee and visible fade
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SmoothMarqueeAuto(
                text: subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                  fontSize: 13,
                  height: 1.25,
                    ),
                scrollDuration: const Duration(seconds: 10),
                pauseDuration: const Duration(seconds: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    const double btnSize = 48;
    const double glyphSize = 24; // same for spinner & icon

    final isTransitioning = widget.isInitializing ||
        widget.isConnecting ||
        widget.isBuffering ||
        widget.isRetrying ||
        _optimisticLoading;
    final buttonColor = widget.isPlaying
        ? Colors.red.shade600  // More vibrant red for pause
        : Colors.blue.shade600; // More vibrant blue for play

    return SizedBox.square(
      dimension: btnSize,
      child: Material(
        color: buttonColor,
        elevation: widget.isPlaying ? 8 : 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isTransitioning ? null : _handlePlayPause,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (child, _) => SizedBox.square(
                dimension: glyphSize, // force equal visual footprint
                child: Center(child: child),
              ),
              child: _buildButtonContentWithKeys(glyphSize),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContentWithKeys(double glyphSize) {
    if (widget.isRetrying) {
      return Column(
        key: const ValueKey('retrying'),
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: glyphSize,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${widget.retryAttempt}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (widget.isInitializing ||
        widget.isConnecting ||
        widget.isBuffering) {
      return SizedBox.square(
        key: const ValueKey('loading'),
        dimension: glyphSize,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Icon(
        widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        key: ValueKey(widget.isPlaying ? 'pause' : 'play'),
        size: glyphSize,
        color: Colors.white,
      );
    }
  }

  void _handlePlayPause() {
    setState(() {
      // Show spinner immediately; repository will emit real state shortly
      _optimisticLoading = true;
    });
    widget.onPlayPause();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Floating Toolbar (Left) - Navigate to radio page
        Expanded(
          child: Material(
            elevation: 6, // M3 elevation for floating toolbar
            borderRadius: BorderRadius.circular(32),
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: widget.onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    // Frosted glass backdrop blur + translucent overlay
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    // Foreground content
                    Container(
                      height: 64,
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Album Art
                          AlbumArtWidget.circle(
                            size: 48,
                            filterQuality: FilterQuality.high,
                          ),
                          const SizedBox(width: 6),
                          // Text Content
                          Expanded(child: _buildTextContent()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Spacing between toolbar and FAB
        const SizedBox(width: 8),
        // Floating Action Button (Right) - Play/Pause action
        _buildActionButton(),
      ],
    );
  }
}
