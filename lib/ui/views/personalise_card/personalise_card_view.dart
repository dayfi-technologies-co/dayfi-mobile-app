import 'dart:math';

import 'package:dayfi/services/api/database_service.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/filled_btn_small.dart';
import 'package:dayfi/ui/components/input_fields/pin_text_field.dart';
import 'package:dayfi/ui/components/top_snack_bar.dart';
import 'package:dayfi/ui/views/virtual_card_details/virtual_card_details_view.dart';
import 'package:dayfi/ui/views/virtual_card_details/virtual_card_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/views/personalise_card/personalise_card_viewmodel.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PersonaliseCardView extends StackedView<PersonaliseCardViewModel> {
  const PersonaliseCardView({super.key});

  @override
  Widget builder(
    BuildContext context,
    PersonaliseCardViewModel model,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff5645F5),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: FilledBtnSmall(
              textColor: const Color(0xff5645F5),
              backgroundColor: Colors.white,
              onPressed: () {},
              text: "Need Help?",
            ),
          ),
        ],
      ),
      body: model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : model.hasError
              ? Center(
                  child: Text(
                    'Error loading user data. Please log in again.',
                    style: TextStyle(
                      fontFamily: 'Boldonse',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                )
              : model.user == null
                  ? Center(
                      child: Text(
                        'No user data found. Please log in.',
                        style: TextStyle(
                          fontFamily: 'Boldonse',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8.h),
                            Text(
                              'Personalise your card',
                              style: TextStyle(
                                fontFamily: 'Boldonse',
                                fontSize: 22.00,
                                height: 1.2,
                                letterSpacing: -0.2,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff2A0079),
                              ),
                            ),
                            verticalSpace(8),
                            Padding(
                              padding: const EdgeInsets.only(right: 48.0),
                              child: Text(
                                'What name and color would you like your card to be?',
                                style: TextStyle(
                                  fontFamily: 'Karla',
                                  fontSize: 15,
                                  color: Color(0xFF302D53),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -.02,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            verticalSpace(24.h),
                          
                            Column(
                              children: [
                                VirtualCard(
                                  userName: model.cardHolderName.isNotEmpty
                                      ? model.cardHolderName
                                      : "${model.user!.firstName} ${model.user!.lastName}",
                                  currencySymbol: "\$",
                                  balance: 00.00,
                                  cardColor: model.selectedColor,
                                  cardNumber: "**** **** **** ****",
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Select a card color',
                                  style: TextStyle(
                                    fontFamily: 'Karla',
                                    fontSize: 15,
                                    color: Color(0xFF302D53),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -.02,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _colorDot(
                                        Color.fromARGB(255, 12, 2, 29), model),
                                    _colorDot(Color(0xff2A0079), model),
                                    _colorDot(Color.fromARGB(255, 137, 104, 4),
                                        model),
                                    _colorDot(
                                        Color.fromARGB(255, 4, 61, 63), model),
                                    _colorDot(Color.fromARGB(255, 139, 11, 118),
                                        model),
                                  ],
                                ),
                              ],
                            ),
                            verticalSpace(40.h),
                            Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 18),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24, horizontal: 18),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff2A0079)
                                        .withOpacity(.075),
                                    border: Border.all(
                                        color: const Color(0xff5645F5)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Our rate",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -.1,
                                              height: 1.45,
                                              fontFamily: "Karla",
                                              color: Color(0xff2A0079),
                                            ),
                                          ),
                                          Text(
                                            "\$1",
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              height: 1.45,
                                              color: const Color(0xff2A0079),
                                            ),
                                          ),
                                        ],
                                      ),
                                      verticalSpace(8.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Total leaving your wallet",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -.1,
                                              height: 1.45,
                                              fontFamily: "Karla",
                                              color: Color(0xff2A0079),
                                            ),
                                          ),
                                          Text(
                                            "\$2",
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              height: 1.45,
                                              color: const Color(0xff2A0079),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Image.asset(
                                        "assets/images/idea.png",
                                        height: 22,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            verticalSpace(32.h),
                            FilledBtn(
                              onPressed: model.user != null &&
                                      model.user!.userId.isNotEmpty
                                  ? () =>
                                      _showCardPinBottomSheet(context, model)
                                  : () => TopSnackbar.show(
                                        isError: true,
                                        context,
                                        message: "Please log in to proceed.",
                                      ),
                              backgroundColor: const Color(0xff5645F5),
                              text: "Next - Card PIN",
                            ),
                            verticalSpace(40.h),
                          ],
                        ),
                      ),
                    ),
    );
  }

  void _showCardPinBottomSheet(
    BuildContext context,
    PersonaliseCardViewModel model,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PinBottomSheet(
        onPinComplete: (pin) {
          Navigator.pop(context); // Close the first sheet
          _showConfirmPinBottomSheet(context, model, pin);
        },
      ),
    );
  }

  void _showConfirmPinBottomSheet(
    BuildContext context,
    PersonaliseCardViewModel model,
    String firstPin,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PinBottomSheet(
        onPinComplete: (secondPin) async {
          Navigator.pop(context); // Close confirm sheet

          if (secondPin == firstPin) {
            try {
              final databaseService = DatabaseService();
              final userId = model.user!.userId;
              // Generate a unique card number
              final random = Random();
              final cardNumber =
                  '4${random.nextInt(1000).toString().padLeft(3, '0')} ${random.nextInt(10000).toString().padLeft(4, '0')} ${random.nextInt(10000).toString().padLeft(4, '0')} ${random.nextInt(10000).toString().padLeft(4, '0')}';
              final dummyCard = VirtualCardModel(
                userId: userId,
                cardNumber: cardNumber,
                cardHolderName: model.cardHolderName.isNotEmpty
                    ? model.cardHolderName
                    : '${model.user!.firstName} ${model.user!.lastName}',
                expiryDate: '12/28',
                cvv: '123',
                streetName: model.user!.street ?? '123 Main St',
                city: model.user!.city ?? 'New York',
                state: model.user!.state ?? 'NY',
                postcode: model.user!.postalCode ?? '10001',
              );

              await databaseService.cacheVirtualCards([dummyCard], userId);
              debugPrint(
                  'Dummy virtual card saved for user: $userId, card: $cardNumber');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CardSuccessScreen(),
                ),
              );
            } catch (e) {
              debugPrint('Error saving virtual card: $e');
              TopSnackbar.show(
                isError: true,
                context,
                message: "Failed to save card details. Please try again.",
              );
            }
          } else {
            TopSnackbar.show(
              isError: true,
              context,
              message: "PINs do not match. Please try again.",
            );
          }
        },
      ),
    );
  }

  Widget _colorDot(Color color, PersonaliseCardViewModel model) {
    return GestureDetector(
      onTap: () => model.updateCardColor(color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: model.selectedColor == color
                ? Colors.white
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: model.selectedColor == color
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : const SizedBox(),
      ),
    );
  }

  @override
  PersonaliseCardViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PersonaliseCardViewModel();

  @override
  void onViewModelReady(PersonaliseCardViewModel viewModel) async {
    await viewModel.loadUser();
    super.onViewModelReady(viewModel);
  }
}

