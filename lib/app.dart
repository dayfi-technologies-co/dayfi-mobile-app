import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dayfi/common/utils/dayfi_platform.dart';
import 'package:dayfi/features/web/utils/web_route_helper.dart'
    show instantWebBootRoute, resolveWebInitialRoute, unauthenticatedEntryRoute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/common/app_constants.dart';

import 'package:dayfi/core/navigation/navigator_key.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/core/theme/app_theme.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/theme_provider.dart';
import 'package:dayfi/core/theme/app_theme_extensions.dart';
import 'package:dayfi/app_locator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayfi/services/transaction_monitor_service.dart';
import 'package:dayfi/common/widgets/connectivity_wrapper.dart';
import 'package:dayfi/common/widgets/dayfi_responsive_scope.dart';
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
  final DayfiRouteTracker _routeTracker = DayfiRouteTracker();

  String _initialRoute = unauthenticatedEntryRoute;
  bool _isInitialized = false;
  bool _transactionMonitorStarted = false;
  String? _instantBootRoute;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlutterNativeSplash.remove();
      });
    }
    if (isDayfiWeb) {
      final instantRoute = instantWebBootRoute(Uri.base.path);
      if (instantRoute != null) {
        _instantBootRoute = instantRoute;
        _initialRoute = instantRoute;
        _isInitialized = true;
      }
    }
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    try {
      final secureStorage = locator<SecureStorageService>();
      final versionService = locator<VersionService>();

      // Check if this is a new app version and clear data if needed
      await versionService.isNewVersion();

      // Detect reinstall: SharedPreferences is wiped on uninstall but iOS
      // Keychain (flutter_secure_storage) survives. If our sentinel is missing
      // but secure storage has auth data, this is a fresh install — wipe stale
      // Keychain so the user sees onboarding, not the old passcode screen.
      final prefs = locator<SharedPreferences>();
      final hasLaunchedBefore = prefs.getBool('has_launched_before') ?? false;
      if (!hasLaunchedBefore) {
        final staleToken = await secureStorage.read(StorageKeys.token);
        if (staleToken.isNotEmpty) {
          AppLogger.info('Reinstall detected — clearing stale Keychain data');
          await secureStorage.deleteAll();
        }
        await prefs.setBool('has_launched_before', true);
      }

      final firstTime = await secureStorage.read(StorageKeys.isFirstTime);
      final token = await secureStorage.read(StorageKeys.token);
      final passcode = await secureStorage.read(StorageKeys.passcode);
      final userData = await secureStorage.read(StorageKeys.user);

      final bool isFirstTimeUser = firstTime.isEmpty || firstTime == 'true';
      final String userToken = token;
      final String userPasscode = passcode;
      final String userJson = userData;

      // Check if user data is actually valid (not empty, not "null" string, and valid JSON)
      final bool hasValidUserData = userJson.isNotEmpty && 
          userJson != 'null' && 
          _isValidUserJson(userJson);

      String appBootstrapRoute = unauthenticatedEntryRoute;

      // Validate data consistency - if we have a token but no user data, something is wrong
      if (userToken.isNotEmpty && !hasValidUserData) {
        AppLogger.warning('Inconsistent state: token exists but no valid user data');
        await _clearInconsistentData(secureStorage);
        appBootstrapRoute = unauthenticatedEntryRoute;
      } else if (isFirstTimeUser && userToken.isEmpty) {
        appBootstrapRoute = unauthenticatedEntryRoute;
      } else if (userToken.isEmpty) {
        appBootstrapRoute = unauthenticatedEntryRoute;
      } else if (userPasscode.isEmpty) {
        final phone =
            (jsonDecode(userJson) as Map<String, dynamic>)['phone_number']
                ?.toString()
                .trim() ??
            '';
        appBootstrapRoute =
            phone.isNotEmpty
                ? AppRoute.createPasscodeView
                : AppRoute.successSignupView;
      } else {
        appBootstrapRoute = AppRoute.passcodeView;
      }

      final isAuthenticated = userToken.isNotEmpty && hasValidUserData;

      _initialRoute = resolveWebInitialRoute(
        uriPath: Uri.base.path,
        fallbackAppRoute: appBootstrapRoute,
        isAuthenticated: isAuthenticated,
      );

      AppLogger.info('Initial route determined: $_initialRoute');
    } catch (e) {
      AppLogger.error('Error determining initial route: $e');
      _initialRoute = unauthenticatedEntryRoute;
    } finally {
      if (mounted) {
        final targetRoute = _initialRoute;
        final instantRoute = _instantBootRoute;
        final shouldReplaceRoute =
            instantRoute == null || targetRoute != instantRoute;

        setState(() {
          _isInitialized = true;
        });

        if (shouldReplaceRoute) {
          // Navigator may still be on bootstrap splash — swap to the resolved entry.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final nav = NavigatorKey.appNavigatorKey.currentState;
            if (nav == null) return;
            nav.pushReplacementNamed(targetRoute);
          });
        }
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
      AppLogger.info('Cleared inconsistent data');
    } catch (e) {
      AppLogger.error('Error clearing inconsistent data: $e');
    }
  }

  /// Check if the user JSON string is valid and contains required data
  bool _isValidUserJson(String userJson) {
    try {
      final decoded = jsonDecode(userJson);
      if (decoded == null || decoded is! Map<String, dynamic>) {
        return false;
      }
      // Check for essential user fields
      final userId = decoded['user_id'] as String?;
      final email = decoded['email'] as String?;
      return userId != null && userId.isNotEmpty && email != null && email.isNotEmpty;
    } catch (e) {
      AppLogger.error('Invalid user JSON: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // One ProviderScope + one MaterialApp for the whole app lifecycle. Previously we
    // swapped a bare MaterialApp (splash) for a second MaterialApp under ProviderScope,
    // which remounted Navigator/Riverpod and felt like "the screen loads twice".
    return ProviderScope(
      observers: [ProviderScopeObserver()],
      overrides: [
        themeProvider.overrideWith((ref) {
          final prefs = ref.watch(sharedPreferencesProvider);
          return ThemeNotifier(prefs);
        }),
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
              final themeMode = ref.watch(flutterThemeModeProvider);

              if (_isInitialized && !_transactionMonitorStarted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted || _transactionMonitorStarted) return;
                  _transactionMonitorStarted = true;
                  ref.read(transactionMonitorProvider).startMonitoring();
                });
              }

              final dialogTheme = DialogThemeData(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                constraints: BoxConstraints(
                  maxWidth:
                      isDayfiWeb
                          ? DayfiResponsive.dialogMaxWidth
                          : 560,
                  minWidth: 280,
                ),
              );

              return ConnectivityWrapper(
                child: MaterialApp(
                  builder: (context, child) {
                    // Ignore iOS/Android system font-size accessibility scaling.
                    final mediaQuery = MediaQuery.of(context);
                    final scaledChild = MediaQuery(
                      data: mediaQuery.copyWith(
                        textScaler: TextScaler.noScaling,
                      ),
                      child: child ?? const SizedBox.shrink(),
                    );
                    return DayfiWebAppShell(
                      routeTracker: _routeTracker,
                      child: scaledChild,
                    );
                  },
                  navigatorObservers: [
                    _routeTracker,
                    if (analyticsObserver != null) analyticsObserver!,
                  ],
                  debugShowCheckedModeBanner: false,
                  title: AppConstants.appName,
                  theme: themeData.copyWith(
                    scaffoldBackgroundColor: const Color(0xffFEF9F3),
                    dialogTheme: dialogTheme,
                    extensions:
                        AppThemeExtensionsFactory.createLightExtensions().values
                            .toList(),
                  ),
                  darkTheme: AppTheme.darkTheme.copyWith(
                    scaffoldBackgroundColor: AppColors.neutral950,
                    dialogTheme: dialogTheme,
                    extensions:
                        AppThemeExtensionsFactory.createDarkExtensions().values
                            .toList(),
                  ),
                  themeMode:
                      isDayfiWeb && themeMode == ThemeMode.system
                          ? ThemeMode.dark
                          : themeMode,
                  navigatorKey: NavigatorKey.appNavigatorKey,
                  // Keep a stable bootstrap route; never swap home ↔ initialRoute after init.
                  initialRoute: '/',
                  onGenerateRoute: (RouteSettings settings) {
                    if (!_isInitialized) {
                      return MaterialPageRoute<void>(
                        settings: settings,
                        builder: (_) => const _BootstrapSplash(),
                      );
                    }
                    final name = settings.name;
                    if (name == null || name == '/') {
                      return AppRoute.getRoute(
                        RouteSettings(name: _initialRoute),
                      );
                    }
                    return AppRoute.getRoute(settings);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Shown under the same [MaterialApp] until async route bootstrap completes.
class _BootstrapSplash extends StatefulWidget {
  const _BootstrapSplash();

  @override
  State<_BootstrapSplash> createState() => _BootstrapSplashState();
}

class _BootstrapSplashState extends State<_BootstrapSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isDayfiWeb
            ? AppColors.neutral950
            : AppColors.splashBackgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _pulseAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: Image.asset('assets/images/logo_splash.png', width: 88.0),
          ),
        ),
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