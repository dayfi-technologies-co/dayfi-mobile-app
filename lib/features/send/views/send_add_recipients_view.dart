import 'dart:developer';
import 'dart:async' show unawaited;
import 'package:dayfi/common/constants/username_copy.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/features/send/constants/send_copy.dart';

import 'package:dayfi/common/utils/ui_helpers.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/features/recipients/helpers/recipient_save_helper.dart';
import 'package:dayfi/features/recipients/widgets/recipient_avatar_badge.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayfi/common/utils/haptic_helper.dart';

import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/common/utils/platform_date_picker.dart';
import 'package:dayfi/common/utils/phone_country_utils.dart';
import 'package:dayfi/common/utils/account_number_utils.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
// ignore: depend_on_referenced_packages
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/send/services/ngn_banks_cache.dart';
import 'package:dayfi/features/wallet/constants/global_wallet.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';

bool _isBankRecipientDeliveryMethod(String? method) {
  switch (method?.toLowerCase()) {
    case 'bank':
    case 'bank_transfer':
    case 'eft':
    case 'p2p':
    case 'peer_to_peer':
    case 'peer-to-peer':
      return true;
    default:
      return false;
  }
}

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

  // Manual account name for countries without verification support
  final _manualAccountNameController = TextEditingController();
  bool _hasConfirmedDetails = false;

  bool get _saveRecipientOnly =>
      widget.selectedData['saveRecipientOnly'] == true;

  /// Countries that support YellowCard bank account verification
  /// Currently only Nigeria is supported per YellowCard API docs
  static const List<String> _verificationSupportedCountries = ['NG'];

  /// Check if the selected country supports account verification
  bool get _isVerificationSupported {
    return _verificationSupportedCountries.contains(
      _selectedCountry.toUpperCase(),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedData['receiveCountry'] ?? '';

    // Get the correct channel ID based on delivery method
    _selectedChannelId = widget.selectedData['recipientChannelId'] ?? '';

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

      _hydrateBanksFromCache();
      _ensureBanksLoaded().then((_) {
        if (mounted) {
          _applyPrefillBeneficiary();
          _applyPrefillAccountNumber();
        }
      });
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
    _manualAccountNameController.dispose();
    super.dispose();
  }

  void _applyPrefillBeneficiary() {
    final raw = widget.selectedData['prefillBeneficiary'];
    if (raw is! BeneficiaryWithSource) return;
    _applyBeneficiarySelection(raw);
  }

  void _applyPrefillAccountNumber() {
    final raw = widget.selectedData['prefillAccountNumber']?.toString().trim();
    if (raw == null || raw.isEmpty) return;
    if (_accountNumberController.text.trim().isNotEmpty) return;
    _accountNumberController.text = raw;
  }

  Network? _findNetworkForBeneficiary(BeneficiaryWithSource entry) {
    Network? matchByName(String? name) {
      final needle = name?.trim().toLowerCase();
      if (needle == null || needle.isEmpty) return null;
      for (final network in _allNetworks) {
        if ((network.name ?? '').toLowerCase() == needle) return network;
      }
      final ng = NgnBanksCache.cached;
      if (ng != null) {
        for (final network in ng) {
          if ((network.name ?? '').toLowerCase() == needle) return network;
        }
      }
      final sendNetworks = ref.read(sendViewModelProvider).networks;
      for (final network in sendNetworks) {
        if ((network.name ?? '').toLowerCase() == needle) {
          for (final local in _allNetworks) {
            if (local.id == network.id) return local;
          }
          return network;
        }
      }
      return null;
    }

    final byBankName = matchByName(entry.beneficiary.bankName);
    if (byBankName != null) return byBankName;

    final networkId = entry.source.networkId?.trim() ?? '';
    if (networkId.isEmpty) return null;

    final resolved =
        ref.read(sendViewModelProvider.notifier).findNetworkById(networkId);
    if (resolved != null) return resolved;

    for (final network in _allNetworks) {
      if (network.id == networkId) return network;
    }

    for (final network in _allNetworks) {
      final code = _bankCodeForNetwork(network);
      if (code != null && code == networkId) return network;
    }

    final sendNetworks = ref.read(sendViewModelProvider).networks;
    for (final network in sendNetworks) {
      if (network.id == networkId) {
        for (final local in _allNetworks) {
          if (local.id == network.id) return local;
        }
        return network;
      }
    }

    final needle = networkId.toLowerCase();
    for (final network in _allNetworks) {
      if ((network.name ?? '').toLowerCase() == needle) return network;
    }

    for (final network in sendNetworks) {
      if ((network.name ?? '').toLowerCase() == needle) {
        for (final local in _allNetworks) {
          if (local.id == network.id) return local;
        }
        return network;
      }
    }

    return null;
  }

  void _applyBeneficiarySelection(BeneficiaryWithSource result) {
    final accountNumber =
        result.source.accountNumber ?? result.beneficiary.accountNumber ?? '';
    final resolvedName = RecipientHistoryHelper.primaryLabel(
      result.beneficiary,
      result.source,
    );
    final country =
        widget.selectedData['receiveCountry']?.toString().trim().isNotEmpty ==
                true
            ? widget.selectedData['receiveCountry'].toString()
            : RecipientHistoryHelper.resolveReceiveCountry(result);

    final network = _findNetworkForBeneficiary(result);

    setState(() {
      _selectedCountry = country.toUpperCase();
      _selectedNetworkId = network?.id ?? result.source.networkId ?? '';
      _accountNumberController.text = accountNumber;
      _resolvedAccountName = resolvedName;
      _lastResolvedAccountNumber = accountNumber.trim();
      _lastResolvedNetworkId = _selectedNetworkId;

      if (result.beneficiary.phone.isNotEmpty == true) {
        _phoneController.text = result.beneficiary.phone;
      }
      _manualAccountNameController.text = resolvedName;
      _hasConfirmedDetails = true;

      if (network != null) {
        _selectedNetwork = network;
        _networkController.text = network.name ?? '';
        _selectedNetworkId = network.id ?? _selectedNetworkId;
        _lastResolvedNetworkId = _selectedNetworkId;
      } else {
        final bankLabel =
            result.beneficiary.bankName?.trim().isNotEmpty == true
                ? result.beneficiary.bankName!.trim()
                : RecipientHistoryHelper.bankNameFromNetworkId(
                  result.source.networkId,
                );
        if (bankLabel != null && bankLabel.isNotEmpty) {
          _networkController.text = bankLabel;
        } else if (result.source.networkId?.isNotEmpty == true) {
          _networkController.text = result.source.networkId!;
        }
      }

      _applyNetworkFilter();
    });
  }

  bool get _usesFlutterwaveBanks =>
      _selectedCountry.toUpperCase() == 'NG' && _isBankDeliveryMethod;

  void _hydrateBanksFromCache() {
    List<Network>? banks;

    if (_usesFlutterwaveBanks) {
      banks = NgnBanksCache.cached;
    } else {
      final sendState = ref.read(sendViewModelProvider);
      if (sendState.networks.isNotEmpty) {
        banks = sendState.networks;
      } else if (widget.selectedData['networks'] != null) {
        banks = List<Network>.from(widget.selectedData['networks']);
      }
    }

    if (banks == null || banks.isEmpty) return;

    setState(() {
      _allNetworks = banks!;
      _applyNetworkFilter();
      _isLoadingNetworks = false;
    });
  }

  Future<void> _ensureBanksLoaded() async {
    if (_filteredNetworks.isNotEmpty) return;

    if (_filteredNetworks.isEmpty) {
      setState(() => _isLoadingNetworks = true);
    }

    try {
      final notifier = ref.read(sendViewModelProvider.notifier);
      List<Network> banks;

      if (_usesFlutterwaveBanks) {
        banks = await notifier.loadNigerianBanks();
      } else {
        final sendState = ref.read(sendViewModelProvider);
        if (sendState.networks.isEmpty) {
          await notifier.refreshPaymentNetworks();
        }
        banks = ref.read(sendViewModelProvider).networks;
      }

      if (!mounted) return;
      setState(() {
        _allNetworks = banks;
        _applyNetworkFilter();
        _networkError =
            _filteredNetworks.isEmpty ? 'No banks available right now' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _networkError ??= 'Error loading banks: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoadingNetworks = false);
    }
  }

  String? _bankCodeForNetwork(Network? network) {
    if (network == null) return null;
    final code = network.code;
    if (code is String && RegExp(r'^\d{3,6}$').hasMatch(code)) return code;
    if (code is Map) {
      final ng = code['NG'] ?? code['ng'];
      if (ng != null && RegExp(r'^\d{3,6}$').hasMatch(ng.toString())) {
        return ng.toString();
      }
    }
    final id = network.id ?? '';
    if (RegExp(r'^\d{3,6}$').hasMatch(id)) return id;
    return null;
  }

  /// Filter networks based on selected channel ID
  void _applyNetworkFilter() {
    if (_allNetworks.isEmpty) {
      _filteredNetworks = [];
      _searchedNetworks = [];
      return;
    }

    final isNgBank =
        _selectedCountry.toUpperCase() == 'NG' && _isBankDeliveryMethod;

    if (isNgBank &&
        (_selectedChannelId.isEmpty ||
            _selectedChannelId == 'ngn_bank_flutterwave')) {
      final banks =
          _allNetworks.where((network) {
            final ids = network.channelIds ?? [];
            if (ids.isEmpty || ids.contains('ngn_bank_flutterwave')) {
              return network.status == 'active' || network.status == null;
            }
            return false;
          }).toList();

      final list = banks.isNotEmpty ? banks : List<Network>.from(_allNetworks);
      list.sort(
        (a, b) => (a.name ?? '')
            .toLowerCase()
            .compareTo((b.name ?? '').toLowerCase()),
      );
      _filteredNetworks = list;
      _searchedNetworks = _filteredNetworks;
      return;
    }

    if (_selectedChannelId.isEmpty) {
      final targetCountry = _selectedCountry.toUpperCase();

      // If channelId is missing, don't dump *all* cached networks into the list.
      // Prefer filtering by `network.country` to avoid NG networks bleeding into ZA.
      final byCountry = _allNetworks.where((network) {
        final statusOk = network.status == 'active' || network.status == null;
        if (!statusOk) return false;
        final nCountry = network.country?.toUpperCase() ?? '';
        return nCountry.isNotEmpty ? nCountry == targetCountry : false;
      }).toList();

      _filteredNetworks = byCountry;
      _searchedNetworks = _filteredNetworks;
      return;
    }

    // Filter networks by channel ID - networks that support the selected channel.
    // Flutterwave NG banks use synthetic channel id `ngn_bank_flutterwave`.
    final channelNetworks =
        _allNetworks.where((network) {
          final ids = network.channelIds ?? [];
          final hasChannelId =
              ids.contains(_selectedChannelId) ||
              // Only allow Flutterwave NGN synthetic channel on NG routes.
              (isNgBank && ids.contains('ngn_bank_flutterwave'));
          return (network.status == 'active' || network.status == null) &&
              hasChannelId;
        }).toList();

    channelNetworks.sort((a, b) {
      final nameA = a.name ?? '';
      final nameB = b.name ?? '';
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    _filteredNetworks = channelNetworks;
    _searchedNetworks = _filteredNetworks;
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

      // Clear manual verification fields for non-verification countries
      _manualAccountNameController.clear();
      _hasConfirmedDetails = false;
    });

    _tryAutoVerifyAccount();
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
    if (_selectedNetwork?.name == 'Manual Input') {
      return; // No resolution for manual input
    }

    final accountNumber = _accountNumberController.text.trim();
    final deliveryMethod =
        widget.selectedData['recipientDeliveryMethod'] ?? 'bank';
    final minLength = AccountNumberUtils.getMinLength(
      _selectedCountry,
      deliveryMethod,
    );

    // If account number is reduced below minimum length, immediately clear everything
    if (accountNumber.length < minLength) {
      setState(() {
        _resolveError = null;
        _resolvedAccountName = null;
        _isResolving = false; // Stop any ongoing resolution
        _lastResolvedAccountNumber = null;
        _lastResolvedNetworkId = null;
      });
      return;
    }

    // If the account number changed from what was resolved, clear the resolution
    if (accountNumber != _lastResolvedAccountNumber ||
        _selectedNetworkId != _lastResolvedNetworkId) {
      setState(() {
        _resolveError = null;
        _resolvedAccountName = null;
        _lastResolvedAccountNumber = null;
        _lastResolvedNetworkId = null;
      });
    }

    _tryAutoVerifyAccount();
  }

  /// Resolve account name automatically when digits reach the required length.
  void _tryAutoVerifyAccount() {
    if (!_isVerificationSupported) return;
    if (_selectedNetwork == null || _selectedNetwork?.name == 'Manual Input') {
      return;
    }
    if (_isResolving) return;

    final accountNumber = _accountNumberController.text.trim();
    final deliveryMethod =
        widget.selectedData['recipientDeliveryMethod'] ?? 'bank';

    if (accountNumber == _lastResolvedAccountNumber &&
        _selectedNetworkId == _lastResolvedNetworkId &&
        _resolvedAccountName != null) {
      return;
    }

    if (!AccountNumberUtils.isAccountNumberComplete(
          accountNumber,
          _selectedCountry,
          deliveryMethod,
        ) ||
        !RegExp(r'^\d+$').hasMatch(accountNumber)) {
      return;
    }

    _resolveAccount(accountNumber);
  }

  Future<void> _pasteAccountNumber() async {
    if (_selectedNetwork == null) return;

    HapticHelper.lightImpact();
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final raw = clipboardData?.text?.trim();
    if (raw == null || raw.isEmpty) return;

    final deliveryMethod =
        widget.selectedData['recipientDeliveryMethod'] ?? 'bank';
    final maxLength = AccountNumberUtils.getMaxLength(
      _selectedCountry,
      deliveryMethod,
    );
    var sanitized = AccountNumberUtils.sanitizeDigits(raw, _selectedCountry);
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    _accountNumberController.value = TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: sanitized.length),
    );
    _onAccountNumberChanged();
    if (mounted) setState(() {});
  }

  Widget? _buildAccountNumberSuffixIcon() {
    if (_isResolving) {
      return Container(
        margin: const EdgeInsets.all(12),
        child: LoadingAnimationWidget.horizontalRotatingDots(
          color: AppColors.purple500ForTheme(context),
          size: 22,
        ),
      );
    }

    if (_resolvedAccountName != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: SvgPicture.asset(
          'assets/icons/svgs/circle-check.svg',
          width: 26,
          height: 26,
          color: AppColors.success600,
        ),
      );
    }

    if (_resolveError != null && _accountNumberController.text.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          _accountNumberController.clear();
          setState(() {
            _resolveError = null;
            _resolvedAccountName = null;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            'assets/icons/svgs/circle-x.svg',
            width: 26,
            height: 26,
            color: AppColors.error600,
          ),
        ),
      );
    }

    if (_selectedNetwork != null &&
        _resolvedAccountName == null &&
        !_isResolving) {
      return GestureDetector(
        onTap: _pasteAccountNumber,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Paste',
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  letterSpacing: 0,
                  height: 1.450,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 6),
              SvgPicture.asset(
                'assets/icons/svgs/paste.svg',
                color: Theme.of(context).colorScheme.primary,
                height: 16,
              ),
            ],
          ),
        ),
      );
    }

    return null;
  }

  Future<void> _resolveAccount(String accountNumber) async {
    if (_isResolving) return; // Prevent multiple simultaneous calls

    // Don't attempt verification for countries without support
    if (!_isVerificationSupported) {
      return;
    }

    // Ensure both network and account number are available
    if (_selectedNetwork == null || _selectedNetworkId.isEmpty) {
      setState(() {
        _resolveError = 'Please select a $_providerTypeName first';
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
        bankCode: _bankCodeForNetwork(_selectedNetwork),
      );

      // Check if the account number still meets minimum length after the API call
      // This prevents showing results for outdated account numbers
      final deliveryMethod =
          widget.selectedData['recipientDeliveryMethod'] ?? 'bank';
      final minLength = AccountNumberUtils.getMinLength(
        _selectedCountry,
        deliveryMethod,
      );
      if (_accountNumberController.text.trim().length < minLength) {
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
        _resolveError = e.toString();
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
                      height: 40,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            // size: 20,
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
                  fontSize: 24,
                  // height: 1.6,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              centerTitle: true,
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth > 600;
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 500 : double.infinity,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 24 : 18,
                        vertical: 8,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            DayfiScreenDescription(
                              text:
                                  _saveRecipientOnly
                                      ? SendCopy.saveRecipient
                                      : SendCopy.addRecipient,
                              bottomSpacing: 32,
                            ),
                            // Network Selection Field
                            _buildNetworkSelectionField(),
                            if (_selectedNetwork == null) ...[
                              SizedBox(height: 8),
                              Center(
                                // padding: EdgeInsets.only(left: 16),
                                child: Text(
                                  _isBankDeliveryMethod
                                      ? 'Select a bank to enable account resolution'
                                      : 'Select a mobile money provider to enable account resolution',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontFamily: 'Chirp',
                                    fontSize: 12.5,
                                    letterSpacing: -.25,
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
                                      fontFamily: 'Chirp',
                                      fontSize: 12.5,
                                      letterSpacing: -.25,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                                : SizedBox(height: 0),

                            _networkController.text == 'Manual Input'
                                ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "Manual Input allows you to enter bank details directly for transfers to any bank in ${_getCountryName(_selectedCountry)}. Please provide the bank name and account holder name.",
                                    style: AppTypography.bodySmall.copyWith(
                                      fontFamily: 'Chirp',
                                      fontSize: 12.5,
                                      letterSpacing: -.25,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                                : SizedBox(height: 0),

                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              height:
                                  (_selectedNetwork?.name == 'Manual Input')
                                      ? 180
                                      : 0,
                              child:
                                  (_selectedNetwork?.name == 'Manual Input')
                                      ? Padding(
                                        padding: EdgeInsets.only(top: 18),
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
                                            SizedBox(height: 18),
                                            CustomTextField(
                                              controller:
                                                  _accountNameController,
                                              label: 'Account Name',
                                              hintText:
                                                  'Enter account holder name',
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
                              SizedBox(height: 16),
                              Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.error50,
                                    borderRadius: BorderRadius.circular(20),
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
                                        size: 14,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        _isBankDeliveryMethod
                                            ? 'No banks available for this delivery method'
                                            : 'No providers available for this delivery method',
                                        style: TextStyle(
                                          fontFamily: 'Chirp',
                                          fontSize: 13,
                                          letterSpacing: -.25,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.error700,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: 18),

                            // Account Number Field (Required)
                            CustomTextField(
                              controller: _accountNumberController,
                              label:
                                  _selectedNetwork?.name == 'Manual Input'
                                      ? 'Account Number'
                                      : _isBankDeliveryMethod
                                      ? 'Account Number'
                                      : 'Mobile Money Number',
                              hintText:
                                  _selectedNetwork == null
                                      ? _isBankDeliveryMethod
                                          ? 'Select a bank first'
                                          : 'Select a mobile money provider first'
                                      : AccountNumberUtils.getAccountNumberHint(
                                        _selectedCountry,
                                        widget.selectedData['recipientDeliveryMethod'] ??
                                            'bank',
                                      ),
                              keyboardType: TextInputType.phone,
                              autocorrect: false,
                              enableSuggestions: false,
                              formatter: AccountNumberInputFormatter(
                                countryCode: _selectedCountry,
                                maxLength: AccountNumberUtils.getMaxLength(
                                  _selectedCountry,
                                  widget.selectedData['recipientDeliveryMethod'] ??
                                      'bank',
                                ),
                              ),
                              maxLength: AccountNumberUtils.getMaxLength(
                                _selectedCountry,
                                widget.selectedData['recipientDeliveryMethod'] ??
                                    'bank',
                              ),
                              enabled: _selectedNetwork != null,
                              suffixIcon: _buildAccountNumberSuffixIcon(),
                              validator: (value) {
                                if (_selectedNetwork == null) {
                                  return 'Please select a $_providerTypeName first';
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter account number';
                                }
                                final validationError =
                                    AccountNumberUtils.validateAccountNumber(
                                      value.trim(),
                                      _selectedCountry,
                                      widget.selectedData['recipientDeliveryMethod'] ??
                                          'bank',
                                    );
                                if (validationError != null) {
                                  return validationError;
                                }
                                if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        key: ValueKey('error'),
                                        children: [
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: AppColors.error600,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                _resolveError!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontFamily: 'Chirp',
                                                      fontSize: 14,
                                                      letterSpacing: -.25,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors.error700,
                                                      height: 1.3,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                      : _resolvedAccountName != null
                                      ? Column(
                                        key: ValueKey('success'),
                                        children: [
                                          SizedBox(height: 12),
                                          Center(
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: AppColors.success50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: AppColors.success200,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Text(
                                                _resolvedAccountName!,
                                                style: TextStyle(
                                                  fontFamily: 'Chirp',
                                                  fontSize: 14,
                                                  letterSpacing: -.25,
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

                            // UI for countries without verification support
                            if (!_isVerificationSupported &&
                                _selectedNetwork != null &&
                                _selectedNetwork!.name != 'Manual Input') ...[
                              SizedBox(height: 8),

                              // Info banner about verification unavailability
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text(
                                  'Account verification isn\'t available in ${_getCountryName(_selectedCountry)} yet. Please enter the account holder\'s name and confirm the details are correct.',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontFamily: 'Chirp',
                                    fontSize: 12.5,
                                    letterSpacing: -.25,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: 16),

                              // Manual account holder name field
                              CustomTextField(
                                controller: _manualAccountNameController,
                                label: 'Account Holder Name',
                                hintText: 'Enter the recipient\'s full name',
                                textCapitalization: TextCapitalization.words,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter the account holder\'s name';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 16),

                              // Confirmation checkbox
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _hasConfirmedDetails =
                                        !_hasConfirmedDetails;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Checkbox(
                                          value: _hasConfirmedDetails,
                                          onChanged: (value) {
                                            setState(() {
                                              _hasConfirmedDetails =
                                                  value ?? false;
                                            });
                                          },
                                          activeColor: AppColors.purple500,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'I confirm the recipient details are correct',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontFamily: 'Chirp',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: -0.20,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            // SizedBox(height: 24),

                            // // Optional Fields Section
                            // Center(
                            //   child: Padding(
                            //     padding: EdgeInsets.symmetric(
                            //       vertical: 4,
                            //       horizontal: 2,
                            //     ),
                            //     child: Text(
                            //       'Additional Information',
                            //       style: Theme.of(
                            //         context,
                            //       ).textTheme.titleMedium?.copyWith(
                            //      fontFamily: 'FunnelDisplay',
                            //         fontSize: 12.5,
                            //         fontWeight: FontWeight.w600,
                            //         // color: AppColors.neutral900,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(height: 18),

                            // // Phone Number (Optional)
                            // _buildPhoneNumberField(),

                            // SizedBox(height: 18),

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

                            // SizedBox(height: 18),

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

                            // SizedBox(height: 18),

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
                            SizedBox(height: 18),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
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
                                  SizedBox(width: 4),
                                  Image.asset(
                                    "assets/images/idea.png",
                                    height: 20,
                                    // color: Theme.of(context).colorScheme.primary,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "By continuing with this payment you are confirming that, to the best of your knowledge, the details you are providing are correct.",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        fontFamily: 'Chirp',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.4,
                                        height: 1.5,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 32),

                            // Continue Button
                       Padding(padding: EdgeInsets.symmetric(horizontal: 18), child:     PrimaryButton(
                              text: _saveRecipientOnly ? 'Save Recipient' : 'Enter Amount',
                              onPressed: _validateAndContinue,
                              enabled: _isFormValid(),
                              height: 48.00000,
                              backgroundColor:
                                  _isFormValid()
                                      ? AppColors.purple500
                                      : AppColors.purple500.withOpacity(.25),
                              textColor:
                                  _isFormValid()
                                      ? AppColors.neutral0
                                      : AppColors.neutral0.withOpacity(.20),
                              fontFamily: 'Chirp',
                              letterSpacing: -.70,
                              fontSize: 18,
                              width: double.infinity,
                              fullWidth: true,
                              borderRadius: 40,
                            ),),

                            SizedBox(height: 20),

                            if (!_saveRecipientOnly)
                              Center(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    // padding: EdgeInsets.zero,
                                    // minimumSize: Size(50, 30),
                                    splashFactory: NoSplash.splashFactory,
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.transparent,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    alignment: Alignment.center,
                                  ),
                                  onPressed: () async {
                                  unawaited(
                                    ref
                                        .read(recipientsProvider.notifier)
                                        .loadBeneficiaries(),
                                  );
                                  final result = await showAppBottomSheet<
                                    BeneficiaryWithSource
                                  >(
                                    context: context,
                                    isScrollControlled: true,
                                    barrierColor: Colors.black.withOpacity(
                                      0.85,
                                    ),
                                    backgroundColor:
                                        Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                    builder:
                                        (context) => Consumer(
                                          builder: (context, sheetRef, _) {
                                            final recipientsState = sheetRef
                                                .watch(recipientsProvider);
                                            final allBeneficiaries =
                                                RecipientHistoryHelper
                                                    .filterForSendContext(
                                                      recipientsState
                                                          .beneficiaries,
                                                      deliveryMethod: widget
                                                              .selectedData[
                                                          'recipientDeliveryMethod']
                                                          ?.toString(),
                                                      receiveCountry: widget
                                                              .selectedData[
                                                          'receiveCountry']
                                                          ?.toString(),
                                                      receiveCurrency: widget
                                                              .selectedData[
                                                          'receiveCurrency']
                                                          ?.toString(),
                                                    );

                                            return StatefulBuilder(
                                              builder: (
                                                context,
                                                setModalState,
                                              ) {
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
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            20,
                                                          ),
                                                        ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(height: 18),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 18,
                                                            ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            SizedBox(
                                                              height: 40,
                                                              width: 40,
                                                            ),
                                                            Text(
                                                              'Select Beneficiary',
                                                              style: AppTypography.titleLarge.copyWith(
                                                                fontFamily:
                                                                    'FunnelDisplay',
                                                                fontSize: 20,
                                                                // height: 1.6,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
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
                                                                  Colors
                                                                      .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap:
                                                                  () =>
                                                                      Navigator.pop(
                                                                        context,
                                                                      ),
                                                              child: Stack(
                                                                alignment:
                                                                    AlignmentGeometry
                                                                        .center,
                                                                children: [
                                                                  SvgPicture.asset(
                                                                    "assets/icons/svgs/notificationn.svg",
                                                                    height: 40,
                                                                    color:
                                                                        Theme.of(
                                                                          context,
                                                                        ).colorScheme.surface,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 40,
                                                                    width: 40,
                                                                    child: Center(
                                                                      child: Image.asset(
                                                                        "assets/icons/pngs/cancelicon.png",
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            20,
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
                                                      SizedBox(height: 9),
                                                      Expanded(
                                                        child: SingleChildScrollView(
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                height: 9,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          24.0,
                                                                    ),
                                                                child: Opacity(
                                                                  opacity: .85,
                                                                  child: Text(
                                                                    'Choose a recent beneficiary to auto-fill recipient details',
                                                                    style: Theme.of(
                                                                      context,
                                                                    ).textTheme.bodyMedium?.copyWith(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontFamily:
                                                                          'Chirp',
                                                                      letterSpacing:
                                                                          -.3,
                                                                      height:
                                                                          1.5,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 32,
                                                              ),
                                                              allBeneficiaries
                                                                      .isEmpty
                                                                  ? Center(
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        SizedBox(
                                                                          height:
                                                                              16,
                                                                        ),
                                                                        SvgPicture.asset(
                                                                          'assets/icons/svgs/search-normal.svg',
                                                                          height:
                                                                              64,
                                                                          color: Theme.of(
                                                                            context,
                                                                          ).colorScheme.onSurface.withOpacity(
                                                                            0.6,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              16,
                                                                        ),
                                                                        Text(
                                                                          'No beneficiaries found',
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                'FunnelDisplay',
                                                                            fontSize:
                                                                                16,
                                                                            color: Theme.of(
                                                                              context,
                                                                            ).colorScheme.onSurface.withOpacity(
                                                                              0.6,
                                                                            ),
                                                                          ),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              8,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                32.0,
                                                                          ),
                                                                          child: Text(
                                                                            'No recent beneficiaries for this country and payment type',
                                                                            style: AppTypography.bodyMedium.copyWith(
                                                                              fontFamily:
                                                                                  'Chirp',
                                                                              fontSize:
                                                                                  14,
                                                                              color: Theme.of(
                                                                                context,
                                                                              ).colorScheme.onSurface.withOpacity(
                                                                                0.4,
                                                                              ),
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                  : Container(
                                                                    margin: EdgeInsets.only(
                                                                      left: 18,
                                                                      right: 18,
                                                                      bottom:
                                                                          20,
                                                                      // top: 16,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          Theme.of(
                                                                            context,
                                                                          ).colorScheme.surface,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    child: ListView.separated(
                                                                      shrinkWrap:
                                                                          true,
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
                                                                                12,
                                                                          ),
                                                                      itemBuilder: (
                                                                        context,
                                                                        index,
                                                                      ) {
                                                                        final b =
                                                                            allBeneficiaries[index];
                                                                        return AnimatedContainer(
                                                                          key: ValueKey(
                                                                            b.beneficiary.id,
                                                                          ),
                                                                          duration: const Duration(
                                                                            milliseconds:
                                                                                200,
                                                                          ),
                                                                          curve:
                                                                              Curves.easeOut,
                                                                          transform: Matrix4.diagonal3Values(
                                                                            1.0,
                                                                            1.0,
                                                                            1.0,
                                                                          ),
                                                                          child: Container(
                                                                            margin: EdgeInsets.only(
                                                                              bottom:
                                                                                  8,
                                                                              top:
                                                                                  8,
                                                                            ),
                                                                            padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  16,
                                                                              vertical:
                                                                                  12,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              color:
                                                                                  Theme.of(
                                                                                    context,
                                                                                  ).colorScheme.surface,
                                                                              borderRadius: BorderRadius.circular(
                                                                                12,
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
                                                                                  RecipientAvatarBadge(
                                                                                    entry: b,
                                                                                    flagPathForCountry:
                                                                                        _getFlagPath,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width:
                                                                                        10,
                                                                                  ),
                                                                                  // Beneficiary Info
                                                                                  Expanded(
                                                                                    child: Column(
                                                                                      crossAxisAlignment:
                                                                                          CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          RecipientHistoryHelper.primaryLabel(
                                                                                            b.beneficiary,
                                                                                            b.source,
                                                                                          ).toUpperCase(),
                                                                                          style: AppTypography.bodyLarge.copyWith(
                                                                                            fontFamily:
                                                                                                'Chirp',
                                                                                            fontSize:
                                                                                                16,
                                                                                            fontWeight:
                                                                                                FontWeight.w600,
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height:
                                                                                              2,
                                                                                        ),
                                                                                        Text(
                                                                                          (() {
                                                                                            if (RecipientHistoryHelper.isDayfiRecipient(b)) {
                                                                                              return RecipientHistoryHelper.secondaryLabel(
                                                                                                b.beneficiary,
                                                                                                b.source,
                                                                                                ledgerCurrency: b.ledgerCurrency,
                                                                                              );
                                                                                            }
                                                                                            final notifier =
                                                                                                ref.read(
                                                                                                  sendViewModelProvider.notifier,
                                                                                                );
                                                                                            final resolvedNetwork =
                                                                                                notifier.findNetworkById(
                                                                                                  b.source.networkId,
                                                                                                );
                                                                                            final label =
                                                                                                RecipientHistoryHelper.recipientChannelLabel(
                                                                                                  b,
                                                                                                  networkName:
                                                                                                      resolvedNetwork?.name,
                                                                                                );
                                                                                            final acct =
                                                                                                b.source.accountNumber ??
                                                                                                b.beneficiary.accountNumber ??
                                                                                                '';
                                                                                            return acct.isNotEmpty
                                                                                                ? '$label · $acct'
                                                                                                : label;
                                                                                          })(),
                                                                                          style: AppTypography.bodyMedium.copyWith(
                                                                                            fontFamily:
                                                                                                'Chirp',
                                                                                            fontSize:
                                                                                                13,
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
                                                                                        12,
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
                                    _applyBeneficiarySelection(result);
                                  }
                                },
                                child: Text(
                                  'See recents and beneficiaries',
                                  style: TextStyle(
                                    fontFamily: 'Chirp',
                                    color: AppColors.purple500ForTheme(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -.40,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ), // Loading overlay that freezes the screen during account resolution
        if (_isResolving)
          Container(
            color: Colors.black.withOpacity(0.5),
            // child: Center(child: CupertinoActivityIndicator()),
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
              : _isBankDeliveryMethod
              ? 'Bank Name'
              : 'Mobile Money Provider',
      hintText: _getNetworkHintText(),
      shouldReadOnly: true,
      onTap:
          _filteredNetworks.isNotEmpty
              ? _showNetworkBottomSheet
              : () {
                _ensureBanksLoaded();
              },
      suffixIcon: _buildNetworkSuffixIcon(),
      errorText: _networkError,
      validator: (value) {
        if (_selectedNetwork == null) {
          return _isBankDeliveryMethod
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
      case 'dayfi_tag':
        return UsernameCopy.label;
      case 'bank_transfer':
      case 'bank':
        return 'Bank Transfer';
      case 'p2p':
      case 'peer_to_peer':
      case 'peer-to-peer':
        return 'Bank Transfer (P2P)';
      case 'eft':
        return 'Bank Transfer (EFT)';
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
        return 'Wallet';
      case 'card':
      case 'card_payment':
        return 'Card';
      case 'crypto':
      case 'cryptocurrency':
        return 'Crypto';
      case 'digital_dollar':
      case 'stablecoins':
        return 'Digital Dollar';
      default:
        return method
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  /// Check if the delivery method is bank-related
  bool get _isBankDeliveryMethod => _isBankRecipientDeliveryMethod(
    widget.selectedData['recipientDeliveryMethod'] as String?,
  );

  /// Get the provider type name based on delivery method
  String get _providerTypeName {
    return _isBankDeliveryMethod ? 'bank' : 'mobile money provider';
  }

  /// Get the hint text based on current state
  String _getNetworkHintText() {
    if (_isLoadingNetworks) {
      return _isBankDeliveryMethod
          ? 'Select a bank'
          : 'Select a mobile money provider';
    } else if (_networkError != null) {
      return _isBankDeliveryMethod
          ? 'Error loading banks'
          : 'Error loading mobile money providers';
    } else if (_filteredNetworks.isEmpty) {
      return _isBankDeliveryMethod
          ? 'No banks available for this country'
          : 'No mobile money providers available for this country';
    } else {
      return _isBankDeliveryMethod
          ? 'Select a bank'
          : 'Select a mobile money provider';
    }
  }

  /// Build the suffix icon based on current state
  Widget? _buildNetworkSuffixIcon() {
    if (_isLoadingNetworks) {
      return Container(
        margin: EdgeInsets.all(12),
        child: LoadingAnimationWidget.horizontalRotatingDots(
          color: AppColors.purple500ForTheme(context),
          size: 20,
        ),
      );
    } else if (_networkError != null) {
      return Icon(Icons.error_outline, color: AppColors.error600, size: 20);
    } else if (_filteredNetworks.isNotEmpty) {
      return Icon(
        Icons.keyboard_arrow_down,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        size: 24,
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
          height: 36,
          width: 36,
        );
      case 'phone':
        return SvgPicture.asset(
          'assets/icons/svgs/device-mobile.svg',
          height: 36,
          width: 36,
        );
      default:
        return SvgPicture.asset(
          'assets/icons/svgs/paymentt.svg',
          height: 36,
          width: 36,
        );
    }
  }

  /// Get account type from delivery method
  String _getAccountTypeFromDeliveryMethod() {
    return RecipientHistoryHelper.accountTypeFromDeliveryMethod(
      widget.selectedData['recipientDeliveryMethod'] as String?,
    );
  }

  /// Get display name for account type
  String _getAccountTypeDisplayName(String accountType) {
    switch (accountType) {
      case 'bank':
        return 'Bank Account';
      case 'phone':
      case 'mobile_money':
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
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 18),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(height: 40, width: 40),
                            Text(
                              'Select ${_getAccountTypeFromDeliveryMethod() == 'bank' ? 'Bank' : 'Mobile Money Provider'}',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                fontFamily: 'FunnelDisplay',
                                fontSize: 20,
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
                                    height: 40,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Center(
                                      child: Image.asset(
                                        "assets/icons/pngs/cancelicon.png",
                                        height: 20,
                                        width: 20,
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
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: CustomTextField(
                          isSearch: true,
                          controller: _networkSearchController,
                          label: '',
                          hintText:
                              'Search ${_isBankDeliveryMethod ? 'banks' : 'mobile money providers'} ',
                          borderRadius: 40,
                          prefixIcon: Container(
                            width: 40,
                            alignment: Alignment.centerRight,
                            constraints: BoxConstraints.tightForFinite(),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/svgs/search-normal.svg',
                                height: 26,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            _filterNetworksBySearch(value);
                            setModalState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child:
                            _searchedNetworks.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/svgs/search-normal.svg',
                                        height: 64,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No ${_getAccountTypeFromDeliveryMethod() == 'bank' ? 'banks' : 'mobile money providers'} found',
                                        style: TextStyle(
                                          fontFamily: 'FunnelDisplay',
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try searching with different keywords',
                                        style: AppTypography.bodyMedium
                                            .copyWith(
                                              fontFamily: 'Chirp',
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.4),
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    0,
                                    18,
                                    24,
                                  ),
                                  itemCount: _searchedNetworks.length,
                                  itemBuilder: (context, index) {
                                    final network = _searchedNetworks[index];
                                    final isSelected =
                                        _selectedNetwork?.id == network.id;

                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                      title: Text(
                                        network.name?.replaceAll('_', ' ') ??
                                            'Unknown Network',
                                        style: AppTypography.bodyLarge
                                            .copyWith(
                                              fontFamily: 'Chirp',
                                              fontSize: 16,
                                              letterSpacing: -.4,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
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

  Future<void> _validateAndContinue() async {
    // Determine if form is valid based on verification support
    final isManualInput = _selectedNetwork?.name == 'Manual Input';
    final hasVerifiedAccount =
        _resolvedAccountName != null && _resolvedAccountName!.isNotEmpty;
    final hasManualAccountName =
        _manualAccountNameController.text.trim().isNotEmpty;

    // Form is valid if:
    // 1. Manual Input mode with required fields, OR
    // 2. Verification supported country with verified account, OR
    // 3. Non-verification country with manual account name and confirmation
    final isValid =
        _formKey.currentState!.validate() &&
        _selectedNetwork != null &&
        (isManualInput ||
            (_isVerificationSupported && hasVerifiedAccount) ||
            (!_isVerificationSupported &&
                hasManualAccountName &&
                _hasConfirmedDetails));

    if (isValid) {
      analyticsService.logEvent(
        name: 'recipient_added',
        parameters: {
          'country': _selectedCountry,
          'networkId': _selectedNetworkId,
          'verification_supported': _isVerificationSupported,
        },
      );

      // Determine the account name based on the mode
      String accountName;
      if (isManualInput) {
        accountName = _accountNameController.text.trim();
      } else if (_isVerificationSupported && hasVerifiedAccount) {
        accountName = _resolvedAccountName!.trim();
      } else {
        accountName = _manualAccountNameController.text.trim();
      }

      final bankCode = _bankCodeForNetwork(_selectedNetwork);
      final sendNotifier = ref.read(sendViewModelProvider.notifier);
      await sendNotifier.initialize();
      final deliveryMethod =
          widget.selectedData['recipientDeliveryMethod']?.toString() ?? 'bank';
      final receiveCurrency =
          widget.selectedData['receiveCurrency']?.toString() ?? 'NGN';
      final resolvedChannelId = sendNotifier.resolveRecipientChannelId(
        receiveCountry: _selectedCountry,
        receiveCurrency: receiveCurrency,
        deliveryMethod: deliveryMethod,
        networkId: _selectedNetworkId,
        existingChannelId:
            widget.selectedData['recipientChannelId']?.toString(),
      );
      final recipientData = {
        'name': accountName,
        'country': _selectedCountry,
        'phone':
            _getFormattedPhoneNumber(), // Use formatted phone number with country code
        'address': _addressController.text.trim(),
        'dob': _dobController.text.trim(),
        'email': _emailController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'networkId': _selectedNetworkId,
        if (bankCode != null) 'bankCode': bankCode,
        'bankName': isManualInput
            ? _bankNameController.text.trim()
            : (_selectedNetwork?.name ?? ''),
        'networkName': isManualInput
            ? _bankNameController.text.trim()
            : (_selectedNetwork?.name ?? ''),
        'accountName':
            isManualInput ? _accountNameController.text.trim() : accountName,
        'recipientDeliveryMethod': deliveryMethod,
        if (resolvedChannelId != null) 'recipientChannelId': resolvedChannelId,
        'isVerified': _isVerificationSupported && hasVerifiedAccount,
      };

      if (_saveRecipientOnly) {
        final accountType = RecipientHistoryHelper.accountTypeFromDeliveryMethod(
          widget.selectedData['recipientDeliveryMethod'] as String?,
        );
        final currency =
            widget.selectedData['receiveCurrency']?.toString() ?? 'NGN';
        final entry = RecipientSaveHelper.bankOrMobile(
          name: accountName,
          country: _selectedCountry,
          currency: currency,
          accountNumber: _accountNumberController.text.trim(),
          networkId: _selectedNetworkId,
          accountType: accountType,
          phone: _getFormattedPhoneNumber(),
          bankName: _selectedNetwork?.name,
        );
        await RecipientSaveHelper.save(ref, entry);
        if (!mounted) return;
        RecipientSaveHelper.completeSaveRecipientOnlyNavigation(context);
        return;
      }

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
          'selectedData': {
            ...widget.selectedData,
            ...payWithRouteArgs(
              payWithCurrency: ref.read(selectedDebitCurrencyProvider),
              receiveCurrency:
                  widget.selectedData['receiveCurrency']?.toString() ?? 'NGN',
            ),
          },
          'recipientData': recipientData,
          'senderData': senderData,
        },
      );
    } else {
      String errorMessage = 'Please complete the following:';
      if (_selectedNetwork == null) {
        errorMessage +=
            '\n• ${_isBankDeliveryMethod ? 'Select a bank' : 'Select a mobile money provider'}';
      } else if (_isVerificationSupported) {
        if (!hasVerifiedAccount) {
          errorMessage +=
              '\n• Verify the account number to confirm the recipient name';
        }
      } else {
        if (!hasManualAccountName) {
          errorMessage += '\n• Enter the recipient\'s account holder name';
        }
        if (!_hasConfirmedDetails) {
          errorMessage += '\n• Confirm that the recipient details are correct';
        }
      }

      TopSnackbar.show(context, message: errorMessage, isError: true);
    }
  }

  /// Check if the form is valid for submission
  bool _isFormValid() {
    // Check if network is selected
    if (_selectedNetwork == null) return false;

    final deliveryMethod =
        widget.selectedData['recipientDeliveryMethod'] ?? 'bank';

    if (_selectedNetwork!.name == 'Manual Input') {
      // For manual input, check bank name, account name, and account number
      if (_bankNameController.text.trim().isEmpty ||
          _accountNameController.text.trim().isEmpty ||
          _accountNumberController.text.trim().isEmpty) {
        return false;
      }
    } else {
      // Check if account number is valid using dynamic validation
      final accountNumber = _accountNumberController.text.trim();
      if (!AccountNumberUtils.isAccountNumberComplete(
            accountNumber,
            _selectedCountry,
            deliveryMethod,
          ) ||
          !RegExp(r'^\d+$').hasMatch(accountNumber)) {
        return false;
      }

      // For countries with verification support, require resolved account name
      if (_isVerificationSupported) {
        if (_resolvedAccountName == null || _resolvedAccountName!.isEmpty) {
          return false;
        }
      } else {
        // For countries without verification, require manual account name and confirmation
        if (_manualAccountNameController.text.trim().isEmpty ||
            !_hasConfirmedDetails) {
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
            padding: EdgeInsets.only(left: 16, top: 12),
            child: Text(
              "${countryInfo?.countryCode ?? '+234'}     ",
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: 'Chirp',
                fontSize: 16,
                letterSpacing: -.25,
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
        //   SizedBox(height: 4),
        //   Text(
        //     'Enter ${countryInfo.maxLength} digits for ${countryInfo.name}',
        //     style: AppTypography.bodySmall.copyWith(
        //       fontFamily: 'Chirp',
        //       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        //     ),
        //   ),
        // ],
      ],
    );
  }
}
