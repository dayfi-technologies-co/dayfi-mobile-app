import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/buttons.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';

class SendCryptoNetworksView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedChannel;

  const SendCryptoNetworksView({super.key, required this.selectedChannel});

  @override
  ConsumerState<SendCryptoNetworksView> createState() =>
      _SendCryptoNetworksViewState();
}

class _SendCryptoNetworksViewState
    extends ConsumerState<SendCryptoNetworksView> {
  String? _selectedNetwork;

  Color _getNetworkColor(String networkKey) {
    switch (networkKey.toUpperCase()) {
      case 'ERC20':
        return Colors.blue;
      case 'BSC':
      case 'BNB':
        return Colors.orange;
      case 'POLYGON':
      case 'POL':
        return Colors.purple;
      case 'SOL':
      case 'SOLANA':
        return Colors.cyan;
      case 'CELO':
        return Colors.yellow;
      case 'XLM':
        return Colors.red;
      case 'BASE':
        return Colors.blueAccent;
      case 'TRC20':
      case 'TRON':
        return Colors.orange;
      default:
        return AppColors.success400;
    }
  }

  String? _getNetworkIconPath(String networkKey) {
    switch (networkKey.toUpperCase()) {
      case 'ERC20':
        return 'assets/icons/svgs/ethereum-eth-logo.svg';
      case 'BSC':
      case 'BNB':
        return null; // No icon found
      case 'POLYGON':
      case 'POL':
        return 'assets/icons/svgs/polygon-matic-logo.svg';
      case 'SOL':
      case 'SOLANA':
        return 'assets/icons/svgs/solana-sol-logo.svg';
      case 'CELO':
        return 'assets/icons/svgs/celo-celo-logo.svg';
      case 'XLM':
        return 'assets/icons/svgs/stellar-xlm-logo.svg';
      case 'BASE':
        return null; // No icon found
      case 'TRC20':
      case 'TRON':
        return 'assets/icons/svgs/tron-trx-logo.svg';
      default:
        return null;
    }
  }

  Widget _buildNetworkCard(MapEntry<String, dynamic> networkEntry) {
    final networkKey = networkEntry.key;
    final network = networkEntry.value as Map<String, dynamic>;
    final name = network['name'] ?? networkKey;
    final enabled = network['enabled'] ?? false;
    final requiresMemo = network['requiresMemo'] ?? false;
    // final activities = network['activities'] as List? ?? [];
    final isSelected = _selectedNetwork == networkKey;

    return GestureDetector(
      onTap:
          enabled
              ? () {
                setState(() {
                  _selectedNetwork = networkKey;
                });
              }
              : () {
                TopSnackbar.show(
                  context,
                  message: '$name network is not available',
                  isError: false,
                );
              },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isSelected && enabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
            width: isSelected ? 1 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral500.withOpacity(0.0375),
              blurRadius: 8.0,
              offset: const Offset(0, 8),
              spreadRadius: 0.8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child:
                    _getNetworkIconPath(networkKey) != null
                        ? SvgPicture.asset(
                          _getNetworkIconPath(networkKey)!,
                          width: 32.w,
                          height: 32.w,
                          fit: BoxFit.contain,
                        )
                        : Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color:
                                enabled
                                    ? _getNetworkColor(
                                      networkKey,
                                    ).withOpacity(0.15)
                                    : AppColors.neutral400.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              networkKey,
                              style: AppTypography.labelSmall.copyWith(
                                fontFamily: 'Karla',
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                color:
                                    enabled
                                        ? _getNetworkColor(networkKey)
                                        : AppColors.neutral600,
                              ),
                            ),
                          ),
                        ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        networkKey,
                        style: AppTypography.titleMedium.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              enabled
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        " ($name)",
                        style: AppTypography.bodySmall.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                          height: 1.5,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (requiresMemo) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning400.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Memo',
                                style: AppTypography.labelSmall.copyWith(
                                  fontFamily: 'Karla',
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  // if (activities.isNotEmpty) ...[
                  //   SizedBox(height: 4.h),
                  //   Wrap(
                  //     spacing: 6.w,
                  //     runSpacing: 4.h,
                  //     children:
                  //         activities.map((activity) {
                  //           return Container(
                  //             padding: EdgeInsets.symmetric(
                  //               horizontal: 8.w,
                  //               vertical: 4.h,
                  //             ),
                  //             decoration: BoxDecoration(
                  //               color: AppColors.purple500.withOpacity(0.15),
                  //               borderRadius: BorderRadius.circular(8.r),
                  //             ),
                  //             child: Text(
                  //               activity.toString().toUpperCase(),
                  //               style: AppTypography.labelSmall.copyWith(
                  //                 fontFamily: 'Karla',
                  //                 fontSize: 8.sp,
                  //                 fontWeight: FontWeight.w600,
                  //                 color: AppColors.purple500,
                  //               ),
                  //             ),
                  //           );
                  //         }).toList(),
                  //   ),
                  // ],
                  if (name.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      "Click here to select the network",
                      style: AppTypography.bodySmall.copyWith(
                        fontFamily: 'Karla',
                        fontSize: 12.sp,
                        letterSpacing: -0.3,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            if (isSelected && enabled)
              SvgPicture.asset(
                'assets/icons/svgs/circle-check.svg',
                color: Theme.of(context).colorScheme.primary,
                height: 24.sp,
                width: 24.sp,
              )
            else if (!enabled)
              Text(
                'Unavailable',
                style: AppTypography.labelSmall.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_selectedNetwork == null) {
      TopSnackbar.show(
        context,
        message: 'Please select a network',
        isError: true,
      );
      return;
    }

    // TODO: Navigate to next screen with selected network
    TopSnackbar.show(
      context,
      message: 'Network selected: $_selectedNetwork',
      isError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final channelCode = widget.selectedChannel['code'] ?? 'currency';
    final networks =
        widget.selectedChannel['networks'] as Map<String, dynamic>? ?? {};

    // Filter to show only enabled networks, excluding BASE
    final enabledNetworks =
        networks.entries
            .where(
              (entry) =>
                  entry.value['enabled'] == true &&
                  entry.key.toUpperCase() != 'BASE',
            )
            .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Network',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 28.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Selected currency info
            // Container(
            //   padding: EdgeInsets.all(16.w),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.surface,
            //     borderRadius: BorderRadius.circular(12.r),
            //     boxShadow: [
            //       BoxShadow(
            //         color: AppColors.neutral500.withOpacity(0.0375),
            //         blurRadius: 8.0,
            //         offset: const Offset(0, 8),
            //         spreadRadius: 0.8,
            //       ),
            //     ],
            //   ),
            //   child: Row(
            //     children: [
            //       Container(
            //         width: 48.w,
            //         height: 48.w,
            //         decoration: BoxDecoration(
            //           color: Theme.of(context).colorScheme.surface,
            //           borderRadius: BorderRadius.circular(8.r),
            //         ),
            //         child: Center(
            //           child: _getCryptoIconPath(channelCode) != null
            //               ? channelCode.toUpperCase() == 'CUSD'
            //                   ? Image.asset(
            //                       _getCryptoIconPath(channelCode)!,
            //                       width: 48.w,
            //                       height: 48.w,
            //                       fit: BoxFit.contain,
            //                     )
            //                   : SvgPicture.asset(
            //                       _getCryptoIconPath(channelCode)!,
            //                       width: 48.w,
            //                       height: 48.w,
            //                       fit: BoxFit.contain,
            //                     )
            //               : Text(
            //                   channelCode,
            //                   style: AppTypography.titleLarge.copyWith(
            //                     fontFamily: 'CabinetGrotesk',
            //                     fontSize: 20.sp,
            //                     fontWeight: FontWeight.w700,
            //                     color: AppColors.purple500,
            //                   ),
            //                 ),
            //         ),
            //       ),
            //       SizedBox(width: 16.w),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               channelCode,
            //               style: AppTypography.titleLarge.copyWith(
            //                 fontFamily: 'CabinetGrotesk',
            //                 fontSize: 18.sp,
            //                 fontWeight: FontWeight.w600,
            //                 color: Theme.of(context).colorScheme.onSurface,
            //               ),
            //             ),
            //             Text(
            //               channelName,
            //               style: AppTypography.bodySmall.copyWith(
            //                 fontFamily: 'Karla',
            //                 fontSize: 12.sp,
            //                 fontWeight: FontWeight.w400,
            //                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Text(
              'What network do you want to use for $channelCode?',
              style: AppTypography.titleLarge.copyWith(
                fontFamily: 'CabinetGrotesk',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            if (enabledNetworks.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.network_check_outlined,
                        size: 64.sp,
                        color: AppColors.neutral400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No Networks Available',
                        style: AppTypography.titleLarge.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No networks are currently enabled for this currency',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 14.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...enabledNetworks.map((networkEntry) {
                return _buildNetworkCard(networkEntry);
              }).toList(),

            SizedBox(height: 100.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral500.withOpacity(0.05),
              blurRadius: 20.0,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: PrimaryButton(
            text:
                _selectedNetwork != null
                    ? 'Continue with ${enabledNetworks.firstWhere((e) => e.key == _selectedNetwork).value['name']}'
                    : 'Select a Network',
            onPressed: _handleContinue,
            backgroundColor:
                _selectedNetwork != null
                    ? AppColors.purple500
                    : AppColors.neutral400,
            textColor: AppColors.neutral0,
            height: 60.h,
            fontFamily: 'Karla',
            letterSpacing: -.8,
            fontSize: 18,
            width: double.infinity,
            fullWidth: true,
            borderRadius: 40.r,
          ),
        ),
      ),
    );
  }
}
