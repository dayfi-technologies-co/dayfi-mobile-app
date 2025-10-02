import 'package:dayfi/services/local/connectivity_service.dart';

class ConnectivityUtils {
  /// Check if device is currently connected to any network
  static bool get isConnected => ConnectivityService.isConnected;
  
  /// Get current connection type (WiFi, Mobile Data, etc.)
  static String get connectionType => ConnectivityService.connectionType;
  
  /// Check if device is connected to WiFi
  static Future<bool> isWiFiConnected() async {
    return await ConnectivityService.isWiFiConnected();
  }
  
  /// Check if device is connected to mobile data
  static Future<bool> isMobileDataConnected() async {
    return await ConnectivityService.isMobileDataConnected();
  }
  
  /// Get detailed connectivity information
  static Future<Map<String, dynamic>> getConnectivityInfo() async {
    return await ConnectivityService.getConnectivityInfo();
  }
  
  /// Wait for a connection (useful for retry logic)
  static Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return await ConnectivityService.waitForConnection(timeout: timeout);
  }
  
  /// Check if device is offline
  static Future<bool> isOffline() async {
    final info = await getConnectivityInfo();
    return info['isOffline'] ?? true;
  }
  
  /// Get a user-friendly connection status message
  static Future<String> getConnectionStatusMessage() async {
    final info = await getConnectivityInfo();
    
    if (info['isOffline'] == true) {
      return 'No internet connection';
    }
    
    if (info['hasWiFi'] == true) {
      return 'Connected to WiFi';
    }
    
    if (info['hasMobileData'] == true) {
      return 'Connected to mobile data';
    }
    
    if (info['hasEthernet'] == true) {
      return 'Connected to Ethernet';
    }
    
    return 'Connected to internet';
  }
}







