import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dayfi/common/utils/app_logger.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  static bool _isConnected = false;
  static String _connectionType = 'Unknown';

  /// Get current connectivity status
  static bool get isConnected => _isConnected;
  static String get connectionType => _connectionType;

  /// Initialize connectivity monitoring
  static Future<void> initialize() async {
    try {
      // Check initial connectivity status
      await _checkConnectivity();
      
      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          AppLogger.error('Connectivity stream error: $error');
        },
      );
      
      AppLogger.info('Connectivity service initialized');
    } catch (e) {
      AppLogger.error('Error initializing connectivity service: $e');
    }
  }

  /// Check current connectivity status
  static Future<void> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(results);
    } catch (e) {
      AppLogger.error('Error checking connectivity: $e');
      _isConnected = false;
      _connectionType = 'Error';
    }
  }

  /// Handle connectivity changes
  static void _onConnectivityChanged(List<ConnectivityResult> results) {
    _updateConnectivityStatus(results);
  }

  /// Update connectivity status based on results
  static void _updateConnectivityStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _isConnected = false;
      _connectionType = 'No Connection';
      AppLogger.info('No connectivity detected');
      return;
    }

    // Check for any active connection
    _isConnected = results.any((result) => result != ConnectivityResult.none);
    
    if (_isConnected) {
      if (results.contains(ConnectivityResult.wifi)) {
        _connectionType = 'WiFi';
      } else if (results.contains(ConnectivityResult.mobile)) {
        _connectionType = 'Mobile Data';
      } else if (results.contains(ConnectivityResult.ethernet)) {
        _connectionType = 'Ethernet';
      } else if (results.contains(ConnectivityResult.bluetooth)) {
        _connectionType = 'Bluetooth';
      } else if (results.contains(ConnectivityResult.vpn)) {
        _connectionType = 'VPN';
      } else {
        _connectionType = 'Other';
      }
      AppLogger.info('Connected via: $_connectionType');
    } else {
      _connectionType = 'Disconnected';
      AppLogger.info('Device is disconnected');
    }
  }

  /// Check if device is connected to WiFi
  static Future<bool> isWiFiConnected() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.wifi);
    } catch (e) {
      AppLogger.error('Error checking WiFi connection: $e');
      return false;
    }
  }

  /// Check if device is connected to mobile data
  static Future<bool> isMobileDataConnected() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.mobile);
    } catch (e) {
      AppLogger.error('Error checking mobile data connection: $e');
      return false;
    }
  }

  /// Get detailed connectivity information
  static Future<Map<String, dynamic>> getConnectivityInfo() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      
      return {
        'isConnected': results.any((result) => result != ConnectivityResult.none),
        'connectionTypes': results.map((e) => e.toString()).toList(),
        'hasWiFi': results.contains(ConnectivityResult.wifi),
        'hasMobileData': results.contains(ConnectivityResult.mobile),
        'hasEthernet': results.contains(ConnectivityResult.ethernet),
        'hasBluetooth': results.contains(ConnectivityResult.bluetooth),
        'hasVPN': results.contains(ConnectivityResult.vpn),
        'isOffline': results.isEmpty || results.every((result) => result == ConnectivityResult.none),
      };
    } catch (e) {
      AppLogger.error('Error getting connectivity info: $e');
      return {
        'isConnected': false,
        'connectionTypes': [],
        'hasWiFi': false,
        'hasMobileData': false,
        'hasEthernet': false,
        'hasBluetooth': false,
        'hasVPN': false,
        'isOffline': true,
        'error': e.toString(),
      };
    }
  }

  /// Wait for a specific connection type
  static Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
    ConnectivityResult? preferredType,
  }) async {
    try {
      final completer = Completer<bool>();
      StreamSubscription<List<ConnectivityResult>>? subscription;
      Timer? timer;

      // Set up timeout
      timer = Timer(timeout, () {
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      // Listen for connectivity changes
      subscription = _connectivity.onConnectivityChanged.listen((results) {
        if (preferredType != null) {
          if (results.contains(preferredType)) {
            subscription?.cancel();
            timer?.cancel();
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          }
        } else {
          // Any connection is fine
          if (results.any((result) => result != ConnectivityResult.none)) {
            subscription?.cancel();
            timer?.cancel();
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          }
        }
      });

      // Check current status immediately
      final currentResults = await _connectivity.checkConnectivity();
      if (preferredType != null) {
        if (currentResults.contains(preferredType)) {
          subscription.cancel();
          timer.cancel();
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        }
      } else {
        if (currentResults.any((result) => result != ConnectivityResult.none)) {
          subscription.cancel();
          timer.cancel();
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        }
      }

      return await completer.future;
    } catch (e) {
      AppLogger.error('Error waiting for connection: $e');
      return false;
    }
  }

  /// Dispose of resources
  static void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    AppLogger.info('Connectivity service disposed');
  }
}







