import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Branded checkbox — rounded square with checkmark (auth / signup style).
class DayfiCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;

  const DayfiCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final accent = AppColors.purple500ForTheme(context);
    final enabled = onChanged != null;

    return Semantics(
      checked: value,
      enabled: enabled,
      button: enabled,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!value) : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: value ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: value ? accent : onSurface.withValues(alpha: 0.28),
              width: 1.5,
            ),
          ),
          child:
              value
                  ? Icon(
                    Icons.check_rounded,
                    size: size * 0.72,
                    color: AppColors.neutral0,
                  )
                  : null,
        ),
      ),
    );
  }
}

/// Checkbox with label — tap anywhere on the row to toggle.
class DayfiCheckboxTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final TextStyle? labelStyle;
  final double checkboxSize;

  const DayfiCheckboxTile({
    super.key,
    required this.value,
    this.onChanged,
    required this.label,
    this.labelStyle,
    this.checkboxSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final enabled = onChanged != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              DayfiCheckbox(
                value: value,
                onChanged: onChanged,
                size: checkboxSize,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style:
                      labelStyle ??
                      TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.25,
                        height: 1.3,
                        color: onSurface,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
