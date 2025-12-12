import 'package:dayfi/common/utils/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';

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

  @override
  void initState() {
    super.initState();
    _dayfiIdController.text = widget.selectedData['accountNumber'] ?? '';
    _loadMyDayfiId();
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
      AppLogger.error('Error loading my DayFi ID: $e');
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
        try {
          if (response.data != null) {
            final data = response.data as Map<String, dynamic>;
            if (data.containsKey('first_name') ||
                data.containsKey('last_name')) {
              final firstName = data['first_name']?.toString() ?? '';
              final lastName = data['last_name']?.toString() ?? '';
              recipientDisplayName = '$firstName $lastName'.trim();
              if (recipientDisplayName.isEmpty) {
                recipientDisplayName = '@$cleanDayfiId';
              }
            } else if (data.containsKey('name')) {
              recipientDisplayName = data['name']?.toString();
            }
          }
        } catch (e) {
          AppLogger.debug('Could not extract recipient name: $e');
        }

        // Prevent sending to own Dayfi ID
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

          if (myDayfi != null &&
              myDayfi.isNotEmpty &&
              myDayfi.toLowerCase() == cleanDayfiId.toLowerCase()) {
            if (mounted) {
              setState(() {
                _validationError = 'Cannot send to your own Dayfi ID';
                _validatedDayfiId = null;
                _recipientName = null;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _validatedDayfiId = cleanDayfiId;
                _recipientName = recipientDisplayName ?? '@$cleanDayfiId';
                _validationError = null;
              });
            }
          }
        } catch (e) {
          AppLogger.error('Error checking local Dayfi ID: $e');
          if (mounted) {
            setState(() {
              _validatedDayfiId = cleanDayfiId;
              _recipientName = recipientDisplayName ?? '@$cleanDayfiId';
              _validationError = null;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _validationError = 'Dayfi ID not found';
            _validatedDayfiId = null;
            _recipientName = null;
          });
        }
      }
    } catch (e) {
      AppLogger.error('Error validating Dayfi ID: $e');
      if (mounted) {
        setState(() {
          _validationError = 'Unable to verify ID. Please try again';
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

  void _handleContinue() {
    if (_formKey.currentState!.validate() &&
        _validatedDayfiId != null &&
        _validatedDayfiId!.isNotEmpty) {
      // Navigate to send view to enter amount, then to review
      appRouter.pushNamed(
        AppRoute.sendView,
        arguments: {
          'selectedData': {
            ...widget.selectedData,
            'dayfiId': _dayfiIdController.text.trim(),
            'recipientName': _recipientName,
          },
        },
      );
    } else {
      TopSnackbar.show(
        context,
        message:
            _validatedDayfiId == null
                ? 'Please enter a valid Dayfi ID'
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
                    "Add a recipient via dayfi tag to proceed with your transfer",
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
                SizedBox(height: 24.h),

                // Dayfi ID Input Field
                CustomTextField(
                  controller: _dayfiIdController,
                  label: "Recipient's Dayfi Tag",
                  hintText: 'dayfitag',
                  textCapitalization: TextCapitalization.none,
                  autofocus: true,
                  contentPadding: EdgeInsets.only(
                    top: 16.h,
                    left: 0.w,
                    right: 12.w,
                    bottom: 16.h,
                  ),
                  // Use `prefix` instead of `prefixIcon` to avoid the large
                  // built-in prefixIcon constraints and extra horizontal gap.
                  prefix: Padding(
                    padding: EdgeInsets.only(right: 0.w, left: 12.w),
                    child: Text(
                      '@',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: 'Karla',
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
                            margin: EdgeInsets.all(12.w),
                            child:
                                LoadingAnimationWidget.horizontalRotatingDots(
                                  color: AppColors.purple500ForTheme(context),
                                  size: 22,
                                ),
                          )
                          : _validatedDayfiId != null
                          ? Padding(
                            padding: EdgeInsets.all(12.w),
                            child: SvgPicture.asset(
                              'assets/icons/svgs/circle-check.svg',
                              width: 26.w,
                              height: 26.h,
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
                  //       _dayfiIdController.text = clipboardData.text!;
                  //       _onDayfiIdChanged(clipboardData.text!);
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
                  //                 Theme.of(context).colorScheme.primary,
                  //           ),
                  //         ),
                  //         SizedBox(width: 6.w),
                  //         SvgPicture.asset(
                  //           "assets/icons/svgs/paste.svg",
                  //           color:
                  //               Theme.of(context).colorScheme.primary,
                  //           height: 16.sp,
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
                                        Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                            ),
                          )
                          : _validatedDayfiId != null
                          ? Column(
                            key: ValueKey('success'),
                            children: [
                              SizedBox(height: 16.h),
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.success50,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: AppColors.success200,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    _recipientName != null &&
                                            !_recipientName!.startsWith('@')
                                        ? 'Sending to $_recipientName'
                                            .toUpperCase()
                                        : 'Sending to @$_validatedDayfiId'
                                            .toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'karla',
                                      fontSize: 14.sp,
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
                          ? Container(
                            key: ValueKey('error'),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
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
                                  Icons.info_outline,
                                  color: AppColors.error600,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    _validationError!,
                                    style: TextStyle(
                                      fontFamily: 'Karla',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : const SizedBox(key: ValueKey('empty'), height: 0),
                ),

                SizedBox(height: 40.h),

                // Continue Button
                PrimaryButton(
                  text: 'Enter Amount',
                  onPressed: _validatedDayfiId != null ? _handleContinue : null,
                  height: 48.00000.h,
                  backgroundColor:
                      _validatedDayfiId != null
                          ? AppColors.purple500
                          : AppColors.purple500ForTheme(
                            context,
                          ).withOpacity(.15),
                  textColor:
                      _validatedDayfiId != null
                          ? AppColors.neutral0
                          : AppColors.neutral0.withOpacity(.35),
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
                      FocusScope.of(context).unfocus();
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
                                        .where((b) {
                                          final isDayFi =
                                              b.source.accountType
                                                      ?.toLowerCase() ==
                                                  'dayfi' ||
                                              b.source.accountNumber
                                                      ?.startsWith('@') ==
                                                  true ||
                                              b.beneficiary.accountNumber
                                                      ?.startsWith('@') ==
                                                  true ||
                                              b.beneficiary.accountType
                                                      ?.toLowerCase() ==
                                                  'dayfi';
                                          final isNotOwn =
                                              (b.beneficiary.accountNumber ??
                                                  '') !=
                                              (_myDayfiId ?? '');
                                          return isDayFi && isNotOwn;
                                        })
                                        .fold<
                                          Map<String, BeneficiaryWithSource>
                                        >({}, (map, b) {
                                          final key =
                                              b.beneficiary.accountNumber ?? '';
                                          if (!map.containsKey(key))
                                            map[key] = b;
                                          return map;
                                        })
                                        .values
                                        .toList();
                                return StatefulBuilder(
                                  builder: (context, setModalState) {
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
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
                                                            Theme.of(context)
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
                                                            Theme.of(context)
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
                                          SizedBox(height: 18.h),

                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 24.0,
                                                        ),
                                                    child: Opacity(
                                                      opacity: .85,
                                                      child: Text(
                                                        'Choose a recent beneficiary to auto-fill recipient details',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontSize: 16.sp,
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
                                                            TextAlign.center,
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
                                                                fontSize: 16.sp,
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
                                                        margin: EdgeInsets.only(
                                                          left: 18.w,
                                                          right: 18.w,
                                                          bottom: 20.h,
                                                          // top: 16.h,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Theme.of(context)
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
                                                              EdgeInsets.zero,
                                                          itemCount:
                                                              allBeneficiaries
                                                                  .length,
                                                          separatorBuilder:
                                                              (_, __) =>
                                                                  SizedBox(
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
                                                                      Column(
                                                                        children: [
                                                                          Stack(
                                                                            alignment: Alignment.bottomRight,
                                                                            children:
                                                                             [
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
                                                                                String
                                                                                accountNum =
                                                                                    b.beneficiary.accountNumber ??
                                                                                    b.source.accountNumber ??
                                                                                    '';
                                                                                // If accountNum looks like a wallet ID, use beneficiary name instead
                                                                                if (accountNum.startsWith(
                                                                                  'wallet-',
                                                                                )) {
                                                                                  accountNum =
                                                                                      b.beneficiary.name;
                                                                                }
                                                                                // Always add @ prefix for DayFi tags in this view
                                                                                if (!accountNum.startsWith(
                                                                                  '@',
                                                                                )) {
                                                                                  accountNum =
                                                                                      '@$accountNum';
                                                                                }
                                                                                return accountNum;
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
                                                                        Icons
                                                                            .chevron_right,
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
                        // For DayFi tag flow, just set the DayFi ID from the beneficiary
                        final dayfiId =
                            result.beneficiary.accountNumber?.replaceAll(
                              '@',
                              '',
                            ) ??
                            result.source.accountNumber?.replaceAll('@', '') ??
                            '';
                        if (dayfiId.isNotEmpty) {
                          _dayfiIdController.text = dayfiId;
                          _onDayfiIdChanged(dayfiId);
                        }
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
    );
  }
}
