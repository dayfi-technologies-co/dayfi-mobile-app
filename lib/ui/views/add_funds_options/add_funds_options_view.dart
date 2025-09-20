import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';

import 'add_funds_options_viewmodel.dart';

class AddFundsOptionsView extends StackedView<AddFundsOptionsViewModel> {
  const AddFundsOptionsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    AddFundsOptionsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => viewModel.navigationService.back(),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff5645F5),
          ),
        ),
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            text: "Add funds",
            style: TextStyle(
                fontSize: 19,
                color: Color(0xFF151515),
                fontFamily: 'Karla',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              verticalSpaceSmall,
              _buildOptionCard(
                icon: "assets/images/icons8-@-100.png",
                title: "Dayfi-ID",
                description:
                    "Add instantly to your wallet using a Dayfi-ID for free",
                // onTap: () => Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => DayfiApp())),
                context: context,
              ),
              verticalSpaceSmall,
              _buildOptionCard(
                icon: "assets/images/icons8-debit-card-100.png",
                title: "Debit card — Tap or Scan",
                description:
                    "Add funds instantly to your wallet using a debit card with tap or scan",
                // onTap: () => Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => DayfiApp())),
                context: context,
              ),
              verticalSpaceSmall,
              _buildOptionCard(
                icon: "assets/images/icons8-bank-100.png",
                title: "Bank transfer",
                description:
                    "Add funds securely to your wallet from any bank account with ease",
                // onTap: () => Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => DayfiApp())),
                context: context,
              ),
              // verticalSpaceSmall,
              // _buildOptionCard(
              //   icon: "assets/images/icons8-crypto-100.png",
              //   title: "Crypto address",
              //   description:
              //       "Add funds quickly to your wallet using a USDT crypto address",
              //   onTap: () => Navigator.push(context,
              //       MaterialPageRoute(builder: (context) => DayfiApp())),
              //   context: context,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String icon,
    required String title,
    required String description,
    // required VoidCallback onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      // onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          color: Color.fromARGB(255, 246, 248, 242),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              icon,
              height: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: -0.2,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff011B33),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.25,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF808080),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  @override
  AddFundsOptionsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AddFundsOptionsViewModel();
}
