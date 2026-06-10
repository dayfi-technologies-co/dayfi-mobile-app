import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Onboarding-style selectable chip grid (occupation / use-case pattern).
class DayfiSelectionGrid<T> extends StatelessWidget {
  final List<T> options;
  final bool Function(T option) isSelected;
  final String Function(T option) label;
  final ValueChanged<T> onSelected;
  final int crossAxisCount;
  final double childAspectRatio;
  final bool showTopDivider;
  final bool compact;

  const DayfiSelectionGrid({
    super.key,
    required this.options,
    required this.isSelected,
    required this.label,
    required this.onSelected,
    this.crossAxisCount = 2,
    this.childAspectRatio = 2.5,
    this.showTopDivider = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bodyColor = Theme.of(context).textTheme.bodyMedium!.color!;

    return Container(
      margin: compact ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 8),
      padding: compact ? EdgeInsets.zero : const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border:
            showTopDivider && !compact
                ? Border(
                  top: BorderSide(color: bodyColor.withValues(alpha: 0.075)),
                )
                : null,
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        padding: compact ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 14),
        mainAxisSpacing: compact ? 6 : 8,
        crossAxisSpacing: compact ? 6 : 8,
        childAspectRatio: compact ? 3.1 : childAspectRatio,
        children:
            options.map((option) {
              final selected = isSelected(option);
              return InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => onSelected(option),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 8 : 8,
                    vertical: compact ? 8 : 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? const Color(0xff5A78F4)
                            : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          label(option),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: compact ? 15 : 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Chirp',
                            color: selected ? AppColors.neutral0 : bodyColor,
                            letterSpacing: -.40,
                            height: 1,
                          ),
                        ),
                      ),
                      if (selected)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: SvgPicture.asset(
                            'assets/icons/svgs/circle-check.svg',
                            height: 16,
                            width: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.neutral0,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
