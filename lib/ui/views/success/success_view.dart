import 'package:flutter_svg/svg.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stacked/stacked.dart';

import 'success_viewmodel.dart';

class SuccessView extends StackedView<SuccessViewModel> {
  // final UserModel? user;
  const SuccessView({super.key});

  @override
  Widget builder(
    BuildContext context,
    SuccessViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xff5645F5),
      body: Stack(
        children: [
          // Background with entrance animation
          Opacity(
            opacity: .05,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              color: const Color(0xffCAC5FC),
              width: MediaQuery.of(context).size.width,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
              .scale(begin: const Offset(1.05, 1.05), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.easeOutCubic),
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: ConfettiWidget(
          //     confettiController: ConfettiController(),
          //     blastDirection: 3.14 / 2,
          //     maxBlastForce: 5,
          //     minBlastForce: 1,
          //     emissionFrequency: 0.03,
          //     numberOfParticles: 10,
          //     gravity: 0.1,
          //     colors: const [
          //       Colors.purple,
          //       Colors.white,
          //       Colors.pink,
          //       Colors.cyan,
          //       Colors.amber,
          //     ],
          //   ),
          // ),
          // Opacity(
          //   opacity: .25,
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(24),
          //     child: Image.asset(
          //       'assets/images/splashscreen.png',
          //       fit: BoxFit.cover,
          //       width: MediaQuery.of(context).size.width,
          //       height: MediaQuery.of(context).size.height,
          //     ),
          //   ),
          // ),
          // Main content with staggered animations
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .05),
              _buildBody(context),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildNextStepButton(viewModel),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        // Success icon with bounce animation
        SvgPicture.asset(
          "assets/svgs/successcheck.svg",
          height: 88,
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
            .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), delay: 300.ms, duration: 600.ms, curve: Curves.elasticOut),
        
        SizedBox(height: 18),
        
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title with smooth entrance
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  "Welcome to DayFi",
                  style: TextStyle(
                    fontFamily: 'Boldonse',
                    fontSize: 22.00,
                    height: 1.15,
                    letterSpacing: 0.00,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              
              SizedBox(height: 16),
              
              // Subtitle with smooth entrance
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Your financial journey starts now! Manage your money effortlessly, one day at a time, with DayFi's seamless tools. 🚀",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Karla',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.450,
                    color: Colors.white,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepButton(SuccessViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 32.0),
      child: SizedBox(
        child: FilledBtn(
          onPressed: () => viewModel.navigationService
              .clearStackAndShow(Routes.createPasscodeView),
          text: "Next - Create Passcode",
          backgroundColor: Colors.white,
          textColor: const Color(0xff5645F5),
          semanticLabel: 'Continue to create passcode',
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.3, end: 0, delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic)
        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic)
        .shimmer(delay: 800.ms, duration: 1000.ms, color: Colors.white.withOpacity(0.3));
  }

  @override
  SuccessViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      SuccessViewModel();
}
