import 'dart:async';

import 'package:dayfi/common/services/feature_activity_service.dart';
import 'package:dayfi/features/dayearn/dayearn_entry.dart';
import 'package:dayfi/core/navigation/dayfi_page_transitions.dart';
import 'package:dayfi/features/dayearn/views/dayearn_create_view.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';

abstract final class DayEarnFlow {
  /// Pop feature stack back to main tab shell (bottom nav).
  static void popToMain(BuildContext context) {
    if (!context.mounted) return;
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name == AppRoute.mainView || route.isFirst,
    );
  }

  /// Push create flow; returns true when a pot was created.
  static Future<bool> openCreate(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      DayfiPageRoute<bool>(
        builder: (_) => const DayEarnCreateView(),
      ),
    );
    return result == true;
  }

  /// DayEarn dashboard — clears create/success above, lands on DayEarn home.
  static void openHome(BuildContext context) {
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoute.dayEarnView,
      (route) =>
          route.settings.name == AppRoute.mainView || route.isFirst,
    );
  }

  /// Call after pot creation before [openHome].
  static Future<void> onPotCreated() async {
    await DayEarnEntry.markHasPots();
    FeatureActivityService.instance.invalidate();
  }

  /// Success screen Done — land on DayEarn home.
  static void finishCreateFromSuccess(BuildContext context) {
    if (!context.mounted) return;
    unawaited(onPotCreated());
    openHome(context);
  }
}
