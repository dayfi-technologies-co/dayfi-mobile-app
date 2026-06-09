import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/pay/constants/pay_copy.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_icon_badge.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';

/// First step in Pay bills: choose local (NGN) or international.
class PayBillsScopeView extends StatelessWidget {
  const PayBillsScopeView({super.key});

  void _openLocal(BuildContext context) {
    Navigator.pushNamed(context, AppRoute.payView);
  }

  void _openInternational(BuildContext context) {
    Navigator.pushNamed(context, AppRoute.payBillsInternationalView);
  }

  @override
  Widget build(BuildContext context) {
    return DayfiFeatureScaffold(
      title: kPayBillsHubTitle,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DayfiScreenDescription(text: kPayBillsHubDescription),
            _PayScopeMethodGroup(
              tiles: [
                _PayScopeMethodTile(
                  title: payViaTitle('Local bills'),
                  innerIconAsset: 'assets/icons/svgs/invoice_c.svg',
                  enabled: true,
                  onTap: () => _openLocal(context),
                ),
                _PayScopeMethodTile(
                  title: payViaTitle('International bills'),
                  innerIconAsset: 'assets/icons/svgs/invoice_c.svg',
                  badge: 'Coming soon',
                  enabled: false,
                  onTap: () => _openInternational(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PayScopeMethodGroup extends StatelessWidget {
  const _PayScopeMethodGroup({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: tiles[i],
          ),
          if (i < tiles.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _PayScopeMethodTile extends StatelessWidget {
  const _PayScopeMethodTile({
    required this.title,
    required this.innerIconAsset,
    this.badge,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String innerIconAsset;
  final String? badge;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
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
                PayBillIconBadge(innerIconAsset: innerIconAsset),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 18,
                      letterSpacing: -.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _badgeBackground(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: AppTypography.labelSmall.copyWith(
                        fontFamily: 'Chirp',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _badgeForeground(context),
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

  Color _badgeBackground(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.08);
  }

  Color _badgeForeground(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
  }
}
