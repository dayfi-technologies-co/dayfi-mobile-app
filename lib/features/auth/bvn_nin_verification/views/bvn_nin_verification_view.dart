import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/auth/bvn_nin_verification/vm/bvn_nin_verification_viewmodel.dart';
import 'package:flutter_svg/svg.dart';

class BvnNinVerificationView extends ConsumerStatefulWidget {
  final bool showBackButton;

  const BvnNinVerificationView({super.key, this.showBackButton = false});

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
    final verificationNotifier = ref.read(bvnNinVerificationProvider.notifier);

    // Update controllers when state changes
    _updateControllers(verificationState);

    // Get showBackButton from arguments if available
    final args = ModalRoute.of(context)?.settings.arguments;
    final showBackButton = (args is Map && args['showBackButton'] == true) || widget.showBackButton;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: .5,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        shadowColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 72,
        leading: showBackButton
            ? InkWell(
                onTap: () {
                  verificationNotifier.resetForm();
                  Navigator.pop(context);
                  FocusScope.of(context).unfocus();
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
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
        automaticallyImplyLeading: false,
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(18.0, 12, 18.0, 40.0),
        child: // Submit Button
            PrimaryButton(
              borderRadius: 38,
              text: "Verify",
              onPressed:
                  verificationState.isFormValid && !verificationState.isBusy
                      ? () => verificationNotifier.submitVerification(context, widget.showBackButton)
                      : null,
              backgroundColor:
                  verificationState.isFormValid
                      ? AppColors.purple500ForTheme(context)
                      : AppColors.purple500ForTheme(context).withOpacity(.15),
              height: 48.00000.h,
              textColor:
                  verificationState.isFormValid
                      ? AppColors.neutral0
                      : AppColors.neutral0.withOpacity(.35),
              fontFamily: 'Karla',
              letterSpacing: -.70,
              fontSize: 18,
              width: double.infinity,
              fullWidth: true,
              isLoading: verificationState.isBusy,
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 300.ms, curve: Curves.easeOutCubic)
            .slideY(
              begin: 0.2,
              end: 0,
              delay: 500.ms,
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            )
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.0, 1.0),
              delay: 500.ms,
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    Text(
                      "KYC Level 2 Verification",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontSize: 18.sp,
                        fontFamily: 'Boldonse',
                        letterSpacing: -.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 18.h),
                    Padding(
                      padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * .2,
                      ),
                      child: Text(
                        "Enter your BVN and NIN to complete your KYC Level 2 verification. This will only take about 30 seconds.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Karla',
                          letterSpacing: -.6,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // BVN field
                    _buildBvnField(verificationState, verificationNotifier),
                    SizedBox(height: 18.h),

                    // NIN field
                    _buildNinField(verificationState, verificationNotifier),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // ),
      // ),
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
                letterSpacing: -.6,
                fontWeight: FontWeight.w500,
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
                letterSpacing: -.6,
                fontWeight: FontWeight.w500,
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
