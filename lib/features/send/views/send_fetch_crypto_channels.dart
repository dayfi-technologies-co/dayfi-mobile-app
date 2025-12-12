import 'dart:convert';
import 'package:dayfi/common/widgets/empty_state_widget.dart';
import 'package:dayfi/common/widgets/error_state_widget.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/features/send/views/crypto_networks_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SendFetchCryptoChannelsView extends ConsumerStatefulWidget {
  const SendFetchCryptoChannelsView({super.key});

  @override
  ConsumerState<SendFetchCryptoChannelsView> createState() =>
      _SendFetchCryptoChannelsViewState();
}

class _SendFetchCryptoChannelsViewState
    extends ConsumerState<SendFetchCryptoChannelsView> {
  static List<dynamic>? _cachedCryptoChannels;
  bool _isLoading = false;
  List<dynamic> _cryptoChannels = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (_cachedCryptoChannels != null) {
      _cryptoChannels = _cachedCryptoChannels!;
    } else {
      _fetchCryptoChannels();
    }
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
        dynamic rawChannels = response.data?.rawChannels;
        List<dynamic> channels = [];

        if (rawChannels != null) {
          if (rawChannels is List) {
            channels = rawChannels;
          } else if (rawChannels is String) {
            try {
              final decoded = const JsonDecoder().convert(rawChannels) as List;
              channels = decoded;
            } catch (e) {
              // print('❌ Error parsing channels JSON string: $e');
            }
          }
        }

        final filteredChannels =
            channels.where((channel) {
              if (channel is Map<String, dynamic>) {
                final zones = channel['zones'] as List? ?? [];
                final enabled = channel['enabled'] ?? false;
                final hasStablecoins = zones.any(
                  (zone) =>
                      zone.toString().toLowerCase().contains('stablecoins'),
                );
                return hasStablecoins && enabled;
              }
              return false;
            }).toList();

        setState(() {
          _cryptoChannels = filteredChannels;
          _isLoading = false;
        });
        _cachedCryptoChannels = filteredChannels;
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

  void _showCryptoNetworksSheet(Map<String, dynamic> channel) {
    showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.85),
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext ctx) {
        return CryptoNetworksView(channel: channel);
      },
    );
  }

  Widget _buildCryptoChannelCard(Map<String, dynamic> channel) {
    final code = channel['code'] ?? 'Unknown';
    final name = channel['name'] ?? 'Unknown';
    final enabled = channel['enabled'] ?? false;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 18.w),
      onTap: () {
        _showCryptoNetworksSheet(channel);
      },
      title: Row(
        children: [
          Container(
            height: 32.0.h,
            width: 32.0.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child:
                  _getCryptoIconPath(code) != null
                      ? code.toUpperCase() == 'CUSD'
                          ? Image.asset(
                            _getCryptoIconPath(code)!,
                            height: 32.0.h,
                            width: 32.0.w,
                            fit: BoxFit.contain,
                          )
                          : SvgPicture.asset(
                            _getCryptoIconPath(code)!,
                            height: 32.0.h,
                            width: 32.0.w,
                            fit: BoxFit.contain,
                            colorFilter: null,
                          )
                      : Text(
                        code,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 18.sp,
                          letterSpacing: -.6,
                          fontWeight: FontWeight.w500,
                          color:
                              enabled
                                  ? AppColors.purple500ForTheme(context)
                                  : AppColors.neutral600,
                        ),
                      ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            name,
            style: AppTypography.bodyLarge.copyWith(
              fontFamily: 'Karla',
              fontSize: 16.sp,
              letterSpacing: -.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: Text(
        code,
        style: AppTypography.bodyLarge.copyWith(
          fontFamily: 'Karla',
          fontSize: 14.sp,
          letterSpacing: -.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 60.h),
            child: LoadingAnimationWidget.waveDots(
              color: AppColors.purple500ForTheme(context),
              size: 24.sp,
            ),
          ),
        )
        : _errorMessage != null
        ? ErrorStateWidget(
          message: 'Failed to load Crypto Channels',
          details: _errorMessage,
          onRetry: _fetchCryptoChannels,
        )
        : _cryptoChannels.isEmpty
        ? EmptyStateWidget(
          icon: Icons.inbox_outlined,
          title: 'No Crypto Channels',
          message: 'No crypto channels available at the moment',
        )
        : RefreshIndicator(
          onRefresh: _fetchCryptoChannels,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            
                ..._cryptoChannels.map((channel) {
                  return _buildCryptoChannelCard(channel);
                }),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        );
  }
}
