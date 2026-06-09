import 'package:dayfi/common/utils/ui_helpers.dart';
import 'package:dayfi/common/constants/username_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/routes/route.dart';
import 'dart:async';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/features/send/send_flow.dart';
import 'package:dayfi/features/recipients/helpers/recipient_save_helper.dart';
import 'package:dayfi/features/recipients/widgets/recipient_avatar_badge.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/features/wallet/constants/global_wallet.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';

class SendDayfiIdView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;

  const SendDayfiIdView({super.key, required this.selectedData});

  @override
  ConsumerState<SendDayfiIdView> createState() => _SendDayfiIdViewState();
}

class _SendDayfiIdViewState extends ConsumerState<SendDayfiIdView> {
  final _formKey = GlobalKey<FormState>();
  final _dayfiIdController = TextEditingController();
  Timer? _debounceTimer;
  bool _isValidating = false;
  String? _validationError;
  String? _validatedDayfiId;
  String? _recipientName;

  String? _myDayfiId;

  bool get _saveRecipientOnly =>
      widget.selectedData['saveRecipientOnly'] == true;

  @override
  void initState() {
    super.initState();
    final prefillTag = (widget.selectedData['accountNumber'] ??
            widget.selectedData['dayfiId'] ??
            widget.selectedData['recipientTag'])
        ?.toString()
        .replaceFirst('@', '')
        .trim();
    if (prefillTag != null && prefillTag.isNotEmpty) {
      _dayfiIdController.text = prefillTag;
      _validatedDayfiId = prefillTag;
      _recipientName = widget.selectedData['recipientName']?.toString();
    }
    _loadMyDayfiId();
    if (_validatedDayfiId != null && _validatedDayfiId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _validateDayfiId(_validatedDayfiId!);
      });
    }
  }

  Future<void> _loadMyDayfiId() async {
    try {
      final localCache = locator<LocalCache>();
      final userData = await localCache.getUser();

      String? myDayfi;
      if (userData.containsKey('dayfi_id')) {
        myDayfi = (userData['dayfi_id'] ?? '').toString().trim();
      }
      if ((myDayfi == null || myDayfi.isEmpty) &&
          userData.containsKey('dayfiId')) {
        myDayfi = (userData['dayfiId'] ?? '').toString().trim();
      }

      if (mounted) {
        setState(() {
          _myDayfiId = myDayfi;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading my Dayfi Tag: $e');
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _dayfiIdController.dispose();
    super.dispose();
  }

  Future<void> _validateDayfiId(String dayfiId) async {
    if (dayfiId.isEmpty) {
      if (mounted) {
        setState(() {
          _validationError = null;
          _validatedDayfiId = null;
          _recipientName = null;
        });
      }
      return;
    }

    // Remove @ if present for validation
    final cleanDayfiId = dayfiId.replaceAll('@', '').trim();

    if (cleanDayfiId.length < 3) {
      if (mounted) {
        setState(() {
          _validationError = 'Minimum 3 characters required';
          _validatedDayfiId = null;
          _recipientName = null;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isValidating = true;
        _validationError = null;
        _recipientName = null;
      });
    }

    try {
      final authService = locator<AuthService>();
      final response = await authService.validateDayfiId(dayfiId: cleanDayfiId);

      if (!mounted) return;

      if (response.error == false) {
        // Extract recipient name from response if available

        String? recipientDisplayName;
        String? recipientCurrency;
        String? recipientCountry;
        try {
          if (response.data != null) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('first_name') || data.containsKey('last_name')) {
              final firstName = data['first_name']?.toString() ?? '';
              final lastName = data['last_name']?.toString() ?? '';
              recipientDisplayName = '$firstName $lastName'.trim();
            }
            if (recipientDisplayName == null || recipientDisplayName.isEmpty) {
              final accountName = data['account_name']?.toString() ??
                  data['accountName']?.toString() ??
                  data['name']?.toString();
              if (accountName != null && accountName.trim().isNotEmpty) {
                recipientDisplayName = accountName.trim();
              }
            }
            if (recipientDisplayName == null || recipientDisplayName.isEmpty) {
              recipientDisplayName = '@$cleanDayfiId';
            }
            // Get recipient currency and country from API response
            if (data.containsKey('currency')) {
              recipientCurrency = data['currency']?.toString();
            }
            if (data.containsKey('country')) {
              recipientCountry = data['country']?.toString();
            }
          }
        } catch (e) {
          AppLogger.debug('Could not extract recipient name/currency/country: $e');
        }

        // Validate currency-country match
        String? selectedCountry = widget.selectedData['country']?.toString();
        String? expectedCurrency;
        // Map country code to expected currency (expand as needed)
        if (selectedCountry != null) {
          switch (selectedCountry.toUpperCase()) {
            case 'NG':
              expectedCurrency = 'NGN';
              break;
            case 'GH':
              expectedCurrency = 'GHS';
              break;
            case 'KE':
              expectedCurrency = 'KES';
              break;
            case 'RW':
              expectedCurrency = 'RWF';
              break;
            // Add more country-currency mappings as needed
            default:
              expectedCurrency = null;
          }
        }

        // Error if recipient country from API does not match selected country
        if (selectedCountry != null && recipientCountry != null && recipientCountry.toLowerCase() != selectedCountry.toLowerCase()) {
          if (mounted) {
            setState(() {
              _validationError = 'Recipient country ($recipientCountry) does not match selected country ($selectedCountry)';
              _validatedDayfiId = null;
              _recipientName = null;
            });
          }
          return;
        }

        if (expectedCurrency != null && recipientCurrency != null && recipientCurrency != expectedCurrency) {
          if (mounted) {
            setState(() {
              _validationError = 'Recipient currency ($recipientCurrency) does not match selected country ($selectedCountry)';
              _validatedDayfiId = null;
              _recipientName = null;
            });
          }
          return;
        }

        if (mounted) {
          setState(() {
            _validatedDayfiId = cleanDayfiId;
            _recipientName = recipientDisplayName ?? '@$cleanDayfiId';
            _validationError = null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _validationError = UsernameCopy.notFound;
            _validatedDayfiId = null;
            _recipientName = null;
          });
        }
      }
    } catch (e) {
      AppLogger.error('UsernameCopy.validationError: $e');
      if (mounted) {
        setState(() {
          _validationError = 'Unable to verify username';
          _validatedDayfiId = null;
          _recipientName = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  void _onDayfiIdChanged(String value) {
    // Remove @ if user types it
    if (value.startsWith('@')) {
      final cleanValue = value.substring(1);
      if (_dayfiIdController.text != cleanValue) {
        _dayfiIdController.text = cleanValue;
        _dayfiIdController.selection = TextSelection.fromPosition(
          TextPosition(offset: cleanValue.length),
        );
      }
      return;
    }

    // Clear previous timer
    _debounceTimer?.cancel();

    // Reset validation state immediately when typing
    if (mounted) {
      setState(() {
        _validatedDayfiId = null;
        _recipientName = null;
        if (value.isEmpty) {
          _validationError = null;
        }
      });
    }

    // Debounce validation
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted && _dayfiIdController.text == value.replaceAll('@', '')) {
        _validateDayfiId(value.replaceAll('@', ''));
      }
    });
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate() &&
        _validatedDayfiId != null &&
        _validatedDayfiId!.isNotEmpty) {
      if (_saveRecipientOnly) {
        final currency =
            widget.selectedData['receiveCurrency']?.toString() ?? 'USD';
        final entry = RecipientSaveHelper.dayfi(
          tag: _dayfiIdController.text.trim(),
          displayName:
              _recipientName?.trim().isNotEmpty == true
                  ? _recipientName!.trim()
                  : '@${_dayfiIdController.text.trim()}',
          currency: currency,
        );
        await RecipientSaveHelper.save(ref, entry);
        if (!mounted) return;
        RecipientSaveHelper.completeSaveRecipientOnlyNavigation(context);
        return;
      }

      final payWith = ref.read(selectedDebitCurrencyProvider);
      final receiveCurrency =
          widget.selectedData['receiveCurrency']?.toString().toUpperCase() ??
          payWith;
      final receiveCountry =
          widget.selectedData['receiveCountry']?.toString().toUpperCase() ??
          (receiveCurrency.isNotEmpty
              ? countryForCurrency(receiveCurrency)
              : null);

      appRouter.pushNamed(
        AppRoute.sendView,
        arguments: {
          'selectedData': {
            ...widget.selectedData,
            ...payWithRouteArgs(payWithCurrency: payWith),
            'dayfiId': _dayfiIdController.text.trim(),
            'recipientName': _recipientName,
            'receiveCurrency': payWith,
            if (receiveCountry != null && receiveCountry.isNotEmpty)
              'receiveCountry': receiveCountry,
            if (widget.selectedData['prefillSendAmount'] != null)
              'prefillSendAmount': widget.selectedData['prefillSendAmount'],
          },
        },
      );
    } else {
      TopSnackbar.show(
        context,
        message:
            _validatedDayfiId == null
                ? UsernameCopy.enterValid
                : 'Please complete the form',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: .5,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,

          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leadingWidth: 72,
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
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 24 : 24,
                          ),
                          child: Text(
                            _saveRecipientOnly
                                ? 'Save a ${UsernameCopy.label.toLowerCase()} recipient for future transfers.'
                                : UsernameCopy.addRecipientSubtitle,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Chirp',
                              letterSpacing: -.25,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 24),

                        // Dayfi Tag Input Field
                        CustomTextField(
                          controller: _dayfiIdController,
                          label: UsernameCopy.recipient,
                          hintText: 'dayfitag',
                          textCapitalization: TextCapitalization.none,
                          autofocus: true,
                          contentPadding: EdgeInsets.only(
                            top: 16,
                            left: 0,
                            right: 12,
                            bottom: 16,
                          ),
                          // Use `prefix` instead of `prefixIcon` to avoid the large
                          // built-in prefixIcon constraints and extra horizontal gap.
                          prefix: Padding(
                            padding: EdgeInsets.only(right: 0, left: 12),
                            child: Text(
                              '@',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Chirp',
                                fontWeight: FontWeight.w600,
                                color: AppColors.purple500ForTheme(context),
                              ),
                            ),
                          ),
                          onChanged: _onDayfiIdChanged,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null; // Don't show error until they try to continue
                            }
                            final cleanValue = value.replaceAll('@', '').trim();
                            if (cleanValue.length < 3) {
                              return 'Minimum 3 characters required';
                            }
                            if (_validationError != null) {
                              return _validationError;
                            }
                            return null;
                          },
                          errorFontSize: 0,
                          suffixIcon:
                              _isValidating
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
                                  : _validatedDayfiId != null
                                  ? Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                      'assets/icons/svgs/circle-check.svg',
                                      width: 26,
                                      height: 26,
                                      color: AppColors.success600,
                                    ),
                                  )
                                  : _validationError != null &&
                                      _dayfiIdController.text.isNotEmpty
                                  ? GestureDetector(
                                    onTap: () {
                                      _dayfiIdController.clear();
                                      _onDayfiIdChanged('');
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SvgPicture.asset(
                                        'assets/icons/svgs/circle-x.svg',
                                        width: 26,
                                        height: 26,
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
                          //       _dayfiIdController.text = clipboardData.text!;
                          //       _onDayfiIdChanged(clipboardData.text!);
                          //     }
                          //   },
                          //   child: Padding(
                          //     padding: EdgeInsets.all(16),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.end,
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [
                          //         Text(
                          //           "paste",
                          //           style: TextStyle(
                          //             fontFamily: 'Chirp',
                          //             fontWeight: FontWeight.w600,
                          //             fontSize: 12.5,
                          //             letterSpacing: 0.00,
                          //             height: 1.450,
                          //             color:
                          //                 Theme.of(context).colorScheme.primary,
                          //           ),
                          //         ),
                          //         SizedBox(width: 6),
                          //         SvgPicture.asset(
                          //           "assets/icons/svgs/paste.svg",
                          //           color:
                          //               Theme.of(context).colorScheme.primary,
                          //           height: 16,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ),

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
                              _isValidating
                                  ? Center(
                                    key: ValueKey('loading'),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child:
                                          LoadingAnimationWidget.horizontalRotatingDots(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            size: 20,
                                          ),
                                    ),
                                  )
                                  : _validatedDayfiId != null
                                  ? Column(
                                    key: ValueKey('success'),
                                    children: [
                                      SizedBox(height: 16),
                                      Center(
                                        child: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.success50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: AppColors.success200,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Text(
                                            _recipientName != null &&
                                                    !_recipientName!.startsWith(
                                                      '@',
                                                    )
                                                ? 'Sending to $_recipientName'
                                                    .toUpperCase()
                                                : 'Sending to @$_validatedDayfiId'
                                                    .toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: 'Chirp',
                                              fontSize: 14,
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
                                  : _validationError != null &&
                                      _dayfiIdController.text.isNotEmpty
                                  ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                            _validationError!,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              fontFamily: 'Chirp',
                                              fontSize: 14,
                                              letterSpacing: -.25,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.error700,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                  : const SizedBox(
                                    key: ValueKey('empty'),
                                    height: 0,
                                  ),
                        ),

                        SizedBox(height: 32),

                        // Continue Button
                   Padding(padding: EdgeInsets.symmetric(horizontal: 18), child:     PrimaryButton(
                          text: _saveRecipientOnly ? 'Save Recipient' : 'Enter Amount',
                          onPressed:
                              _validatedDayfiId != null
                                  ? _handleContinue
                                  : null,
                          height: 48.00000,
                          backgroundColor:
                              _validatedDayfiId != null
                                  ? AppColors.purple500
                                  : AppColors.purple500ForTheme(
                                    context,
                                  ).withOpacity(.15),
                          textColor:
                              _validatedDayfiId != null
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
                            child: Center(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  // padding: EdgeInsets.zero,
                                  // minimumSize: Size(50, 30),
                                  splashFactory: NoSplash.splashFactory,
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.transparent,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.center,
                                ),
                                onPressed: () async {
                                FocusScope.of(context).unfocus();
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
                                  barrierColor: Colors.black.withOpacity(0.85),

                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  builder:
                                      (context) => Consumer(
                                        builder: (context, sheetRef, _) {
                                          final recipientsState = sheetRef
                                              .watch(recipientsProvider);
                                          final allBeneficiaries =
                                              RecipientHistoryHelper
                                                  .filterForSendContext(
                                                    recipientsState.beneficiaries,
                                                    deliveryMethod: 'dayfi_tag',
                                                    currency: (widget
                                                                .selectedData[
                                                            'debitCurrency'] ??
                                                        widget.selectedData[
                                                            'sendCurrency'])
                                                        ?.toString(),
                                                    receiveCountry: widget
                                                            .selectedData[
                                                        'receiveCountry']
                                                        ?.toString(),
                                                    receiveCurrency: widget
                                                            .selectedData[
                                                        'receiveCurrency']
                                                        ?.toString(),
                                                  )
                                                  .where(
                                                    (b) {
                                                      final tag = b
                                                          .source
                                                          .accountNumber
                                                          ?.replaceFirst(
                                                            '@',
                                                            '',
                                                          )
                                                          .trim()
                                                          .toLowerCase();
                                                      final excluded =
                                                          _myDayfiId
                                                              ?.replaceFirst(
                                                                '@',
                                                                '',
                                                              )
                                                              .trim()
                                                              .toLowerCase();
                                                      return excluded == null ||
                                                          excluded.isEmpty ||
                                                          tag != excluded;
                                                    },
                                                  )
                                                  .toList();
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
                                                            style: AppTypography
                                                                .titleLarge
                                                                .copyWith(
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
                                                                      ).colorScheme.onSurface,
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
                                                    SizedBox(height: 18),

                                                    Expanded(
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          children: [
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
                                                                    height: 1.5,
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
                                                                  margin:
                                                                      EdgeInsets.only(
                                                                        left:
                                                                            18,
                                                                        right:
                                                                            18,
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
                                                                                        RecipientHistoryHelper.secondaryLabel(
                                                                                          b.beneficiary,
                                                                                          b.source,
                                                                                          ledgerCurrency:
                                                                                              b.ledgerCurrency,
                                                                                        ),
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
                                  // For Dayfi Tag flow, just set the Dayfi Tag from the beneficiary
                                  final dayfiId =
                                      result.beneficiary.accountNumber
                                          ?.replaceAll('@', '') ??
                                      result.source.accountNumber?.replaceAll(
                                        '@',
                                        '',
                                      ) ??
                                      '';
                                  if (dayfiId.isNotEmpty) {
                                    _dayfiIdController.text = dayfiId;
                                    _onDayfiIdChanged(dayfiId);
                                  }
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
    );
  }
}
