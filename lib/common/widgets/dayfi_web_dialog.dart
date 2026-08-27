import 'package:dayfi/common/utils/dayfi_platform.dart';
import 'package:dayfi/common/widgets/dayfi_responsive_scope.dart';
import 'package:flutter/material.dart';

/// Caps dialog width on web so mobile-first layouts do not stretch edge-to-edge.
class DayfiWebDialog extends StatelessWidget {
  const DayfiWebDialog({
    super.key,
    required this.child,
    this.maxWidth = DayfiResponsive.dialogMaxWidth,
    this.backgroundColor,
    this.shape,
    this.insetPadding,
  });

  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final EdgeInsets? insetPadding;

  @override
  Widget build(BuildContext context) {
    final resolvedInset =
        insetPadding ??
        EdgeInsets.symmetric(
          horizontal: isDayfiWeb ? 24 : 40,
          vertical: 24,
        );

    return Dialog(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      shape: shape,
      insetPadding: resolvedInset,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: isDayfiWeb ? maxWidth : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDayfiWeb ? maxWidth : 560,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Material [AlertDialog] wrapped with a fixed web width cap.
class DayfiWebAlertDialog extends StatelessWidget {
  const DayfiWebAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.icon,
    this.scrollable = false,
    this.maxWidth = DayfiResponsive.dialogMaxWidth,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final Widget? icon;
  final bool scrollable;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return DayfiWebDialog(
      maxWidth: maxWidth,
      child: AlertDialog(
        title: title,
        content: content,
        actions: actions,
        icon: icon,
        scrollable: scrollable,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}

/// Drop-in replacement for [showDialog] — builders should return [DayfiWebDialog].
Future<T?> showDayfiDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return showDialog<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  );
}
