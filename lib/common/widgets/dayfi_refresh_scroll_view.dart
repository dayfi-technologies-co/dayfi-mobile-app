import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:flutter/cupertino.dart';

/// Shared pull-to-refresh scroll physics (iOS-style bounce + always scrollable).
const ScrollPhysics dayfiRefreshScrollPhysics = BouncingScrollPhysics(
  parent: AlwaysScrollableScrollPhysics(),
);

/// Consistent haptics + keyboard dismiss for pull-to-refresh across Dayfi.
class DayfiRefreshHandler {
  DayfiRefreshHandler._();

  static Future<void> run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    await HapticHelper.lightImpact();
    FocusScope.of(context).unfocus();
    try {
      await action();
      await HapticHelper.success();
    } catch (_) {
      await HapticHelper.error();
    }
  }
}

/// Cupertino pull-to-refresh sliver used on Home, Transactions, Earn, etc.
class DayfiRefreshSliverControl extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const DayfiRefreshSliverControl({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: () => DayfiRefreshHandler.run(context, onRefresh),
    );
  }
}

/// [CustomScrollView] with unified Dayfi refresh behavior.
class DayfiRefreshScrollView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  const DayfiRefreshScrollView({
    super.key,
    required this.onRefresh,
    required this.slivers,
    this.controller,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: physics ?? dayfiRefreshScrollPhysics,
      slivers: [
        DayfiRefreshSliverControl(onRefresh: onRefresh),
        ...slivers,
      ],
    );
  }
}
