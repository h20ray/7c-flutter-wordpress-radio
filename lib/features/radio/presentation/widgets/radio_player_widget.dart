import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/album_art_widget.dart';
import '../../../../core/services/network_status_service.dart';
import '../../../../core/models/album_art_state.dart';
import '../../data/services/album_art_service.dart';
import '../../domain/entities/radio_entity.dart';
import '../bloc/radio_player_bloc.dart';
import '../bloc/radio_player_event.dart';
import '../bloc/radio_player_state.dart';

class RadioPlayerWidget extends StatelessWidget {
  final RadioEntity radioConfig;

  const RadioPlayerWidget({
    super.key,
    required this.radioConfig,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadioPlayerBloc, RadioPlayerState>(
      buildWhen: (previous, current) {
        // Only rebuild when significant state changes occur
        return previous.runtimeType != current.runtimeType ||
               (previous.maybeWhen(
                 ready: (isPlaying, currentUrl, currentArtist, currentTitle, currentAlbumArtUrl, isDucking, canAutoResume) => 
                   current.maybeWhen(
                     ready: (newIsPlaying, newCurrentUrl, newCurrentArtist, newCurrentTitle, newCurrentAlbumArtUrl, newIsDucking, newCanAutoResume) =>
                       isPlaying != newIsPlaying || 
                       currentArtist != newCurrentArtist || 
                       currentTitle != newCurrentTitle ||
                       currentAlbumArtUrl != newCurrentAlbumArtUrl ||
                       isDucking != newIsDucking,
                     orElse: () => true,
                   ),
                 orElse: () => true,
               ));
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Radio Info Card
                _buildRadioInfoCard(context, state),
                const SizedBox(height: 24),
                // Player Controls
                _buildPlayerControls(context, state),
                const SizedBox(height: 24),
                // Stream URL Info (for debugging)
                if (radioConfig.streamUrl.isNotEmpty)
                  _buildStreamInfoCard(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadioInfoCard(BuildContext context, RadioPlayerState state) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Album Art Display
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildAlbumArtWithDuckingIndicator(context, state),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Radio',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Streaming from server',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Configuration Info
            _buildConfigInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArtWithDuckingIndicator(BuildContext context, RadioPlayerState state) {
    return state.maybeWhen(
      ready: (isPlaying, currentUrl, currentArtist, currentTitle,
          currentAlbumArtUrl, isDucking, canAutoResume) {
        return Stack(
          children: [
            // Add smooth transition to prevent flashing
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: AlbumArtWidget.roundedRect(
                key: ValueKey('album_art_${currentArtist}_$currentTitle'),
                width: 60,
                height: 60,
                borderRadius: 8,
                filterQuality: FilterQuality.low,
              ),
            ),
            // Ducking indicator
            if (isDucking)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.volume_down,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            // Network status indicator
            StreamBuilder<bool>(
              stream: NetworkStatusService.instance.networkStatusStream,
              initialData: NetworkStatusService.instance.isOnline,
              builder: (context, snapshot) {
                final isOnline = snapshot.data ?? true;
                if (!isOnline) {
                  return Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.wifi_off,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        );
      },
      orElse: () => AlbumArtWidget.roundedRect(
        width: 60,
        height: 60,
        borderRadius: 8,
        filterQuality: FilterQuality.low,
      ),
    );
  }

  Widget _buildPlayerControls(BuildContext context, RadioPlayerState state) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Play/Pause Button with smooth transitions
            GestureDetector(
              onTap: () => _handlePlayPause(context, state),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state.maybeWhen(
                    ready: (isPlaying, currentUrl, currentArtist, currentTitle,
                            currentAlbumArtUrl, isDucking, canAutoResume) =>
                        isDucking
                            ? Colors.orange
                            : Theme.of(context).primaryColor,
                    orElse: () => Colors.grey,
                  ),
                ),
                child: _buildPlayButtonContent(context, state),
              ),
            ),
            const SizedBox(height: 16),
            // Status Text with smooth transitions
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Text(
                key: ValueKey(_getStatusText(context, state)),
                _getStatusText(context, state),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: state.maybeWhen(
                        error: (failure, message) => Colors.red,
                        orElse: () => null,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 8),
            // Show current track info if available
            _buildTrackInfo(context, state),
            const SizedBox(height: 8),
            // Album art status indicator
            _buildAlbumArtStatus(context),
            const SizedBox(height: 8),
            // Error message or instruction text
            _buildInstructionText(context, state),
            // Retry button for errors
            if (state.maybeWhen(error: (_, __) => true, orElse: () => false))
              _buildErrorActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackInfo(BuildContext context, RadioPlayerState state) {
    return state.maybeWhen(
      ready: (isPlaying, currentUrl, currentArtist, currentTitle,
          currentAlbumArtUrl, isDucking, canAutoResume) {
        if (currentTitle != null || currentArtist != null) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Column(
              key: ValueKey('track_${currentArtist}_$currentTitle'),
              children: [
                if (currentTitle != null)
                  Text(
                    currentTitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDucking ? Colors.orange : null,
                        ),
                    textAlign: TextAlign.center,
                  ),
                if (currentArtist != null)
                  Text(
                    currentArtist,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              isDucking ? Colors.orange[700] : Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
              // Audio focus status indicator
              if (isDucking)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.volume_down,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Volume reduced',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              if (canAutoResume && !isPlaying)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_circle_outline,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Will auto-resume',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildAlbumArtStatus(BuildContext context) {
    return StreamBuilder<AlbumArtState>(
      stream: AlbumArtService.instance.albumArtStream,
      initialData: AlbumArtService.instance.currentState,
      builder: (context, snapshot) {
        final albumArtState = snapshot.data ?? AlbumArtService.instance.currentState;
        
        if (albumArtState.isLoading) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Loading album art...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          );
        }
        
        if (albumArtState.error != null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Album art error',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red[800],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          );
        }
        
        if (albumArtState.isOffline) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Offline mode',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          );
        }
        
        if (albumArtState.isCached) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cached,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Cached',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInstructionText(BuildContext context, RadioPlayerState state) {
    return state.maybeWhen(
      error: (failure, message) => Text(
        message ?? failure.message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red,
            ),
        textAlign: TextAlign.center,
      ),
      initializing: () => Text(
        'radio_please_wait'.tr(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
      ),
      ready: (isPlaying, currentUrl, currentArtist, currentTitle,
              currentAlbumArtUrl, isDucking, canAutoResume) =>
          Text(
        isPlaying
            ? (isDucking
                ? 'Volume reduced due to other audio'
                : 'radio_tap_to_pause'.tr())
            : (canAutoResume
                ? 'Paused - will auto-resume'
                : 'radio_tap_to_play'.tr()),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDucking ? Colors.orange : Colors.grey,
            ),
      ),
      initial: () => Text(
        'radio_please_wait'.tr(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
      ),
      orElse: () => Text(
        'radio_please_wait'.tr(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
      ),
    );
  }

  Widget _buildErrorActions(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _handleRetry(context),
              child: Text('radio_retry'.tr()),
            ),
            ElevatedButton(
              onPressed: () => _handleReset(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: Text('radio_reset'.tr()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreamInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stream Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'URL: ${radioConfig.streamUrl}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
            Text(
              'Last Updated: ${_formatDateTime(radioConfig.lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuration',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _buildConfigRow('Autoplay', radioConfig.autoplay),
        _buildConfigRow('Show Album Cover', radioConfig.showAlbumCover),
        _buildConfigRow('Text Scrolling', radioConfig.textScrolling),
      ],
    );
  }

  Widget _buildConfigRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: value ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _getStatusText(BuildContext context, RadioPlayerState state) {
    return state.maybeWhen(
      error: (failure, message) => 'radio_error'.tr(),
      initializing: () => 'radio_initializing'.tr(),
      connecting: () => 'radio_connecting'.tr(),
      buffering: () => 'radio_buffering'.tr(),
      retrying: (attempt, reason) => '${'radio_retrying'.tr()} ($attempt)',
      ready: (isPlaying, currentUrl, currentArtist, currentTitle,
              currentAlbumArtUrl, isDucking, canAutoResume) =>
          isPlaying
              ? (isDucking
                  ? 'Playing (Volume Reduced)'
                  : 'radio_now_playing'.tr())
              : (canAutoResume ? 'Paused (Auto-resume)' : 'radio_paused'.tr()),
      initial: () => 'radio_initializing'.tr(),
      orElse: () => 'radio_initializing'.tr(),
    );
  }

  Widget _buildPlayButtonContent(BuildContext context, RadioPlayerState state) {
    return state.maybeWhen(
      retrying: (attempt, reason) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$attempt',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      connecting: () => const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      ),
      buffering: () => const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      ),
      initializing: () => const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      ),
      ready: (isPlaying, currentUrl, currentArtist, currentTitle,
              currentAlbumArtUrl, isDucking, canAutoResume) =>
          Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
        size: 40,
      ),
      orElse: () => const Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  void _handlePlayPause(BuildContext context, RadioPlayerState state) {
    final bloc = context.read<RadioPlayerBloc>();
    // Smart toggle handles all states automatically
    bloc.add(const RadioPlayerEvent.togglePlayPause());
  }

  void _handleRetry(BuildContext context) {
    final bloc = context.read<RadioPlayerBloc>();
    bloc.add(RadioPlayerEvent.initialize(radioConfig));
  }

  void _handleReset(BuildContext context) {
    final bloc = context.read<RadioPlayerBloc>();
    bloc.add(const RadioPlayerEvent.reset());
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
