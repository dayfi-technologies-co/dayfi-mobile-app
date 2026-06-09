import 'package:flutter/material.dart';

/// Shared layout rules for DayX and DayFlow chat overlays.
abstract final class AgentChatLayout {
  static const horizontalPadding = 18.0;

  /// Bubble width as a fraction of the padded content area.
  static const bubbleWidthFraction = 0.82;

  static double contentWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width - horizontalPadding * 2;
  }

  static double bubbleMaxWidth(BuildContext context) {
    return contentWidth(context) * bubbleWidthFraction;
  }
}

/// Applies the standard 18px horizontal inset for agent chat overlays.
class AgentChatHorizontalPadding extends StatelessWidget {
  const AgentChatHorizontalPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AgentChatLayout.horizontalPadding,
      ),
      child: child,
    );
  }
}
