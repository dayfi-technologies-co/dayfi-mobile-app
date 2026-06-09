import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Small horizontal chips (create-budget mock): teal fill + check when selected.
class DayfiCompactChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const DayfiCompactChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((label) {
        final isSelected = selected == label;
        return InkWell(
          onTap: () => onSelected(label),
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary400
                  : onSurface.withOpacity(0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary400
                    : onSurface.withOpacity(0.12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  SvgPicture.asset(
                    'assets/icons/svgs/circle-check.svg',
                    height: 14,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.25,
                    color: isSelected ? Colors.black87 : onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Maps internal values to display labels for chips.
class DayfiCompactChipOption {
  final String value;
  final String label;

  const DayfiCompactChipOption({required this.value, required this.label});
}

class DayfiCompactChipRowMapped extends StatelessWidget {
  final List<DayfiCompactChipOption> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const DayfiCompactChipRowMapped({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final labels = options.map((o) => o.label).toList();
    final selectedLabel = options
        .firstWhere(
          (o) => o.value == selectedValue,
          orElse: () => options.first,
        )
        .label;

    return DayfiCompactChipRow(
      options: labels,
      selected: selectedLabel,
      onSelected: (label) {
        final match = options.firstWhere((o) => o.label == label);
        onSelected(match.value);
      },
    );
  }
}
