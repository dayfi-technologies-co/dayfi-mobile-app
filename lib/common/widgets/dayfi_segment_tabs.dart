import 'package:flutter/material.dart';

/// Segmented control for Add money / similar flows (Username · Bank · On-chain).
class DayfiSegmentTabs extends StatelessWidget {
  final TabController controller;
  final List<String> labels;

  const DayfiSegmentTabs({
    super.key,
    required this.controller,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: TabBar(
          controller: controller,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          indicator: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(9),
            // boxShadow: [
            //   BoxShadow(
            //     color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            //     blurRadius: 8,
            //     offset: const Offset(0, 2),
            //   ),
            // ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Theme.of(context).textTheme.bodyLarge!.color,
          unselectedLabelColor: onSurface.withValues(alpha: 0.55),
          labelStyle: const TextStyle(
            fontFamily: 'Chirp',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Chirp',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          tabs: labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
    );
  }
}
