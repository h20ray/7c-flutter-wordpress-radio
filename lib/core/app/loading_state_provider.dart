import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loading status messages for different initialization stages
enum LoadingStatus {
  checkingConnection,
  loadingConfig,
  initializingDependencies,
  initializingStorage,
  initializingConnectivity,
  initializingNotifications,
  initializingAuth,
  initializingRadio,
  preparingApp,
  complete,
}

/// State for loading screen with progress and status
class LoadingState {
  final double progress; // 0.0 to 1.0
  final LoadingStatus status;
  final String? errorMessage;

  const LoadingState({
    this.progress = 0.0,
    this.status = LoadingStatus.checkingConnection,
    this.errorMessage,
  });

  LoadingState copyWith({
    double? progress,
    LoadingStatus? status,
    String? errorMessage,
  }) {
    return LoadingState(
      progress: progress ?? this.progress,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Provider for loading state
final loadingStateProvider =
    StateNotifierProvider<LoadingStateNotifier, LoadingState>((ref) {
  return LoadingStateNotifier();
});

/// Notifier for managing loading state
class LoadingStateNotifier extends StateNotifier<LoadingState> {
  LoadingStateNotifier() : super(const LoadingState());

  void updateProgress(double progress, LoadingStatus status) {
    state = state.copyWith(
      progress: progress.clamp(0.0, 1.0),
      status: status,
    );
  }

  void setError(String errorMessage) {
    state = state.copyWith(errorMessage: errorMessage);
  }

  void reset() {
    state = const LoadingState();
  }
}

