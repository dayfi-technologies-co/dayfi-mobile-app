import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/common/widgets/custom_bottom_sheet.dart';
import 'package:dayfi/common/widgets/custom_text_field.dart';
import 'package:dayfi/common/widgets/pin_view.dart';
import 'package:dayfi/common/widgets/pincode_input.dart';
import 'package:dayfi/common/widgets/upload_icon.dart';
import 'package:dayfi/common/widgets/loading_bottom_sheet_controller.dart';
import 'package:dayfi/common/widgets/buttons/help_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_otp_verification_text_field.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/core/theme/theme_toggle_widget.dart';
import 'package:dayfi/core/theme/theme_provider.dart';
import 'package:dayfi/common/widgets/buttons/buttons.dart';
import 'package:dayfi/routes/route.dart';

class StyleDemoView extends ConsumerWidget {
  const StyleDemoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Style Demo'),
        actions: const [ThemeToggleWidget(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Title
              Text(
                'Your everyday money app'.toUpperCase(),
                style: AppTypography.displayLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Theme Demo Cards
              Row(
                children: [
                  Expanded(
                    child: _buildDemoCard(
                      context,
                      'Primary',
                      AppColors.primary500,
                      colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDemoCard(
                      context,
                      'Secondary',
                      AppColors.sauce500,
                      colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDemoCard(
                      context,
                      'Success',
                      AppColors.success500,
                      colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDemoCard(
                      context,
                      'Warning',
                      AppColors.warning500,
                      colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Typography Showcase
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Typography Showcase',
                      style: AppTypography.headlineH4.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Display Styles
                    _buildTypographyRow(
                      'Display Large',
                      AppTypography.displayLarge,
                    ),
                    _buildTypographyRow(
                      'Display Medium',
                      AppTypography.displayMedium,
                    ),
                    _buildTypographyRow(
                      'Display Small',
                      AppTypography.displaySmall,
                    ),

                    const SizedBox(height: 12),

                    // Headline Styles
                    _buildTypographyRow(
                      'Headline H1',
                      AppTypography.headlineLarge,
                    ),
                    _buildTypographyRow(
                      'Headline H2',
                      AppTypography.headlineMedium,
                    ),
                    _buildTypographyRow(
                      'Headline H3',
                      AppTypography.headlineSmall,
                    ),
                    _buildTypographyRow(
                      'Headline H4',
                      AppTypography.headlineH4,
                    ),

                    const SizedBox(height: 12),

                    // Title Styles
                    _buildTypographyRow(
                      'Title Large',
                      AppTypography.titleLarge,
                    ),
                    _buildTypographyRow(
                      'Title Medium',
                      AppTypography.titleMedium,
                    ),
                    _buildTypographyRow(
                      'Title Regular',
                      AppTypography.titleRegular,
                    ),
                    _buildTypographyRow(
                      'Title Small',
                      AppTypography.titleSmall,
                    ),

                    const SizedBox(height: 12),

                    // Body Styles
                    _buildTypographyRow('Body Large', AppTypography.bodyLarge),
                    _buildTypographyRow(
                      'Body Medium',
                      AppTypography.bodyMedium,
                    ),
                    _buildTypographyRow(
                      'Body Regular',
                      AppTypography.bodyRegular,
                    ),
                    _buildTypographyRow('Body Small', AppTypography.bodySmall),

                    const SizedBox(height: 12),

                    // Label Styles
                    _buildTypographyRow(
                      'Label Large',
                      AppTypography.labelLarge,
                    ),
                    _buildTypographyRow(
                      'Label Medium',
                      AppTypography.labelMedium,
                    ),
                    _buildTypographyRow(
                      'Label Regular',
                      AppTypography.labelRegular,
                    ),
                    _buildTypographyRow(
                      'Label Small',
                      AppTypography.labelSmall,
                    ),
                    _buildTypographyRow('Label Tiny', AppTypography.labelTiny),

                    const SizedBox(height: 12),

                    // Micro Styles
                    _buildTypographyRow(
                      'Micro Large',
                      AppTypography.microLarge,
                    ),
                    _buildTypographyRow(
                      'Micro Medium',
                      AppTypography.microMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Current Theme Info
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current Theme',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      themeMode == AppThemeMode.light
                          ? 'Light Mode'
                          : themeMode == AppThemeMode.dark
                          ? 'Dark Mode'
                          : 'System Mode',
                      style: AppTypography.bodyLarge.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Button Showcase
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Button Showcase',
                      style: AppTypography.headlineH4.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Primary Buttons
                    _buildButtonRow('Primary Buttons', [
                      PrimaryButton.dayfi(text: 'Default', onPressed: () {}),
                      PrimaryButton.dayfi(
                        text: 'Small',
                        onPressed: () {},
                      ).copyWith(width: 120, height: 40, fontSize: 14),
                      PrimaryButton.dayfi(
                        text: 'Large',
                        onPressed: () {},
                      ).copyWith(width: 200, height: 56, fontSize: 20),
                    ]),

                    const SizedBox(height: 16),

                    // Secondary Buttons
                    _buildButtonRow('Secondary Buttons', [
                      SecondaryButton.dayfi(
                        text: 'Default',
                        onPressed: () {},
                      ),
                      SecondaryButton.dayfi(
                        text: 'Custom',
                        onPressed: () {},
                      ).copyWith(
                        backgroundColor: AppColors.orange500,
                        textColor: AppColors.neutral0,
                        borderColor: AppColors.orange500,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Custom Color Buttons
                    _buildButtonRow('Custom Colors', [
                      PrimaryButton.dayfi(
                        text: 'Success',
                        onPressed: () {},
                      ).copyWith(
                        backgroundColor: AppColors.success500,
                        textColor: AppColors.neutral0,
                      ),
                      PrimaryButton.dayfi(
                        text: 'Warning',
                        onPressed: () {},
                      ).copyWith(
                        backgroundColor: AppColors.warning500,
                        textColor: AppColors.neutral0,
                      ),
                      PrimaryButton.dayfi(
                        text: 'Orange',
                        onPressed: () {},
                      ).copyWith(
                        backgroundColor: AppColors.orange500,
                        textColor: AppColors.neutral0,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Disabled and Loading States
                    _buildButtonRow('States', [
                      PrimaryButton.dayfi(
                        text: 'Disabled',
                        onPressed: null,
                        enabled: false,
                      ),
                      PrimaryButton.dayfi(
                        text: 'Loading',
                        onPressed: () {},
                        isLoading: true,
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Help Button
                    _buildButtonRow('Help Button', [HelpButton()]),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Text Field Showcase
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Text Field Showcase',
                      style: AppTypography.headlineH4.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Primary Buttons
                    _buildButtonRow('OTP Verification Text Field', [
                      OtpVerificationTextField(
                        length: 6,
                        onCompleted: (code) {
                          /* verify code */
                        },
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Loading Bottom Sheet Demo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading Modal Demo',
                      style: AppTypography.headlineH4.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Demo buttons
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        PrimaryButton.dayfi(
                          text: 'Simple Loading',
                          onPressed: () => _showSimpleLoadingDemo(context),
                        ),
                        PrimaryButton.dayfi(
                          text: 'Progress Loading',
                          onPressed: () => _showProgressLoadingDemo(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Bottom Sheet Example Usage
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bottom Sheet Showcase',
                      style: AppTypography.headlineH4.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bottom Sheet Example Usage
                    _buildBottomSheetRow('Sample Bottom Sheet', [
                      PrimaryButton.dayfi(
                        text: 'Show Sample Bottom Sheet',
                        onPressed: () => _showSampleBottomSheet(context),
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Continue Button
              Center(
                child: PrimaryButton.dayfi(
                  text: 'Continue to Login',
                  onPressed: () {
                    appRouter.pushNamed(AppRoute.loginView);
                  },
                ),
              ),

              const SizedBox(height: 32),

              ImageUploadTile(
                onImagePicked: (image) {},
                imageSource: ImageSource.camera,
                preferredCameraDevice: CameraDevice.rear,
                description: 'Upload your profile picture',
              ),

              const SizedBox(height: 32),

              Card(elevation: 2, child: PinView()),
              SizedBox(height: 32),
              CustomTextField(
                label: 'Email Address',
                controller: TextEditingController(),
                keyboardType: TextInputType.emailAddress,
                borderColor: Colors.black26,
                fillColor: Colors.grey.shade50,
              ),
              SizedBox(height: 16),
              PinCodeInput(
                length: 4,
                spacing: 12,
                borderRadius: 12,
                fillColor: Colors.blue.shade50,
                focusedBorderColor: Colors.blue.shade400,
                borderColor: Colors.blue.shade200,
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
                onCompleted: (value) {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context,
    String title,
    Color color,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.circle, color: textColor, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypographyRow(String label, TextStyle style) {
    return Builder(
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'The quick brown fox jumps over the lazy dog',
                    style: style.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildButtonRow(String title, List<Widget> buttons) {
    return Builder(
      builder:
          (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 12, runSpacing: 8, children: buttons),
            ],
          ),
    );
  }

  // Loading Modal Demo Methods
  void _showSimpleLoadingDemo(BuildContext context) {
    // Super simple - just context and loadingDuration
    LoadingModal.show(
      context: context,
      loadingDuration: const Duration(seconds: 3),
    );
  }

  void _showProgressLoadingDemo(BuildContext context) {
    LoadingModal.show(
      context: context,
      title: 'CHECKING OTP',
      controller: loadingModalController,
      isSuccess: true,
      showProgressText: true,
    );

    // Simulate progress updates
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (loadingModalController.currentProgress < 1.0) {
        loadingModalController.updateProgress(
          loadingModalController.currentProgress + 0.1,
        );
      } else {
        timer.cancel();
        loadingModalController.complete();
      }
    });
  }

  Widget _buildBottomSheetRow(String title, List<Widget> buttons) {
    return Builder(
      builder:
          (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 12, runSpacing: 8, children: buttons),
            ],
          ),
    );
  }

  // Bottom Sheet Example Usage
  void _showSampleBottomSheet(BuildContext context) {
    CustomBottomSheet.show(
      context: context,
      bottomSheet: CustomBottomSheet(
        fixedHeight: 500.h,
        showHandle: false,
        showCloseIcon: true,
        closeIconPosition: CloseIconPosition.right,
        showContinueButton: true,
        continueButtonText: 'SUBMIT',
        onContinue: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sample bottom sheet submitted!')),
          );
        },
        backgroundColor: AppColors.neutral0,
        borderRadius: 24.r,
        contentPadding: EdgeInsets.all(24.w),
        continueButtonPadding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          bottom: 50.h,
        ),
        isDismissible: true,
        enableDrag: true,
        child: _buildSampleBottomSheetContent(),
      ),
    );
  }

  // Content Builders
  Widget _buildSampleBottomSheetContent() {
    return Column(
      children: [
        Text(
          'This is a sample bottom sheet.',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutral900,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        Container(
          height: 200.h,
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.neutral300),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 32.w,
                  color: AppColors.neutral400,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Sample bottom sheet',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.neutral700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'This is a sample bottom sheet',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
