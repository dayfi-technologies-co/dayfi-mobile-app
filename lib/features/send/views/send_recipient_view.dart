// import 'package:dayfi/common/widgets/buttons/help_button.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/common/widgets/error_state_widget.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
// import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/routes/route.dart';

class SendRecipientView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;

  const SendRecipientView({super.key, required this.selectedData});

  @override
  ConsumerState<SendRecipientView> createState() => _SendRecipientViewState();
}

class _SendRecipientViewState extends ConsumerState<SendRecipientView> {
  final TextEditingController _searchController = TextEditingController();
  final _searchDebouncer = SearchDebouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Debug: Print received data
      print('📦 SendRecipientView - Received selectedData:');
      print('   receiveCountry: ${widget.selectedData['receiveCountry']}');
      print('   receiveCurrency: ${widget.selectedData['receiveCurrency']}');
      print('   sendCountry: ${widget.selectedData['sendCountry']}');
      print('   sendCurrency: ${widget.selectedData['sendCurrency']}');
      print('   recipientDeliveryMethod: ${widget.selectedData['recipientDeliveryMethod']}');
      print('   recipientChannelId: ${widget.selectedData['recipientChannelId']}');
      print('   All keys: ${widget.selectedData.keys.toList()}');
      
      _loadBeneficiaries();
    });
  }

  void _loadBeneficiaries() {
    // Load all beneficiaries first
    ref.read(recipientsProvider.notifier).loadBeneficiaries();
  }

  /// Get full country name from country code
  String _getCountryName(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'CD':
        return 'Democratic Republic of Congo';
      case 'RW':
        return 'Rwanda';
      case 'NG':
        return 'Nigeria';
      case 'KE':
        return 'Kenya';
      case 'UG':
        return 'Uganda';
      case 'TZ':
        return 'Tanzania';
      case 'ZA':
        return 'South Africa';
      case 'BW':
        return 'Botswana';
      case 'GH':
        return 'Ghana';
      case 'SN':
        return 'Senegal';
      case 'CI':
        return 'Côte d\'Ivoire';
      case 'CM':
        return 'Cameroon';
      case 'BF':
        return 'Burkina Faso';
      case 'ML':
        return 'Mali';
      case 'NE':
        return 'Niger';
      case 'TD':
        return 'Chad';
      case 'CF':
        return 'Central African Republic';
      case 'GA':
        return 'Gabon';
      case 'CG':
        return 'Republic of Congo';
      case 'AO':
        return 'Angola';
      case 'ZM':
        return 'Zambia';
      case 'ZW':
        return 'Zimbabwe';
      case 'MW':
        return 'Malawi';
      case 'MZ':
        return 'Mozambique';
      case 'MG':
        return 'Madagascar';
      case 'MU':
        return 'Mauritius';
      case 'SC':
        return 'Seychelles';
      case 'KM':
        return 'Comoros';
      case 'DJ':
        return 'Djibouti';
      case 'ET':
        return 'Ethiopia';
      case 'ER':
        return 'Eritrea';
      case 'SO':
        return 'Somalia';
      case 'SS':
        return 'South Sudan';
      case 'SD':
        return 'Sudan';
      case 'EG':
        return 'Egypt';
      case 'LY':
        return 'Libya';
      case 'TN':
        return 'Tunisia';
      case 'DZ':
        return 'Algeria';
      case 'MA':
        return 'Morocco';
      case 'LR':
        return 'Liberia';
      case 'SL':
        return 'Sierra Leone';
      case 'GN':
        return 'Guinea';
      case 'GW':
        return 'Guinea-Bissau';
      case 'CV':
        return 'Cape Verde';
      case 'ST':
        return 'São Tomé and Príncipe';
      case 'GQ':
        return 'Equatorial Guinea';
      case 'BI':
        return 'Burundi';
      default:
        return countryCode;
    }
  }

  /// Get display name for channel type
  String _getChannelDisplayName(String channelType) {
    switch (channelType.toLowerCase()) {
      case 'bank':
      case 'bank_transfer':
      case 'p2p':
        return 'Bank Transfer';
      case 'mobile_money':
      case 'momo':
      case 'mobilemoney':
        return 'Mobile Money';
      case 'spenn':
        return 'Spenn';
      case 'cash_pickup':
      case 'cash':
        return 'Cash Pickup';
      case 'wallet':
      case 'digital_wallet':
        return 'Digital Wallet';
      case 'card':
      case 'card_payment':
        return 'Card Payment';
      case 'crypto':
      case 'cryptocurrency':
        return 'Cryptocurrency';
      default:
        return channelType;
    }
  }

  List<BeneficiaryWithSource> _getFilteredBeneficiaries() {
    final recipientsState = ref.watch(recipientsProvider);
    final targetCountry = widget.selectedData['receiveCountry'] ?? '';

    if (targetCountry.isEmpty) return recipientsState.beneficiaries;

    // Filter beneficiaries ONLY by country - show all channels
    final filtered =
        recipientsState.beneficiaries.where((beneficiaryWithSource) {
          final countryMatch =
              beneficiaryWithSource.beneficiary.country == targetCountry;
          return countryMatch;
        }).toList();

    // Apply search filter if there's a search query
    if (_searchController.text.isNotEmpty) {
      final searchQuery = _searchController.text.toLowerCase();
      return filtered.where((beneficiaryWithSource) {
        final beneficiary = beneficiaryWithSource.beneficiary;
        return beneficiary.name.toLowerCase().contains(searchQuery) ||
            beneficiary.phone.contains(searchQuery) ||
            beneficiary.email.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Return all filtered beneficiaries (no user/self-funding filtering)
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipientsState = ref.watch(recipientsProvider);
    final allFilteredBeneficiaries = _getFilteredBeneficiaries();
    
    // Remove duplicate beneficiaries based on account number and filter out empty names
    final seenAccountNumbers = <String>{};
    final filteredBeneficiaries = allFilteredBeneficiaries.where((beneficiary) {
      // Skip if beneficiary name is empty or whitespace only
      if (beneficiary.beneficiary.name.trim().isEmpty) {
        return false;
      }
      
      final accountNumber = beneficiary.source.accountNumber ?? '';
      if (seenAccountNumbers.contains(accountNumber)) {
        return false; // Skip duplicate
      }
      seenAccountNumbers.add(accountNumber);
      return true;
    }).toList();
    
    final targetCountry = widget.selectedData['receiveCountry'] ?? 'Unknown';
    final targetCurrency = widget.selectedData['receiveCurrency'] ?? 'Unknown';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
            onPressed:
                () => {
                  Navigator.pop(context),
                  FocusScope.of(context).unfocus(),
                },
          ),
          title: Text(
            'Beneficiaries',
            style: AppTypography.titleLarge.copyWith(
           fontFamily: 'CabinetGrotesk',
               fontSize: 19.sp, // height: 1.6,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            if (filteredBeneficiaries.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: IconButton(
                  onPressed: () {
                    appRouter.pushNamed(
                      AppRoute.addRecipientsView,
                      arguments: widget.selectedData,
                    );
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/svgs/user-plus.svg",
                    width: 24.w,
                    height: 24.w,
                    color: Theme.of(context).colorScheme.onSurface,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  tooltip: 'Add beneficiary',
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _loadBeneficiaries();
          },
          child: Padding(
            padding: EdgeInsetsGeometry.only(bottom: 0.h),
            child:
                recipientsState.isLoading && filteredBeneficiaries.isEmpty
                    ? Padding(
                      padding: EdgeInsets.all(16.w),
                      child: ShimmerWidgets.recipientListShimmer(
                        context,
                        itemCount: 8,
                      ),
                    )
                    : recipientsState.errorMessage != null &&
                        filteredBeneficiaries.isEmpty
                    ? ErrorStateWidget(
                      message: 'Failed to load Beneficiaries',
                      details: recipientsState.errorMessage,
                      onRetry: _loadBeneficiaries,
                    )
                    : filteredBeneficiaries.isEmpty
                    ? _buildEmptyState(
                      targetCountry,
                      targetCurrency,
                      widget.selectedData['recipientDeliveryMethod'] ??
                          'Bank Transfer',
                    )
                    : ListView(
                      children: [
                        // Search Bar
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                          child: CustomTextField(
                            controller: _searchController,
                            label: '',
                            hintText: 'Search...',
                            borderRadius: 40,
                            prefixIcon: Container(
                              width: 40.w,
                              alignment: Alignment.centerRight,
                              constraints: BoxConstraints.tightForFinite(),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/svgs/search-normal.svg',
                                  height: 22.sp,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              _searchDebouncer.run(() {
                                setState(() {}); // Trigger rebuild to update filtered list
                              });
                            },
                          ),
                        ),

                        // Beneficiaries List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: 24.w,
                            right: 24.w,
                            bottom: 112.h,
                          ),
                          itemCount: filteredBeneficiaries.length,
                          itemBuilder: (context, index) {
                            final beneficiary = filteredBeneficiaries[index];
                            return _buildRecipientCard(
                              beneficiary,
                              bottomMargin:
                                  index == filteredBeneficiaries.length - 1
                                      ? 8
                                      : 24,
                            );
                          },
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String country, String currency, String channelType) {
    // Get full country name
    final countryName = _getCountryName(country);
    final displayChannelType = _getChannelDisplayName(channelType);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16.h),

            // Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 56.w),
              child: Text(
                'You do not have any Beneficiaries yet for $countryName in $currency and $displayChannelType',
                style: AppTypography.bodyLarge.copyWith(
               fontFamily: 'CabinetGrotesk',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  height: 1.4,
                  letterSpacing: -.4,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 56.h),

            // Create Beneficiaries Button
            PrimaryButton(
              borderRadius: 38,
              text: 'Create Beneficiaries',
              onPressed: () {
                appRouter.pushNamed(
                  AppRoute.addRecipientsView,
                  arguments: widget.selectedData,
                );
              },
              backgroundColor: AppColors.purple500,
              height: 48.000.h,
              textColor: AppColors.neutral0,
              fontFamily: 'Karla',
              letterSpacing: -.8,
              fontSize: 18,
              width: double.infinity,
              fullWidth: true,
            ),

            SizedBox(height: 56.h),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientCard(
    BeneficiaryWithSource beneficiaryWithSource, {
    double bottomMargin = 2,
  }) {
    final beneficiary = beneficiaryWithSource.beneficiary;
    final source = beneficiaryWithSource.source;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h, top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral500.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                margin: EdgeInsets.only(bottom: 4.w, right: 4.w),
                decoration: BoxDecoration(
                  color: AppColors.purple500ForTheme(context),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(beneficiary.name),
                    style: TextStyle(
                      color: AppColors.neutral0,
                      fontFamily: 'Karla',
                      fontSize: 16.sp,
                      letterSpacing: -.3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: AppColors.neutral0,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neutral200, width: 1),
                  ),
                  child: ClipOval(
                    child: SvgPicture.asset(
                      _getFlagPath(beneficiary.country),
                      fit: BoxFit.cover,
                      width: 24.w,
                      height: 24.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),

          // Beneficiary Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beneficiary.name.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 18.sp,
                    letterSpacing: -.3,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Row(
                  children: [
                    _getAccountIcon(source),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        '${_getChannelAndNetworkInfo(beneficiaryWithSource)} • ${_getAccountNumber(source)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -.3,
                          height: 1.450,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Select Button
          PrimaryButton(
            text: 'Select',
            onPressed: () => _selectBeneficiary(beneficiaryWithSource),
            height: 32.h,
            width: 80.w,
            backgroundColor: AppColors.purple500,
            textColor: AppColors.neutral0,
            fontFamily: 'Karla',
            fontSize: 14.sp,
            borderRadius: 20.r,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    // Normalize and split on one-or-more whitespace, then remove empties
    final words =
        name.trim().split(RegExp(r"\s+")).where((w) => w.isNotEmpty).toList();

    if (words.isEmpty) return '?';

    // Single word: return its first letter
    if (words.length == 1) {
      final w = words[0];
      if (w.isEmpty) return '?';
      return w[0].toUpperCase();
    }

    // Multiple words: use first letter of first and last word
    final first = words.first;
    final last = words.last;
    final firstChar = first.isNotEmpty ? first[0] : '';
    final lastChar = last.isNotEmpty ? last[0] : '';

    final initials = (firstChar + lastChar).toUpperCase();
    return initials.isEmpty ? '?' : initials;
  }

  // Helper function to get flag SVG path from country code
  String _getFlagPath(String? countryCode) {
    switch (countryCode?.toUpperCase()) {
      case 'NG':
        return 'assets/icons/svgs/world_flags/nigeria.svg';
      case 'GH':
        return 'assets/icons/svgs/world_flags/ghana.svg';
      case 'RW':
        return 'assets/icons/svgs/world_flags/rwanda.svg';
      case 'KE':
        return 'assets/icons/svgs/world_flags/kenya.svg';
      case 'UG':
        return 'assets/icons/svgs/world_flags/uganda.svg';
      case 'TZ':
        return 'assets/icons/svgs/world_flags/tanzania.svg';
      case 'ZA':
        return 'assets/icons/svgs/world_flags/south africa.svg';
      case 'BF':
        return 'assets/icons/svgs/world_flags/burkina faso.svg';
      case 'BJ':
        return 'assets/icons/svgs/world_flags/benin.svg';
      case 'BW':
        return 'assets/icons/svgs/world_flags/botswana.svg';
      case 'CD':
        return 'assets/icons/svgs/world_flags/democratic republic of congo.svg';
      case 'CG':
        return 'assets/icons/svgs/world_flags/republic of the congo.svg';
      case 'CI':
        return 'assets/icons/svgs/world_flags/ivory coast.svg';
      case 'CM':
        return 'assets/icons/svgs/world_flags/cameroon.svg';
      case 'GA':
        return 'assets/icons/svgs/world_flags/gabon.svg';
      case 'MW':
        return 'assets/icons/svgs/world_flags/malawi.svg';
      case 'SN':
        return 'assets/icons/svgs/world_flags/senegal.svg';
      case 'TG':
        return 'assets/icons/svgs/world_flags/togo.svg';
      case 'ZM':
        return 'assets/icons/svgs/world_flags/zambia.svg';
      case 'US':
        return 'assets/icons/svgs/world_flags/united states.svg';
      case 'GB':
        return 'assets/icons/svgs/world_flags/united kingdom.svg';
      case 'CA':
        return 'assets/icons/svgs/world_flags/canada.svg';
      default:
        return 'assets/icons/svgs/world_flags/nigeria.svg'; // fallback
    }
  }

  String _getAccountNumber(payment.Source source) {
    if (source.accountNumber != null && source.accountNumber!.isNotEmpty) {
      return source.accountNumber!;
    } else {
      return 'N/A';
    }
  }

  Widget _getAccountIcon(payment.Source source) {
    final accountType = source.accountType?.toLowerCase() ?? '';
    String overlayIcon;
    switch (accountType) {
      case 'bank':
        overlayIcon = 'assets/icons/svgs/building-bank.svg';
        break;
      case 'phone':
      case 'mobile':
      case 'mobile_money':
      case 'momo':
        overlayIcon = 'assets/icons/svgs/device-mobile.svg';
        break;
      case 'crypto':
        overlayIcon = 'assets/icons/svgs/currency-dollar.svg';
        break;
      case 'card':
        overlayIcon = 'assets/icons/svgs/carddd.svg';
        break;
      default:
        overlayIcon = 'assets/icons/svgs/paymentt.svg';
    }

    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.r)),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svgs/swap.svg',
            height: 22,
            color: AppColors.neutral700.withOpacity(.35),
          ),
          SvgPicture.asset(
            overlayIcon,
            height: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.65),
          ),
        ],
      ),
    );
  }

  String _getChannelAndNetworkInfo(
    BeneficiaryWithSource beneficiaryWithSource,
  ) {
    final source = beneficiaryWithSource.source;

    try {
      final sendState = ref.watch(sendViewModelProvider);
      final networkId = source.networkId;

      if (networkId == null || networkId.isEmpty) {
        return 'Bank Transfer';
      }

      // If networks are empty, try to trigger a refresh
      if (sendState.networks.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(sendViewModelProvider.notifier).initialize();
        });
        return 'Bank Transfer';
      }

      final network = sendState.networks.firstWhere(
        (n) => n.id == networkId,
        orElse: () => payment.Network(id: null, name: null),
      );

      if (network.id == null) {
        return 'Bank Transfer';
      }

      return network.name ?? 'Bank Transfer';
    } catch (e) {
      return 'Bank Transfer';
    }
  }

  void _selectBeneficiary(BeneficiaryWithSource beneficiaryWithSource) {
    final beneficiary = beneficiaryWithSource.beneficiary;
    final source = beneficiaryWithSource.source;

    // Get user profile data for sender information
    final profileState = ref.read(profileViewModelProvider);
    final user = profileState.user;

    // Create sender data from user profile
    final senderData = {
      'name':
          user != null ? '${user.firstName} ${user.lastName}'.trim() : 'User',
      'country': user?.country ?? 'NG',
      'phone': user?.phoneNumber ?? '+2340000000000',
      'address': user?.address ?? 'Not provided',
      'dob': user?.dateOfBirth ?? '1990-01-01',
      'email': user?.email ?? 'user@example.com',
      'idNumber': user?.idNumber ?? 'A12345678',
      'idType': user?.idType ?? 'passport',
    };

    // Create recipient data from selected beneficiary
    final recipientData = {
      'name': beneficiary.name,
      'country': beneficiary.country,
      'phone': beneficiary.phone,
      'address': beneficiary.address,
      'dob': beneficiary.dob,
      'email': beneficiary.email,
      'accountNumber': source.accountNumber ?? '',
      'networkId': source.networkId ?? '',
    };

    // Navigate to review screen
    appRouter.pushNamed(
      AppRoute.sendReviewView,
      arguments: {
        'selectedData': widget.selectedData,
        'recipientData': recipientData,
        'senderData': senderData,
      },
    );
  }
}
