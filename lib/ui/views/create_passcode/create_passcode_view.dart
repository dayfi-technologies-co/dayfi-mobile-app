import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/views/reenter_passcode/reenter_passcode_view.dart';
import 'package:stacked/stacked.dart';

import 'create_passcode_viewmodel.dart';

class CreatePasscodeView extends StackedView<CreatePasscodeViewModel> {
  const CreatePasscodeView({super.key});

  @override
  Widget builder(
    BuildContext context,
    CreatePasscodeViewModel viewModel,
    Widget? child,
  ) {
    return ViewModelBuilder<CreatePasscodeViewModel>.reactive(
      viewModelBuilder: () => CreatePasscodeViewModel(),
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
                backgroundColor: Color(0xffF6F5FE),
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

                          // Advanced back button without shadow
                          Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: IconButton(
                                  onPressed:
                                      () => model.navigationService.back(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Color(0xff5645F5),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(
                                delay: 300.ms,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .slideX(
                                begin: -0.3,
                                end: 0,
                                delay: 300.ms,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.0, 1.0),
                                delay: 300.ms,
                                duration: 500.ms,
                                curve: Curves.elasticOut,
                              )
                              .shimmer(
                                delay: 1000.ms,
                                duration: 1500.ms,
                                color: const Color(0xff5645F5).withOpacity(0.3),
                                angle: 30,
                              ),

                          verticalSpace(16.h),

                          // Title with smooth entrance
                          Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Text(
                                  "Create passcode",
                                  style: TextStyle(
                                    fontFamily: 'Boldonse',
                                    fontSize: 22.00,
                                    height: 1.2,
                                    letterSpacing: 0.00,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xff2A0079),
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              )
                              .animate()
                              .fadeIn(
                                delay: 300.ms,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .slideY(
                                begin: 0.3,
                                end: 0,
                                delay: 300.ms,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .scale(
                                begin: const Offset(0.95, 0.95),
                                end: const Offset(1.0, 1.0),
                                delay: 300.ms,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                              ),

                          verticalSpace(8.h),

                          // Subtitle with smooth entrance
                          Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Text(
                                  "Enter 6-digit passcode to create",
                                  style: TextStyle(
                                    fontFamily: 'Karla',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    height: 1.450,
                                    color: const Color(0xFF302D53),
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              )
                              .animate()
                              .fadeIn(
                                delay: 400.ms,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                delay: 400.ms,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                              ),
                        ],
                      ),

                      // Passcode widget with animation
                      Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: PasscodeWidget(
                              passcodeLength: 6,
                              currentPasscode: model.passcode,
                              onPasscodeChanged: model.updatePasscode,
                            ),
                          )
                          .animate()
                          .fadeIn(
                            delay: 500.ms,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            delay: 500.ms,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .scale(
                            begin: const Offset(0.98, 0.98),
                            end: const Offset(1.0, 1.0),
                            delay: 500.ms,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 24),
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

  @override
  CreatePasscodeViewModel viewModelBuilder(BuildContext context) =>
      CreatePasscodeViewModel();
}
