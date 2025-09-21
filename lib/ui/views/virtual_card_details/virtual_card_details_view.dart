import 'package:dayfi/ui/views/personalise_card/personalise_card_view.dart';
import 'package:dayfi/ui/views/virtual_card_details/virtual_card_details_viewmodel.dart';
import 'package:dayfi/ui/views/virtual_card_details/virtual_card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/filled_btn_small.dart';
import 'package:stacked/stacked.dart';
import 'package:dayfi/services/api/database_service.dart';
import 'dart:developer';

class VirtualCardDetailsView extends StackedView<VirtualCardDetailsViewModel> {
  const VirtualCardDetailsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    VirtualCardDetailsViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        backgroundColor: const Color(0xffF6F5FE),
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff2A0079)),
          onPressed: () => Navigator.pop(context),
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
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(
    BuildContext context,
    VirtualCardDetailsViewModel viewModel,
  ) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: viewModel.user != null
          ? DatabaseService().getCachedVirtualCards(viewModel.user!.userId)
          : Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          log('Error loading virtual cards: ${snapshot.error}');
          return const Center(
            child: Text(
              'Error loading card details',
              style: TextStyle(
                fontFamily: 'Boldonse',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No virtual card found',
                  style: TextStyle(
                    fontFamily: 'Boldonse',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff2A0079),
                  ),
                ),
                verticalSpace(16.h),
                FilledBtn(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonaliseCardView(),
                      ),
                    );
                  },
                  text: 'Create a Virtual Card',
                  backgroundColor: const Color(0xff5645F5),
                ),
              ],
            ),
          );
        }

        // Get the first card and verify user_id
        final cardMap = snapshot.data![0];
        if (cardMap['user_id'] != viewModel.user!.userId) {
          log('Card user_id mismatch: expected ${viewModel.user!.userId}, got ${cardMap['user_id']}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No matching virtual card found for this user',
                  style: TextStyle(
                    fontFamily: 'Boldonse',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                verticalSpace(16.h),
                FilledBtn(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonaliseCardView(),
                      ),
                    );
                  },
                  text: 'Create a Virtual Card',
                  backgroundColor: const Color(0xff5645F5),
                ),
              ],
            ),
          );
        }

        // Create VirtualCardModel with userId
        final card = VirtualCardModel(
          userId: cardMap['user_id'] ?? viewModel.user!.userId,
          cardNumber: cardMap['card_number'] ?? '**** **** **** 1234',
          cardHolderName: cardMap['card_holder_name'] ?? 'Unknown',
          expiryDate: cardMap['expiry_date'] ?? '12/28',
          cvv: cardMap['cvv'] ?? '123',
          streetName: cardMap['street_name'] ?? 'Unknown',
          city: cardMap['city'] ?? 'Unknown',
          state: cardMap['state'] ?? 'Unknown',
          postcode: cardMap['postcode'] ?? '00000',
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpace(8.h),
              const Text(
                "USD Virtual Card Details",
                style: TextStyle(
                  fontSize: 27.5,
                  fontFamily: "SpaceGrotesk",
                  height: 1.2,
                  letterSpacing: 0.00,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2A0079),
                ),
              ),
              verticalSpace(6.h),
              const Text(
                "Copy and share your card details easily",
                style: TextStyle(
                  fontFamily: 'Karla',
                  fontWeight: FontWeight.w600,
                  letterSpacing: .3,
                  height: 1.450,
                  color: Color(0xFF302D53),
                ),
              ),
              verticalSpace(24.h),
              VirtualCard(
                userName: card.cardHolderName,
                currencySymbol: "\$",
                balance:
                    00.00, // Placeholder; replace with actual balance if available
                cardColor: const Color.fromARGB(255, 12, 2, 29),
                cardNumber:
                    "**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}",
              ),
              verticalSpace(40.h),
              Text(
                "Card information",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Boldonse',
                  letterSpacing: 0.3,
                  color: Color(0xff2A0079),
                ),
              ),
              verticalSpace(8.h),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xff5645F5).withOpacity(.08),
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: const Color(0xff5645F5).withOpacity(.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.cardNumber,
                                  style: const TextStyle(
                                    fontFamily: 'Boldonse',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.00,
                                    height: 1.450,
                                    color: Color(0xff2A0079),
                                  ),
                                ),
                                const Text(
                                  'Card Number',
                                  style: TextStyle(
                                    fontFamily: 'Karla',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.00,
                                    height: 1.450,
                                    color: Color(0xFF302D53),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: card.cardNumber));
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    "copy",
                                    style: TextStyle(
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: 0.00,
                                      height: 1.450,
                                      color: Color(0xff5645F5),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.copy,
                                    color: Color(0xff5645F5),
                                    size: 17,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.cardHolderName,
                                  style: const TextStyle(
                                    fontFamily: 'Boldonse',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.00,
                                    height: 1.450,
                                    color: Color(0xff2A0079),
                                  ),
                                ),
                                const Text(
                                  'Cardholder Name',
                                  style: TextStyle(
                                    fontFamily: 'Karla',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.00,
                                    height: 1.450,
                                    color: Color(0xFF302D53),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: card.cardHolderName));
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    "copy",
                                    style: TextStyle(
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: 0.00,
                                      height: 1.450,
                                      color: Color(0xff5645F5),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.copy,
                                    color: Color(0xff5645F5),
                                    size: 17,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.expiryDate,
                                  style: const TextStyle(
                                    fontFamily: 'Boldonse',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.00,
                                    height: 1.450,
                                    color: Color(0xff2A0079),
                                  ),
                                ),
                                const Text(
                                  'Expiry Date',
                                  style: TextStyle(
                                    fontFamily: 'Karla',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.00,
                                    height: 1.450,
                                    color: Color(0xFF302D53),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: card.expiryDate));
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    "copy",
                                    style: TextStyle(
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: 0.00,
                                      height: 1.450,
                                      color: Color(0xff5645F5),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.copy,
                                    color: Color(0xff5645F5),
                                    size: 17,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.cvv,
                                  style: const TextStyle(
                                    fontFamily: 'Boldonse',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.00,
                                    height: 1.450,
                                    color: Color(0xff2A0079),
                                  ),
                                ),
                                const Text(
                                  'CVV',
                                  style: TextStyle(
                                    fontFamily: 'Karla',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.00,
                                    height: 1.450,
                                    color: Color(0xFF302D53),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: card.cvv));
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    "copy",
                                    style: TextStyle(
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: 0.00,
                                      height: 1.450,
                                      color: Color(0xff5645F5),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.copy,
                                    color: Color(0xff5645F5),
                                    size: 17,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.fullAddress,
                                  style: const TextStyle(
                                    fontFamily: 'Boldonse',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.00,
                                    height: 1.450,
                                    color: Color(0xff2A0079),
                                  ),
                                ),
                                const Text(
                                  'Billing Address',
                                  style: TextStyle(
                                    fontFamily: 'Karla',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.00,
                                    height: 1.450,
                                    color: Color(0xFF302D53),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: card.fullAddress));
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    "copy",
                                    style: TextStyle(
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: 0.00,
                                      height: 1.450,
                                      color: Color(0xff5645F5),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.copy,
                                    color: Color(0xff5645F5),
                                    size: 17,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 252, 254),
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                          color: const Color.fromARGB(255, 26, 77, 104)),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/idea.png",
                          height: 22,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Charge for funding your USD virtual card is 1% capped at \$5.00',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Karla',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              height: 1.450,
                              color: Color.fromARGB(255, 26, 77, 104),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledBtn(
                onPressed: () => {},
                text: 'Share details',
                backgroundColor: const Color(0xff5645F5),
              ),
              verticalSpace(40.h),
            ],
          ),
        );
      },
    );
  }

  @override
  VirtualCardDetailsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      VirtualCardDetailsViewModel();

  @override
  void onViewModelReady(VirtualCardDetailsViewModel viewModel) async {
    await viewModel.loadUser();
    super.onViewModelReady(viewModel);
  }
}
