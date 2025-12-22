import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/auth/forgot_password/vm/forgot_password_viewmodel.dart';
import 'package:flutter_svg/svg.dart';

class ForgotPasswordView extends ConsumerStatefulWidget {
  final String? initialEmail;
  
  const ForgotPasswordView({super.key, this.initialEmail});

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    // Set initial email if provided
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(forgotPasswordProvider.notifier).setEmail(widget.initialEmail!);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgotPasswordState = ref.watch(forgotPasswordProvider);
    final forgotPasswordNotifier = ref.read(forgotPasswordProvider.notifier);
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard and remove focus from all text fields
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            resizeToAvoidBottomInset: false,
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
                      forgotPasswordNotifier.resetForm(),
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
                      child: PrimaryButton(
                            borderRadius: 38,
                            text: "Receive Reset Code",
                            onPressed:
                                forgotPasswordState.isFormValid &&
                                        !forgotPasswordState.isBusy
                                    ? () => forgotPasswordNotifier.forgotPassword(context)
                                    : null,
                            enabled:
                                forgotPasswordState.isFormValid &&
                                !forgotPasswordState.isBusy,
                            isLoading: forgotPasswordState.isBusy,
                            backgroundColor:
                                forgotPasswordState.isFormValid
                                    ? AppColors.purple500ForTheme(context)
                                    : AppColors.purple500ForTheme(context).withOpacity(.15),
                            height: 48.00000,
                            textColor:
                                forgotPasswordState.isFormValid
                                 ? AppColors.neutral0
                                          : AppColors.neutral0.withOpacity(.20),
                            fontFamily: 'Chirp',
                            letterSpacing: -.70,
                            fontSize: 18,
                            fullWidth: true,
                          )
                          .animate()
                          .fadeIn(
                            delay: 600.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            delay: 600.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1.0, 1.0),
                            delay: 600.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          
            body: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth > 600;
                    return SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 8),
          
                                Text(
                                  "Reset password",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayLarge?.copyWith(
                                    color: Theme.of(context).textTheme.headlineLarge?.color,
                                    fontSize: isWide ? 32 : 28,
                                    letterSpacing:-.250,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'FunnelDisplay',
                                    height: 1,
                                  ),
                                ),
          
                                SizedBox(height: 32),
          
                                // Email field
                                CustomTextField(
                                      label: "Email Address",
                                      hintText: "Enter your email address here",
                                      controller: _emailController,
                                      onChanged: forgotPasswordNotifier.setEmail,
                                      keyboardType: TextInputType.emailAddress,
                                      textCapitalization: TextCapitalization.none,
                                    )
                                    .animate()
                                    .fadeIn(
                                      delay: 400.ms,
                                      duration: 400.ms,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .slideY(
                                      begin: 0.3,
                                      end: 0,
                                      delay: 400.ms,
                                      duration: 400.ms,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .scale(
                                      begin: const Offset(0.98, 0.98),
                                      end: const Offset(1.0, 1.0),
                                      delay: 400.ms,
                                      duration: 400.ms,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .shimmer(
                                      delay: 800.ms,
                                      duration: 1000.ms,
                                      color: AppColors.purple500ForTheme(
                                        context,
                                      ).withOpacity(0.1),
                                      angle: 15,
                                    ),
          
                                if (forgotPasswordState.emailError.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0, left: 14),
                                    child: Text(
                                      forgotPasswordState.emailError,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
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
            ),
          ),

           if (forgotPasswordState.isBusy)
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
      ),
    );
  }
}
