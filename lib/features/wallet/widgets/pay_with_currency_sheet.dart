import 'package:dayfi/features/wallet/constants/global_wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Pick pay / display currency (USD, GBP, EUR, NGN) for global wallet.
Future<String?> showPayWithCurrencySheet(
  BuildContext context, {
  required String selected,
  String title = 'Pay with',
  String? helperText =
      'Same global balance — shown in the currency you choose.',
}) {
  return showModalBottomSheet<String>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.85),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder:
        (ctx) => _PayWithCurrencySheet(
          title: title,
          selected: selected,
          helperText: helperText,
        ),
  );
}

class _PayWithCurrencySheet extends StatelessWidget {
  final String title;
  final String selected;
  final String? helperText;

  const _PayWithCurrencySheet({
    required this.title,
    required this.selected,
    this.helperText,
  });

  Widget _closeButton(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () => Navigator.pop(context),
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

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.15),
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
                      style: TextStyle(
                        fontFamily: 'FunnelDisplay',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                  ),
                  _closeButton(context),
                ],
              ),
            ),
            if (helperText != null && helperText!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  helperText!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 13,
                    height: 1.4,
                    color: onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              // decoration: BoxDecoration(
              //   color: Theme.of(context).colorScheme.surface,
              //   borderRadius: BorderRadius.circular(14),
              // ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(kGlobalPayCurrencies.length, (i) {
                  final c = kGlobalPayCurrencies[i];
                  final isSelected = c == selected.toUpperCase();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context, c),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              ClipOval(
                                child: SvgPicture.asset(
                                  kGlobalPayCurrencyFlags[c]!,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      kGlobalPayCurrencyNames[c] ?? c,
                                      style: TextStyle(
                                        fontFamily: 'Chirp',
                                        fontSize: 15,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                        color: onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c,
                                      style: TextStyle(
                                        fontFamily: 'Chirp',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: onSurface.withValues(
                                          alpha: 0.55,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                SvgPicture.asset(
                                  'assets/icons/svgs/circle-check.svg',
                                  width: 18,
                                  height: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (i < kGlobalPayCurrencies.length - 1)
                        Divider(
                          height: 1,
                          indent: 58,
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.075),
                        ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
