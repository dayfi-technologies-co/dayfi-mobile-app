import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
import 'package:dayfi/app/app.bottomsheets.dart';
import 'package:dayfi/app/app.dialogs.dart';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/services/app_update_service.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/views/force_update/force_update_view.dart';
import 'package:stacked_services/stacked_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  // setup();
  setupBottomSheetUi();
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<Map<String, dynamic>> _initFuture;
  AppUpdateStatus? _updateStatus;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  Future<Map<String, dynamic>> _initializeApp() async {
    // Check for app updates first
    final appUpdateService = locator<AppUpdateService>();
    _updateStatus = await appUpdateService.checkForUpdates();
    
    // If force update is required, we'll handle it in the build method
    if (_updateStatus is ForceUpdateRequired) {
      return {
        '_isFirstTimeUser': false,
        '_userToken': null,
        '_userPasscode': null,
        '_forceUpdateRequired': true,
      };
    }
    
    // Continue with normal initialization
    return _fetchKnownTokens();
  }

  Future<Map<String, dynamic>> _fetchKnownTokens() async {
    final secureStorage = locator<SecureStorageService>();
    final firstTime = await secureStorage.read('first_time_user');
    final token = await secureStorage.read('user_token');
    final passcode = await secureStorage.read('user_passcode');

    return {
      '_isFirstTimeUser': firstTime == null || firstTime == 'true',
      '_userToken': token,
      '_userPasscode': passcode,
      '_forceUpdateRequired': false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(374, 844),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _initFuture,
        builder: (context, snapshot) {
          // Check if force update is required
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final data = snapshot.data!;
            final bool forceUpdateRequired = data['_forceUpdateRequired'] as bool? ?? false;
            
            if (forceUpdateRequired && _updateStatus != null) {
              return ForceUpdateView(updateStatus: _updateStatus!);
            }
          }
          
          // Determine initial route based on snapshot data
          String initialRoute = '/startup-view'; // Default to StartupView
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final data = snapshot.data!;
            final bool isFirstTimeUser = data['_isFirstTimeUser'] as bool;
            final String? userToken = data['_userToken'] as String?;
            final String? userPasscode = data['_userPasscode'] as String?;

            print(
                "Navigating with: $isFirstTimeUser, $userToken, $userPasscode");

            if (isFirstTimeUser && userToken == null) {
              initialRoute = '/startup-view'; // StartupView
            } else if (userToken == null || userToken.isEmpty) {
              initialRoute = '/login-view'; // LoginView
            } else if (userPasscode == null || userPasscode.isEmpty) {
              initialRoute = '/login-view'; // LoginView
            } else {
              initialRoute = '/passcode-view'; // PasscodeView
            }
          }

          // Show loading screen while waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: AppScaffold(
                backgroundColor: Color(0xffF6F5FE),
                body: Center(child: CupertinoActivityIndicator()),
              ),
            );
          }

          // Show error screen if future fails
          if (snapshot.hasError || !snapshot.hasData) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: AppScaffold(
                backgroundColor: Color(0xffF6F5FE),
                body: Center(child: Text('Error loading user data')),
              ),
            );
          }

          // Main app with stacked router
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: StackedService.navigatorKey,
            navigatorObservers: [StackedService.routeObserver],
            title: 'Dayfi',
            theme: ThemeData(
              fontFamily: 'Karla',
              useMaterial3: true,
              primaryColor: Color(0xffF6F5FE),
            ),
            initialRoute: initialRoute,
            onGenerateRoute:
                StackedRouter().onGenerateRoute, // Use stacked router
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => AppScaffold(
                  backgroundColor: Color(0xffF6F5FE),
                  body: Center(
                    child: Text('Route "${settings.name}" not found'),
                  ),
                ),
              );
            },
            builder: (context, child) {
              // Show optional update dialog after app loads
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showOptionalUpdateIfNeeded(context);
              });
              return child!;
            },
          );
        },
      ),
    );
  }
  
  void _showOptionalUpdateIfNeeded(BuildContext context) {
    if (_updateStatus is OptionalUpdateAvailable) {
      final appUpdateService = locator<AppUpdateService>();
      appUpdateService.showUpdateDialog(context, _updateStatus!);
    }
  }
}
