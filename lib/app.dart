import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/common/app_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/navigation/navigator_key.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/core/theme/app_theme.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/theme_provider.dart';
import 'package:dayfi/core/theme/app_theme_extensions.dart';
import 'package:dayfi/app_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayfi/services/transaction_monitor_service.dart';
import 'package:dayfi/common/widgets/connectivity_wrapper.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/services/version_service.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/utils/app_logger.dart';

import 'services/local/analytics_service.dart';

class ProviderScopeObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Set the global container reference when the first provider is created
    if (getGlobalProviderContainer() == null) {
      setGlobalProviderContainer(container);
    }
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  String _initialRoute = AppRoute.onboardingView;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    try {
      final secureStorage = locator<SecureStorageService>();
      final versionService = locator<VersionService>();

      // Check if this is a new app version and clear data if needed
      await versionService.isNewVersion();

      final firstTime = await secureStorage.read(StorageKeys.isFirstTime);
      final token = await secureStorage.read(StorageKeys.token);
      final passcode = await secureStorage.read(StorageKeys.passcode);
      final userData = await secureStorage.read(StorageKeys.user);

      final bool isFirstTimeUser = firstTime.isEmpty || firstTime == 'true';
      final String userToken = token;
      final String userPasscode = passcode;
      final String userJson = userData;

      // Validate data consistency - if we have a token but no user data, something is wrong
      if (userToken.isNotEmpty && userJson.isEmpty) {
        // Clear inconsistent data and redirect to login
        await _clearInconsistentData(secureStorage);
        _initialRoute = AppRoute.onboardingView;
      } else if (isFirstTimeUser && userToken.isEmpty) {
        _initialRoute = AppRoute.onboardingView;
      } else if (userToken.isEmpty) {
        _initialRoute = AppRoute.onboardingView;
      } else if (userPasscode.isEmpty) {
        _initialRoute = AppRoute.onboardingView;
      } else {
        _initialRoute = AppRoute.passcodeView;
      }

      AppLogger.info('Initial route determined: $_initialRoute');
    } catch (e) {
      AppLogger.error('Error determining initial route: $e');
      // Navigate to onboarding view as fallback
      _initialRoute = AppRoute.onboardingView;
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  /// Clear inconsistent data when token exists but user data is missing
  Future<void> _clearInconsistentData(
    SecureStorageService secureStorage,
  ) async {
    try {
      await secureStorage.delete(StorageKeys.token);
      await secureStorage.delete(StorageKeys.email);
      await secureStorage.delete(StorageKeys.password);
      await secureStorage.delete(StorageKeys.passcode);
      await secureStorage.delete(StorageKeys.user);
    } catch (e) {
      AppLogger.error('Error clearing inconsistent data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a minimal loading screen while determining route
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFFFD800),
          body: Center(
            child: Image.asset('assets/images/logo_splash.png', width: 150.0)
          ),
        ),
      );
    }

    return ProviderScope(
      observers: [ProviderScopeObserver()],
      overrides: [
        // Override the theme provider with SharedPreferences
        themeProvider.overrideWith((ref) {
          final prefs = ref.watch(sharedPreferencesProvider);
          return ThemeNotifier(prefs);
        }),
        // Override the SharedPreferences provider
        sharedPreferencesProvider.overrideWith((ref) {
          return ref.watch(sharedPreferencesInstanceProvider);
        }),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer(
            builder: (context, ref, child) {
              final themeData = ref.watch(themeDataProvider);

              // Initialize transaction monitoring
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final transactionMonitor = ref.read(transactionMonitorProvider);
                transactionMonitor.startMonitoring();
              });
              final themeMode = ref.watch(flutterThemeModeProvider);

              return ConnectivityWrapper(
                child: MaterialApp(
                  navigatorObservers: [analyticsObserver],
                  debugShowCheckedModeBanner: false,
                  title: AppConstants.appName,
                  theme: themeData.copyWith(
                    scaffoldBackgroundColor: const Color(0xffFEF9F3),
                    extensions:
                        AppThemeExtensionsFactory.createLightExtensions().values
                            .toList(),
                  ),
                  darkTheme: AppTheme.darkTheme.copyWith(
                    scaffoldBackgroundColor: AppColors.neutral950,
                    extensions:
                        AppThemeExtensionsFactory.createDarkExtensions().values
                            .toList(),
                  ),
                  themeMode: themeMode,
                  initialRoute: _initialRoute,
                  navigatorKey: NavigatorKey.appNavigatorKey,
                  onGenerateRoute: AppRoute.getRoute,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// SharedPreferences Instance Provider
///
/// Provides the SharedPreferences instance from the app locator
final sharedPreferencesInstanceProvider = Provider<SharedPreferences>((ref) {
  return sharedPreferences;
});
