import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AddMoneyOptionIconStyle { jagged, flag }

class AddMoneyOption {
  final String id;
  final String title;
  final String? subtitle;
  final String iconAsset;
  final bool enabled;
  final AddMoneyOptionIconStyle iconStyle;

  const AddMoneyOption({
    required this.id,
    required this.title,
    this.subtitle,
    required this.iconAsset,
    this.enabled = true,
    this.iconStyle = AddMoneyOptionIconStyle.jagged,
  });
}

/// Add-money options — one surface card per row (matches Send delivery sheet).
class AddMoneyOptionList extends StatelessWidget {
  final List<AddMoneyOption> options;
  final void Function(AddMoneyOption option) onTap;

  const AddMoneyOptionList({
    super.key,
    required this.options,
    required this.onTap,
  });

  Widget _optionIcon(BuildContext context, AddMoneyOption option) {
    if (option.iconStyle == AddMoneyOptionIconStyle.flag) {
      return ClipOval(
        child: SvgPicture.asset(
          option.iconAsset,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svgs/swap.svg',
            height: 40,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SvgPicture.asset(
            option.iconAsset,
            height: 28,
            color: Theme.of(context).colorScheme.surface,
          ),
        ],
      ),
    );
  }

  Widget _optionTile(BuildContext context, AddMoneyOption option) {
    return Opacity(
      opacity: option.enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: option.enabled ? () => onTap(option) : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.transparent,
          highlightColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _optionIcon(context, option),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(
                          fontFamily: 'Chirp',
                          fontSize: 18,
                          letterSpacing: -.25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (option.subtitle != null &&
                          option.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          option.subtitle!,
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -.25,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!option.enabled) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Coming soon',
                      style: AppTypography.labelSmall.copyWith(
                        fontFamily: 'Chirp',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < options.length; i++) ...[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: _optionTile(context, options[i]),
          ),
          if (i < options.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

Widget _addMoneySheetCloseButton(BuildContext context) {
  return InkWell(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    onTap: () {
      Navigator.pop(context);
      FocusScope.of(context).unfocus();
    },
    child: Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/svgs/notificationn.svg',
          height: 40,
          color: Theme.of(context).colorScheme.surface,
        ),
        SizedBox(
          height: 40,
          width: 40,
          child: Center(
            child: Image.asset(
              'assets/icons/pngs/cancelicon.png',
              height: 20,
              width: 20,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<T?> showAddMoneyPickerSheet<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  required List<AddMoneyOption> options,
}) {
  return showModalBottomSheet<T>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.85),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                          fontFamily: 'FunnelDisplay',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(ctx).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _addMoneySheetCloseButton(ctx),
                  ],
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Chirp',
                      letterSpacing: -.25,
                      height: 1.45,
                      color: Theme.of(
                        ctx,
                      ).colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: AddMoneyOptionList(
                  options: options,
                  onTap: (option) => Navigator.pop(ctx, option.id),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}
