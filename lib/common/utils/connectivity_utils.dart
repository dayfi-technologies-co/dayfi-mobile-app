import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/remote/network/api_error.dart';

/// Utility class for handling connectivity and network-related operations
class ConnectivityUtils {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      // If no connectivity at all
      if (connectivityResult.contains(ConnectivityResult.none)) {
        AppLogger.info('No internet connection detected');
        return false;
      }
      
      // If there's connectivity, we assume internet is available
      // In a real app, you might want to ping a server to confirm
      AppLogger.info('Internet connection detected: $connectivityResult');
      return true;
    } catch (e) {
      AppLogger.error('Error checking connectivity: $e');
      return false;
    }
  }

  /// Get user-friendly error message based on connectivity status
  static Future<String> getConnectivityErrorMessage() async {
    final hasConnection = await hasInternetConnection();
    
    if (!hasConnection) {
      return 'No internet connection. Please check your network settings and try again.';
    }
    
    return 'Network error. Please try again.';
  }

  /// Check if an error is related to connectivity issues
  static bool isConnectivityError(dynamic error) {
    if (error == null) return false;
    
    final errorString = error.toString().toLowerCase();
    
    // Common connectivity error patterns
    const connectivityErrorPatterns = [
      'socketexception',
      'handshakeexception',
      'timeoutexception',
      'connection refused',
      'network is unreachable',
      'no internet',
      'connection timed out',
      'failed to connect',
      'unable to resolve host',
      'network error',
      'connection error',
    ];
    
    return connectivityErrorPatterns.any((pattern) => 
        errorString.contains(pattern));
  }

  /// Get appropriate error message based on error type
  static Future<String> getErrorMessage(dynamic error) async {
    AppLogger.info('ConnectivityUtils.getErrorMessage called with error: $error');
    AppLogger.info('Error type: ${error.runtimeType}');
    
    // Check if it's an ApiError object with a specific error description
    if (error is ApiError) {
      AppLogger.info('Error is ApiError, description: ${error.errorDescription}');
      // Return the specific error message from the API
      return error.errorDescription ?? 'Something went wrong. Please try again.';
    }
    
    // Check if it's an ApiError object with a specific error description
    if (error != null && error.toString().isNotEmpty && !error.toString().contains('Exception')) {
      AppLogger.info('Error appears to be a string message: ${error.toString()}');
      // This is likely an ApiError with a specific message from the server
      return error.toString();
    }
    
    if (isConnectivityError(error)) {
      AppLogger.info('Error is connectivity related');
      return await getConnectivityErrorMessage();
    }
    
    // For null value errors, provide a more user-friendly message
    if (error.toString().toLowerCase().contains('null')) {
      AppLogger.info('Error contains null value');
      return 'Unable to process request. Please check your internet connection and try again.';
    }
    
    // For other errors, return a generic message
    AppLogger.info('Using generic error message');
    return 'Something went wrong. Please try again.';
  }
}