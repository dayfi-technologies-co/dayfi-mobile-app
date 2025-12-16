import 'dart:developer';

import 'package:dayfi/common/utils/ui_helpers.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:dayfi/features/send/vm/send_viewmodel.dart';

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
  final _bankNameController = TextEditingController();
  final _accountNameController = TextEditingController();

  String _selectedCountry = '';
  String _selectedChannelId = ''; // This is the actual channel ID for filtering
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
  String? _lastResolvedAccountNumber;
  String? _lastResolvedNetworkId;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedData['receiveCountry'] ?? '';

    // Get the correct channel ID based on delivery method
    if (widget.selectedData['recipientDeliveryMethod'] == 'bank' ||
        widget.selectedData['recipientDeliveryMethod'] == 'eft' ||
        widget.selectedData['recipientDeliveryMethod'] == 'p2p') {
      _selectedChannelId = widget.selectedData['recipientChannelId'] ?? '';
    } else {
      _selectedChannelId = widget.selectedData['recipientChannelId'] ?? '';
    }

    // print('🚀 SendAddRecipientsView initialized');
    // print('🌍 Selected country: $_selectedCountry');
    // print('🔗 Selected channel ID for filtering: $_selectedChannelId');
    // print('📋 Full selectedData: ${widget.selectedData}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      analyticsService.trackScreenView(screenName: 'SendAddRecipientsView');

      // Load beneficiaries if not already loaded
      final recipientsState = ref.read(recipientsProvider);
      if (recipientsState.beneficiaries.isEmpty && !recipientsState.isLoading) {
        ref
            .read(recipientsProvider.notifier)
            .loadBeneficiaries(isInitialLoad: true);
      }

      // Use networks from sendState if available, otherwise from selectedData, otherwise fetch
      final sendState = ref.read(sendViewModelProvider);
      if (sendState.networks.isNotEmpty) {
        setState(() {
          _allNetworks = sendState.networks;
          _filterNetworks();
        });
      } else if (widget.selectedData['networks'] != null) {
        setState(() {
          _allNetworks = List<Network>.from(widget.selectedData['networks']);
          _filterNetworks();
        });
      } else {
        _fetchNetworks();
      }
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
    _bankNameController.dispose();
    _accountNameController.dispose();
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

    // print('🔍 Filtering networks for channel ID: $_selectedChannelId');
    // print('📊 Total networks available: ${_allNetworks.length}');

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

    // print('🎯 Filtered networks count: ${channelNetworks.length}');

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

      // Clear manual input fields
      _bankNameController.clear();
      _accountNameController.clear();
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
    if (_selectedNetwork?.name == 'Manual Input')
      return; // No resolution for manual input

    final accountNumber = _accountNumberController.text.trim();

    // If account number is reduced below 10 digits, immediately clear everything
    if (accountNumber.length < 10) {
      setState(() {
        _resolveError = null;
        _resolvedAccountName = null;
        _isResolving = false; // Stop any ongoing resolution
        _lastResolvedAccountNumber = null;
        _lastResolvedNetworkId = null;
      });
      return;
    }

    // Check if account number is exactly 10 digits AND network is selected
    if (accountNumber.length == 10 &&
        RegExp(r'^\d{10}$').hasMatch(accountNumber) &&
        _selectedNetwork != null &&
        _selectedNetworkId.isNotEmpty) {
      // Check if we already resolved this account number for this network
      if (accountNumber == _lastResolvedAccountNumber &&
          _selectedNetworkId == _lastResolvedNetworkId &&
          _resolvedAccountName != null) {
        // Already resolved, no need to call API again
        return;
      }
      // Close keyboard when account number is complete
      FocusScope.of(context).unfocus();
      _resolveAccount(accountNumber);
    } else {
      // Clear resolved name if account number is not 10 digits or network not selected
      setState(() {
        _resolveError = null;
        _resolvedAccountName = null;
        _isResolving = false; // Stop any ongoing resolution
        _lastResolvedAccountNumber = null;
        _lastResolvedNetworkId = null;
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
          _lastResolvedAccountNumber = accountNumber;
          _lastResolvedNetworkId = _selectedNetworkId;
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
    final sendState = ref.watch(sendViewModelProvider);
    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              leadingWidth: 72,
              scrolledUnderElevation: .5,
              foregroundColor: Theme.of(context).scaffoldBackgroundColor,
              shadowColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
              leading: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap:
                    () => {
                      Navigator.pop(context),
                      FocusScope.of(context).unfocus(),
                    },
                child: Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/svgs/notificationn.svg",
                      height: 40.sp,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    SizedBox(
                      height: 40.sp,
                      width: 40.sp,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20.sp,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            // size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                'Add Recipient',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontFamily: 'FunnelDisplay',
                  fontSize: 24.sp,
                  // height: 1.6,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        "Add a recipient to continue your transfer to ${_getCountryName(widget.selectedData['receiveCountry'])} (${widget.selectedData['receiveCurrency'] ?? 'Unknown'}) via ${_getDeliveryMethodDisplayName(widget.selectedData['recipientDeliveryMethod'])}",
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
                    SizedBox(height: 32.h),
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
                              ? 'Select a bank to enable account resolution'
                              : 'Select a mobile money provider to enable account resolution',
                          style: AppTypography.bodySmall.copyWith(
                            fontFamily: 'Karla',
                            fontSize: 12.sp,
                            letterSpacing: -.6,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    _networkController.text == 'Mobile Money'
                        ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "This network supports all mobile money providers in ${_getCountryName(_selectedCountry)}. Please ensure the account number you enter is registered with a mobile money provider in that country.",
                            style: AppTypography.bodySmall.copyWith(
                              fontFamily: 'Karla',
                              fontSize: 12.sp,
                              letterSpacing: -.6,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : SizedBox(height: 0.h),

                    _networkController.text == 'Manual Input'
                        ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Manual Input allows you to enter bank details directly for transfers to any bank in ${_getCountryName(_selectedCountry)}. Please provide the bank name and account holder name.",
                            style: AppTypography.bodySmall.copyWith(
                              fontFamily: 'Karla',
                              fontSize: 12.sp,
                              letterSpacing: -.6,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : SizedBox(height: 0.h),

                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height:
                          (_selectedNetwork?.name == 'Manual Input')
                              ? 180.h
                              : 0,
                      child:
                          (_selectedNetwork?.name == 'Manual Input')
                              ? Padding(
                                padding: EdgeInsets.only(top: 18.h),
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      controller: _bankNameController,
                                      label: 'Bank Name',
                                      hintText: 'Enter bank name',
                                      textCapitalization:
                                          TextCapitalization.words,
                                      validator: (value) {
                                        if (_selectedNetwork?.name ==
                                            'Manual Input') {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Please enter bank name';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 18.h),
                                    CustomTextField(
                                      controller: _accountNameController,
                                      label: 'Account Name',
                                      hintText: 'Enter account holder name',
                                      textCapitalization:
                                          TextCapitalization.words,
                                      validator: (value) {
                                        if (_selectedNetwork?.name ==
                                            'Manual Input') {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Please enter account name';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              )
                              : SizedBox.shrink(),
                    ),

                    if (_filteredNetworks.isEmpty &&
                        !_isLoadingNetworks &&
                        _networkError == null) ...[
                      SizedBox(height: 16.h),
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColors.error50,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: AppColors.error200,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.error600,
                                size: 14.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                widget.selectedData['recipientDeliveryMethod'] ==
                                            'bank' ||
                                        widget.selectedData['recipientDeliveryMethod'] ==
                                            'p2p'
                                    ? 'No banks available for this delivery method'
                                    : 'No providers available for this delivery method',
                                style: TextStyle(
                                  fontFamily: 'Karla',
                                  fontSize: 13.sp,
                                  letterSpacing: -.6,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error700,
                                ),
                              ),
                                    SizedBox(width: 2.w),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 18.h),

                    // Account Number Field (Required)
                    CustomTextField(
                      controller: _accountNumberController,
                      label:
                          _selectedNetwork?.name == 'Manual Input'
                              ? 'Account Number'
                              : widget.selectedData['recipientDeliveryMethod'] ==
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
                                      size: 22,
                                    ),
                              )
                              : _resolvedAccountName != null
                              ? Padding(
                                padding: EdgeInsets.all(12.w),
                                child: SvgPicture.asset(
                                  'assets/icons/svgs/circle-check.svg',
                                  width: 26.w,
                                  height: 26.h,
                                  color: AppColors.success600,
                                ),
                              )
                              : _resolveError != null &&
                                  _accountNumberController.text.isNotEmpty
                              ? GestureDetector(
                                onTap: () {
                                  _accountNumberController.clear();
                                  setState(() {
                                    _resolveError = null;
                                    _resolvedAccountName = null;
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: SvgPicture.asset(
                                    'assets/icons/svgs/circle-x.svg',
                                    width: 26.w,
                                    height: 26.h,
                                    color: AppColors.error600,
                                  ),
                                ),
                              )
                              : null,

                      // GestureDetector(
                      //   onTap: () async {
                      //     HapticHelper.lightImpact();
                      //     // Paste from clipboard
                      //     final clipboardData = await Clipboard.getData(
                      //       Clipboard.kTextPlain,
                      //     );
                      //     if (clipboardData?.text != null &&
                      //         clipboardData!.text!.isNotEmpty) {
                      //       _accountNumberController.text =
                      //           clipboardData.text!;
                      //       _onAccountNumberChanged();
                      //     }
                      //   },
                      //   child: Padding(
                      //     padding: EdgeInsets.all(16.w),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.end,
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Text(
                      //           "paste",
                      //           style: TextStyle(
                      //             fontFamily: 'Karla',
                      //             fontWeight: FontWeight.w600,
                      //             fontSize: 12.sp,
                      //             letterSpacing: 0.00,
                      //             height: 1.450,
                      //             color:
                      //                 Theme.of(
                      //                   context,
                      //                 ).colorScheme.primary,
                      //           ),
                      //         ),
                      //         SizedBox(width: 6.w),
                      //         SvgPicture.asset(
                      //           "assets/icons/svgs/paste.svg",
                      //           color:
                      //               Theme.of(
                      //                 context,
                      //               ).colorScheme.primary,
                      //           height: 16.sp,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
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

                    // Account resolution messages
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0, -0.15),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      },
                      child:
                          _resolveError != null
                              ? Column(
                                key: ValueKey('error'),
                                children: [
                                  SizedBox(height: 8.h),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.error50,
                                      borderRadius: BorderRadius.circular(12.r),
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
                                          size: 16.sp,
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
                                               letterSpacing: -.6,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.error700,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                              : _resolvedAccountName != null
                              ? Column(
                                key: ValueKey('success'),
                                children: [
                                  SizedBox(height: 12.h),
                                  Center(
                                    child: Container(
                                      // width: double.infinity,
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.success50,
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color: AppColors.success200,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        _resolvedAccountName!,
                                        style: TextStyle(
                                          fontFamily: 'karla',
                                          fontSize: 14.sp,
                                           letterSpacing: -.6,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.success700,
                                          height: 1.3,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : const SizedBox(
                                key: ValueKey('empty'),
                                height: 0,
                              ),
                    ),

                    // SizedBox(height: 24.h),

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
                    //      fontFamily: 'FunnelDisplay',
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
                    SizedBox(height: 18.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12.r),
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
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.4,
                                height: 1.5,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Continue Button
                    PrimaryButton(
                      text: 'Enter Amount',
                      onPressed: _validateAndContinue,
                      enabled: _isFormValid(),
                      height: 48.00000.h,
                      backgroundColor: AppColors.purple500,
                      textColor: AppColors.neutral0,
                      fontFamily: 'Karla',
                      letterSpacing: -.70,
                      fontSize: 18,
                      width: double.infinity,
                      fullWidth: true,
                      borderRadius: 40.r,
                    ),

                    SizedBox(height: 20.h),

                    Center(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () async {
                          // Show recent beneficiaries in a bottom sheet and allow selection
                          final result = await showAppBottomSheet<
                            BeneficiaryWithSource
                          >(
                            context: context,
                            isScrollControlled: true,
                            barrierColor: Colors.black.withOpacity(0.85),
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            builder:
                                (context) => Consumer(
                                  builder: (context, sheetRef, _) {
                                    final recipientsState = sheetRef.watch(
                                      recipientsProvider,
                                    );
                                    final allBeneficiaries =
                                        recipientsState.beneficiaries
                                            .where(
                                              (b) =>
                                                  (b.beneficiary.country ??
                                                      '') ==
                                                  (widget.selectedData['receiveCountry'] ??
                                                      ''),
                                            )
                                            .toList();

                                    final networks =
                                        sheetRef
                                            .watch(sendViewModelProvider)
                                            .networks ??
                                        [];

                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Container(
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.92,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).scaffoldBackgroundColor,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20.r),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(height: 18.h),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 18.w,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      height: 40.h,
                                                      width: 40.w,
                                                    ),
                                                    Text(
                                                      'Select Beneficiary',
                                                      style: AppTypography
                                                          .titleLarge
                                                          .copyWith(
                                                            fontFamily:
                                                                'FunnelDisplay',
                                                            fontSize: 20.sp,
                                                            // height: 1.6,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface,
                                                          ),
                                                    ),
                                                    InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                      child: Stack(
                                                        alignment:
                                                            AlignmentGeometry
                                                                .center,
                                                        children: [
                                                          SvgPicture.asset(
                                                            "assets/icons/svgs/notificationn.svg",
                                                            height: 40.sp,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .surface,
                                                          ),
                                                          SizedBox(
                                                            height: 40.sp,
                                                            width: 40.sp,
                                                            child: Center(
                                                              child: Image.asset(
                                                                "assets/icons/pngs/cancelicon.png",
                                                                height: 20.h,
                                                                width: 20.w,
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .textTheme
                                                                        .bodyLarge!
                                                                        .color,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 9.h),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      SizedBox(height: 9.h),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 24.0,
                                                            ),
                                                        child: Opacity(
                                                          opacity: .85,
                                                          child: Text(
                                                            'Choose a recent beneficiary to auto-fill recipient details',
                                                            style: Theme.of(
                                                                  context,
                                                                )
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.copyWith(
                                                                  fontSize:
                                                                      16.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      'Karla',
                                                                  letterSpacing:
                                                                      -.3,
                                                                  height: 1.5,
                                                                ),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 32.h),
                                                      allBeneficiaries.isEmpty
                                                          ? Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                SizedBox(
                                                                  height: 16.h,
                                                                ),
                                                                SvgPicture.asset(
                                                                  'assets/icons/svgs/search-normal.svg',
                                                                  height: 64.sp,
                                                                  color: Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .onSurface
                                                                      .withOpacity(
                                                                        0.6,
                                                                      ),
                                                                ),
                                                                SizedBox(
                                                                  height: 16.h,
                                                                ),
                                                                Text(
                                                                  'No beneficiaries found',
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        'FunnelDisplay',
                                                                    fontSize:
                                                                        16.sp,
                                                                    color: Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .onSurface
                                                                        .withOpacity(
                                                                          0.6,
                                                                        ),
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                SizedBox(
                                                                  height: 8.h,
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            32.0,
                                                                      ),
                                                                  child: Text(
                                                                    'No recent beneficiaries for this country and payment type',
                                                                    style: AppTypography.bodyMedium.copyWith(
                                                                      fontFamily:
                                                                          'Karla',
                                                                      fontSize:
                                                                          14.sp,
                                                                      color: Theme.of(
                                                                            context,
                                                                          )
                                                                          .colorScheme
                                                                          .onSurface
                                                                          .withOpacity(
                                                                            0.4,
                                                                          ),
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                          : Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                  left: 18.w,
                                                                  right: 18.w,
                                                                  bottom: 20.h,
                                                                  // top: 16.h,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .surface,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12.r,
                                                                  ),
                                                            ),
                                                            child: ListView.separated(
                                                              shrinkWrap: true,
                                                              physics:
                                                                  NeverScrollableScrollPhysics(),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              itemCount:
                                                                  allBeneficiaries
                                                                      .length,
                                                              separatorBuilder:
                                                                  (
                                                                    _,
                                                                    __,
                                                                  ) => SizedBox(
                                                                    height:
                                                                        12.h,
                                                                  ),
                                                              itemBuilder: (
                                                                context,
                                                                index,
                                                              ) {
                                                                final b =
                                                                    allBeneficiaries[index];
                                                                return AnimatedContainer(
                                                                  key: ValueKey(
                                                                    b
                                                                        .beneficiary
                                                                        .id,
                                                                  ),
                                                                  duration:
                                                                      const Duration(
                                                                        milliseconds:
                                                                            200,
                                                                      ),
                                                                  curve:
                                                                      Curves
                                                                          .easeOut,
                                                                  transform:
                                                                      Matrix4.diagonal3Values(
                                                                        1.0,
                                                                        1.0,
                                                                        1.0,
                                                                      ),
                                                                  child: Container(
                                                                    margin: EdgeInsets.only(
                                                                      bottom:
                                                                          8.h,
                                                                      top: 8.h,
                                                                    ),
                                                                    padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          16.w,
                                                                      vertical:
                                                                          12.h,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          Theme.of(
                                                                            context,
                                                                          ).colorScheme.surface,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12.r,
                                                                          ),
                                                                    ),
                                                                    child: InkWell(
                                                                      onTap: () {
                                                                        Navigator.pop(
                                                                          context,
                                                                          b,
                                                                        );
                                                                      },
                                                                      child: Row(
                                                                        children: [
                                                                          // Avatar
                                                                          Stack(
                                                                            alignment:
                                                                                Alignment.bottomRight,
                                                                            children: [
                                                                              Stack(
                                                                                alignment:
                                                                                    Alignment.center,
                                                                                children: [
                                                                                  SvgPicture.asset(
                                                                                    'assets/icons/svgs/account.svg',
                                                                                    width:
                                                                                        40.w,
                                                                                    height:
                                                                                        40.w,
                                                                                    color: AppColors.purple500ForTheme(
                                                                                      context,
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    (b.beneficiary.name.isNotEmpty
                                                                                            ? b.beneficiary.name[0]
                                                                                            : '?')
                                                                                        .toUpperCase(),
                                                                                    style: TextStyle(
                                                                                      color:
                                                                                          AppColors.neutral0,
                                                                                      fontFamily:
                                                                                          'Karla',
                                                                                      fontSize:
                                                                                          16.sp,
                                                                                      fontWeight:
                                                                                          FontWeight.w500,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),

                                                                              Align(
                                                                                alignment:
                                                                                    Alignment.bottomRight,
                                                                                child: Container(
                                                                                  width:
                                                                                      15.w,
                                                                                  height:
                                                                                      15.w,
                                                                                  decoration: BoxDecoration(
                                                                                    color:
                                                                                        AppColors.neutral0,
                                                                                    shape:
                                                                                        BoxShape.circle,
                                                                                    border: Border.all(
                                                                                      color:
                                                                                          AppColors.neutral200,
                                                                                      width:
                                                                                          1,
                                                                                    ),
                                                                                  ),
                                                                                  child: ClipOval(
                                                                                    child: SvgPicture.asset(
                                                                                      _getFlagPath(
                                                                                        b.beneficiary.country,
                                                                                      ),
                                                                                      fit:
                                                                                          BoxFit.cover,
                                                                                      width:
                                                                                          20.w,
                                                                                      height:
                                                                                          20.w,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                10.w,
                                                                          ),
                                                                          // Beneficiary Info
                                                                          Expanded(
                                                                            child: Column(
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  b.beneficiary.name.toUpperCase(),
                                                                                  style: AppTypography.bodyLarge.copyWith(
                                                                                    fontFamily:
                                                                                        'Karla',
                                                                                    fontSize:
                                                                                        16.sp,
                                                                                    fontWeight:
                                                                                        FontWeight.w600,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height:
                                                                                      2.h,
                                                                                ),
                                                                                Text(
                                                                                  (() {
                                                                                    final networkName =
                                                                                        networks.any(
                                                                                              (
                                                                                                n,
                                                                                              ) =>
                                                                                                  n.id ==
                                                                                                  b.source.networkId,
                                                                                            )
                                                                                            ? networks
                                                                                                .firstWhere(
                                                                                                  (
                                                                                                    n,
                                                                                                  ) =>
                                                                                                      n.id ==
                                                                                                      b.source.networkId,
                                                                                                )
                                                                                                .name
                                                                                            : _getDeliveryMethodDisplayName(
                                                                                              b.beneficiary.accountType,
                                                                                            );
                                                                                    return "$networkName - ${b.source.accountNumber ?? b.beneficiary.accountNumber ?? ''}";
                                                                                  })(),
                                                                                  style: AppTypography.bodyMedium.copyWith(
                                                                                    fontFamily:
                                                                                        'Karla',
                                                                                    fontSize:
                                                                                        13.sp,
                                                                                    color: Theme.of(
                                                                                      context,
                                                                                    ).colorScheme.onSurface.withOpacity(
                                                                                      0.6,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                12.w,
                                                                          ),
                                                                          Icon(
                                                                            Icons.chevron_right,
                                                                            color:
                                                                                AppColors.neutral400,
                                                                          ),
                                                                        ],
                                                                      ),
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
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                          );

                          if (result != null) {
                            setState(() {
                              // Populate form with selected beneficiary details
                              _selectedNetworkId =
                                  result.source.networkId ?? '';
                              _accountNumberController.text =
                                  result.source.accountNumber ??
                                  result.beneficiary.accountNumber ??
                                  '';
                              _resolvedAccountName = result.beneficiary.name;
                              _phoneController.text =
                                  result.beneficiary.phone ?? '';

                              // Try to find matching network in loaded networks
                              final match =
                                  _allNetworks
                                      .where(
                                        (n) => n.id == result.source.networkId,
                                      )
                                      .toList();
                              if (match.isNotEmpty) {
                                _selectedNetwork = match.first;
                                _networkController.text =
                                    match.first.name ?? '';
                                _selectedNetworkId = match.first.id ?? '';
                              } else {
                                // Fallback to using the network name from source if available
                                _networkController.text =
                                    result.source.networkId ?? '';
                              }
                            });
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          child: Text(
                            'See recents and beneficiaries',
                            style: TextStyle(
                              fontFamily: 'Karla',
                              color: AppColors.purple500ForTheme(context),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -.6,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ), // Loading overlay that freezes the screen during account resolution
        if (_isResolving)
          Container(
            color: Colors.black.withOpacity(0.425),
            child: Center(child: CupertinoActivityIndicator()),
          ),
        if (_isLoadingNetworks)
          Container(
            color: Colors.black.withOpacity(0.425),
            child: Center(child: CupertinoActivityIndicator()),
          ),
      ],
    );
  }

  /// Build network selection field
  Widget _buildNetworkSelectionField() {
    return CustomTextField(
      controller: _networkController,
      label:
          _networkController.text == 'Manual Input'
              ? ""
              : widget.selectedData['recipientDeliveryMethod'] == 'bank' ||
                  widget.selectedData['recipientDeliveryMethod'] == 'eft' ||
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
          return widget.selectedData['recipientDeliveryMethod'] == 'bank' ||
                  widget.selectedData['recipientDeliveryMethod'] == 'eft' ||
                  widget.selectedData['recipientDeliveryMethod'] == 'p2p'
              ? 'Please select a bank'
              : 'Please select a mobile money provider';
        }
        return null;
      },
    );
  }

  // Helper function to get full country name from country code
  String _getCountryName(String? countryCode) {
    switch (countryCode?.toUpperCase()) {
      case 'NG':
        return 'Nigeria';
      case 'GH':
        return 'Ghana';
      case 'RW':
        return 'Rwanda';
      case 'KE':
        return 'Kenya';
      case 'UG':
        return 'Uganda';
      case 'TZ':
        return 'Tanzania';
      case 'ZA':
        return 'South Africa';
      case 'BF':
        return 'Burkina Faso';
      case 'BJ':
        return 'Benin';
      case 'BW':
        return 'Botswana';
      case 'CD':
        return 'Democratic Republic of Congo';
      case 'CG':
        return 'Republic of Congo';
      case 'CI':
        return 'Côte d\'Ivoire';
      case 'CM':
        return 'Cameroon';
      case 'GA':
        return 'Gabon';

      case 'MW':
        return 'Malawi';
      case 'ML':
        return 'Mali';
      case 'SN':
        return 'Senegal';
      case 'TG':
        return 'Togo';
      case 'ZM':
        return 'Zambia';
      case 'US':
        return 'United States';
      case 'GB':
        return 'United Kingdom';
      case 'CA':
        return 'Canada';
      default:
        return countryCode ?? 'Unknown';
    }
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
      case 'ML':
        return 'assets/icons/svgs/world_flags/mali.svg';
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

  // Helper function to get delivery method display name
  String _getDeliveryMethodDisplayName(String? method) {
    if (method == null) return 'Unknown';
    switch (method.toLowerCase()) {
      case 'bank':
      case 'bank_transfer':
      case 'p2p':
      case 'peer_to_peer':
      case 'eft':
        return 'Bank Transfer';
      case 'mobile_money':
      case 'momo':
        return 'Mobile Money';
      case 'dayfi_tag':
        return 'DayFi Tag';
      default:
        return method
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Get the hint text based on current state
  String _getNetworkHintText() {
    if (_isLoadingNetworks) {
      return widget.selectedData['recipientDeliveryMethod'] == 'bank' ||
              widget.selectedData['recipientDeliveryMethod'] == 'eft' ||
              widget.selectedData['recipientDeliveryMethod'] == 'p2p'
          ? 'Select a bank'
          : 'Select a mobile money provider';
    } else if (_networkError != null) {
      return widget.selectedData['recipientDeliveryMethod'] == 'bank' ||
              widget.selectedData['recipientDeliveryMethod'] == 'eft' ||
              widget.selectedData['recipientDeliveryMethod'] == 'p2p'
          ? 'Error loading banks'
          : 'Error loading mobile money providers';
    } else if (_filteredNetworks.isEmpty) {
      return widget.selectedData['recipientDeliveryMethod'] == 'bank' ||
              widget.selectedData['recipientDeliveryMethod'] == 'eft' ||
              widget.selectedData['recipientDeliveryMethod'] == 'p2p'
          ? 'No banks available for this country'
          : 'No mobile money providers available for this country';
    } else {
      return widget.selectedData['recipientDeliveryMethod'] == 'bank' ||
              widget.selectedData['recipientDeliveryMethod'] == 'eft' ||
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
          height: 24.sp,
          width: 24.sp,
        );
      case 'phone':
        return SvgPicture.asset(
          'assets/icons/svgs/device-mobile.svg',
          height: 24.sp,
          width: 24.sp,
        );
      default:
        return SvgPicture.asset(
          'assets/icons/svgs/paymentt.svg',
          height: 24.sp,
          width: 24.sp,
        );
    }
  }

  /// Get account type from delivery method
  String _getAccountTypeFromDeliveryMethod() {
    final method = widget.selectedData['recipientDeliveryMethod'];
    if (method == 'bank' || method == 'eft' || method == 'p2p') return 'bank';
    if (method == 'mobile_money') return 'phone';
    return 'bank'; // default
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
      barrierColor: Colors.black.withOpacity(0.85),
      context: context,
      isScrollControlled: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
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
                            SizedBox(height: 40.h, width: 40.w),
                            Text(
                              'Select ${_getAccountTypeFromDeliveryMethod() == 'bank' ? 'Bank' : 'Mobile Money Provider'}',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                fontFamily: 'FunnelDisplay',
                                fontSize: 20.sp,
                                // height: 1.6,
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
                              child: Stack(
                                alignment: AlignmentGeometry.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/svgs/notificationn.svg",
                                    height: 40.sp,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                  SizedBox(
                                    height: 40.sp,
                                    width: 40.sp,
                                    child: Center(
                                      child: Image.asset(
                                        "assets/icons/pngs/cancelicon.png",
                                        height: 20.h,
                                        width: 20.w,
                                        color:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge!.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Search field
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: CustomTextField(
                                  isSearch: true,
                                  controller: _networkSearchController,
                                  label: '',
                                  hintText:
                                      'Search ${widget.selectedData['recipientDeliveryMethod'] == 'bank' || widget.selectedData['recipientDeliveryMethod'] == 'eft' || widget.selectedData['recipientDeliveryMethod'] == 'p2p' ? 'banks' : 'mobile money providers'} ',
                                  borderRadius: 40,
                                  prefixIcon: Container(
                                    width: 40.w,
                                    alignment: Alignment.centerRight,
                                    constraints:
                                        BoxConstraints.tightForFinite(),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/svgs/search-normal.svg',
                                        height: 26,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _filterNetworksBySearch(value);
                                    setModalState(() {});
                                  },
                                ),
                              ),
                              SizedBox(height: 16.h),
                              _searchedNetworks.isEmpty
                                  ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          'No ${_getAccountTypeFromDeliveryMethod() == 'bank' ? 'banks' : 'mobile money providers'} found',
                                          style: TextStyle(
                                            fontFamily: 'FunnelDisplay',
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
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
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
                                          network.name?.replaceAll("_", " ") ?? 'Unknown Network',
                                          style: AppTypography.bodyLarge
                                              .copyWith(
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
                                                  style: AppTypography
                                                      .bodyMedium
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
                            ],
                          ),
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
        (_selectedNetwork!.name == 'Manual Input' ||
            (_resolvedAccountName != null &&
                _resolvedAccountName!.isNotEmpty))) {
      analyticsService.logEvent(
        name: 'recipient_added',
        parameters: {
          'country': _selectedCountry,
          'networkId': _selectedNetworkId,
        },
      );
      final recipientData = {
        'name':
            _selectedNetwork!.name == 'Manual Input'
                ? _accountNameController.text.trim()
                : _resolvedAccountName!.trim(),
        'country': _selectedCountry,
        'phone':
            _getFormattedPhoneNumber(), // Use formatted phone number with country code
        'address': _addressController.text.trim(),
        'dob': _dobController.text.trim(),
        'email': _emailController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'networkId': _selectedNetworkId,
        'recipientDeliveryMethod':
            widget.selectedData['recipientDeliveryMethod'] ?? '',
        'recipientChannelId': widget.selectedData['recipientChannelId'] ?? '',
        'bankName':
            _selectedNetwork!.name == 'Manual Input'
                ? _bankNameController.text.trim()
                : null,
        'accountName':
            _selectedNetwork!.name == 'Manual Input'
                ? _accountNameController.text.trim()
                : null,
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
        AppRoute.sendView,
        arguments: {
          'selectedData': widget.selectedData,
          'recipientData': recipientData,
          'senderData': senderData,
        },
      );
    } else {
      String errorMessage = 'Please complete the following:';
      if (_selectedNetwork == null) {
        errorMessage +=
            '\n• ${widget.selectedData['recipientDeliveryMethod'] == 'bank' || widget.selectedData['recipientDeliveryMethod'] == 'eft' || widget.selectedData['recipientDeliveryMethod'] == 'p2p' ? 'Select a bank' : 'Select a mobile money provider'}';
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

      TopSnackbar.show(context, message: errorMessage, isError: true);
    }
  }

  /// Check if the form is valid for submission
  bool _isFormValid() {
    // Check if network is selected
    if (_selectedNetwork == null) return false;

    if (_selectedNetwork!.name == 'Manual Input') {
      // For manual input, check bank name, account name, and account number
      if (_bankNameController.text.trim().isEmpty ||
          _accountNameController.text.trim().isEmpty ||
          _accountNumberController.text.trim().isEmpty) {
        return false;
      }
    } else {
      // Check if account number is valid (10 digits)
      final accountNumber = _accountNumberController.text.trim();
      if (accountNumber.length != 10 ||
          !RegExp(r'^\d{10}$').hasMatch(accountNumber)) {
        return false;
      }

      // Check if account is resolved (for non-p2p methods)
      if (widget.selectedData['recipientDeliveryMethod'] != 'p2p') {
        if (_resolvedAccountName == null || _resolvedAccountName!.isEmpty) {
          return false;
        }
      }
    }

    return true;
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
                letterSpacing: -.6,
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
