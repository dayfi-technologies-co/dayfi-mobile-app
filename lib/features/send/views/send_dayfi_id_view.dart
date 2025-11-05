import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/routes/route.dart';

class SendDayfiIdView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;

  const SendDayfiIdView({super.key, required this.selectedData});

  @override
  ConsumerState<SendDayfiIdView> createState() => _SendDayfiIdViewState();
}

class _SendDayfiIdViewState extends ConsumerState<SendDayfiIdView> {
  final _formKey = GlobalKey<FormState>();
  final _dayfiIdController = TextEditingController();
  bool _isValidating = false;
  String? _validationError;
  String? _validatedDayfiId;

  @override
  void dispose() {
    _dayfiIdController.dispose();
    super.dispose();
  }

  Future<void> _validateDayfiId(String dayfiId) async {
    if (dayfiId.isEmpty) {
      setState(() {
        _validationError = null;
        _validatedDayfiId = null;
      });
      return;
    }

    // Remove @ if present for validation
    final cleanDayfiId = dayfiId.replaceAll('@', '').trim();

    if (cleanDayfiId.length < 3) {
      setState(() {
        _validationError = 'Dayfi ID must be at least 3 characters';
        _validatedDayfiId = null;
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _validationError = null;
    });

    try {
      final authService = locator<AuthService>();
      final response = await authService.validateDayfiId(dayfiId: cleanDayfiId);

      if (response.error == false) {
        setState(() {
          _validatedDayfiId = cleanDayfiId;
          _validationError = null;
        });
      } else {
        setState(() {
          _validationError = 'Dayfi ID not found';
          _validatedDayfiId = null;
        });
      }
    } catch (e) {
      AppLogger.error('Error validating Dayfi ID: $e');
      setState(() {
        _validationError = 'Dayfi ID not found';
        _validatedDayfiId = null;
      });
    } finally {
      setState(() {
        _isValidating = false;
      });
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
    }

    // Debounce validation
    Future.delayed(const Duration(milliseconds: 500), () {
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
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),

                // Dayfi ID Input Field
                CustomTextField(
                  controller: _dayfiIdController,
                  label: 'Dayfi ID',
                  hintText: 'Enter recipient Dayfi ID',
                  textCapitalization: TextCapitalization.none,
                  contentPadding: EdgeInsets.only(
                    top: 14.h,
                    left: 2.w,
                    right: 10.w,
                    bottom: 14.h,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 14.w, top: 10.w),
                    child: Text(
                      '@',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'Karla',
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  onChanged: _onDayfiIdChanged,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter Dayfi ID';
                    }
                    final cleanValue = value.replaceAll('@', '').trim();
                    if (cleanValue.length < 3) {
                      return 'Dayfi ID must be at least 3 characters';
                    }
                    if (_validationError != null) {
                      return _validationError;
                    }
                    if (_validatedDayfiId == null && !_isValidating) {
                      return 'Please wait for validation';
                    }
                    return null;
                  },
                  suffixIcon:
                      _isValidating
                          ? Container(
                            margin: EdgeInsets.all(12),
                            child:
                                LoadingAnimationWidget.horizontalRotatingDots(
                                  color: AppColors.purple500ForTheme(context),
                                  size: 20,
                                ),
                          )
                          : _validatedDayfiId != null
                          ? Padding(
                            padding: EdgeInsets.all(12.w),
                            child: SvgPicture.asset(
                              'assets/icons/svgs/circle-check.svg',
                              color: AppColors.success700,
                              height: 10.sp,
                            ),
                          )
                          : null,
                ),

                // Success message
                if (_validatedDayfiId != null && !_isValidating) ...[
                  SizedBox(height: 12.h),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success700,
                        borderRadius: BorderRadius.circular(32.r),
                      ),
                      child: Text(
                        'Valid Dayfi ID',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral0,
                          letterSpacing: 0.5,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 48.h),

                // Continue Button
                PrimaryButton(
                  text: 'Next - Review Transfer',
                  onPressed: _validatedDayfiId != null ? _handleContinue : null,
                  height: 60.h,
                  backgroundColor:
                      _validatedDayfiId != null
                          ? AppColors.purple500
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.12),
                  textColor:
                      _validatedDayfiId != null
                          ? AppColors.neutral0
                          : AppColors.neutral0.withOpacity(.5),
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
