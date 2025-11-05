import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/features/send/views/send_view.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/utils/app_logger.dart';

class RecipientsView extends ConsumerStatefulWidget {
  const RecipientsView({super.key});

  @override
  ConsumerState<RecipientsView> createState() => _RecipientsViewState();
}

class _RecipientsViewState extends ConsumerState<RecipientsView>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipientsProvider.notifier).loadBeneficiaries();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh Beneficiaries when app comes back to foreground
      _refreshRecipients();
    }
  }

  void _refreshRecipients() {
    ref.read(recipientsProvider.notifier).loadBeneficiaries();
  }

  @override
  Widget build(BuildContext context) {
    final recipientsState = ref.watch(recipientsProvider);
    final profileState = ref.watch(profileViewModelProvider);
    final user = profileState.user;

    // Build multiple name variations for comparison
    Set<String> userNames = {};
    if (user != null) {
      final firstName = user.firstName.trim().toLowerCase();
      final middleName = user.middleName?.trim().toLowerCase();
      final lastName = user.lastName.trim().toLowerCase();
      
      // Add different name combinations
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        userNames.add('$firstName $lastName');
        userNames.add('${firstName}${lastName}');
        userNames.add('$firstName $lastName'.trim());
      }
      
      if (middleName != null && middleName.isNotEmpty) {
        if (firstName.isNotEmpty && lastName.isNotEmpty) {
          userNames.add('$firstName $middleName $lastName');
          userNames.add('$firstName $middleName$lastName');
          userNames.add('${firstName}${middleName}${lastName}');
        }
      }
      
      // Also add the userName from profileState (which includes middle name)
      final userName = profileState.userName.toLowerCase().trim();
      if (userName.isNotEmpty && userName != 'loading...') {
        userNames.add(userName);
        // Add without spaces
        userNames.add(userName.replaceAll(' ', ''));
      }
    }

    // Filter out beneficiaries whose name matches any variation of the user's name
    final visibleBeneficiaries = recipientsState.filteredBeneficiaries
        .where((beneficiary) {
          if (userNames.isEmpty) return true; // Show all if no user data
          
          final beneficiaryName = beneficiary.beneficiary.name.toLowerCase().trim();
          final beneficiaryNameNoSpaces = beneficiaryName.replaceAll(' ', '').replaceAll('-', '');
          
          // Check against all name variations
          for (final userName in userNames) {
            final userNameNoSpaces = userName.replaceAll(' ', '').replaceAll('-', '');
            
            // Exact match (with or without spaces)
            if (beneficiaryName == userName || 
                beneficiaryNameNoSpaces == userNameNoSpaces) {
              AppLogger.debug('Filtering out beneficiary: ${beneficiaryName} matches user: $userName');
              return false; // Hide this beneficiary
            }
            
            // Check if names are similar (handles minor variations)
            // Normalize both names for comparison
            final normalizedBeneficiary = beneficiaryNameNoSpaces;
            final normalizedUser = userNameNoSpaces;
            
            if (normalizedBeneficiary == normalizedUser ||
                normalizedBeneficiary.contains(normalizedUser) ||
                normalizedUser.contains(normalizedBeneficiary)) {
              // Additional check: if lengths are similar, it's likely a match
              final lengthDiff = (normalizedBeneficiary.length - normalizedUser.length).abs();
              if (lengthDiff <= 2) { // Allow 2 character difference
                AppLogger.debug('Filtering out beneficiary: ${beneficiaryName} matches user: $userName (similar)');
                return false; // Hide this beneficiary
              }
            }
          }
          
          return true; // Show this beneficiary
        })
        .toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: const SizedBox.shrink(),

          automaticallyImplyLeading: false,
          title: Text(
            "Beneficiaries",
            style: AppTypography.titleLarge.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          // actions: [
          //   Padding(
          //     padding: EdgeInsets.only(right: 16.w),
          //     child: IconButton(
          //       onPressed: () {
          //         appRouter.pushNamed(
          //           AppRoute.addRecipientsView,
          //           arguments: <String, dynamic>{},
          //         );
          //       },
          //       icon: SvgPicture.asset(
          //         "assets/icons/svgs/user-plus.svg",
          //         width: 24.w,
          //         height: 24.w,
          //         color: Theme.of(context).colorScheme.onSurface,
          //         colorFilter: ColorFilter.mode(
          //           Theme.of(context).colorScheme.onSurface,
          //           BlendMode.srcIn,
          //         ),
          //       ),
          //       tooltip: 'Add beneficiary',
          //       style: IconButton.styleFrom(
          //         padding: EdgeInsets.zero,
          //         minimumSize: Size.zero,
          //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //       ),
          //     ),
          //   ),
          //   SizedBox(width: 16.w),
          // ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _refreshRecipients();
          },
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                child: CustomTextField(
                  controller: _searchController,
                  label: '',
                  hintText: 'Search...',
                  borderRadius: 40,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    size: 20.sp,
                  ),
                  onChanged: (value) {
                    ref
                        .read(recipientsProvider.notifier)
                        .searchBeneficiaries(value);
                  },
                ),
              ),

              // Beneficiaries List
              Expanded(
                child: Padding(
                  padding: EdgeInsetsGeometry.only(bottom: 0.h),
                  child:
                      recipientsState.isLoading
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LoadingAnimationWidget.horizontalRotatingDots(
                                  color: AppColors.purple500ForTheme(context),
                                  size: 20,
                                ),
                                SizedBox(height: 40.h),
                              ],
                            ),
                          )
                          : recipientsState.errorMessage != null
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon(
                                //   Icons.error_outline,
                                //   size: 48.sp,
                                //   color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                // ),
                                // SizedBox(height: 16.h),
                                Text(
                                  'Failed to load Beneficiaries',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    fontFamily: 'CabinetGrotesk',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18.sp,
                                    height: 1.4,
                                    letterSpacing: -.4,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  recipientsState.errorMessage!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Karla',
                                    letterSpacing: -.6,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 40.h),
                              ],
                            ),
                          )
                          : visibleBeneficiaries.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon(
                                //   Icons.person_outline,
                                //   size: 48.sp,
                                //   color: Theme.of(
                                //     context,
                                //   ).colorScheme.onSurface.withOpacity(0.6),
                                // ),
                                Text(
                                  'No Beneficiaries found',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    fontFamily: 'CabinetGrotesk',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18.sp,
                                    height: 1.4,
                                    letterSpacing: -.4,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 40.h),
                              ],
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.only(
                              left: 24.w,
                              right: 24.w,
                              bottom: 112.h,
                            ),
                            itemCount: visibleBeneficiaries.length,
                            itemBuilder: (context, index) {
                              final beneficiary = visibleBeneficiaries[index];
                              return _buildRecipientCard(
                                beneficiary,
                                bottomMargin:
                                    index == visibleBeneficiaries.length - 1
                                        ? 8
                                        : 24,
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientCard(
    BeneficiaryWithSource beneficiaryWithSource, {
    double bottomMargin = 8,
  }) {
    final beneficiary = beneficiaryWithSource.beneficiary;
    final source = beneficiaryWithSource.source;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h, top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
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
                      letterSpacing: -.6,
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
          SizedBox(width: 8.w),

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
                    letterSpacing: -.6,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                // SizedBox(height: 4.h),
                // Text(
                //   '${_getAccountType(beneficiary)} - ${_getAccountNumber(beneficiary)}',
                //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                //     fontFamily: 'Karla',
                //     fontSize: 14.sp,
                //     fontWeight: FontWeight.w400,
                //     letterSpacing: -.6,
                //     height: 1.450,
                //     color: Theme.of(
                //       context,
                //     ).colorScheme.onSurface.withOpacity(0.6),
                //   ),
                // ),
                if (beneficiary.country.isNotEmpty) ...[
                  // SizedBox(height: 6.h),
                  Text(
                    '${_getChannelAndNetworkInfo(beneficiaryWithSource)} • ${_getAccountNumber(source)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -.6,
                      height: 1.450,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Send Button
          // PrimaryButton(
          //   text: 'Send',
          //   onPressed: () => _navigateToSend(beneficiaryWithSource),
          //   height: 32.h,
          //   width: 68.w,
          //   backgroundColor: AppColors.purple500ForTheme(context),
          //   textColor: AppColors.neutral0,
          //   fontFamily: 'Karla',
          //   fontSize: 14.sp,
          //   borderRadius: 20.r,
          //   fontWeight: FontWeight.w400,
          // ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
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
    // Use actual account number from source data
    if (source.accountNumber != null && source.accountNumber!.isNotEmpty) {
      return source.accountNumber!;
    } else {
      return 'N/A';
    }
  }

  String _getChannelAndNetworkInfo(
    BeneficiaryWithSource beneficiaryWithSource,
  ) {
    final beneficiary = beneficiaryWithSource.beneficiary;
    final source = beneficiaryWithSource.source;

    try {
      final sendState = ref.watch(sendViewModelProvider);
      final networkId = source.networkId;

      if (networkId == null || networkId.isEmpty) {
        print('❌ No network ID found for beneficiary: ${beneficiary.name}');
        return 'Unknown Network';
      }

      // Debug logging
      print('🔍 Looking for network ID: $networkId');
      print('📊 Available networks count: ${sendState.networks.length}');
      print(
        '📋 Available network IDs: ${sendState.networks.map((n) => n.id).join(", ")}',
      );

      // If networks are empty, try to trigger a refresh
      if (sendState.networks.isEmpty) {
        print('⚠️ No networks loaded, triggering refresh...');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(sendViewModelProvider.notifier).initialize();
        });
        return 'Loading...';
      }

      final network = sendState.networks.firstWhere(
        (n) => n.id == networkId,
        orElse: () => payment.Network(id: null, name: null),
      );

      if (network.id == null) {
        print('❌ Network not found for ID: $networkId');
        return 'Unknown Network';
      }

      print('✅ Found network: ${network.name} for ID: $networkId');
      return network.name ?? 'Unknown Network';
    } catch (e) {
      print('❌ Error getting network name: $e');
      return 'Unknown Network';
    }
  }

  /// Get simplified delivery method type (just the main category)
  String _getDeliveryMethodType(String? method) {
    if (method == null || method.isEmpty) {
      return 'Unknown Method';
    }

    switch (method.toLowerCase()) {
      case 'bank_transfer':
      case 'bank':
      case 'p2p':
      case 'peer_to_peer':
      case 'peer-to-peer':
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
        return 'Crypto';
      default:
        return method
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  void _navigateToSend(BeneficiaryWithSource beneficiaryWithSource) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SendView()),
    );
  }
}
