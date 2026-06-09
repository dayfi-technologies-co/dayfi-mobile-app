import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/core/theme/theme_toggle_widget.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_icon_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileSettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: Theme.of(context)
                .textTheme
                .bodyLarge!
                .color!
                .withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            fontFamily: 'Chirp',
            letterSpacing: -0.20,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          children[i],
        ],
      ],
    );
  }
}

class ProfileSettingsTile extends StatelessWidget {
  final String icon;
  final String icon2;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final String? actionText;
  final Color? actionColor;

  const ProfileSettingsTile({
    super.key,
    required this.icon,
    required this.icon2,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.actionText,
    this.actionColor,
  });

  bool get _isDelete => icon2 == 'assets/icons/svgs/delete.svg';

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              PayBillIconBadge(
                innerIconAsset: icon2,
                size: 44,
                innerIconColor: _isDelete ? iconColor : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isDelete ? AppColors.error500 : onSurface,
                  ),
                ),
              ),
              if (actionText != null) ...[
                Text(
                  actionText!,
                  style: AppTypography.labelMedium.copyWith(
                    color: actionColor ?? AppColors.neutral600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Chirp',
                    letterSpacing: -0.20,
                    height: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileThemeSettingsTile extends ConsumerWidget {
  const ProfileThemeSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticHelper.lightImpact();
          showThemeSelectionSheet(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const PayBillIconBadge(
                innerIconAsset: 'assets/icons/svgs/sun.svg',
                size: 44,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Theme',
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileBiometricSettingsTile extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const ProfileBiometricSettingsTile({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const PayBillIconBadge(
              innerIconAsset: 'assets/icons/svgs/security-safe.svg',
              size: 44,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Biometric login',
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
            ),
            Switch.adaptive(
              value: enabled,
              onChanged: onChanged,
              activeColor: AppColors.purple500,
            ),
          ],
        ),
      ),
    );
  }
}
