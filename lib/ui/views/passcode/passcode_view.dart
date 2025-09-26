import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/views/main/main_view.dart';
import 'package:dayfi/ui/views/passcode/passcode_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PasscodeView extends StackedView<PasscodeViewModel> {
  const PasscodeView({super.key});

  @override
  Widget builder(BuildContext context, PasscodeViewModel model, Widget? child) {
    return Stack(
      children: [
        // Advanced animated background with gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xffF6F5FE).withOpacity(0.4),
                const Color(0xff5645F5).withOpacity(0.1),
                const Color(0xffF6F5FE).withOpacity(0.6),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 1000.ms, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(1.0, 1.0),
          duration: 1200.ms,
          curve: Curves.easeOutCubic,
        ),

        // Floating particles background
        ...List.generate(12, (index) => _buildFloatingParticle(index)),

        // Floating geometric shapes
        ...List.generate(8, (index) => _buildFloatingShape(index)),

        // Main content
        AppScaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    backgroundImage: const NetworkImage(
                      'https://avatar.iran.liara.run/public/52',
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),
              const SizedBox(height: 16),
              Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontFamily: 'Boldonse',
                      fontSize: 22.00,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff2A0079),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                    delay: 100.ms,
                  )
                  .slideY(
                    begin: -0.1,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                    delay: 100.ms,
                  ),
              verticalSpace(8.h),
              model.user != null && model.user!.firstName != ""
                  ? Text(
                        model.user!.firstName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          height: 1.450,
                          color: Color(0xff2A0079),
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                        delay: 200.ms,
                      )
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                        delay: 200.ms,
                      )
                  : SizedBox.shrink(),
              const SizedBox(height: 32),
              model.isVerifying
                  ? CupertinoActivityIndicator(
                        color: Color(0xff5645F5), // innit
                      )
                      .animate()
                      .fadeIn(
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                        delay: 300.ms,
                      )
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                        delay: 300.ms,
                      )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    index < model.passcode.length
                                        ? const Color(0xff5645F5)
                                        : Colors.transparent,
                                border: Border.all(
                                  color: const Color(0xff5645F5), // innit
                                  width: 2,
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                            delay: Duration(milliseconds: 300 + (index * 50)),
                          )
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                            delay: Duration(milliseconds: 300 + (index * 50)),
                          );
                    }),
                  ),
              SizedBox(height: MediaQuery.of(context).size.width * .3),
              Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Enter your passcode',
                      style: TextStyle(
                        fontFamily: 'Karla',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        height: 1.450,
                        color: Color(0xff2A0079),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  )
                  .animate()
                  .fadeIn(
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                    delay: 400.ms,
                  )
                  .slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                    delay: 400.ms,
                  ),
              const SizedBox(height: 8),
              GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ...List.generate(9, (index) {
                        final number = (index + 1).toString();
                        return _buildNumberButton(number, model, index);
                      }),
                      _buildIconButton(
                        iconSvg:
                            model.hasFaceId
                                ? "assets/svgs/face_id.svg"
                                : "assets/svgs/fingerprint.svg",
                        icon: model.hasFaceId ? Icons.face : Icons.fingerprint,
                        onTap:
                            model.isBiometricAvailable
                                ? () async {
                                  final authenticated =
                                      await model.authenticateWithBiometrics();
                                  if (authenticated) {
                                    model.navigationService
                                        .clearStackAndShowView(MainView());
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Biometric authentication failed',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                            height: 1.450,
                                            color: Colors.white,
                                            fontFamily: 'Karla',
                                          ),
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                                : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Biometric authentication not available',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                          height: 1.450,
                                          color: Colors.white,
                                          fontFamily: "Karla",
                                        ),
                                      ),
                                    ),
                                  );
                                },
                        index: 9,
                      ),
                      _buildNumberButton('0', model, 10),
                      _buildIconButton(
                        iconSvg: "",
                        icon: Icons.arrow_back_ios,
                        onTap: model.removeDigit,
                        index: 11,
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                    delay: 500.ms,
                  )
                  .slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                    delay: 500.ms,
                  ),
              const SizedBox(height: 32),
              //  SizedBox(height: 24.h),
              Center(
                    child: Text.rich(
                      textAlign: TextAlign.end,
                      TextSpan(
                        text: "Not your account?",
                        style: TextStyle(
                          fontFamily: 'Karla',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -.04,
                          height: 1.450,
                          color: Theme.of(context).textTheme.bodyLarge!.color!
                          // ignore: deprecated_member_use
                          .withOpacity(.85),
                        ),
                        children: [
                          TextSpan(
                            text: " Log out",
                            style: const TextStyle(
                              fontFamily: 'Karla',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -.04,
                              height: 1.450,
                              color: Color(0xff5645F5), // innit
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    model.logout();
                                  },
                          ),
                        ],
                      ),
                      semanticsLabel: '',
                    ),
                  )
                  .animate()
                  .fadeIn(
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                    delay: 600.ms,
                  )
                  .slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                    delay: 600.ms,
                  ),

              const Spacer(flex: 1),
            ],
          ),
        ),
          ))      ],
    );
  }

  Widget _buildNumberButton(String number, PasscodeViewModel model, int index) {
    return GestureDetector(
          onTap: () => model.addDigit(number),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 24.00,
                  fontFamily: 'Boldonse',
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 500.ms,
          curve: Curves.easeOutCubic,
          delay: Duration(milliseconds: 500 + (index * 50)),
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
          delay: Duration(milliseconds: 500 + (index * 50)),
        );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String iconSvg,
    required VoidCallback onTap,
    required int index,
  }) {
    return InkWell(
          onTap: onTap,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Center(
              child:
                  (icon == Icons.fingerprint || icon == Icons.face)
                      ? SvgPicture.asset(
                        iconSvg,
                        height: 36,
                        color: Color(0xff5645F5), // innit
                      )
                      : Icon(
                        icon,
                        size:
                            (icon == Icons.fingerprint || icon == Icons.face)
                                ? 36
                                : 24,
                        color: Color(0xff5645F5), // innit
                      ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 500.ms,
          curve: Curves.easeOutCubic,
          delay: Duration(milliseconds: 500 + (index * 50)),
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
          delay: Duration(milliseconds: 500 + (index * 50)),
        );
  }

  @override
  PasscodeViewModel viewModelBuilder(BuildContext context) =>
      PasscodeViewModel();

  Widget _buildFloatingParticle(int index) {
    final colors = [
      const Color(0xff5645F5).withOpacity(0.08),
      const Color(0xff7C3AED).withOpacity(0.06),
      const Color(0xffEC4899).withOpacity(0.05),
      const Color(0xff10B981).withOpacity(0.07),
      const Color(0xffF59E0B).withOpacity(0.06),
    ];
    
    return Positioned(
      top: (80 + (index * 60)).h,
      left: (30 + (index * 80)).w,
      child: Container(
        width: (6 + (index % 4) * 3).w,
        height: (6 + (index % 4) * 3).w,
        decoration: BoxDecoration(
          color: colors[index % colors.length],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors[index % colors.length],
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      )
      .animate()
      .fadeIn(
        delay: Duration(milliseconds: 800 + (index * 150)),
        duration: 1200.ms,
        curve: Curves.easeOutCubic,
      )
      .scale(
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
        delay: Duration(milliseconds: 800 + (index * 150)),
        duration: 1000.ms,
        curve: Curves.elasticOut,
      )
      .moveY(
        begin: 0,
        end: -30,
        duration: 4000.ms,
        curve: Curves.easeInOut,
      )
      .then()
      .moveY(
        begin: -30,
        end: 0,
        duration: 4000.ms,
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildFloatingShape(int index) {
    final shapes = ['circle', 'square', 'triangle', 'diamond'];
    final colors = [
      const Color(0xff5645F5).withOpacity(0.12),
      const Color(0xff7C3AED).withOpacity(0.10),
      const Color(0xffEC4899).withOpacity(0.08),
      const Color(0xff10B981).withOpacity(0.09),
    ];
    
    return Positioned(
      top: (120 + (index * 90)).h,
      left: (60 + (index * 100)).w,
      child: Container(
        width: (15 + (index * 3)).w,
        height: (15 + (index * 3)).w,
        decoration: BoxDecoration(
          color: colors[index % colors.length],
          shape: shapes[index % shapes.length] == 'circle' 
              ? BoxShape.circle 
              : BoxShape.rectangle,
          borderRadius: shapes[index % shapes.length] == 'circle' 
              ? null 
              : shapes[index % shapes.length] == 'diamond'
                  ? BorderRadius.circular(2)
                  : BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: colors[index % colors.length],
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      )
      .animate()
      .fadeIn(
        delay: Duration(milliseconds: 1000 + (index * 200)),
        duration: 1500.ms,
        curve: Curves.easeOutCubic,
      )
      .scale(
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
        delay: Duration(milliseconds: 1000 + (index * 200)),
        duration: 1200.ms,
        curve: Curves.elasticOut,
      )
      .rotate(
        begin: 0,
        end: 2 * 3.14159,
        duration: 25000.ms,
        curve: Curves.linear,
      )
      .moveX(
        begin: 0,
        end: 20,
        duration: 6000.ms,
        curve: Curves.easeInOut,
      )
      .then()
      .moveX(
        begin: 20,
        end: 0,
        duration: 6000.ms,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void onViewModelReady(PasscodeViewModel viewModel) {
    viewModel.loadUser();
    super.onViewModelReady(viewModel);
  }
}
