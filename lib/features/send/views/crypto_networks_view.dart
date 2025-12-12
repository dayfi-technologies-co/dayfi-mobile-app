import 'package:dayfi/app_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 18.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 40.h, width: 40.w),
                Text(
                  'Choose Network',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 20.sp,
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
                    size: 28.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Opacity(
              opacity: .7,
              child: Text(
                'Select the network you want to use for this crypto transfer.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Karla',
                  letterSpacing: -.6,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 24.h),
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
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 8.h,
                      ),
                      itemCount: enabledNetworks.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
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
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40.w,
                                  height: 40.w,
                                  child:
                                      _getNetworkIconPath(networkKey) != null
                                          ? _isPNGIcon(networkKey)
                                              ? Image.asset(
                                                _getNetworkIconPath(
                                                  networkKey,
                                                )!,
                                                width: 32.w,
                                                height: 32.w,
                                                fit: BoxFit.contain,
                                              )
                                              : SvgPicture.asset(
                                                _getNetworkIconPath(
                                                  networkKey,
                                                )!,
                                                width: 32.w,
                                                height: 32.w,
                                                fit: BoxFit.contain,
                                              )
                                          : Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.purple500ForTheme(
                                                    context,
                                                  ).withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(50.r),
                                            ),
                                            child: Center(
                                              child: Text(
                                                networkKey.toString().substring(0, 2),
                                                style: AppTypography.labelSmall
                                                    .copyWith(
                                                      fontFamily: 'Karla',
                                                      fontSize: 18.sp,
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
                                SizedBox(width: 12.w),
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
                                                          fontFamily: 'Karla',
                                                          fontSize: 18.sp,
                                                          letterSpacing: -.6,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                  ),

                                                  if (requiresMemo) ...[
                                                    SizedBox(width: 8.w),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8.w,
                                                            vertical: 3.h,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .warning400
                                                            .withOpacity(0.15),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.r,
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
                                                                      'Karla',
                                                                  fontSize:
                                                                      10.sp,
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
                                              SizedBox(height: 4.h),
                                              Text(
                                                name,
                                                style: AppTypography.bodySmall
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 1.4,
                                                      fontFamily: 'Karla',
                                                      letterSpacing: -.6,
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
                                SizedBox(width: 32.w),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.neutral400,
                                  size: 20.sp,
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
    );
  }
}
