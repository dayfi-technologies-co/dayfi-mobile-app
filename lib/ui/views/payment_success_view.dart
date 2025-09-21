import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/ui/common/amount_formatter.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/pin_text_field.dart';
import 'package:dayfi/ui/views/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show SizeExtension;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentSuccessView extends StatefulWidget {
  final String transactionReference;
  final String amount;
  final String currency;
  final VoidCallback onClose;

  PaymentSuccessView({
    required this.transactionReference,
    required this.amount,
    required this.currency,
    required this.onClose,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PaymentSuccessViewState createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView> {
  final HomeViewModel model = HomeViewModel();
  bool isLoading = false;
  TextEditingController otpTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => model.navigationService.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xff5645F5),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpace(10),
              
              // Title with smooth entrance
              Text(
                "Verify Transaction",
                style: TextStyle(
                  fontFamily: 'Boldonse',
                  fontSize: 27.5,
                  height: 1.2,
                  letterSpacing: 0.00,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff2A0079),
                ),
                textAlign: TextAlign.start,
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              
              verticalSpace(12),
              
              // Subtitle with smooth entrance
              Text(
                "Enter the 6-digit OTP sent to your phone to verify the transaction.",
                style: TextStyle(
                  fontFamily: 'Karla',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  height: 1.450,
                  color: const Color(0xFF302D53),
                ),
                textAlign: TextAlign.start,
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              
              verticalSpace(48),
              
              // PIN field with animation
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * .025),
                child: Column(
                  children: [
                    PinTextField(
                      length: 6,
                      obscureText: true,
                      controller: otpTextEditingController,
                      textInputAction: TextInputAction.done,
                      onTextChanged: (value) {
                        // No need to handle logic here for demo purposes
                      },
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              
              verticalSpace(MediaQuery.of(context).size.height * .2),
              
              // Submit button with enhanced animation
              FilledBtn(
                onPressed: () async {
                  if (otpTextEditingController.text.length == 6) {
                    setState(() {
                      isLoading = true;
                    });
                    // Simulate 2-second delay for verification
                    await Future.delayed(const Duration(seconds: 2));
                    // Navigate to MainPaymentSuccessView
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPaymentSuccessView(
                          transactionReference: widget.transactionReference,
                          amount: widget.amount,
                          currency: widget.currency,
                          onClose: widget.onClose,
                        ),
                      ),
                    );
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                text: "Complete",
                isLoading: isLoading,
                backgroundColor: const Color(0xff5645F5),
                textColor: Colors.white,
                semanticLabel: 'Complete transaction verification',
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .shimmer(delay: 700.ms, duration: 1000.ms, color: Colors.white.withOpacity(0.3)),
              
              verticalSpace(40),
            ],
          ),
        ),
      ),
    );
  }
}

class MainPaymentSuccessView extends StatelessWidget {
  final String transactionReference;
  final String amount;
  final String currency;
  final VoidCallback onClose;

  MainPaymentSuccessView({
    required this.transactionReference,
    required this.amount,
    required this.currency,
    required this.onClose,
  });

  final HomeViewModel model = HomeViewModel();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xff5645F5),
      body: Stack(
        children: [
          // Background with entrance animation
          Image.asset(
            'assets/images/backgroud.png',
            fit: BoxFit.cover,
            color: const Color(0xff2A0079),
            width: MediaQuery.of(context).size.width,
          )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
              .scale(begin: const Offset(1.05, 1.05), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.easeOutCubic),
          
          // Main content with staggered animations
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .05),
              _buildBody(context),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildNextStepButton(model),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title with smooth entrance
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  "Top-up Successful",
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
              
              const SizedBox(height: 16),
              
              // Subtitle with smooth entrance
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Your wallet has been funded successfully.",
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
        
        verticalSpace(40.h),
        
        // Transaction details with animation
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.04),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Top-up Amount",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.1,
                      height: 1.450,
                      fontFamily: "Karla",
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    AmountFormatter.formatCurrency(double.parse(amount)),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.450,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
              verticalSpace(10.h),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Status",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.1,
                      height: 1.450,
                      fontFamily: "Karla",
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    "Successful",
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic)
            .slideY(begin: 0.3, end: 0, delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic)
            .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildNextStepButton(HomeViewModel model) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 32.0),
      child: SizedBox(
        child: FilledBtn(
          onPressed: () => model.navigationService.navigateToMainView(),
          text: "Close, I'm done",
          backgroundColor: Colors.white,
          textColor: const Color(0xff5645F5),
          semanticLabel: 'Close payment success screen',
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 500.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.3, end: 0, delay: 800.ms, duration: 500.ms, curve: Curves.easeOutCubic)
        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 800.ms, duration: 500.ms, curve: Curves.easeOutCubic)
        .shimmer(delay: 900.ms, duration: 1000.ms, color: Colors.white.withOpacity(0.3));
  }
}
