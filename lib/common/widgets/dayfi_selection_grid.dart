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

  const DayfiSelectionGrid({
    super.key,
    required this.options,
    required this.isSelected,
    required this.label,
    required this.onSelected,
    this.crossAxisCount = 2,
    this.childAspectRatio = 2.5,
    this.showTopDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final bodyColor = Theme.of(context).textTheme.bodyMedium!.color!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border:
            showTopDivider
                ? Border(
                  top: BorderSide(color: bodyColor.withValues(alpha: 0.075)),
                )
                : null,
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        padding: const EdgeInsets.symmetric(vertical: 14),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: childAspectRatio,
        children:
            options.map((option) {
              final selected = isSelected(option);
              return InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => onSelected(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? const Color(0xff5A78F4)
                            : bodyColor.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: bodyColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 16, height: 16),
                          if (selected)
                            SvgPicture.asset(
                              'assets/icons/svgs/circle-check.svg',
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                AppColors.neutral0,
                                BlendMode.srcIn,
                              ),
                            )
                          else
                            const SizedBox(width: 16, height: 16),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          label(option),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Chirp',
                            color: selected ? AppColors.neutral0 : bodyColor,
                            letterSpacing: -.40,
                            height: 1,
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
