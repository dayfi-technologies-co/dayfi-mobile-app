import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/send/views/send_review_view.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/app_locator.dart';
// ignore: depend_on_referenced_packages
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SendAddRecipientsView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;

  const SendAddRecipientsView({super.key, required this.selectedData});

  @override
  ConsumerState<SendAddRecipientsView> createState() =>
      _SendAddRecipientsViewState();
}

class _SendAddRecipientsViewState extends ConsumerState<SendAddRecipientsView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _accountNumberController = TextEditingController();

  String _selectedCountry = '';
  String _selectedNetworkId = '';

  // Account resolution state
  bool _isResolving = false;
  String? _resolveError;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedData['receiveCountry'] ?? '';
    _selectedNetworkId = widget.selectedData['networkId'] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      analyticsService.trackScreenView(screenName: 'SendAddRecipientsView');
    });

    // Add listener to account number field for auto-resolution
    _accountNumberController.addListener(_onAccountNumberChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _onAccountNumberChanged() {
    final accountNumber = _accountNumberController.text.trim();

    // Check if account number is exactly 10 digits
    if (accountNumber.length == 10 &&
        RegExp(r'^\d{10}$').hasMatch(accountNumber)) {
      _resolveAccount(accountNumber);
    } else {
      // Clear name field if account number is not 10 digits
      if (_nameController.text.isNotEmpty) {
        _nameController.clear();
      }
      setState(() {
        _resolveError = null;
      });
    }
  }

  Future<void> _resolveAccount(String accountNumber) async {
    if (_isResolving) return; // Prevent multiple simultaneous calls

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

      if (response.statusCode == 200 && !response.error) {
        // Extract account name from PaymentData object
        final accountName =
            response.data?.accountName ?? 'Account Resolved Successfully';

        setState(() {
          _nameController.text = accountName;
          _resolveError = null;
        });

      } else {
        setState(() {
          _resolveError = response.message;
          _nameController.clear();
        });
      }
    } catch (e) {
      setState(() {
        _resolveError = 'Error resolving account: $e';
        log(_resolveError.toString());
        _nameController.clear();
      });
    } finally {
      setState(() {
        _isResolving = false;
      });
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
              // size: 20.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Add Recipient',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.8,
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
                // Account Number Field (Required)
                CustomTextField(
                  controller: _accountNumberController,
                  label: 'Account Number',
                  hintText: 'Enter 10-digit account number',
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  suffixIcon:
                      _isResolving
                          ? Container(
                            margin: EdgeInsets.all(12),
                            child:
                                LoadingAnimationWidget.horizontalRotatingDots(
                                  color: AppColors.purple500,
                                  size: 20,
                                ),
                          )
                          : null,
                  validator: (value) {
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
                      border: Border.all(color: AppColors.error200, width: 1.0),
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

                // Full Name Field (Hidden until account is resolved)
                if (_nameController.text.isNotEmpty) ...[
                  SizedBox(height: 18.h),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hintText: 'Will be auto-filled from account number',
                    shouldReadOnly: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter account number to resolve name';
                      }
                      return null;
                    },
                    suffixIcon:
                        _isResolving
                            ? Container(
                              margin: EdgeInsets.all(12),
                              child:
                                  LoadingAnimationWidget.horizontalRotatingDots(
                                    color: AppColors.purple500,
                                    size: 20,
                                  ),
                            )
                            : null,
                  ),
                ],

                // SizedBox(height: 32.h),

                // // Optional Fields Section
                // _buildSectionTitle('Additional Information'),
                SizedBox(height: 18.h),

                // Phone Number (Optional)
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number (Optional)',
                  hintText: 'Enter phone number',
                  maxLength: 11,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    // No validation required for optional field
                    return null;
                  },
                ),

                SizedBox(height: 18.h),

                // Address (Optional)
                CustomTextField(
                  controller: _addressController,
                  label: 'Address (Optional)',
                  hintText: 'Enter address',
                  validator: (value) {
                    // No validation required for optional field
                    return null;
                  },
                ),

                SizedBox(height: 18.h),

                // Date of Birth (Optional)
                CustomTextField(
                  controller: _dobController,
                  label: 'Date of Birth (Optional)',
                  hintText: 'DD/MM/YYYY',
                  shouldReadOnly: true,
                  onTap: () => _selectDate(),
                  validator: (value) {
                    // No validation required for optional field
                    return null;
                  },
                ),

                SizedBox(height: 18.h),

                // Email Address (Optional)
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address (Optional)',
                  hintText: 'Enter email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 18.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 4.w),
                      Image.asset(
                        "assets/images/idea.png",
                        height: 18.h,
                        // color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "By continuing with this payment you are confirming that, to the best of your knowledge, the details you are providing are correct.",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            fontSize: 12.5.sp,
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.4,
                            height: 1.5,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 48.h),

                // Continue Button
                PrimaryButton(
                  text: 'Continue',
                  onPressed: _validateAndContinue,
                  height: 60.h,
                  backgroundColor: AppColors.purple500,
                  textColor: AppColors.neutral0,
                  fontFamily: 'Karla',
                  letterSpacing: -.8,
                  fontSize: 18,
                  width: double.infinity,
                  fullWidth: true,
                  borderRadius: 40.r,
                ),

                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 years ago
    );

    if (picked != null) {
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _validateAndContinue() {
    if (_formKey.currentState!.validate() &&
        _nameController.text.trim().isNotEmpty) {
      analyticsService.logEvent(name: 'recipient_added', parameters: {
        'country': _selectedCountry,
        'networkId': _selectedNetworkId,
      });
      final recipientData = {
        'name': _nameController.text.trim(),
        'country': _selectedCountry,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'dob': _dobController.text.trim(),
        'email': _emailController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'networkId': _selectedNetworkId,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SendReviewView(
                selectedData: widget.selectedData,
                recipientData: recipientData,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter account number to resolve name'),
          backgroundColor: AppColors.error500,
        ),
      );
    }
  }
}
