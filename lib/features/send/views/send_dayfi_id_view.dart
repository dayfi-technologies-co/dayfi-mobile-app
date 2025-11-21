import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/routes/route.dart';
import 'dart:async';

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
  List<String> _savedDayfiIds = [];
  bool _isLoadingSavedIds = false;

  @override
  void initState() {
    super.initState();
    _loadSavedDayfiIds();
  }

  Future<void> _loadSavedDayfiIds() async {
    if (mounted) {
      setState(() {
        _isLoadingSavedIds = true;
      });
    }

    try {
      final walletService = locator<WalletService>();
      final dayfiIds = await walletService.getUniqueDayfiIds();

      if (mounted) {
        setState(() {
          _savedDayfiIds = dayfiIds;
          _isLoadingSavedIds = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading saved DayFi IDs: $e');
      if (mounted) {
        setState(() {
          _isLoadingSavedIds = false;
        });
      }
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
      appRouter.pushNamed(
        AppRoute.sendDayfiIdReviewView,
        arguments: {
          'selectedData': widget.selectedData,
          'dayfiId': _validatedDayfiId!,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _validatedDayfiId == null
                ? 'Please enter a valid Dayfi ID'
                : 'Please complete the form',
          ),
          backgroundColor: AppColors.error500,
        ),
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
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Enter Dayfi ID',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 19.sp,
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
                // SizedBox(height: 24.h),

                // Dayfi ID Input Field
                CustomTextField(
                  controller: _dayfiIdController,
                  label: "Recipient's Dayfi Tag",
                  hintText: 'johndoe',
                  textCapitalization: TextCapitalization.none,
                  autofocus: true,
                  contentPadding: EdgeInsets.only(
                    top: 16.h,
                    left: 2.w,
                    right: 10.w,
                    bottom: 16.h,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 24.w, top: 10.w),
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
                          ? Padding(
                            padding: EdgeInsets.all(12.w),
                            child: SvgPicture.asset(
                              'assets/icons/svgs/circle-x.svg',
                              width: 26.w,
                              height: 26.h,
                              color: AppColors.error600,
                            ),
                          )
                          : null,
                ),

                // Saved DayFi IDs Chips
                if (_savedDayfiIds.isNotEmpty && !_isLoadingSavedIds) ...[
                  SizedBox(height: 16.h),
                  // Text(
                  //   'Recent tags',
                  //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  //     fontFamily: 'Karla',
                  //     fontSize: 13.sp,
                  //     fontWeight: FontWeight.w500,
                  //     letterSpacing: -0.2,
                  //     color: Theme.of(
                  //       context,
                  //     ).colorScheme.onSurface.withOpacity(0.6),
                  //   ),
                  // ),
                  // SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children:
                        _savedDayfiIds.map((dayfiId) {
                          final isSelected = _dayfiIdController.text == dayfiId;
                          return InkWell(
                            onTap: () {
                              _dayfiIdController.text = dayfiId;
                              _onDayfiIdChanged(dayfiId);
                            },
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.purple500.withOpacity(0.1)
                                        : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppColors.purple500
                                          : Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.2),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '@',
                                    style: TextStyle(
                                      fontFamily: 'Karla',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                      color:
                                          isSelected
                                              ? AppColors.purple500
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(.65),
                                    ),
                                  ),
                                  Text(
                                    dayfiId,
                                    style: TextStyle(
                                      fontFamily: 'Karla',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.2,
                                      color:
                                          isSelected
                                              ? AppColors.purple500
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],

                // Success message
                if (_validatedDayfiId != null && !_isValidating) ...[
                  SizedBox(height: 16.h),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success50,
                        borderRadius: BorderRadius.circular(32.r),
                        border: Border.all(
                          color: AppColors.success200,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        _recipientName != null &&
                                _recipientName!.startsWith('@')
                            ? 'Valid Dayfi ID: $_recipientName'.toUpperCase()
                            : 'Sending to ${_recipientName ?? "@$_validatedDayfiId"}'
                                .toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],

                // Error message
                if (_validationError != null &&
                    !_isValidating &&
                    _dayfiIdController.text.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.error200, width: 1.0),
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
                  ),
                ],

                SizedBox(height: 56.h),

                // Continue Button
                PrimaryButton(
                  text: 'Review Transfer',
                  onPressed: _validatedDayfiId != null ? _handleContinue : null,
                  height: 48.000.h,
                  backgroundColor:
                      _validatedDayfiId != null
                          ? AppColors.purple500
                          : AppColors.purple500ForTheme(
                            context,
                          ).withOpacity(.25),
                  textColor:
                      _validatedDayfiId != null
                          ? AppColors.neutral0
                          : AppColors.neutral0.withOpacity(.65),
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
    );
  }
}
