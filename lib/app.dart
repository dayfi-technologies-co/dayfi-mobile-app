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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      observers: [
        ProviderScopeObserver(),
      ],
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

              return MaterialApp(
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
                initialRoute: AppRoute.splashView,
                navigatorKey: NavigatorKey.appNavigatorKey,
                onGenerateRoute: AppRoute.getRoute,
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
