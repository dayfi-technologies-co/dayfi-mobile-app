import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/common/utils/platform_date_picker.dart';
import 'package:dayfi/common/utils/phone_country_utils.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
// ignore: depend_on_referenced_packages
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/routes/route.dart';

class SendAddRecipientsView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;

  const SendAddRecipientsView({super.key, required this.selectedData});

  @override
  ConsumerState<SendAddRecipientsView> createState() =>
      _SendAddRecipientsViewState();
}

class _SendAddRecipientsViewState extends ConsumerState<SendAddRecipientsView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _networkController = TextEditingController();

  String _selectedCountry = '';
  String _selectedChannelId = ''; // This is the channel ID from selectedData
  String _selectedNetworkId = ''; // This will be the selected network's ID

  // Network state
  List<Network> _allNetworks = [];
  List<Network> _filteredNetworks = [];
  List<Network> _searchedNetworks = [];
  Network? _selectedNetwork;
  bool _isLoadingNetworks = false;
  String? _networkError;
  final _networkSearchController = TextEditingController();

  // Account resolution state
  bool _isResolving = false;
  String? _resolveError;
  String? _resolvedAccountName;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedData['receiveCountry'] ?? '';
    _selectedChannelId =
        widget.selectedData['networkId'] ??
        ''; // This is actually the channel ID

    print('🚀 SendAddRecipientsView initialized');
    print('🌍 Selected country: $_selectedCountry');
    print('🔗 Selected channel ID: $_selectedChannelId');
    print('📋 Full selectedData: ${widget.selectedData}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      analyticsService.trackScreenView(screenName: 'SendAddRecipientsView');
      _fetchNetworks();
    });

    // Add listener to account number field for auto-resolution
    _accountNumberController.addListener(_onAccountNumberChanged);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _accountNumberController.dispose();
    _networkController.dispose();
    _networkSearchController.dispose();
    super.dispose();
  }

  /// Fetch available networks from the API
  Future<void> _fetchNetworks() async {
    setState(() {
      _isLoadingNetworks = true;
      _networkError = null;
    });

    try {
      final paymentService = locator<PaymentService>();
      final response = await paymentService.fetchNetworks();

      if (response.statusCode == 200 && response.data?.networks != null) {
        setState(() {
          _allNetworks = response.data!.networks!;
          _filterNetworks();
        });
      } else {
        setState(() {
          _networkError =
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to load networks';
        });
      }
    } catch (e) {
      setState(() {
        _networkError = 'Error loading networks: $e';
      });
    } finally {
      setState(() {
        _isLoadingNetworks = false;
      });
    }
  }

  /// Filter networks based on selected channel ID
  void _filterNetworks() {
    if (_allNetworks.isEmpty || _selectedChannelId.isEmpty) return;

    print('🔍 Filtering networks for channel ID: $_selectedChannelId');
    print('📊 Total networks available: ${_allNetworks.length}');

    // Filter networks by channel ID - networks that support the selected channel
    final channelNetworks =
        _allNetworks.where((network) {
          final hasChannelId =
              network.channelIds?.contains(_selectedChannelId) == true;
          if (hasChannelId) {
            print(
              '✅ Network "${network.name}" supports channel $_selectedChannelId',
            );
          }
          return network.status == 'active' && hasChannelId;
        }).toList();

    print('🎯 Filtered networks count: ${channelNetworks.length}');

    // Sort networks alphabetically by name
    channelNetworks.sort((a, b) {
      final nameA = a.name ?? '';
      final nameB = b.name ?? '';
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    setState(() {
      _filteredNetworks = channelNetworks;
      _searchedNetworks = _filteredNetworks; // Initialize searched networks

      // Don't auto-select - let user make the choice
      // This prevents the first item from appearing selected in the bottom sheet
      print(
        '🎯 Available networks: ${_filteredNetworks.map((n) => n.name).join(", ")}',
      );
    });
  }

  /// Filter networks based on search query
  void _filterNetworksBySearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchedNetworks = _filteredNetworks;
      });
      return;
    }

    final filtered =
        _filteredNetworks.where((network) {
          final name = network.name?.toLowerCase() ?? '';
          final accountType = network.accountNumberType?.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();

          return name.contains(searchQuery) ||
              accountType.contains(searchQuery);
        }).toList();

    // Sort filtered results alphabetically by name
    filtered.sort((a, b) {
      final nameA = a.name ?? '';
      final nameB = b.name ?? '';
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    setState(() {
      _searchedNetworks = filtered;
    });
  }

  /// Handle network selection change
  void _onNetworkChanged(Network? network) {
    setState(() {
      _selectedNetwork = network;
      _selectedNetworkId = network?.id ?? '';

      // Update the network controller text
      if (network != null) {
        _networkController.text = network.name ?? 'Unknown Network';
      } else {
        _networkController.text = '';
      }

      // Clear previous account resolution when network changes
      _resolvedAccountName = null;
      _resolveError = null;
    });

    // If there's a valid account number entered, try to resolve it with the new network
    final accountNumber = _accountNumberController.text.trim();
    if (accountNumber.length == 10 &&
        RegExp(r'^\d{10}$').hasMatch(accountNumber) &&
        network != null) {
      _resolveAccount(accountNumber);
    }
  }

  String _formatPhoneNumber(String phone) {
    // Remove any spaces, dashes, or parentheses
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // If it already starts with +, return as is
    if (cleaned.startsWith('+')) {
      return cleaned;
    }

    // If it starts with 0, replace with +234 (Nigeria country code)
    if (cleaned.startsWith('0')) {
      return '+234${cleaned.substring(1)}';
    }

    // If it starts with 234, add + prefix
    if (cleaned.startsWith('234')) {
      return '+$cleaned';
    }

    // If it's a 10-digit number, assume it's Nigerian and add +234
    if (cleaned.length == 10 && RegExp(r'^\d{10}$').hasMatch(cleaned)) {
      return '+234$cleaned';
    }

    // If it's an 11-digit number starting with 1, assume it's Nigerian and add +234
    if (cleaned.length == 11 &&
        cleaned.startsWith('1') &&
        RegExp(r'^\d{11}$').hasMatch(cleaned)) {
      return '+234${cleaned.substring(1)}';
    }

    // Default fallback - add +234 prefix
    return '+234$cleaned';
  }

  void _onAccountNumberChanged() {
    final accountNumber = _accountNumberController.text.trim();

    // If account number is reduced below 10 digits, immediately clear everything
    if (accountNumber.length < 10) {
      setState(() {
        _resolveError = null;
        _resolvedAccountName = null;
        _isResolving = false; // Stop any ongoing resolution
      });
      return;
    }

    // Check if account number is exactly 10 digits AND network is selected
    if (accountNumber.length == 10 &&
        RegExp(r'^\d{10}$').hasMatch(accountNumber) &&
        _selectedNetwork != null &&
        _selectedNetworkId.isNotEmpty) {
      _resolveAccount(accountNumber);
    } else {
      // Clear resolved name if account number is not 10 digits or network not selected
      setState(() {
        _resolveError = null;
        _resolvedAccountName = null;
        _isResolving = false; // Stop any ongoing resolution
      });
    }
  }

  Future<void> _resolveAccount(String accountNumber) async {
    if (_isResolving) return; // Prevent multiple simultaneous calls

    // Ensure both network and account number are available
    if (_selectedNetwork == null || _selectedNetworkId.isEmpty) {
      setState(() {
        _resolveError = 'Please select a network first';
        _isResolving = false;
      });
      return;
    }

    setState(() {
      _isResolving = true;
      _resolveError = null;
    });

    try {
      final paymentService = locator<PaymentService>();
      final response = await paymentService.resolveBank(
        accountNumber: accountNumber,
        networkId: _selectedNetworkId,
      );

      // Check if the account number is still 10 digits after the API call
      // This prevents showing results for outdated account numbers
      if (_accountNumberController.text.trim().length != 10) {
        setState(() {
          _isResolving = false;
          _resolvedAccountName = null;
          _resolveError = null;
        });
        return;
      }

      if (response.statusCode == 200 && !response.error) {
        // Extract account name from PaymentData object
        final accountName =
            response.data?.accountName ?? 'Account Resolved Successfully';

        setState(() {
          _resolvedAccountName = accountName.toUpperCase();
          _resolveError = null;
        });
      } else {
        setState(() {
          _resolveError = response.message;
          _resolvedAccountName = null;
        });
      }
    } catch (e) {
      setState(() {
        _resolveError = 'Error resolving account: $e';
        log(_resolveError.toString());
        _resolvedAccountName = null;
      });
    } finally {
      setState(() {
        _isResolving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
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
                  // size: 20.sp,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Add Beneficiary',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontFamily: 'CabinetGrotesk',
                  fontSize: 20.sp,
                  // height: 1.6,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Network Selection Field
                    _buildNetworkSelectionField(),
                    if (_selectedNetwork == null) ...[
                      SizedBox(height: 8.h),
                      Center(
                        // padding: EdgeInsets.only(left: 16.w),
                        child: Text(
                          widget.selectedData['recipientDeliveryMethod'] ==
                                      'bank' ||
                                  widget.selectedData['recipientDeliveryMethod'] ==
                                      'p2p'
                              ? 'Please select a bank to enable account resolution'
                              : 'Please select a mobile money provider to enable account resolution',
                          style: AppTypography.bodySmall.copyWith(
                            fontFamily: 'Karla',
                            fontSize: 12.sp,
                            letterSpacing: -.3,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    SizedBox(height: 18.h),

                    // Account Number Field (Required)
                    CustomTextField(
                      controller: _accountNumberController,
                      label:
                          widget.selectedData['recipientDeliveryMethod'] ==
                                      'bank' ||
                                  widget.selectedData['recipientDeliveryMethod'] ==
                                      'p2p'
                              ? 'Account Number'
                              : 'Mobile Money Number',
                      hintText:
                          _selectedNetwork == null
                              ? widget.selectedData['recipientDeliveryMethod'] ==
                                          'bank' ||
                                      widget.selectedData['recipientDeliveryMethod'] ==
                                          'p2p'
                                  ? 'Select a bank first'
                                  : 'Select a mobile money provider first'
                              : widget.selectedData['recipientDeliveryMethod'] ==
                                      'bank' ||
                                  widget.selectedData['recipientDeliveryMethod'] ==
                                      'p2p'
                              ? 'Enter 10-digit account number'
                              : 'Enter mobile money number',
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      enabled: _selectedNetwork != null,
                      suffixIcon:
                          _isResolving
                              ? Container(
                                margin: EdgeInsets.all(12),
                                child:
                                    LoadingAnimationWidget.horizontalRotatingDots(
                                      color: AppColors.purple500ForTheme(
                                        context,
                                      ),
                                      size: 20,
                                    ),
                              )
                              : null,
                      validator: (value) {
                        if (_selectedNetwork == null) {
                          return 'Please select a network first';
                        }
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter account number';
                        }
                        if (value.trim().length != 10) {
                          return 'Account number must be exactly 10 digits';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                          return 'Account number must contain only digits';
                        }
                        return null;
                      },
                    ),

                    // Account resolution error display
                    if (_resolveError != null) ...[
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.error50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.error200,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.error600,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _resolveError!,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Karla',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Resolved Account Name Container (Green container showing resolved name)
                    if (_resolvedAccountName != null) ...[
                      SizedBox(height: 12.h),
                      Center(
                        child: Container(
                          // width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success700,
                            borderRadius: BorderRadius.circular(32.r),
                            // border: Border.all(color: AppColors.success200, width: 1.0),
                          ),
                          child: Text(
                            _resolvedAccountName!,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontFamily: 'CabinetGrotesk',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral0,
                              letterSpacing: 0.5,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 32.h),

                    // // Optional Fields Section
                    // Center(
                    //   child: Padding(
                    //     padding: EdgeInsets.symmetric(
                    //       vertical: 4.h,
                    //       horizontal: 2.w,
                    //     ),
                    //     child: Text(
                    //       'Additional Information',
                    //       style: Theme.of(
                    //         context,
                    //       ).textTheme.titleMedium?.copyWith(
                    //      fontFamily: 'CabinetGrotesk',
                    //         fontSize: 12.sp,
                    //         fontWeight: FontWeight.w600,
                    //         // color: AppColors.neutral900,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 18.h),

                    // // Phone Number (Optional)
                    // _buildPhoneNumberField(),

                    // SizedBox(height: 18.h),

                    // // Address (Optional)
                    // CustomTextField(
                    //   controller: _addressController,
                    //   label: 'Residential Address (Optional)',
                    //   keyboardType: TextInputType.streetAddress,
                    //   hintText: 'Enter address',
                    //   textCapitalization: TextCapitalization.words,
                    //   validator: (value) {
                    //     // No validation required for optional field
                    //     return null;
                    //   },
                    // ),

                    // SizedBox(height: 18.h),

                    // // Date of Birth (Optional)
                    // CustomTextField(
                    //   controller: _dobController,
                    //   label: 'Date of Birth (Optional)',
                    //   hintText: 'DD/MM/YYYY',
                    //   shouldReadOnly: true,
                    //   onTap: () => _selectDate(),
                    //   validator: (value) {
                    //     // No validation required for optional field
                    //     return null;
                    //   },
                    // ),

                    // SizedBox(height: 18.h),

                    // // Email Address (Optional)
                    // CustomTextField(
                    //   controller: _emailController,
                    //   label: 'Email Address (Optional)',
                    //   hintText: 'Enter email address',
                    //   keyboardType: TextInputType.emailAddress,
                    //   capitalizeFirstLetter: false,
                    //   textCapitalization: TextCapitalization.none,

                    //   validator: (value) {
                    //     if (value != null && value.trim().isNotEmpty) {
                    //       if (!RegExp(
                    //         r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    //       ).hasMatch(value)) {
                    //         return 'Please enter a valid email address';
                    //       }
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // SizedBox(height: 18.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(4.r),
                        // border: Border.all(
                        //   color: Theme.of(
                        //     context,
                        //   ).colorScheme.primary.withOpacity(0.3),
                        //   width: 1.0,
                        // ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 4.w),
                          Image.asset(
                            "assets/images/idea.png",
                            height: 20.h,
                            // color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              "By continuing with this payment you are confirming that, to the best of your knowledge, the details you are providing are correct.",
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                fontSize: 14.sp,
                                fontFamily: 'Karla',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.4,
                                height: 1.5,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 56.h),

                    // Continue Button
                    PrimaryButton(
                      text: 'Review Transfer',
                      onPressed: _validateAndContinue,
                      height: 48.000.h,
                      backgroundColor: AppColors.purple500,
                      textColor: AppColors.neutral0,
                      fontFamily: 'Karla',
                      letterSpacing: -.8,
                      fontSize: 18,
                      width: double.infinity,
                      fullWidth: true,
                      borderRadius: 40.r,
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ), // Loading overlay that freezes the screen during account resolution
        if (_isResolving)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: LoadingAnimationWidget.horizontalRotatingDots(
                color: AppColors.purple500ForTheme(context),
                size: 40,
              ),
            ),
          ),
      ],
    );
  }

  /// Build network selection field
  Widget _buildNetworkSelectionField() {
    return CustomTextField(
      controller: _networkController,
      label:
          widget.selectedData['recipientDeliveryMethod'] == 'bank' ||
                  widget.selectedData['recipientDeliveryMethod'] == 'p2p'
              ? 'Bank Name'
              : 'Mobile Money Provider',
      hintText: _getNetworkHintText(),
      shouldReadOnly: true,
      onTap: _filteredNetworks.isNotEmpty ? _showNetworkBottomSheet : null,
      suffixIcon: _buildNetworkSuffixIcon(),
      errorText: _networkError,
      validator: (value) {
        if (_selectedNetwork == null) {
          return 'Please select a network';
        }
        return null;
      },
    );
  }

  /// Get the hint text based on current state
  String _getNetworkHintText() {
    if (_isLoadingNetworks) {
      return widget.selectedData['recipientDeliveryMethod'] == 'bank' ||
              widget.selectedData['recipientDeliveryMethod'] == 'p2p'
          ? 'Loading banks...'
          : 'Loading mobile money providers...';
    } else if (_networkError != null) {
      return widget.selectedData['recipientDeliveryMethod'] == 'bank' ||
              widget.selectedData['recipientDeliveryMethod'] == 'p2p'
          ? 'Error loading banks'
          : 'Error loading mobile money providers';
    } else if (_filteredNetworks.isEmpty) {
      return widget.selectedData['recipientDeliveryMethod'] == 'bank' ||
              widget.selectedData['recipientDeliveryMethod'] == 'p2p'
          ? 'No banks available for this channel'
          : 'No mobile money providers available for this channel';
    } else {
      return widget.selectedData['recipientDeliveryMethod'] == 'bank' ||
              widget.selectedData['recipientDeliveryMethod'] == 'p2p'
          ? 'Select a bank'
          : 'Select a mobile money provider';
    }
  }

  /// Build the suffix icon based on current state
  Widget? _buildNetworkSuffixIcon() {
    if (_isLoadingNetworks) {
      return Container(
        margin: EdgeInsets.all(12.w),
        child: LoadingAnimationWidget.horizontalRotatingDots(
          color: AppColors.purple500ForTheme(context),
          size: 20,
        ),
      );
    } else if (_networkError != null) {
      return Icon(Icons.error_outline, color: AppColors.error600, size: 20.sp);
    } else if (_filteredNetworks.isNotEmpty) {
      return Icon(
        Icons.keyboard_arrow_down,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        size: 24.sp,
      );
    }
    return null;
  }

  /// Get network icon based on account type
  Widget _getNetworkIcon(Network network) {
    switch (network.accountNumberType) {
      case 'bank':
        return SvgPicture.asset(
          'assets/icons/svgs/building-bank.svg',
          height: 32.sp,
          width: 32.sp,
        );
      case 'phone':
        return SvgPicture.asset(
          'assets/icons/svgs/device-mobile.svg',
          height: 32.sp,
          width: 32.sp,
        );
      default:
        return SvgPicture.asset(
          'assets/icons/svgs/paymentt.svg',
          height: 32.sp,
          width: 32.sp,
        );
    }
  }

  /// Get display name for account type
  String _getAccountTypeDisplayName(String accountType) {
    switch (accountType) {
      case 'bank':
        return 'Bank Account';
      case 'phone':
        return 'Mobile Money';
      default:
        return accountType.toUpperCase();
    }
  }

  /// Show network selection bottom sheet
  void _showNetworkBottomSheet() {
    if (_filteredNetworks.isEmpty) return;

    // Clear search when opening bottom sheet
    _networkSearchController.clear();
    _searchedNetworks = _filteredNetworks;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  height: MediaQuery.of(context).size.height * 0.92,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 18.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(height: 24.h, width: 22.w),
                            Text(
                              'Select Network',
                              style: AppTypography.titleLarge.copyWith(
                                fontFamily: 'CabinetGrotesk',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                "assets/icons/pngs/cancelicon.png",
                                height: 24.h,
                                width: 24.w,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Search field
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: CustomTextField(
                          controller: _networkSearchController,
                          label: '',
                          hintText: 'Search networks',
                          borderRadius: 40,
                          prefixIcon: Container(
                            width: 40.w,
                            alignment: Alignment.centerRight,
                            constraints: BoxConstraints.tightForFinite(),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/svgs/swap.svg',
                                  height: 34,
                                  color: AppColors.neutral700.withOpacity(.35),
                                ),
                                Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/svgs/search-normal.svg',
                                    height: 26,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onChanged: (value) {
                            _filterNetworksBySearch(value);
                            setModalState(() {});
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Expanded(
                        child:
                            _searchedNetworks.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/svgs/search-normal.svg',
                                        height: 64.sp,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),

                                      SizedBox(height: 16.h),
                                      Text(
                                        'No networks found',
                                        style: TextStyle(
                                          fontFamily: 'CabinetGrotesk',
                                          fontSize: 16.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),

                                      SizedBox(height: 8.h),
                                      Text(
                                        'Try searching with different keywords',
                                        style: AppTypography.bodyMedium
                                            .copyWith(
                                              fontFamily: 'Karla',
                                              fontSize: 14.sp,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.4),
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                                : ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 18.w,
                                  ),
                                  itemCount: _searchedNetworks.length,
                                  itemBuilder: (context, index) {
                                    final network = _searchedNetworks[index];
                                    final isSelected =
                                        _selectedNetwork?.id == network.id;

                                    return ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4.h,
                                      ),
                                      leading: Container(
                                        padding: EdgeInsets.all(6.r),
                                        decoration: BoxDecoration(
                                          color: AppColors.neutral0,
                                          shape: BoxShape.circle,
                                        ),
                                        child: _getNetworkIcon(network),
                                      ),
                                      title: Text(
                                        network.name ?? 'Unknown Network',
                                        style: AppTypography.bodyLarge.copyWith(
                                          fontFamily: 'Karla',
                                          fontSize: 16.sp,
                                          letterSpacing: -.4,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle:
                                          network.accountNumberType != null
                                              ? Text(
                                                _getAccountTypeDisplayName(
                                                  network.accountNumberType!,
                                                ),
                                                style: AppTypography.bodyMedium
                                                    .copyWith(
                                                      fontFamily: 'Karla',
                                                      fontSize: 14.sp,
                                                      letterSpacing: -.4,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withOpacity(0.6),
                                                    ),
                                              )
                                              : null,
                                      trailing:
                                          isSelected
                                              ? SvgPicture.asset(
                                                'assets/icons/svgs/circle-check.svg',
                                                color:
                                                    AppColors.purple500ForTheme(
                                                      context,
                                                    ),
                                              )
                                              : null,
                                      onTap: () {
                                        _onNetworkChanged(network);
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await PlatformDatePicker.showDateOfBirthPicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 7300), // ~20 years ago as default
      ),
      title: 'Select Date of Birth',
    );

    if (picked != null) {
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _validateAndContinue() {
    if (_formKey.currentState!.validate() &&
        _selectedNetwork != null &&
        _resolvedAccountName != null &&
        _resolvedAccountName!.isNotEmpty) {
      analyticsService.logEvent(
        name: 'recipient_added',
        parameters: {
          'country': _selectedCountry,
          'networkId': _selectedNetworkId,
        },
      );
      final recipientData = {
        'name': _resolvedAccountName!.trim(),
        'country': _selectedCountry,
        'phone':
            _getFormattedPhoneNumber(), // Use formatted phone number with country code
        'address': _addressController.text.trim(),
        'dob': _dobController.text.trim(),
        'email': _emailController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'networkId': _selectedNetworkId,
      };

      // Get user profile data for sender information
      final profileState = ref.read(profileViewModelProvider);
      final user = profileState.user;

      // Create sender data from user profile
      final senderData = {
        'name':
            user != null ? '${user.firstName} ${user.lastName}'.trim() : 'User',
        'country': user?.country ?? 'NG',
        'phone': _formatPhoneNumber(user?.phoneNumber ?? '+2340000000000'),
        'address': user?.address ?? 'Not provided',
        'dob': user?.dateOfBirth ?? '1990-01-01',
        'email': user?.email ?? 'user@example.com',
        'idNumber': user?.idNumber ?? 'A12345678',
        'idType': user?.idType ?? 'passport',
        'userId': user?.userId ?? '12345', // Add user ID for metadata
      };

      appRouter.pushNamed(
        AppRoute.sendReviewView,
        arguments: {
          'selectedData': widget.selectedData,
          'recipientData': recipientData,
          'senderData': senderData,
        },
      );
    } else {
      String errorMessage = 'Please complete the following:';
      if (_selectedNetwork == null) {
        errorMessage += '\n• Select a network';
      }
      if (_resolvedAccountName == null ||
          _resolvedAccountName!.isEmpty &&
              widget.selectedData['recipientDeliveryMethod'] != 'p2p') {
        errorMessage +=
            '\n• Enter a valid account number to resolve the recipient name';
      } else if (_resolvedAccountName == null ||
          _resolvedAccountName!.isEmpty &&
              widget.selectedData['recipientDeliveryMethod'] == 'p2p') {
        errorMessage +=
            '\n• Enter a valid mobile money number to resolve the recipient name';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error500,
        ),
      );
    }
  }

  /// Get recipient country from selected data
  String _getRecipientCountry() {
    return widget.selectedData['receiveCountry'] ?? '';
  }

  /// Get formatted phone number with country code
  String _getFormattedPhoneNumber() {
    final country = _getRecipientCountry();
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) return '';

    return PhoneCountryUtils.formatPhoneNumber(phoneNumber, country);
  }

  /// Build phone number field with country code prefix
  Widget _buildPhoneNumberField() {
    final country = _getRecipientCountry();
    final countryInfo = PhoneCountryUtils.getCountryPhoneInfo(country);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _phoneController,
          label: 'Phone Number (Optional)',
          keyboardType: TextInputType.phone,
          maxLength: countryInfo?.maxLength ?? 10,
          hintText:
              countryInfo != null
                  ? 'X' * countryInfo.maxLength
                  : 'Enter phone number',
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16.w, top: 12.w),
            child: Text(
              "${countryInfo?.countryCode ?? '+234'}     ",
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: 'Karla',
                fontSize: 16,
                letterSpacing: -.3,
                fontWeight: FontWeight.w500,
                height: 1.450,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return null; // Optional field
            }

            final validationError = PhoneCountryUtils.validatePhoneNumber(
              value,
              country,
            );
            return validationError;
          },
          onChanged: (value) {
            // Trigger rebuild to update any dependent UI
            setState(() {});
          },
        ),
        // if (countryInfo != null) ...[
        //   SizedBox(height: 4.h),
        //   Text(
        //     'Enter ${countryInfo.maxLength} digits for ${countryInfo.name}',
        //     style: AppTypography.bodySmall.copyWith(
        //       fontFamily: 'Karla',
        //       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        //     ),
        //   ),
        // ],
      ],
    );
  }
}
