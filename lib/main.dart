import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
import 'package:dayfi/app/app.bottomsheets.dart';
import 'package:dayfi/app/app.dialogs.dart';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
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

  @override
  void initState() {
    super.initState();
    _initFuture = _fetchKnownTokens();
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
    };
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(374, 844),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _initFuture,
        builder: (context, snapshot) {
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
          );
        },
      ),
    );
  }
}
