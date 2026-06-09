import 'dart:math' as math;

import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_category_emoji.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/widgets/dayflow_chat_ui.dart';
import 'package:flutter/material.dart';

class DayFlowAllocationBuilder extends StatefulWidget {
  final DayFlowIncomeEvent income;
  final DayFlowPlan? existingPlan;
  final ValueChanged<DayFlowPlanDraft> onConfirm;

  const DayFlowAllocationBuilder({
    super.key,
    required this.income,
    this.existingPlan,
    required this.onConfirm,
  });

  static const defaultCategories = [
    'Food & Dining',
    'Transport',
    'Bills',
    'Savings',
    'Flex Money',
  ];

  @override
  State<DayFlowAllocationBuilder> createState() =>
      _DayFlowAllocationBuilderState();
}

class _DayFlowAllocationBuilderState extends State<DayFlowAllocationBuilder> {
  late final List<String> _categoryNames;
  late final Map<String, double> _allocations;
  late final double _total;

  @override
  void initState() {
    super.initState();
    _total = widget.income.amount;
    _categoryNames = _resolveCategoryNames();
    _allocations = _initialAllocations();
  }

  List<String> _resolveCategoryNames() {
    final planCats = widget.existingPlan?.categories
            .map((c) => c.name)
            .where((n) => n.isNotEmpty)
            .toList() ??
        [];
    if (planCats.length >= 3) return planCats.take(6).toList();
    return DayFlowAllocationBuilder.defaultCategories;
  }

  Map<String, double> _initialAllocations() {
    return {for (final name in _categoryNames) name: 0.0};
  }

  void _setAllocation(String name, double value) {
    setState(() {
      _allocations[name] = value.clamp(0, _total);
      final flexName = _categoryNames.contains('Flex Money')
          ? 'Flex Money'
          : _categoryNames.last;
      if (name != flexName) {
        final others = _allocations.entries
            .where((e) => e.key != flexName)
            .fold<double>(0, (s, e) => s + e.value);
        _allocations[flexName] = (_total - others).clamp(0, _total);
      }
    });
  }

  double get _allocatedSum =>
      _allocations.values.fold<double>(0, (s, v) => s + v);

  DayFlowPlanDraft _buildDraft() {
    return DayFlowAllocationDraft.fromIncomeAllocation(
      income: widget.income,
      allocations: Map.from(_allocations),
      existingPlan: widget.existingPlan,
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final sliderInactive = onSurface.withValues(alpha: 0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DayFlowCopy.allocationTitle,
          textAlign: TextAlign.center,
          style: DayFlowChatUi.cardTitle(context),
        ),
        const SizedBox(height: 6),
        Text(
          '${formatDayFlowAmount(_total, widget.income.currency)} • ${widget.income.label}',
          textAlign: TextAlign.center,
          style: DayFlowChatUi.cardHint(context),
        ),
        const SizedBox(height: 4),
        Text(
          DayFlowCopy.allocationSubtitle,
          textAlign: TextAlign.center,
          style: DayFlowChatUi.cardHint(context),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 5,
          child: Row(
            children: List.generate(_categoryNames.length, (i) {
              final name = _categoryNames[i];
              final share =
                  _total > 0 ? (_allocations[name] ?? 0) / _total : 0;
              return Expanded(
                flex: math.max(1, (share * 100).round()),
                child: Container(
                  margin: EdgeInsets.only(
                    right: i == _categoryNames.length - 1 ? 0 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: dayFlowCategoryAccentColor(name),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(_categoryNames.length, (i) {
          final name = _categoryNames[i];
          final value = _allocations[name] ?? 0;
          final categoryColor = dayFlowCategoryAccentColor(name);
          final sliderActive = Color.lerp(categoryColor, onSurface, 0.25)!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dayFlowCategoryLabel(name),
                        style: DayFlowChatUi.emphasis(context),
                      ),
                    ),
                    Text(
                      formatDayFlowAmount(
                        value,
                        widget.income.currency,
                      ),
                      style: DayFlowChatUi.rowValue(context),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: sliderActive,
                    inactiveTrackColor: sliderInactive,
                    thumbColor: categoryColor,
                    overlayColor: categoryColor.withValues(alpha: 0.12),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: value.clamp(0, _total),
                    min: 0,
                    max: _total,
                    divisions: _total >= 100 ? 20 : null,
                    onChanged: (v) => _setAllocation(name, v),
                  ),
                ),
              ],
            ),
          );
        }),
        Text(
          'Allocated ${formatDayFlowAmount(_allocatedSum, widget.income.currency)} of ${formatDayFlowAmount(_total, widget.income.currency)}',
          textAlign: TextAlign.center,
          style: DayFlowChatUi.cardHint(context),
        ),
        const SizedBox(height: 12),
        DayFlowChatUi.primaryButton(
          context,
          text: DayFlowCopy.continueToPlan,
          onPressed: (_allocatedSum - _total).abs() < 0.01
              ? () => widget.onConfirm(_buildDraft())
              : null,
        ),
      ],
    );
  }
}
