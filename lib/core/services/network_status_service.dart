import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status
/// Provides real-time network status updates and offline mode detection
class NetworkStatusService {
  static NetworkStatusService? _instance;
  final Connectivity _connectivity = Connectivity();
  
  // Stream controller for broadcasting network status changes
  final StreamController<bool> _networkStatusController = 
      StreamController<bool>.broadcast();
  
  // Current network status
  bool _isOnline = true;
  
  // Stream subscription for connectivity changes
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  NetworkStatusService._internal();

  static NetworkStatusService get instance {
    _instance ??= NetworkStatusService._internal();
    return _instance!;
  }

  /// Stream of network status changes (true = online, false = offline)
  Stream<bool> get networkStatusStream => _networkStatusController.stream;

  /// Current network status
  bool get isOnline => _isOnline;

  /// Initialize the network status service
  Future<void> initialize() async {
    // Get initial connectivity status
    final connectivityResults = await _connectivity.checkConnectivity();
    _updateNetworkStatus(connectivityResults);

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateNetworkStatus,
      onError: (error) {
        // On error, assume offline for safety
        _setNetworkStatus(false);
      },
    );
  }

  /// Update network status based on connectivity results
  void _updateNetworkStatus(List<ConnectivityResult> connectivityResults) {
    // Consider online if any connection type is available
    final isOnline = connectivityResults.any((result) => 
        result != ConnectivityResult.none);
    
    _setNetworkStatus(isOnline);
  }

  /// Set network status and emit to stream if changed
  void _setNetworkStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      if (!_networkStatusController.isClosed) {
        _networkStatusController.add(_isOnline);
      }
    }
  }

  /// Check if device is currently online
  Future<bool> checkConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final isOnline = connectivityResults.any((result) => 
          result != ConnectivityResult.none);
      
      _setNetworkStatus(isOnline);
      return isOnline;
    } catch (e) {
      // On error, assume offline for safety
      _setNetworkStatus(false);
      return false;
    }
  }

  /// Wait for network to become available
  /// Returns true if network becomes available within timeout, false otherwise
  Future<bool> waitForNetwork({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isOnline) return true;

    try {
      await networkStatusStream
          .where((isOnline) => isOnline)
          .first
          .timeout(timeout);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Dispose the service and close streams
  void dispose() {
    _connectivitySubscription?.cancel();
    _networkStatusController.close();
  }
}
