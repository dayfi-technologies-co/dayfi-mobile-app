import 'package:dayfi/app_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/send/views/add_wallet_address_view.dart';
import 'package:dayfi/routes/route.dart';

class CryptoNetworksView extends ConsumerWidget {
  final Map<String, dynamic> channel;

  const CryptoNetworksView({super.key, required this.channel});

  String? _getNetworkIconPath(String networkKey) {
    switch (networkKey.toUpperCase()) {
      case 'ERC20':
        return 'assets/icons/svgs/ethereum-eth-logo.svg';
      case 'BSC':
      case 'BNB':
        return null;
      case 'POLYGON':
      case 'POL':
        return 'assets/icons/pngs/polygon-matic-logo.png';
      case 'SOL':
      case 'SOLANA':
        return 'assets/icons/pngs/solana-sol-logo.png';
      case 'CELO':
        return 'assets/icons/pngs/celo-celo-logo.png';
      case 'XLM':
        return 'assets/icons/svgs/stellar-xlm-logo.svg';
      case 'BASE':
        return null;
      case 'TRC20':
      case 'TRON':
        return 'assets/icons/pngs/tron-trx-logo.png';
      default:
        return null;
    }
  }

  bool _isPNGIcon(String networkKey) {
    switch (networkKey.toUpperCase()) {
      case 'POLYGON':
      case 'POL':
      case 'SOL':
      case 'SOLANA':
      case 'CELO':
      case 'TRC20':
      case 'TRON':
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networks = channel['networks'] as Map<String, dynamic>? ?? {};
    final enabledNetworks =
        networks.entries
            .where(
              (entry) =>
                  entry.value['enabled'] == true &&
                  entry.key.toUpperCase() != 'BASE',
            )
            .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 600;
        return Align(
          alignment: isWide ? Alignment.center : Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 500 : double.infinity,
            ),
            child: Container(
              height: isWide ? MediaQuery.of(context).size.height * 0.5 : MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: isWide ? BorderRadius.circular(20) : BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 18),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: 40, width: 40),
                        Text(
                          'Choose Network',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontFamily: 'FunnelDisplay',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap:
                              () => {
                                Navigator.pop(context),
                        FocusScope.of(context).unfocus(),
                      },
                  child: Icon(
                    Icons.close,
                    size: 28,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Opacity(
              opacity: .7,
              child: Text(
                'Select the network you want to use for this crypto transfer.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Chirp',
                  letterSpacing: -.25,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child:
                enabledNetworks.isEmpty
                    ? Center(
                      child: Text(
                        'No networks available',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontFamily: 'FunnelDisplay',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      itemCount: enabledNetworks.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = enabledNetworks[index];
                        final networkKey = entry.key;
                        final network = entry.value as Map<String, dynamic>;
                        final name = network['name'] ?? networkKey;
                        final requiresMemo = network['requiresMemo'] ?? false;
                        return GestureDetector(
                          onTap: () async {
                            // Use appRouter and AppRoute for navigation
                            final result = await appRouter.pushNamed(
                              AppRoute.addWalletAddressView,
                              arguments: {
                                'selectedData': channel,
                                'networkKey': networkKey,
                                'networkName': name,
                                'requiresMemo': requiresMemo,
                              },
                            );
                            if (result != null && result is Map<String, dynamic>) {
                              Navigator.of(context).pop(result);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child:
                                      _getNetworkIconPath(networkKey) != null
                                          ? _isPNGIcon(networkKey)
                                              ? Image.asset(
                                                _getNetworkIconPath(
                                                  networkKey,
                                                )!,
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.contain,
                                              )
                                              : SvgPicture.asset(
                                                _getNetworkIconPath(
                                                  networkKey,
                                                )!,
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.contain,
                                              )
                                          : Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.purple500ForTheme(
                                                    context,
                                                  ).withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Center(
                                              child: Text(
                                                networkKey.toString().substring(0, 2),
                                                style: AppTypography.labelSmall
                                                    .copyWith(
                                                      fontFamily: 'Chirp',
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.purple500ForTheme(
                                                            context,
                                                          ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    networkKey,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge
                                                        ?.copyWith(
                                                          fontFamily: 'Chirp',
                                                          fontSize: 18,
                                                          letterSpacing: -.25,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                  ),

                                                  if (requiresMemo) ...[
                                                    SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 3,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .warning400
                                                            .withOpacity(0.15),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'Memo',
                                                            style: AppTypography
                                                                .labelSmall
                                                                .copyWith(
                                                                  fontFamily:
                                                                      'Chirp',
                                                                  fontSize:
                                                                      10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      AppColors
                                                                          .warning600,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                name,
                                                style: AppTypography.bodySmall
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 1.2,
                                                      fontFamily: 'Chirp',
                                                      letterSpacing: -.25,
                                                      fontSize: 14,
                                                    ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 32),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.neutral400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
}
