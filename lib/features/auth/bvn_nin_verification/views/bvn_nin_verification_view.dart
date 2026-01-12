import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final showBackButton =
        (args is Map && args['showBackButton'] == true) ||
        widget.showBackButton;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            scrolledUnderElevation: .5,
            foregroundColor: Theme.of(context).scaffoldBackgroundColor,
            shadowColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leadingWidth: 72,
            leading:
                showBackButton
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
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color,
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

          bottomNavigationBar: SafeArea(
            child: AnimatedContainer(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(.2),
                    width: 1,
                  ),
                ),
              ),
              duration: const Duration(milliseconds: 10),
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 8,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom > 0
                        ? MediaQuery.of(context).viewInsets.bottom + 8
                        : 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: // Submit Button
                        PrimaryButton(
                          borderRadius: 38,
                          text: "Verify",
                          onPressed:
                              verificationState.isFormValid &&
                                      !verificationState.isBusy
                                  ? () =>
                                      verificationNotifier.submitVerification(
                                        context,
                                        widget.showBackButton,
                                      )
                                  : null,
                          backgroundColor:
                              verificationState.isFormValid
                                  ? AppColors.purple500ForTheme(context)
                                  : AppColors.purple500ForTheme(
                                    context,
                                  ).withOpacity(.15),
                          height: 48.00000,
                          textColor:
                              verificationState.isFormValid
                                  ? AppColors.neutral0
                                  : AppColors.neutral0.withOpacity(.20),
                          fontFamily: 'Chirp',
                          letterSpacing: -.70,
                          fontSize: 18,
                          fullWidth: true,
                          isLoading: verificationState.isBusy,
                        )
                        .animate()
                        .fadeIn(
                          delay: 500.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
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
                ],
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth > 600;
                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 32 : 18,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              "KYC Level 2 Verification",
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.displayLarge?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.headlineLarge?.color,
                                fontSize: isWide ? 32 : 28,
                                letterSpacing: -.250,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'FunnelDisplay',
                                height: 1,
                              ),
                            ),

                            SizedBox(height: 18),
                            Text(
                              "Enter your BVN and NIN to complete your KYC Level 2 verification. This will only take about 30 seconds.",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Chirp',
                                letterSpacing: -.25,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 32),

                            // BVN field
                            _buildBvnField(
                              verificationState,
                              verificationNotifier,
                            ),
                            SizedBox(height: 18),

                            // NIN field
                            _buildNinField(
                              verificationState,
                              verificationNotifier,
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // ),
          // ),
        ),
        if (verificationState.isBusy)
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: Opacity(
              opacity: 0.5,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
              ),
            ),
          ),
      ],
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
                fontFamily: 'Chirp',
                letterSpacing: -.25,
                fontWeight: FontWeight.w500,
                height: 1.2,
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
                fontFamily: 'Chirp',
                letterSpacing: -.25,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
