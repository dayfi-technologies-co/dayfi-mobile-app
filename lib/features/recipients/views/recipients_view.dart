import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/common/widgets/error_state_widget.dart';
import 'package:dayfi/common/widgets/empty_state_widget.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/utils/debouncer.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/models/wallet_transaction.dart' show Beneficiary;
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/app_locator.dart';

class RecipientsView extends ConsumerStatefulWidget {
  final bool fromProfile;
  final bool fromSendView;

  const RecipientsView({
    super.key,
    this.fromProfile = false,
    this.fromSendView = false,
  });

  @override
  ConsumerState<RecipientsView> createState() => _RecipientsViewState();
}

class _RecipientsViewState extends ConsumerState<RecipientsView>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final _searchDebouncer = SearchDebouncer(milliseconds: 300);
  bool _hasNavigatedToAdd = false;
  int _initialBeneficiaryCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recipientsProvider.notifier)
          .loadBeneficiaries(isInitialLoad: true);
      // Store initial count if coming from profile
      if (widget.fromProfile) {
        final currentState = ref.read(recipientsProvider);
        _initialBeneficiaryCount = currentState.beneficiaries.length;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh Beneficiaries when app comes back to foreground
      _refreshRecipients();

      // Check if we came from profile and a beneficiary was created
      if (widget.fromProfile && _hasNavigatedToAdd) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndNavigateBack();
        });
      }
    }
  }

  Future<void> _checkAndNavigateBack() async {
    // Wait a bit more for the API call to complete
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final currentState = ref.read(recipientsProvider);
    final currentCount = currentState.beneficiaries.length;

    // If beneficiary count increased, it means one was created
    if (currentCount > _initialBeneficiaryCount) {
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Beneficiary created successfully!',
          isError: false,
        );

        // Navigate back to profile after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  void _refreshRecipients() {
    HapticHelper.lightImpact();
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
        userNames.add('$firstName$lastName');
        userNames.add('$firstName $lastName'.trim());
      }

      if (middleName != null && middleName.isNotEmpty) {
        if (firstName.isNotEmpty && lastName.isNotEmpty) {
          userNames.add('$firstName $middleName $lastName');
          userNames.add('$firstName $middleName$lastName');
          userNames.add('$firstName$middleName$lastName');
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

    // Filter out duplicates while showing all beneficiaries
    // TODO: Re-enable self-name filtering if needed (currently commented to show all beneficiaries)
    // final visibleBeneficiaries =
    //     recipientsState.filteredBeneficiaries.where((beneficiary) {
    //       if (userNames.isEmpty) return true; // Show all if no user data
    //
    //       final beneficiaryName =
    //           beneficiary.beneficiary.name.toLowerCase().trim();
    //       final beneficiaryNameNoSpaces = beneficiaryName
    //           .replaceAll(' ', '')
    //           .replaceAll('-', '');
    //
    //       // Check against all name variations
    //       for (final userName in userNames) {
    //         final userNameNoSpaces = userName
    //             .replaceAll(' ', '')
    //             .replaceAll('-', '');
    //
    //         // Exact match (with or without spaces)
    //         if (beneficiaryName == userName ||
    //             beneficiaryNameNoSpaces == userNameNoSpaces) {
    //           AppLogger.debug(
    //             'Filtering out beneficiary: $beneficiaryName matches user: $userName',
    //           );
    //           return false; // Hide this beneficiary
    //         }
    //
    //         // Check if names are similar (handles minor variations)
    //         // Normalize both names for comparison
    //         final normalizedBeneficiary = beneficiaryNameNoSpaces;
    //         final normalizedUser = userNameNoSpaces;
    //
    //         if (normalizedBeneficiary == normalizedUser ||
    //             normalizedBeneficiary.contains(normalizedUser) ||
    //             normalizedUser.contains(normalizedBeneficiary)) {
    //           // Additional check: if lengths are similar, it's likely a match
    //           final lengthDiff =
    //               (normalizedBeneficiary.length - normalizedUser.length).abs();
    //           if (lengthDiff <= 2) {
    //             // Allow 2 character difference
    //             AppLogger.debug(
    //               'Filtering out beneficiary: $beneficiaryName matches user: $userName (similar)',
    //             );
    //             return false; // Hide this beneficiary
    //           }
    //         }
    //       }
    //
    //       return true; // Show this beneficiary
    //     }).toList();

    // Remove duplicate beneficiaries based on account number and filter out empty names
    final seenAccountNumbers = <String>{};
    final visibleBeneficiaries =
        recipientsState.filteredBeneficiaries.where((beneficiary) {
          // Skip if beneficiary name is empty or whitespace only
          if (beneficiary.beneficiary.name.trim().isEmpty) {
            return false;
          }

          // Create a unique key combining source account number and beneficiary account number (DayFi tag)
          final sourceAccountNumber = beneficiary.source.accountNumber ?? '';
          final beneficiaryAccountNumber = beneficiary.beneficiary.accountNumber ?? '';
          
          // For DayFi tags, use the beneficiary's account number as the unique identifier
          final uniqueKey = beneficiary.source.accountType?.toLowerCase() == 'dayfi'
              ? 'dayfi_${beneficiaryAccountNumber.toLowerCase()}'
              : 'other_${sourceAccountNumber}';
          
          if (seenAccountNumbers.contains(uniqueKey)) {
            return false; // Skip duplicate
          }
          seenAccountNumbers.add(uniqueKey);
          return true;
        }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading:
              widget.fromSendView
                  ? IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).colorScheme.onSurface,
                      // size: 20.sp,
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                  : const SizedBox.shrink(),
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
          actions:
              widget.fromSendView
                  ? [
                    Padding(
                      padding: EdgeInsets.only(right: 0.w),
                      child: IconButton(
                        onPressed: () async {
                          if (widget.fromProfile) {
                            _hasNavigatedToAdd = true;
                          }
                          await Navigator.pushNamed(
                            context,
                            AppRoute.addRecipientsView,
                            arguments: <String, dynamic>{
                              'fromProfile': widget.fromProfile,
                            },
                          );

                          // Refresh beneficiaries list when returning
                          _refreshRecipients();

                          // If coming from profile, check if beneficiary was created
                          if (widget.fromProfile && _hasNavigatedToAdd) {
                            // Wait a bit for the list to refresh
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );
                            _checkAndNavigateBack();
                          }
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
                    SizedBox(width: 16.w),
                  ]
                  : [],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _refreshRecipients();
          },
          child: Padding(
            padding: EdgeInsetsGeometry.only(bottom: 0.h),
            child:
                recipientsState.isLoading && visibleBeneficiaries.isEmpty
                    ? ShimmerWidgets.recipientListShimmer(context, itemCount: 6)
                    : recipientsState.errorMessage != null &&
                        visibleBeneficiaries.isEmpty
                    ? ErrorStateWidget(
                      message: 'Failed to load Beneficiaries',
                      details: recipientsState.errorMessage,
                      onRetry: _refreshRecipients,
                    )
                    : visibleBeneficiaries.isEmpty
                    ? EmptyStateWidget(
                      icon: Icons.people_outline,
                      title: 'No beneficiaries yet',
                      message:
                          'Your beneficiaries will appear here. Start sending money quickly',
                      customButton: _buildActionButtonWidget(
                        context,
                        'Send Money',
                        'assets/icons/svgs/swap.svg',
                        () {
                          appRouter.pushNamed(
                            AppRoute.selectDestinationCountryView,
                          );
                        },
                      ),
                    )
                    : ListView(
                      children: [
                        // Search Bar
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 8.h,
                          ),
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
                                ref
                                    .read(recipientsProvider.notifier)
                                    .searchBeneficiaries(value);
                              });
                            },
                          ),
                        ),

                        // Beneficiaries List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: 18.w,
                            right: 18.w,
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
                      ],
                    ),
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
                    letterSpacing: -.3,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Row(
                  children: [
                    _getAccountIcon(source, beneficiary),
                    // SizedBox(width: 2.w),
                    Expanded(
                      child:
                          _getChannelAndNetworkInfo(beneficiaryWithSource) ==
                                  "DayFi Tag"
                              ? Row(
                                children: [
                                  Text(
                                    _getAccountNumber(
                                      source,
                                      beneficiary,
                                    ).split("@").last,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
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
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 3.h,
                                      horizontal: 8.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning400.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Icon(
                                        //   Icons.auto_awesome,
                                        //   size: 10.sp,
                                        //   color: Color(0xFF1A1A1A),
                                        // ),
                                        // SizedBox(width: 4.w),
                                        Text(
                                          "Dayfi Tag",
                                          style: TextStyle(
                                            fontFamily: 'Karla',
                                            fontSize: 10.sp,
                                          color: AppColors.warning600,
                                            fontWeight: FontWeight.w600,
                                            // letterSpacing: 0,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                              : Text(
                                '  ${_getChannelAndNetworkInfo(beneficiaryWithSource)} • ${_getAccountNumber(source, beneficiary)}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
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
          // Send Button
          PrimaryButton(
            text: 'Send',
            onPressed: () => _navigateToSend(beneficiaryWithSource),
            height: 32.h,
            width: 68.w,
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

  String _getAccountNumber(payment.Source source, Beneficiary beneficiary) {
    // For DayFi transfers, use beneficiary.accountNumber (the DayFi tag)
    if (source.accountType?.toLowerCase() == 'dayfi' &&
        beneficiary.accountNumber != null &&
        beneficiary.accountNumber!.isNotEmpty) {
      return '@${beneficiary.accountNumber!}';
    }

    // For other transfers, use source.accountNumber
    if (source.accountNumber != null && source.accountNumber!.isNotEmpty) {
      return source.accountNumber!;
    }

    return 'N/A';
  }

  Widget _getAccountIcon(payment.Source source, Beneficiary beneficiary) {
    final accountType = source.accountType?.toLowerCase() ?? '';
    String overlayIcon;
    switch (accountType) {
      case 'dayfi':
        overlayIcon = 'assets/icons/svgs/at.svg';
        break;
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

    // For DayFi transfers, return "DayFi Tag"
    if (source.accountType?.toLowerCase() == 'dayfi') {
      return 'DayFi Tag';
    }

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

  void _navigateToSend(BeneficiaryWithSource beneficiaryWithSource) {
    // Debug log the beneficiary data being passed
    print('📤 Navigating to send with beneficiary:');
    print('   Name: ${beneficiaryWithSource.beneficiary.name}');
    print('   Account Type: ${beneficiaryWithSource.source.accountType}');
    print('   Account Number: ${beneficiaryWithSource.source.accountNumber}');
    print('   Network ID: ${beneficiaryWithSource.source.networkId}');

    // Navigate to send_view with beneficiary data
    // The send_view will handle routing to the appropriate review screen
    // based on beneficiary type (DayFi tag vs bank/mobile money)
    Navigator.pushNamed(
      context,
      AppRoute.sendView,
      arguments: <String, dynamic>{
        'beneficiaryWithSource': beneficiaryWithSource,
        'fromRecipients': true,
      },
    );
  }

  Widget _buildActionButtonWidget(
    BuildContext context,
    String label,
    String iconAsset,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 0,
              spreadRadius: 0,
              color: Color(0xFFFFC700).withOpacity(.5),
              offset: Offset(0, 2.5),
            ),

          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(48.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 32.w,
              height: 32.w,
              child: Stack(
                alignment: Alignment.center,
                children: [Center(child: SvgPicture.asset(iconAsset))],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: AppTypography.medium,
                height: 1.5,
                fontFamily: 'Karla',
                letterSpacing: -.8,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
