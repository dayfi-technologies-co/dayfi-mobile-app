import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/auth/bvn_nin_verification/vm/bvn_nin_verification_viewmodel.dart';

class BvnNinVerificationView extends ConsumerStatefulWidget {
  const BvnNinVerificationView({super.key});

  @override
  ConsumerState<BvnNinVerificationView> createState() =>
      _BvnNinVerificationViewState();
}

class _BvnNinVerificationViewState
    extends ConsumerState<BvnNinVerificationView> {
  // Text controllers
  late TextEditingController _bvnController;
  late TextEditingController _ninController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Reset form state when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bvnNinVerificationProvider.notifier).resetForm();
    });
  }

  void _initializeControllers() {
    _bvnController = TextEditingController();
    _ninController = TextEditingController();
  }

  @override
  void dispose() {
    _bvnController.dispose();
    _ninController.dispose();
    super.dispose();
  }

  void _updateControllers(BvnNinVerificationState state) {
    if (_bvnController.text != state.bvn) {
      _bvnController.text = state.bvn;
    }
    if (_ninController.text != state.nin) {
      _ninController.text = state.nin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final verificationState = ref.watch(bvnNinVerificationProvider);
    final verificationNotifier =
        ref.read(bvnNinVerificationProvider.notifier);

    // Update controllers when state changes
    _updateControllers(verificationState);

    return WillPopScope(
      onWillPop: () async => false, // Disable device back button
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBar(
                    scrolledUnderElevation: 0,
                    backgroundColor:
                        Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    automaticallyImplyLeading: false, // Remove back button
                    title: Text(
                      "KYC Level 2 Verification",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                           fontFamily: 'CabinetGrotesk',
               fontSize: 20.sp, // height: 1.6,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle
                        Text(
                          "Please provide your BVN and NIN to complete your KYC Level 2 verification.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Karla',
                                letterSpacing: -.3,
                                height: 1.4,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 36.h),

                        // BVN field
                        _buildBvnField(verificationState, verificationNotifier),
                        SizedBox(height: 18.h),

                        // NIN field
                        _buildNinField(verificationState, verificationNotifier),
                        SizedBox(height: 40.h),

                        // Submit Button
                        PrimaryButton(
                          borderRadius: 38,
                          text: "Verify",
                          onPressed: verificationState.isFormValid &&
                                  !verificationState.isBusy
                              ? () => verificationNotifier.submitVerification(context)
                              : null,
                          backgroundColor: verificationState.isFormValid
                              ? AppColors.purple500ForTheme(context)
                              : AppColors.purple500ForTheme(context).withOpacity(.25),
                          height: 48.000.h,
                          textColor: verificationState.isFormValid
                              ? AppColors.neutral0
                              : AppColors.neutral0.withOpacity(.65),
                          fontFamily: 'Karla',
                          letterSpacing: -.8,
                          fontSize: 18,
                          width: double.infinity,
                          fullWidth: true,
                          isLoading: verificationState.isBusy,
                        ),
                        SizedBox(height: 50.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBvnField(
    BvnNinVerificationState state,
    BvnNinVerificationNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "BVN (Bank Verification Number)",
          hintText: "Enter your 11-digit BVN",
          controller: _bvnController,
          maxLength: 11,
          keyboardType: TextInputType.number,
          formatter: FilteringTextInputFormatter.digitsOnly,
          onChanged: notifier.setBvn,
        ),
        if (state.bvnError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.bvnError,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontFamily: 'Karla',
                letterSpacing: -.3,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildNinField(
    BvnNinVerificationState state,
    BvnNinVerificationNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "NIN (National Identification Number)",
          hintText: "Enter your 11-digit NIN",
          controller: _ninController,
          maxLength: 11,
          keyboardType: TextInputType.number,
          formatter: FilteringTextInputFormatter.digitsOnly,
          onChanged: notifier.setNin,
        ),
        if (state.ninError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 14),
            child: Text(
              state.ninError,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontFamily: 'Karla',
                letterSpacing: -.3,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}

