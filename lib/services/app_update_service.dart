import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService {
  static const String _iosAppId = '6752801813'; // Your Apple ID from the error message
  static const String _androidPackageName = 'com.dayfi.app'; // Your Android package name
  
  // Version configuration - you can update these values
  static const String _minSupportedVersion = '1.0.0'; // Minimum version that can still use the app
  static const String _latestVersion = '1.0.0'; // Latest available version
  
  /// Check if app needs to be updated
  Future<AppUpdateStatus> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Check if current version is below minimum supported version
      if (_isVersionLower(currentVersion, _minSupportedVersion)) {
        return AppUpdateStatusFactory.forceUpdateRequired(
          currentVersion: currentVersion,
          latestVersion: _latestVersion,
          isForceUpdate: true,
        );
      }
      
      // For now, we'll only check for force updates
      // You can integrate with new_version package later for optional updates
      // or implement your own API-based version checking
      
      return AppUpdateStatusFactory.noUpdateNeeded(currentVersion: currentVersion);
    } catch (e) {
      print('Error checking for updates: $e');
      return AppUpdateStatusFactory.error(
        currentVersion: '1.0.0', // fallback version
        error: e.toString(),
      );
    }
  }
  
  /// Show update dialog for optional updates
  Future<void> showUpdateDialog(BuildContext context, AppUpdateStatus status) async {
    if (status is! OptionalUpdateAvailable) return;
    
    // Simple dialog implementation
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Available'),
          content: Text(
            'A new version of DayFi is available. We recommend updating to get the latest features and security improvements.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppStore();
              },
              child: const Text('Update Now'),
            ),
          ],
        );
      },
    );
  }
  
  /// Open app store for updates
  Future<void> openAppStore() async {
    try {
      String url;
      if (Platform.isIOS) {
        url = 'https://apps.apple.com/app/id$_iosAppId';
      } else if (Platform.isAndroid) {
        url = 'https://play.google.com/store/apps/details?id=$_androidPackageName';
      } else {
        throw UnsupportedError('Platform not supported');
      }
      
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch app store URL');
      }
    } catch (e) {
      print('Error opening app store: $e');
      rethrow;
    }
  }
  
  /// Compare version strings (e.g., "1.0.0" vs "1.0.1")
  bool _isVersionLower(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();
    
    // Pad with zeros to make arrays same length
    while (v1Parts.length < v2Parts.length) v1Parts.add(0);
    while (v2Parts.length < v1Parts.length) v2Parts.add(0);
    
    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] < v2Parts[i]) return true;
      if (v1Parts[i] > v2Parts[i]) return false;
    }
    return false;
  }
}

/// App update status classes
abstract class AppUpdateStatus {
  final String currentVersion;
  
  const AppUpdateStatus({required this.currentVersion});
}

class NoUpdateNeeded extends AppUpdateStatus {
  const NoUpdateNeeded({required super.currentVersion});
}

class OptionalUpdateAvailable extends AppUpdateStatus {
  final String latestVersion;
  final bool isForceUpdate;
  
  const OptionalUpdateAvailable({
    required super.currentVersion,
    required this.latestVersion,
    required this.isForceUpdate,
  });
}

class ForceUpdateRequired extends AppUpdateStatus {
  final String latestVersion;
  final bool isForceUpdate;
  
  const ForceUpdateRequired({
    required super.currentVersion,
    required this.latestVersion,
    required this.isForceUpdate,
  });
}

class UpdateError extends AppUpdateStatus {
  final String error;
  
  const UpdateError({
    required super.currentVersion,
    required this.error,
  });
}

/// Factory methods for creating status objects
extension AppUpdateStatusFactory on AppUpdateStatus {
  static AppUpdateStatus noUpdateNeeded({required String currentVersion}) {
    return NoUpdateNeeded(currentVersion: currentVersion);
  }
  
  static AppUpdateStatus optionalUpdateAvailable({
    required String currentVersion,
    required String latestVersion,
    required bool isForceUpdate,
  }) {
    return OptionalUpdateAvailable(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      isForceUpdate: isForceUpdate,
    );
  }
  
  static AppUpdateStatus forceUpdateRequired({
    required String currentVersion,
    required String latestVersion,
    required bool isForceUpdate,
  }) {
    return ForceUpdateRequired(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      isForceUpdate: isForceUpdate,
    );
  }
  
  static AppUpdateStatus error({
    required String currentVersion,
    required String error,
  }) {
    return UpdateError(
      currentVersion: currentVersion,
      error: error,
    );
  }
}
