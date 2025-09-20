import 'package:dayfi/ui/common/loader.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigation;
  final bool? isModelBusy;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final Function()? omFloatingActionBtnPressed;
  final Key? scaffoldKey;
  final Widget? drawer;
  final bool? shouldShowFloatingBtn;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool hasSafeArea;

  const AppScaffold({
    super.key,
    required this.body,
    this.bottomNavigation,
    this.isModelBusy,
    this.appBar,
    this.floatingActionButton,
    this.omFloatingActionBtnPressed,
    this.shouldShowFloatingBtn,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.scaffoldKey,
    this.drawer,
    this.hasSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => dismissKeyboard(),
          child: Scaffold(
            backgroundColor: backgroundColor,
            key: scaffoldKey,
            appBar: appBar,
            bottomNavigationBar: bottomNavigation,
            extendBodyBehindAppBar: false,
            body: hasSafeArea
                ? SafeArea(
                    child: body,
                  )
                : body,
            floatingActionButtonLocation: floatingActionButtonLocation,
            floatingActionButton: shouldShowFloatingBtn == false
                ? Container()
                : floatingActionButton,
            drawer: drawer,
          ),
        ),
        if (isModelBusy == true) ...[const Loader()]
      ],
    );
  }
}

void dismissKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

// void openKeyboard() {
//   FocusManager.instance.primaryFocus;
// }
