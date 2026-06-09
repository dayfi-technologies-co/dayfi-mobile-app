import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayfi/common/utils/app_logger.dart';

/// Tracks app version/build from the native bundle (TestFlight + App Store).
///
/// Routine updates must not log users out. Auth tokens, passcode, and secure
/// storage are left untouched. Use [_runVersionMigrations] only for targeted
/// one-off data shape changes when absolutely necessary.
class VersionService {
  static const String _versionKey = 'app_version';
  static const String _buildNumberKey = 'app_build_number';

  final SharedPreferences _sharedPreferences;
  PackageInfo? _packageInfo;

  VersionService(this._sharedPreferences);

  Future<PackageInfo> _loadPackageInfo() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return _packageInfo!;
  }

  /// Records when the installed build changed since the last launch.
  ///
  /// Returns `true` only for an actual update (not first install). Never
  /// clears login session data.
  Future<bool> isNewVersion() async {
    try {
      final info = await _loadPackageInfo();
      final currentVersion = info.version;
      final currentBuildNumber = info.buildNumber;

      final storedVersion = _sharedPreferences.getString(_versionKey);
      final storedBuildNumber = _sharedPreferences.getString(_buildNumberKey);

      AppLogger.info(
        'Version check - Current: $currentVersion ($currentBuildNumber), '
        'Stored: $storedVersion ($storedBuildNumber)',
      );

      final isFirstInstall =
          storedVersion == null && storedBuildNumber == null;
      final isUpdate =
          !isFirstInstall &&
          (storedVersion != currentVersion ||
              storedBuildNumber != currentBuildNumber);

      if (isFirstInstall) {
        await _updateStoredVersion(currentVersion, currentBuildNumber);
        return false;
      }

      if (isUpdate) {
        AppLogger.info(
          'App update detected ($storedVersion+$storedBuildNumber → '
          '$currentVersion+$currentBuildNumber) — preserving login session',
        );
        await _runVersionMigrations(
          fromVersion: storedVersion,
          fromBuild: storedBuildNumber,
          toVersion: currentVersion,
          toBuild: currentBuildNumber,
        );
        await _updateStoredVersion(currentVersion, currentBuildNumber);
      }

      return isUpdate;
    } catch (e) {
      AppLogger.error('Error checking app version: $e');
      return false;
    }
  }

  /// Targeted migrations between specific versions. Does not touch auth data.
  Future<void> _runVersionMigrations({
    required String? fromVersion,
    required String? fromBuild,
    required String toVersion,
    required String toBuild,
  }) async {
    // Add one-off migrations here when a release requires them, e.g.:
    // if (fromVersion == '1.0.0' && fromBuild == '5') { ... }
  }

  Future<void> _updateStoredVersion(String version, String buildNumber) async {
    try {
      await _sharedPreferences.setString(_versionKey, version);
      await _sharedPreferences.setString(_buildNumberKey, buildNumber);
      AppLogger.info('Updated stored version to $version ($buildNumber)');
    } catch (e) {
      AppLogger.error('Error updating stored version: $e');
    }
  }

  Future<String> getCurrentVersion() async {
    final info = await _loadPackageInfo();
    return info.version;
  }

  Future<String> getCurrentBuildNumber() async {
    final info = await _loadPackageInfo();
    return info.buildNumber;
  }
}
