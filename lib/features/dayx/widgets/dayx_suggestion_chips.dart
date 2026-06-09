import 'package:flutter/material.dart';

/// One-tap suggestion chips — same styling as [DayfiCompactChipRow] (unselected).
class DayxSuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  const DayxSuggestionChips({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((label) {
        return InkWell(
          onTap: () => onSelected(label),
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: onSurface.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: onSurface.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.25,
                color: onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
