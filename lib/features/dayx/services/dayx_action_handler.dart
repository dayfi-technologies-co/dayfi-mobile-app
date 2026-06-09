import 'package:dayfi/features/dayx/widgets/dayx_navigation.dart';
import 'package:flutter/material.dart';

export 'package:dayfi/features/dayx/widgets/dayx_navigation.dart'
    show DayxChangeTab, DayxNavigation;

/// Back-compat wrapper — prefer [DayxNavigation.handle].
abstract final class DayxActionHandler {
  static void handleNavigate({
    required BuildContext context,
    required String target,
    required DayxChangeTab changeTab,
    VoidCallback? onBeforeNavigate,
  }) =>
      DayxNavigation.handle(
        context: context,
        target: target,
        changeTab: changeTab,
        onBeforeNavigate: onBeforeNavigate,
      );
}
