import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
import 'package:dayfi/app/app.bottomsheets.dart';
import 'package:dayfi/app/app.dialogs.dart';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
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

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(374, 844),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: StackedService.navigatorKey,
        navigatorObservers: [StackedService.routeObserver],
        title: 'Dayfi',
        theme: ThemeData(
          fontFamily: 'Karla',
          useMaterial3: true,
          primaryColor: Color(0xffF6F5FE),
        ),
        initialRoute: '/splash-view', // Navigate to splash view
        onGenerateRoute: StackedRouter().onGenerateRoute,
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
      ),
    );
  }
}
