import 'package:dayfi/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/amount_custom_text_field.dart';
import 'package:dayfi/ui/views/tranfers_details_selection/tranfers_details_selection_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';

import '../../common/amount_formatter.dart';
import '../amount_entry/amount_entry_view.dart';
import '../amount_entry/amount_entry_viewmodel.dart';
import '../payment_setup/payment_setup_view.dart';
import '../recipient_details/recipient_account_model.dart';

class TransfersDetailsSelectionView
    extends StackedView<TransfersDetailsSelectionViewModel> {
  final String dayfiId;
  final Wallet wallet;
  TransfersDetailsSelectionView({
    super.key,
    required this.dayfiId,
    required this.wallet,
  });

  TextEditingController amount = TextEditingController();

  @override
  Widget builder(
    BuildContext context,
    TransfersDetailsSelectionViewModel viewModel,
    Widget? child,
  ) {
    final isAmountValid =
        viewModel.isAmountValid(amount.text, double.parse(wallet.balance));
    return WillPopScope(
      onWillPop: () async {
        viewModel.navigationService.back();
        return false;
      },
      child: AppScaffold(
        backgroundColor: Color(0xffF6F5FE),
        appBar: AppBar(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Color(0xffF6F5FE),
          leading: IconButton(
            onPressed: () => viewModel.navigationService.back(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xff5645F5), // innit
            ),
          ),
        ),
        body: StatefulBuilder(builder: (BuildContext context, setState) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            constraints: const BoxConstraints.expand(),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpace(10),
                      Padding(
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * .1),
                        child: Text(
                          "Send to $dayfiId",
                          style: TextStyle(
                            fontFamily: 'Boldonse',
                            fontSize: 27.5,
                            height: 1.2,
                            letterSpacing: 0.00,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff2A0079),
                            // color: Color( 0xff5645F5), // innit
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      verticalSpace(12),
                      Text(
                        "Provide the amount you want to send",
                        style: TextStyle(
                          fontFamily: 'Karla',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          height: 1.450,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .color!
                              // ignore: deprecated_member_use
                              .withOpacity(.85),
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                  verticalSpace(40),
                  AmountCustomTextField(
                    label: "Send NGN",
                    hintText: "0",
                    labelText: "Amount to receive",
                    controller: amount,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      try {
                        final amount = double.parse(value.replaceAll(",", ""));
                        if (amount >= double.parse(wallet.balance)) {
                          return 'Insufficient funds in wallet';
                        }
                        if (amount < 100) {
                          return 'Amount can\'t be less than 100';
                        }
                        if (amount > 300000) {
                          return 'Amount can\'t be more than 300,000';
                        }
                        return null; // Valid input
                      } catch (e) {
                        return 'Please enter a valid number';
                      }
                    },
                    formatter: [
                      // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      NumberFormatter(viewModel),
                    ],
                    onChanged: viewModel.setAmount,
                    enableInteractiveSelection: false,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 5),
                        const Text(
                          "NGN",
                          style: TextStyle(
                            fontFamily: 'Karla',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.00,
                            height: 1.450,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Image.asset(
                          "assets/images/nigeria.png",
                          height: 22,
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your NGN balance",
                    style: TextStyle(
                      fontFamily: 'Karla',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.1,
                      height: 1.450,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          // ignore: deprecated_member_use
                          .withOpacity(.85),
                    ),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "₦${AmountFormatter.formatDecimal(double.parse(wallet.balance))}",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.450,
                      color: Color(0xff2A0079),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(height: 24.h),
                        FilledBtn(
                          onPressed: () async {
                            isAmountValid
                                ? showModalBottomSheet(
                                    context: context,
                                    barrierColor: const Color(0xff2A0079)
                                        .withOpacity(0.5),
                                    isDismissible: false,
                                    isScrollControlled: true,
                                    enableDrag: false,
                                    // sheetAnimationStyle: AnimationStyle(
                                    //     duration: Duration.zero), // Set animation duration to zero
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(28.00),
                                      ),
                                    ),
                                    builder: (_) => SendSummaryBottomSheet(
                                      model: viewModel,
                                      amount: amount.text.trim().toString(),
                                      fee: "Free",
                                      walletType: "${wallet.currency} Wallet",
                                      username: dayfiId,
                                    ),
                                  )
                                : null;
                          },
                          backgroundColor: isAmountValid
                              ? const Color(0xff5645F5)
                              : Color(0xffCAC5FC),
                          text: "Next - Summary",

                          // textColor: Colors.white,
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                  verticalSpace(40),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _formatNumber(String value) {
    // Remove all non-digit characters
    value = value.replaceAll(RegExp(r'[^\d]'), '');

    if (value.isEmpty) return '';

    // Convert to number and format
    final number = int.tryParse(value);
    if (number == null) return '';

    // Format with thousand separators
    final formatted = NumberFormat("#,##0.${'0' * 2}", 'en_US').format(number);
    return formatted;
  }

  @override
  TransfersDetailsSelectionViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      TransfersDetailsSelectionViewModel(dayfiId: dayfiId);
}

class SendSummaryBottomSheet extends StatefulWidget {
  const SendSummaryBottomSheet({
    super.key,
    required this.walletType,
    required this.amount,
    required this.fee,
    required this.username,
    required this.model,
  });

  final String walletType;
  final String amount;
  final String fee;
  final String username;
  final TransfersDetailsSelectionViewModel model;

  @override
  State<SendSummaryBottomSheet> createState() => _SendSummaryBottomSheetState();
}

class _SendSummaryBottomSheetState extends State<SendSummaryBottomSheet> {
  @override
  void initState() {
    widget.model.loadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (
      BuildContext context,
      StateSetter setState,
    ) {
      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28.00),
              topRight: Radius.circular(28.00),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
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
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => widget.model.navigationService.back(),
                    child: SvgPicture.asset(
                      'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                      color: const Color(0xff5645F5), // innit
                      height: 28.00,
                    ),
                  ),
                ),
                // SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Send Summary',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        fontFamily: 'Boldonse',
                        letterSpacing: 0.00,
                        color: const Color(0xff2A0079),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .15),
                      child: const Text(
                        'Confirm the details of your transaction before moving on.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Karla",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          height: 1.450,
                          color: Color(0xFF302D53),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff2A0079).withOpacity(.075),
                        border: Border.all(
                          color: const Color(0xff5645F5), // innit
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Sending from',
                            value: widget.walletType ?? 'NGN Wallet',
                          ),
                          SizedBox(height: 12),
                          _SummaryRow(
                            label: 'Transferring to',
                            value: widget.username ?? '@kols',
                          ),
                          SizedBox(height: 12),
                          _SummaryRow(
                            label: 'Amount',
                            value:
                                "₦${AmountFormatter.formatDecimal(double.parse(widget.amount.replaceAll(",", "")))}",
                          ),
                          SizedBox(height: 12),
                          _SummaryRow(
                            label: 'Our fee',
                            value: widget.fee,
                          ),
                          Divider(height: 32, thickness: 1),
                          _SummaryRow(
                            label: 'Total leaving your wallet',
                            value:
                                "₦${AmountFormatter.formatDecimal(double.parse(widget.amount.replaceAll(",", "")))}",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledBtn(
                      onPressed: () => widget.model.user?.transactionPin == null
                          ? widget.model.navigationService
                              .navigateToTransactionPinNewView(oldPIN: null)
                          : showModalBottomSheet(
                              barrierColor:
                                  const Color(0xff2A0079).withOpacity(0.5),
                              context: context,
                              isDismissible: false,
                              isScrollControlled: true,
                              enableDrag: false,
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(28.00),
                                ),
                              ),
                              builder: (context) {
                                return TransactionPinBottomSheet(
                                  pinController: widget.model.pinController,
                                  transfersDetailsSelectionViewModel:
                                      widget.model,
                                  onConfirm: () {
                                    widget.model.initiateUserIDTransfer(
                                      context: context,
                                      amount: int.parse(
                                          widget.amount.replaceAll(",", "")),
                                      walletType: widget.walletType,
                                      dayfiId: widget.username,
                                    );
                                  },
                                );
                              }),
                      text: widget.model.user?.transactionPin == null
                          ? "Create - Transaction PIN"
                          : "Next - Transaction PIN",
                      backgroundColor: const Color(0xff5645F5),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -.1,
            height: 1.450,
            fontFamily: "Karla",
            color: Color(0xff2A0079),
          ),
          textAlign: TextAlign.start,
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            // letterSpacing: -.1,
            height: 1.450,
            color: Color(0xff2A0079),
          ),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}