class VirtualCard extends StatelessWidget {
  final String userName;
  final String currencySymbol;
  final double balance;
  final Color cardColor;
  final String cardNumber; // masked e.g. **** **** **** 1234

  const VirtualCard({
    super.key,
    required this.userName,
    required this.currencySymbol,
    required this.balance,
    required this.cardColor,
    required this.cardNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 187,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Opacity(
            opacity: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/images/backgroud.png',
                fit: BoxFit.cover,
                color: Colors.orangeAccent.shade200,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Myaza Logo & Balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Replace with your SVG or Image.asset
                    Row(
                      children: [
                        Image.asset('assets/images/logoo.png', height: 35),
                        horizontalSpaceTiny,
                        Text(
                          "dayfi",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                            fontFamily: 'Karla',
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      "USD",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        fontFamily: 'Boldonse',
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),

                // Masked card number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cardNumber,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        fontFamily: 'Karla',
                        letterSpacing: 0,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "VALID THRU",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                            fontFamily: 'karla',
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          "**/**",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                            fontFamily: 'karla',
                            letterSpacing: -.5,
                          ),
                        )
                      ],
                    )
                  ],
                ),

                // Bottom Row (Name & Expiry)
                Text(
                  userName.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    fontFamily: 'karla',
                    letterSpacing: 0.5,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PinBottomSheet extends StatefulWidget {
  final Function(String) onPinComplete;

  const _PinBottomSheet({required this.onPinComplete});

  @override
  State<_PinBottomSheet> createState() => _PinBottomSheetState();
}

class _PinBottomSheetState extends State<_PinBottomSheet> {
  final TextEditingController _pinController = TextEditingController();
  bool _isPinValid = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_validatePin);
  }

  void _validatePin() {
    setState(() => _isPinValid = _pinController.text.length == 4);
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 4,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withOpacity(0.25),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    _pinController.clear();
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                    color: const Color(0xff5645F5),
                    height: 28,
                  ),
                ),
              ),
              verticalSpace(8),
              // Title
              const Text(
                "Create Card PIN",
                style: TextStyle(
                  fontFamily: 'Boldonse',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2A0079),
                ),
              ),
              verticalSpace(8),
              const Text(
                "Enter a 4-digit PIN for your virtual card",
                style: TextStyle(
                  fontFamily: 'Karla',
                  fontSize: 15,
                  color: Color(0xFF302D53),
                  fontWeight: FontWeight.w600,
                ),
              ),

              verticalSpace(24),

              // PIN input
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.2,
                ),
                child: PinTextField(
                  length: 4,
                  obscureText: true,
                  onTextChanged: (value) {
                    print("Pin value: $value");
                  },
                  onCompleted: (value) {
                    print("Completed with: $value");
                  },
                  controller: _pinController,
                ),
              ),

              verticalSpace(48),

              // NEXT Button
              FilledBtn(
                text: "Next - Confirm PIN",
                onPressed: _isPinValid
                    ? () => widget.onPinComplete(_pinController.text)
                    : null,
                backgroundColor: _isPinValid
                    ? const Color(0xff5645F5)
                    : const Color(0xffCAC5FC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardSuccessScreen extends StatelessWidget {
  const CardSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff5645F5),
      body: Stack(
        children: [
          // ✅ Background image overlay
          Opacity(
            opacity: 1,
            child: Image.asset(
              'assets/images/backgroud.png',
              fit: BoxFit.cover,
              color: const Color(0xffCAC5FC),
              width: MediaQuery.of(context).size.width,
            ),
          ),

          // ✅ Main content (Body + Button)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              _buildBody(context),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildNextStepButton(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Success body (icon + title + subtitle)
  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        // ✅ Success icon
        SvgPicture.asset(
          "assets/svgs/successcheck.svg",
          height: 88,
        ),
        const SizedBox(height: 18),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Main title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  "USD Virtual Card Created!",
                  style: const TextStyle(
                    fontFamily: 'Boldonse',
                    fontSize: 22.00,
                    height: 1.15,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black26,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Your virtual card is ready for use.\nYou can view it anytime in your cards list.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Karla',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.45,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ✅ Bottom button
  Widget _buildNextStepButton(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 32.0),
      child: SizedBox(
        width: double.infinity,
        child: FilledBtn(
          text: "Next - View card details",
          backgroundColor: Colors.white,
          textColor: const Color(0xff5645F5),
          onPressed: () {
            // ✅ Navigate back or go to cards screen
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VirtualCardDetailsView()));
            // Or pushNamed(context, Routes.cardsView);
          },
        ),
      ),
    );
  }
}
