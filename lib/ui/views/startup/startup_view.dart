import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/outlined_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stacked/stacked.dart';
import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({super.key});

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
                Container(
                  // color: Color(0xffF6F5FE).withOpacity(.1),
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: viewModel.pageController,
                    onPageChanged: (index) {
                      viewModel.setPageIndex(index);
                    },
                    children: [
                      _buildPage(context, image: 'assets/images/swap.png'),
                      _buildPage(context, image: 'assets/images/payments.png'),
                      _buildPage(context, image: 'assets/images/crypto.png'),
                    ],
                  ),
                ),

                // Positioned(
                //   top: 54,
                //   left: 0,
                //   right: 0,
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 21.0),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: List.generate(viewModel.titles.length, (index) {
                //         return Expanded(
                //           child: Container(
                //             margin: const EdgeInsets.symmetric(horizontal: 3),
                //             height: 4.5.r,
                //             child: Stack(
                //               children: [
                //                 Container(
                //                   decoration: BoxDecoration(
                //                     borderRadius: BorderRadius.circular(20),
                //                     color: const Color.fromARGB(
                //                         255, 230, 230, 230),
                //                   ),
                //                 ),
                //                 LayoutBuilder(
                //                     builder: (context, constraints) =>
                //                         Container(
                //                           height: 4.5.r,
                //                           width: constraints.maxWidth,
                //                           decoration: BoxDecoration(
                //                             borderRadius:
                //                                 BorderRadius.circular(20),
                //                             color: Colors.transparent,
                //                           ),
                //                           child: Align(
                //                             alignment: Alignment.centerLeft,
                //                             child: Container(
                //                               width: viewModel.currentPage ==
                //                                       index
                //                                   ? viewModel.animationValue *
                //                                       constraints.maxWidth
                //                                   : 0,
                //                               decoration: BoxDecoration(
                //                                 borderRadius:
                //                                     BorderRadius.circular(20),
                //                                 color: const Color(
                //                                     0xff5645F5), // innit
                //                               ),
                //                             )
                //                                 .animate(
                //                                     target:
                //                                         viewModel.currentPage ==
                //                                                 index
                //                                             ? 1
                //                                             : 0)
                //                                 .fadeIn(duration: 300.ms)
                //                                 .moveX(
                //                                     begin: -20,
                //                                     end: 0,
                //                                     duration: 300.ms,
                //                                     curve: Curves.easeOut),
                //                           ),
                //                         )),
                //               ],
                //             ),
                //           ),
                //         );
                //       }),
                //     ),
                //   ),
                // ),
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
                          height: 1.5,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff2A0079),
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate(key: ValueKey(viewModel.currentPage))
                      .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
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
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                            fontFamily: 'Karla',
                            height: 1.450,
                            color: const Color(0xFF302D53),
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate(key: ValueKey(viewModel.currentPage))
                        .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  const Spacer(),
                  const Spacer(),
                  const Spacer(),
                  const Spacer(),
                  const Spacer(),
                  SizedBox(
                    child: FilledBtn(
                          onPressed: () {
                            viewModel.saveFirstTimeUser();
                            viewModel.navigationService.replaceWithSignupView();
                          },
                          text: "Sign Up",
                          backgroundColor: const Color(0xff5645F5),
                        )
                        .animate()
                        .fadeIn(
                          delay: 200.ms,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 200.ms,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1.0, 1.0),
                          delay: 200.ms,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  verticalSpace(12),
                  SizedBox(
                    child: OutlineBtn(
                          onPressed: () {
                            viewModel.saveFirstTimeUser();
                            viewModel.navigationService.replaceWithLoginView();
                          },
                          text: "Login",
                          textColor: const Color(0xff5645F5),
                          backgroundColor: const Color(0xffffffff),
                          borderColor: const Color(0xff5645F5),
                        )
                        .animate()
                        .fadeIn(
                          delay: 400.ms,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 400.ms,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1.0, 1.0),
                          delay: 400.ms,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, {required String image}) {
    return Container(
      color: const Color(0xffF6F5FE),
      child: Stack(
        children: [
          ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Opacity(
                  opacity: .1,
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
              .scale(
                begin: const Offset(1.05, 1.05),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.easeOutCubic,
              ),
        ],
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();
}
