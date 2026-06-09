import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dayfi/common/utils/app_logger.dart';

/// Service to monitor network connectivity status
/// 
/// This service provides a stream of connectivity status changes
/// and methods to check current connectivity state.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity status
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> result) {
          _updateConnectionStatus(result);
        },
        onError: (error) {
          AppLogger.error('Connectivity stream error: $error');
        },
      );

      AppLogger.info('ConnectivityService initialized successfully');
    } catch (e) {
      AppLogger.error('Error initializing ConnectivityService: $e');
    }
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Treat any transport other than `none` as connected.
    // This is resilient across plugin/platform variants (e.g. `other`, `bluetooth`).
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    // Only emit if status changed
    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      _connectionStatusController.add(hasConnection);
      
      if (hasConnection) {
        AppLogger.info('Internet connection restored');
      } else {
        AppLogger.warning('Internet connection lost');
      }
    }
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final hasConnection = result.any((r) => r != ConnectivityResult.none);
      
      _isConnected = hasConnection;
      return hasConnection;
    } catch (e) {
      AppLogger.error('Error checking connectivity: $e');
      return false;
    }
  }

  /// Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}
