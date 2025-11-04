import 'dart:convert';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/widgets/buttons/buttons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SendFetchCryptoChannelsView extends ConsumerStatefulWidget {
  const SendFetchCryptoChannelsView({super.key});

  @override
  ConsumerState<SendFetchCryptoChannelsView> createState() =>
      _SendFetchCryptoChannelsViewState();
}

class _SendFetchCryptoChannelsViewState
    extends ConsumerState<SendFetchCryptoChannelsView> {
  bool _isLoading = false;
  List<dynamic> _cryptoChannels = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCryptoChannels();
  }

  Future<void> _fetchCryptoChannels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paymentService = locator<PaymentService>();
      final response = await paymentService.fetchCryptoChannels();

      if (!response.error && response.data != null) {
        // Handle the channels data properly
        dynamic rawChannels = response.data?.rawChannels;
        List<dynamic> channels = [];

        print('🔍 rawChannels type: ${rawChannels.runtimeType}');

        if (rawChannels != null) {
          if (rawChannels is List) {
            channels = rawChannels;
            print('✅ Found ${channels.length} crypto channels');
          } else if (rawChannels is String) {
            // If it's a JSON string, try to parse it
            try {
              final decoded = const JsonDecoder().convert(rawChannels) as List;
              channels = decoded;
              print(
                '✅ Parsed ${channels.length} crypto channels from JSON string',
              );
            } catch (e) {
              print('❌ Error parsing channels JSON string: $e');
            }
          } else {
            print(
              '❌ rawChannels is neither List nor String: ${rawChannels.runtimeType}',
            );
          }
        } else {
          print('⚠️ rawChannels is null');
        }

        // Filter to show only stablecoins that are enabled
        final filteredChannels =
            channels.where((channel) {
              if (channel is Map<String, dynamic>) {
                final zones = channel['zones'] as List? ?? [];
                final enabled = channel['enabled'] ?? false;

                // Only show if it has stablecoins zone AND is enabled
                final hasStablecoins = zones.any(
                  (zone) =>
                      zone.toString().toLowerCase().contains('stablecoins'),
                );

                return hasStablecoins && enabled;
              }
              return false;
            }).toList();

        print(
          '✅ Filtered to ${filteredChannels.length} enabled stablecoin channels',
        );

        setState(() {
          _cryptoChannels = filteredChannels;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to load crypto channels';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading crypto channels: $e';
        _isLoading = false;
      });

      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Failed to load crypto channels',
          isError: true,
        );
      }
    }
  }

  Widget _buildNetworkBadge(Map<String, dynamic> network) {
    final networkName = network['name'] ?? 'Unknown';
    final enabled = network['enabled'] ?? false;

    return Container(
      margin: EdgeInsets.only(right: 8.w, bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color:
            enabled
                ? AppColors.success400.withOpacity(0.15)
                : AppColors.neutral400.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: enabled ? AppColors.success400 : AppColors.neutral400,
          width: 1,
        ),
      ),
      child: Text(
        networkName,
        style: AppTypography.labelSmall.copyWith(
          fontFamily: 'Karla',
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: enabled ? AppColors.success600 : AppColors.neutral600,
        ),
      ),
    );
  }

  String? _getCryptoIconPath(String code) {
    switch (code.toUpperCase()) {
      case 'USDC':
        return 'assets/icons/svgs/usd-coin-usdc-logo.svg';
      case 'USDT':
        return 'assets/icons/svgs/tether-usdt-logo.svg';
      case 'CUSD':
        return 'assets/icons/pngs/cusd.png';
      default:
        return null;
    }
  }

  void _navigateToNetworks(Map<String, dynamic> channel) {
    appRouter.pushNamed(AppRoute.cryptoNetworksView, arguments: channel);
  }

  Widget _buildCryptoChannelCard(Map<String, dynamic> channel) {
    final code = channel['code'] ?? 'Unknown';
    final name = channel['name'] ?? 'Unknown';
    final description = channel['description'] ?? '';
    final enabled = channel['enabled'] ?? false;
    final networks = channel['networks'] as Map<String, dynamic>? ?? {};
    final isUTXOBased = channel['isUTXOBased'] ?? false;
    final zones = channel['zones'] as List? ?? [];

    // Get enabled networks
    final enabledNetworks =
        networks.entries
            .where((entry) => entry.value['enabled'] == true)
            .toList();

    return GestureDetector(
      onTap: () => _navigateToNetworks(channel),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          // border: Border.all(
          //   color:
          //       enabled
          //           ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
          //           : Theme.of(context).colorScheme.outline.withOpacity(0.1),
          //   width: 1,
          // ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral500.withOpacity(0.0375),
              blurRadius: 8.0,
              offset: const Offset(0, 8),
              spreadRadius: 0.8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child:
                        _getCryptoIconPath(code) != null
                            ? code.toUpperCase() == 'CUSD'
                                ? Image.asset(
                                  _getCryptoIconPath(code)!,
                                  width: 32.w,
                                  height: 32.w,
                                  fit: BoxFit.contain,
                                )
                                : SvgPicture.asset(
                                  _getCryptoIconPath(code)!,
                                  width: 32.w,
                                  height: 32.w,
                                  fit: BoxFit.contain,
                                  colorFilter: null,
                                )
                            : Text(
                              code,
                              style: AppTypography.titleMedium.copyWith(
                                fontFamily: 'CabinetGrotesk',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color:
                                    enabled
                                        ? AppColors.purple500
                                        : AppColors.neutral600,
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
                            code,
                            style: AppTypography.titleLarge.copyWith(
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
                        ],
                      ),

                      if (name.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          "Click here to select the currency",
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
                      if (!enabled) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'Coming Soon',
                          style: AppTypography.labelSmall.copyWith(
                            fontFamily: 'Karla',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // if (zones.isNotEmpty)
                //   Wrap(
                //     children:
                //         zones.take(2).map((zone) {
                //           return Container(
                //             margin: EdgeInsets.only(left: 4.w),
                //             padding: EdgeInsets.symmetric(
                //               horizontal: 8.w,
                //               vertical: 4.h,
                //             ),
                //             decoration: BoxDecoration(
                //               color: AppColors.purple500.withOpacity(0.15),
                //               borderRadius: BorderRadius.circular(8.r),
                //             ),
                //             child: Text(
                //               (zone as String).toUpperCase(),
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
              ],
            ),

            // if (description.isNotEmpty) ...[
            //   SizedBox(height: 12.h),
            //   Text(
            //     description.replaceAll('<br />', ' ').replaceAll('<br>', ' '),
            //     style: AppTypography.bodySmall.copyWith(
            //       fontFamily: 'Karla',
            //       fontSize: 12.sp,
            //       fontWeight: FontWeight.w400,
            //       letterSpacing: -0.3,
            //       height: 1.5,
            //       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            //     ),
            //     maxLines: 3,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ],

            //   if (enabledNetworks.isNotEmpty) ...[
            //     SizedBox(height: 12.h),
            //     Divider(
            //       color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            //       height: 24.h,
            //     ),
            //     Text(
            //       'Available Networks:',
            //       style: AppTypography.labelMedium.copyWith(
            //         fontFamily: 'Karla',
            //         fontSize: 12.sp,
            //         fontWeight: FontWeight.w600,
            //         color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            //       ),
            //     ),
            //     SizedBox(height: 8.h),
            //     Wrap(
            //       children:
            //           enabledNetworks.map((entry) {
            //             return _buildNetworkBadge(entry.value);
            //           }).toList(),
            //     ),
            //   ],

            //   if (isUTXOBased) ...[
            //     SizedBox(height: 8.h),
            //     Row(
            //       children: [
            //         Icon(
            //           Icons.check_circle_outline,
            //           size: 14.sp,
            //           color: AppColors.success400,
            //         ),
            //         SizedBox(width: 4.w),
            //         Text(
            //           'UTXO Based',
            //           style: AppTypography.labelSmall.copyWith(
            //             fontFamily: 'Karla',
            //             fontSize: 10.sp,
            //             fontWeight: FontWeight.w600,
            //             color: AppColors.success600,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Digital Dollars',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.refresh,
        //       color: Theme.of(context).colorScheme.onSurface,
        //     ),
        //     onPressed: _fetchCryptoChannels,
        //   ),
        // ],
      ),
      body:
          _isLoading
              ? Center(
                child: Padding(
                  padding: EdgeInsetsGeometry.only(bottom: 60.h),
                  child: LoadingAnimationWidget.threeArchedCircle(
                    color: AppColors.purple500,
                    size: 32.sp,
                  ),
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppColors.error400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error Loading Channels',
                        style: AppTypography.titleLarge.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 14.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      PrimaryButton(
                        text: 'Retry',
                        onPressed: _fetchCryptoChannels,
                        backgroundColor: AppColors.purple500,
                        textColor: AppColors.neutral0,
                        height: 48.h,
                        width: 120.w,
                        fontFamily: 'Karla',
                        fontSize: 14.sp,
                        borderRadius: 24.r,
                      ),
                    ],
                  ),
                ),
              )
              : _cryptoChannels.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64.sp,
                      color: AppColors.neutral400,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No Crypto Channels',
                      style: AppTypography.titleLarge.copyWith(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No crypto channels available at the moment',
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
              )
              : RefreshIndicator(
                onRefresh: _fetchCryptoChannels,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'What currency do you want to use as your payment method?',
                        style: AppTypography.titleLarge.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 32.h),
                      ..._cryptoChannels.map((channel) {
                        return _buildCryptoChannelCard(channel);
                      }).toList(),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
    );
  }
}
