import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/views/reenter_passcode/reenter_passcode_viewmodel.dart';
import 'package:stacked/stacked.dart';

class ReenterPasscodeView extends StatelessWidget {
  const ReenterPasscodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReenterPasscodeViewModel>.reactive(
      viewModelBuilder: () => ReenterPasscodeViewModel(),
      builder:
          (context, model, child) => Stack(
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
              ...List.generate(8, (index) => _buildFloatingParticle(index)),

              // Floating geometric shapes
              ...List.generate(6, (index) => _buildFloatingShape(index)),

              // Main content
              AppScaffold(
                backgroundColor: const Color(0xffF6F5FE),
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          verticalSpace(12.h),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: IconButton(
                              onPressed: () {
                                model.navigationService.back();
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xff5645F5), // innit
                              ),
                            ),
                          ),
                          verticalSpace(16.h),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              "Re-enter passcode",
                              style: TextStyle(
                                fontSize: 22.00,
                                fontFamily: 'Boldonse',
                                height: 1.2,
                                letterSpacing: 0.00,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff2A0079),
                                // color: Color( 0xff5645F5), // innit
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          verticalSpace(8.h),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              "Enter 6-digit passcode to confirm",
                              style: TextStyle(
                                fontFamily: 'Karla',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                height: 1.450,
                                color: Color(0xFF302D53),
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: PasscodeWidget(
                          passcodeLength: 6,
                          currentPasscode: model.passcode,
                          onPasscodeChanged:
                              (value) => model.updatePasscode(context, value),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

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
          .moveY(begin: 0, end: -30, duration: 4000.ms, curve: Curves.easeInOut)
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
              shape:
                  shapes[index % shapes.length] == 'circle'
                      ? BoxShape.circle
                      : BoxShape.rectangle,
              borderRadius:
                  shapes[index % shapes.length] == 'circle'
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
          .moveX(begin: 0, end: 20, duration: 6000.ms, curve: Curves.easeInOut)
          .then()
          .moveX(begin: 20, end: 0, duration: 6000.ms, curve: Curves.easeInOut),
    );
  }
}

class PasscodeWidget extends StatelessWidget {
  final int passcodeLength;
  final String currentPasscode;
  final Function(String) onPasscodeChanged;

  const PasscodeWidget({
    super.key,
    required this.passcodeLength,
    required this.currentPasscode,
    required this.onPasscodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            passcodeLength,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      index < currentPasscode.length
                          ? const Color(0xff5645F5)
                          : Colors.transparent,
                  border: Border.all(
                    color: const Color(0xff5645F5), // innit
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.width * .25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "Enter your 6-digit passcode",
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
        ),
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
              return _buildNumberButton(number);
            }),
            const SizedBox.shrink(), // Placeholder for the fingerprint button (not needed)
            _buildNumberButton('0'),
            _buildIconButton(
              icon: Icons.arrow_back_ios,
              onTap: () {
                if (currentPasscode.isNotEmpty) {
                  onPasscodeChanged(
                    currentPasscode.substring(0, currentPasscode.length - 1),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () {
        if (currentPasscode.length < passcodeLength) {
          onPasscodeChanged(currentPasscode + number);
        }
      },
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
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(
            icon,
            // size: 32,
            color: Color(0xff5645F5), // innit
          ),
        ),
      ),
    );
  }
}
