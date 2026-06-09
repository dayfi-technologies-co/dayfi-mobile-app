import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Selectable card (network chip / budget type) — border highlight when selected.
class DayfiOptionCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String iconAsset;

  const DayfiOptionCard({
    super.key,
    required this.label,
    this.subtitle,
    required this.selected,
    required this.onTap,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          // duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          decoration: BoxDecoration(
            color:
                selected
                    ? primary.withValues(alpha: 0.08)
                    : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected
                      ? primary.withValues(alpha: 0.5)
                      : onSurface.withValues(alpha: 0.1),
              width: selected ? 1 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/svgs/swap.svg',
                    height: 36,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  SvgPicture.asset(
                    iconAsset,
                    height: 24,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ],
              ),

              Spacer(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected ? primary : onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 12,
                        color: onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DayfiOptionCardGrid extends StatelessWidget {
  final List<DayfiOptionCardData> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;
  final int crossAxisCount;
  final double childAspectRatio;

  const DayfiOptionCardGrid({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.crossAxisCount = 2,
    this.childAspectRatio = 2.2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: childAspectRatio,
      children:
          options.map((o) {
            return DayfiOptionCard(
              iconAsset: o.iconAsset,
              label: o.label,
              subtitle: o.subtitle,
              selected: selectedValue == o.value,
              onTap: () => onSelected(o.value),
            );
          }).toList(),
    );
  }
}

class DayfiOptionCardData {
  final String value;
  final String label;
  final String? subtitle;
  final String iconAsset;

  const DayfiOptionCardData({
    required this.value,
    required this.label,
    this.subtitle,
    required this.iconAsset,
  });
}
