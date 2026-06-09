import 'package:dayfi/features/dayflow/daybudget_flow.dart';
import 'package:dayfi/features/dayx/models/dayx_intent.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/local/intercom_support_service.dart';
import 'package:flutter/material.dart';

typedef DayxChangeTab = void Function(int index);

/// Routes DayX navigation intents to the correct screen or tab.
class DayxNavigation {
  DayxNavigation._();

  static void handle({
    required BuildContext context,
    required String target,
    required DayxChangeTab changeTab,
    VoidCallback? onBeforeNavigate,
  }) {
    onBeforeNavigate?.call();

    switch (_normalizeTarget(target)) {
      case DayxNavigateTargets.home:
        changeTab(0);
        return;
      case DayxNavigateTargets.transactions:
        changeTab(1);
        return;
      case DayxNavigateTargets.invest:
      case DayxNavigateTargets.earn:
        Navigator.pushNamed(context, AppRoute.dayEarnView);
        return;
      case DayxNavigateTargets.dayflow:
        DayBudgetFlow.open(context);
        return;
      case DayxNavigateTargets.recipients:
        changeTab(2);
        return;
      case DayxNavigateTargets.profile:
        changeTab(3);
        return;
      case DayxNavigateTargets.pay:
        Navigator.pushNamed(context, AppRoute.payBillsScopeView);
        return;
      case DayxNavigateTargets.send:
      case DayxNavigateTargets.withdraw:
        Navigator.pushNamed(context, AppRoute.selectDestinationCountryView);
        return;
      case DayxNavigateTargets.budgets:
        Navigator.pushNamed(context, AppRoute.budgetsView);
        return;
      case DayxNavigateTargets.addMoney:
        Navigator.pushNamed(context, AppRoute.addMoneySelectWalletView);
        return;
      case DayxNavigateTargets.support:
        IntercomSupportService.openContactSupport();
        return;
    }
  }

  /// Maps LLM / chip aliases to canonical [DayxNavigateTargets].
  static String _normalizeTarget(String target) {
    final t = target.trim().toLowerCase().replaceAll(' ', '_');
    switch (t) {
      case 'earn':
      case 'lock':
      case 'lock_&_earn':
      case 'lock_and_earn':
      case 'lock_earn':
      case 'safelock':
      case 'invest':
        return DayxNavigateTargets.invest;
      case 'dayflow':
      case 'day_flow':
      case 'budget':
        return DayxNavigateTargets.dayflow;
      case 'more':
      case 'settings':
        return DayxNavigateTargets.profile;
      case 'history':
        return DayxNavigateTargets.transactions;
      case 'contacts':
        return DayxNavigateTargets.recipients;
      case 'support':
      case 'customer_support':
      case 'contact_support':
        return DayxNavigateTargets.support;
      default:
        return target;
    }
  }
}
