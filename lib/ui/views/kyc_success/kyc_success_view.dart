import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:stacked/stacked.dart';

import 'kyc_success_viewmodel.dart';

class KycSuccessView extends StackedView<KycSuccessViewModel> {
  const KycSuccessView({super.key});

  @override
  Widget builder(
    BuildContext context,
    KycSuccessViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xff5645F5),
      body: Stack(
        children: [
          Opacity(
            opacity: 1,
            child: Image.asset(
              'assets/images/backgroud.png',
              fit: BoxFit.cover,
              color: const Color(0xffCAC5FC),
              width: MediaQuery.of(context).size.width,
            ),
          ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          "assets/svgs/successcheck.svg",
          height: 88,
        ),
        SizedBox(height: 18),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  "Level One Completed",
                  style: TextStyle(
                    fontFamily: 'Boldonse',
                    fontSize: 22.00,
                    height: 1.15,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 28),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Great job! Your spending limit has increased. Keep going to unlock even more benefits.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Karla',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.45,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepButton(KycSuccessViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 32.0),
      child: SizedBox(
        child: FilledBtn(
          onPressed: () =>
              viewModel.navigationService.clearStackAndShow(Routes.mainView),
          text: "Go Home",
          backgroundColor: Colors.white,
          textColor: const Color(0xff5645F5), // innit
        ),
      ),
    );
  }

  @override
  KycSuccessViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      KycSuccessViewModel();
}
