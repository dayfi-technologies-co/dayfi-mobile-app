import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/wallet/constants/crypto_network_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Dropdown field + bottom sheet for choosing a crypto network (receive / send).
class CryptoNetworkSelectorField extends StatelessWidget {
  final String iconAsset;
  final String value;
  final VoidCallback onTap;

  const CryptoNetworkSelectorField({
    super.key,
    required this.iconAsset,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/svgs/swap.svg',
                    height: 40,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  SvgPicture.asset(
                    iconAsset,
                    height: 28,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Network',
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Chirp',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: -.25,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showCryptoNetworkPickerSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required List<CryptoNetworkOption> networks,
  required String selectedKey,
  required ValueChanged<CryptoNetworkOption> onSelected,
  bool receiveMode = false,
}) {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  final items = CryptoNetworkCatalog.topNetworks(networks);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.85),
    builder: (ctx) {
      return FractionallySizedBox(
        heightFactor: 0.88,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: onSurface.withOpacity(0.15),
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
                          color: onSurface,
                        ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => Navigator.pop(ctx),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/svgs/notificationn.svg',
                            height: 40,
                            color: Theme.of(ctx).colorScheme.surface,
                          ),
                          SizedBox(
                            height: 40,
                            width: 40,
                            child: Center(
                              child: Image.asset(
                                'assets/icons/pngs/cancelicon.png',
                                height: 20,
                                width: 20,
                                color: Theme.of(ctx).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  subtitle,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Chirp',
                    letterSpacing: -.25,
                    height: 1.45,
                    color: onSurface.withOpacity(0.55),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: List.generate(items.length, (index) {
                        final network = items[index];
                        final selected = network.key == selectedKey;
                        final canSelect =
                            receiveMode
                                ? network.enabled && network.address.trim().isNotEmpty
                                : network.enabled;

                        return Column(
                          children: [
                            CryptoNetworkOptionTile(
                              iconAsset: CryptoNetworkCatalog.iconAsset(network.key),
                              title: network.name,
                              subtitle: network.subtitle,
                              badge:
                                  network.recommended ? 'Recommended' : null,
                              feeLabel: receiveMode ? null : network.feeLabel,
                              selected: selected,
                              enabled: canSelect,
                              onTap: () {
                                if (!canSelect) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        network.enabled
                                            ? 'Deposit address not ready for ${network.name}'
                                            : '${network.name} is not available yet',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                onSelected(network);
                                Navigator.pop(ctx);
                              },
                            ),
                            if (index < items.length - 1)
                              Divider(
                                height: 1,
                                thickness: 1,
                                indent: 68,
                                endIndent: 16,
                                color: Theme.of(ctx).dividerColor.withOpacity(0.08),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      );
    },
  );
}

class CryptoNetworkOptionTile extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final String? badge;
  final String? feeLabel;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const CryptoNetworkOptionTile({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    this.badge,
    this.feeLabel,
    this.selected = false,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final opacity = enabled ? 1.0 : 0.45;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/svgs/swap.svg',
                      height: 40,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    SvgPicture.asset(
                      iconAsset,
                      height: 28,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontFamily: 'Chirp',
                              fontSize: 18,
                              letterSpacing: -.25,
                              fontWeight: FontWeight.w500,
                              color:
                                  selected && enabled
                                      ? AppColors.primary400
                                      : onSurface,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary400.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                badge!,
                                style: AppTypography.labelSmall.copyWith(
                                  fontFamily: 'Chirp',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary400,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        fontFamily: 'Chirp',
                        letterSpacing: -.25,
                        fontSize: 14,
                        color: onSurface.withOpacity(0.65),
                      ),
                    ),
                    if (feeLabel != null && feeLabel!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Network fee $feeLabel',
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 12.5,
                          color: onSurface.withOpacity(0.45),
                        ),
                      ),
                    ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: onSurface.withOpacity(0.28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
