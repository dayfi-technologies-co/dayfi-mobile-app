import 'dart:async';

import 'package:dayfi/common/services/feature_activity_service.dart';
import 'package:dayfi/features/dayearn/dayearn_entry.dart';
import 'package:dayfi/core/navigation/dayfi_page_transitions.dart';
import 'package:dayfi/features/dayearn/services/dayearn_summary_cache.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/navigation/navigator_key.dart';
import 'package:dayfi/features/dayearn/views/dayearn_create_view.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Refresh caches after any DayEarn wallet movement (non-blocking).
  static Future<void> onFundsMoved(WidgetRef ref) async {
    DayEarnSummaryCache.instance.invalidate();
    FeatureActivityService.instance.invalidate();
    unawaited(
      ref
          .read(transactionsProvider.notifier)
          .loadTransactions(forceRefresh: true)
          .catchError((_) {}),
    );
  }

  /// Call after pot creation — marks local state then refreshes in background.
  static Future<void> onPotCreated(WidgetRef ref) async {
    await DayEarnEntry.markHasPots();
    await onFundsMoved(ref);
  }

  /// Leave the current DayEarn screen, show a top snackbar on the route below.
  static void completeWithSnackbar({
    required BuildContext context,
    required WidgetRef ref,
    required String message,
    bool afterPotCreated = false,
  }) {
    if (afterPotCreated) {
      unawaited(DayEarnEntry.markHasPots());
    }
    unawaited(onFundsMoved(ref));

    if (!context.mounted) return;

    final navigator = Navigator.of(context);
    final shouldPop = navigator.canPop();

    if (shouldPop) {
      navigator.pop(true);
    } else {
      final rootContext = NavigatorKey.appNavigatorKey.currentContext;
      if (rootContext != null && rootContext.mounted) {
        openHome(rootContext);
      }
    }

    // Show after the pop so the snackbar attaches to the route underneath.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rootContext = NavigatorKey.appNavigatorKey.currentContext;
      if (rootContext != null && rootContext.mounted) {
        TopSnackbar.show(rootContext, message: message);
      }
    });
  }

  /// Legacy success screen Done — land on DayEarn home.
  static void finishCreateFromSuccess(BuildContext context) {
    if (!context.mounted) return;
    DayEarnSummaryCache.instance.invalidate();
    FeatureActivityService.instance.invalidate();
    openHome(context);
  }
}
