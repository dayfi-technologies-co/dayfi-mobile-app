import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/outlined_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';
import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({super.key});

  @override
  void onViewModelReady(StartupViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.initialise();
  }

  @override
  Widget builder(
    BuildContext context,
    StartupViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      hasSafeArea: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
          children: [
                // Animated background gradient
                Container(
                    decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xffF6F5FE).withOpacity(0.3),
                        const Color(0xff5645F5).withOpacity(0.1),
                        const Color(0xffF6F5FE).withOpacity(0.5),
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

                Container(
              child: PageView.builder(
                controller: viewModel.pageController,
                onPageChanged: (index) {
                      viewModel.setPageIndex(index);
                },
                    itemCount: viewModel.titles.length,
                itemBuilder: (context, index) {
                      return _buildAdvancedPage(context, index);
                    },
                  ),
                ),
                // Advanced page indicators with glow effect
                Positioned(
                  top: 72.h,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 21.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(viewModel.titles.length, (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 4.5.r,
                            child: Stack(
                              children: [
                                // Background indicator
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: const Color.fromARGB(255, 230, 230, 230),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                LayoutBuilder(
                                  builder: (context, constraints) => Container(
                                    height: 4.5.r,
                                    width: constraints.maxWidth,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.transparent,
                                    ),
                                    child: AnimatedAlign(
                                      alignment: Alignment.centerLeft,
                                      duration: const Duration(milliseconds: 600),
                                      curve: Curves.easeOutCubic,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.easeOutCubic,
                                        width: viewModel.currentPage == index
                                            ? constraints.maxWidth
                                            : 0,
                                        height: 4.5.r,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xff5645F5),
                                              Color(0xff7C3AED),
                                            ],
                                          ),
                                          boxShadow: viewModel.currentPage == index
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xff5645F5).withOpacity(0.4),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : [],
                                        ),
                                      )
                                      .animate(
                                        target: viewModel.currentPage == index ? 1 : 0,
                                      )
                                      .scale(
                                        begin: const Offset(0.8, 0.8),
                                        end: const Offset(1.0, 1.0),
                                        duration: 300.ms,
                                        curve: Curves.elasticOut,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 200 * index),
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .slideX(
                            begin: -0.3,
                            end: 0,
                            delay: Duration(milliseconds: 200 * index),
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          ),
                        );
                      }),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 600.ms)
                .slideY(begin: -0.2, end: 0, delay: 500.ms, duration: 600.ms),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              constraints: const BoxConstraints.expand(),
              child: Column(
                children: [
                  const Spacer(),
                  const Spacer(),
                  Text(
                        viewModel.titles[viewModel.currentPage],
                        style: TextStyle(
                          fontFamily: 'Boldonse',
                          fontSize: 28.00,
                          height: 1.65,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff2A0079),
                          shadows: [
                            Shadow(
                              color: const Color(0xff2A0079).withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate(key: ValueKey(viewModel.currentPage))
                      .fadeIn(
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.4,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .shimmer(
                        duration: 2000.ms,
                        color: const Color(0xff5645F5).withOpacity(0.3),
                        angle: 45,
                      ),
                  verticalSpace(14),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * .1,
                    ),
                    child: Text(
                          viewModel.descriptions[viewModel.currentPage],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            fontFamily: 'Karla',
                            height: 1.5,
                            color: const Color(0xFF302D53),
                            shadows: [
                              Shadow(
                                color: const Color(0xFF302D53).withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate(key: ValueKey(viewModel.currentPage))
                        .fadeIn(
                          delay: 200.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 200.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1.0, 1.0),
                          delay: 200.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  const Spacer(),
                  const Spacer(),
                  const Spacer(),
                  const Spacer(),
                  const Spacer(),
                  // Advanced Sign Up button with glow effect
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff5645F5).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: FilledBtn(
                      onPressed: () {
                        viewModel.saveFirstTimeUser();
                        viewModel.navigationService.replaceWithSignupView();
                      },
                      text: "Sign Up",
                      backgroundColor: const Color(0xff5645F5),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: 400.ms,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .slideY(
                    begin: 0.4,
                    end: 0,
                    delay: 400.ms,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.0, 1.0),
                    delay: 400.ms,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .shimmer(
                    delay: 1000.ms,
                    duration: 1500.ms,
                    color: Colors.white.withOpacity(0.3),
                    angle: 45,
                  ),

                  verticalSpace(16),

                  // Advanced Login button with hover effect
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff5645F5).withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: OutlineBtn(
                      onPressed: () {
                        viewModel.saveFirstTimeUser();
                        viewModel.navigationService.replaceWithLoginView();
                      },
                      text: "Login",
                      textColor: const Color(0xff5645F5),
                      backgroundColor: const Color(0xffffffff),
                      borderColor: const Color(0xff5645F5),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: 600.ms,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .slideY(
                    begin: 0.4,
                    end: 0,
                    delay: 600.ms,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.0, 1.0),
                    delay: 600.ms,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  ),
                  const Spacer(),
                  const Spacer(),
                  const Spacer(),
                ],
              ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildAdvancedPage(BuildContext context, int index) {
    return Container(
      color: const Color(0xffF6F5FE),
      child: Stack(
        children: [
          // Animated background with parallax effect
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/backgroud.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
            ),
          )
          .animate()
          .fadeIn(duration: 800.ms, curve: Curves.easeOutCubic)
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(1.0, 1.0),
            duration: 1000.ms,
            curve: Curves.easeOutCubic,
          )
          .shimmer(
            duration: 3000.ms,
            color: Colors.white.withOpacity(0.1),
            angle: 30,
          ),

          // Floating geometric shapes
          ...List.generate(5, (i) => _buildFloatingShape(i, index)),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final colors = [
      const Color(0xff5645F5).withOpacity(0.1),
      const Color(0xff7C3AED).withOpacity(0.08),
      const Color(0xffEC4899).withOpacity(0.06),
      const Color(0xff10B981).withOpacity(0.07),
    ];
    
    return Positioned(
      top: (100 + (index * 80)).h,
      left: (50 + (index * 60)).w,
      child: Container(
        width: (8 + (index % 3) * 4).w,
        height: (8 + (index % 3) * 4).w,
        decoration: BoxDecoration(
          color: colors[index % colors.length],
          shape: BoxShape.circle,
        ),
      )
      .animate()
      .fadeIn(
        delay: Duration(milliseconds: 500 + (index * 200)),
        duration: 1000.ms,
        curve: Curves.easeOutCubic,
      )
      .scale(
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
        delay: Duration(milliseconds: 500 + (index * 200)),
        duration: 800.ms,
        curve: Curves.elasticOut,
      )
      .moveY(
        begin: 0,
        end: -20,
        duration: 3000.ms,
        curve: Curves.easeInOut,
      )
      .then()
      .moveY(
        begin: -20,
        end: 0,
        duration: 3000.ms,
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildFloatingShape(int index, int pageIndex) {
    final shapes = ['circle', 'square', 'triangle'];
    final colors = [
      const Color(0xff5645F5).withOpacity(0.15),
      const Color(0xff7C3AED).withOpacity(0.12),
      const Color(0xffEC4899).withOpacity(0.10),
    ];
    
    return Positioned(
      top: (150 + (index * 100)).h,
      left: (80 + (index * 120)).w,
      child: Container(
        width: (20 + (index * 5)).w,
        height: (20 + (index * 5)).w,
        decoration: BoxDecoration(
          color: colors[index % colors.length],
          shape: shapes[index % shapes.length] == 'circle' 
              ? BoxShape.circle 
              : BoxShape.rectangle,
          borderRadius: shapes[index % shapes.length] == 'circle' 
              ? null 
              : BorderRadius.circular(4),
        ),
      )
      .animate()
      .fadeIn(
        delay: Duration(milliseconds: 800 + (index * 300)),
        duration: 1200.ms,
        curve: Curves.easeOutCubic,
      )
      .scale(
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
        delay: Duration(milliseconds: 800 + (index * 300)),
        duration: 1000.ms,
        curve: Curves.elasticOut,
      )
      .rotate(
        begin: 0,
        end: 2 * 3.14159,
        duration: 20000.ms,
        curve: Curves.linear,
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();
}
