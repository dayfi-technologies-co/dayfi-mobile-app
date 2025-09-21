import 'package:dayfi/data/models/transaction_history_model.dart';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/ui/views/transaction_details/transaction_details_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/filled_btn_small.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class TransactionDetailsView extends StackedView<TransactionDetailsViewModel> {
  final WalletTransaction transaction;
  final Wallet wallet;

  const TransactionDetailsView(this.wallet,
      {super.key, required this.transaction});

  @override
  Widget builder(
    BuildContext context,
    TransactionDetailsViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xffF6F5FE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff2A0079)),
          onPressed: () => Navigator.pop(context),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 20.0),
        //     child: FilledBtnSmall(
        //       textColor: Color( 0xff5645F5), // innit
        //       backgroundColor: Colors.white,
        //       onPressed: () {},
        //       text: "Need Help?",
        //     ),
        //   ),
        // ],
      ),
      body: _buildBody(transaction),
    );
  }

  Widget _buildBody(WalletTransaction tx) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          verticalSpace(8.h),
          Text(
            "Transaction summary",
            style: TextStyle(
              fontSize: 22,
              fontFamily: "SpaceGrotesk",
              height: 1.2,
              letterSpacing: 0.00,
              fontWeight: FontWeight.w600,
              color: Color(0xff2A0079),
            ),
          ),
          verticalSpace(18),

          // transaction status
          CircleAvatar(
            radius: 24,
            backgroundColor: tx.type == 'card_to_wallet'
                ? Color(0xff00AFF5).withOpacity(.1)
                : Color(0xffFFB97D).withOpacity(.25),
            child: Transform.rotate(
              angle:
                  // 2.37
                  !tx.type.contains("card_to_wallet") ? 0 : 3.12,
              child: Center(
                child: SvgPicture.asset(
                  tx.type.contains("card_to_wallet")
                      ? 'assets/svgs/arrow-narrow-down.svg'
                      : 'assets/svgs/arrow-narrow-down.svg',
                  color: tx.type == 'card_to_wallet'
                      ? Color(0xff00AFF5)
                      : Color(0xffFF897D),
                  height: 17.5,
                ),
              ),
            ),
          ),
          verticalSpace(12),

          // TRANSACTION AMOUNT
          Text(
            "Amount",
            style: TextStyle(
              fontFamily: 'Karla',
              fontWeight: FontWeight.w600,
              letterSpacing: .3,
              fontSize: 16,
              height: 1.450,
              color: Colors.grey.shade800,
            ),
          ),
          verticalSpace(2),
          Center(
            child: Text(
              "${tx.type == 'card_to_wallet' ? '+' : '-'} ₦${NumberFormat("#,##0.${'0' * 2}").format(double.tryParse(tx.amount) ?? 0)}",
              style: GoogleFonts.spaceGrotesk(
                // fontFamily: "Karla",
                fontSize: 22,
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
                color: tx.status == 'success' && tx.type == 'card_to_wallet'
                    ? Colors.green.shade800
                    : tx.status == 'pending'
                        ? Colors.yellow.shade800
                        : Colors.red.shade800,
              ),
            ),
          ),
          verticalSpace(12),
          Text(
            tx.recipientWalletId.toString() == "null"
                ? "Bale Gary"
                : tx.recipientWalletId.toString(),
            style: TextStyle(
              fontFamily: 'Karla',
              fontWeight: FontWeight.w600,
              letterSpacing: .3,
              fontSize: 16,
              height: 1.450,
              color: Color(0xFF302D53),
            ),
          ),
          verticalSpace(20),
          _buildDetailRow("Amount Tendered",
              "₦${NumberFormat("#,##0.${'0' * 2}").format(double.tryParse("${double.parse(tx.fees) + double.parse(tx.amount)}") ?? 0)}"),

          _buildDetailRow(
              tx.senderWalletId == wallet.walletId
                  ? "Amount Sent"
                  : "Amount Received",
              "₦${NumberFormat("#,##0.${'0' * 2}").format(double.tryParse(tx.amount) ?? 0)}"),
          _buildDetailRow("Fees",
              "₦${NumberFormat("#,##0.${'0' * 2}").format(double.tryParse(tx.fees) ?? 0)}"),

          _buildDetailRow("Date | Time",
              "${DateFormat.yMMMEd().format(DateTime.parse(tx.createdAt))} | ${DateFormat.jm().format(DateTime.parse(tx.createdAt))}"),
          _buildDetailRow(
              "Transaction Type",
              tx.type == "card_to_wallet"
                  ? "Wallet Top-up"
                  : "Wallet Transfer"),
          // _buildDetailRow(
          //     "Narration", tx.narration.isNotEmpty ? tx.narration : "-"),
          _buildDetailRow(
            "Status",
            tx.status == 'success' ? "Successful" : tx.status,
          ),
          // if (tx.recipientWalletId != null)
          //   _buildDetailRow("Recipient Wallet ID", tx.recipientWalletId!),
          if (tx.externalAccountNumber != null && tx.externalBankName != null)
            _buildDetailRow("External Account",
                "${tx.externalAccountNumber} (${tx.externalBankName})"),
          if (tx.cardLast4 != null)
            _buildDetailRow(
                "Card", "**** ${tx.cardLast4} (${tx.cardBrand ?? ''})"),
          _buildDetailRow("Reference", tx.reference),

          verticalSpace(8),
          FilledBtn(
            onPressed: () {},
            text: 'Do you need help?',
            backgroundColor: Colors.transparent,
            textColor: Color(0xff5645F5), // innit
          ),
          SizedBox(height: 20),
          FilledBtn(
            onPressed: () {},
            text: 'Share receipt',
            backgroundColor: const Color(0xff5645F5),
          ),
          verticalSpace(40.h),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                Color(0xff2A0079).withOpacity(label == "Reference" ? 0 : .25),
            width: .2500,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                  fontFamily: 'Karla',
                  fontWeight: FontWeight.w600,
                  letterSpacing: .3,
                  fontSize: 14,
                  height: 1.450,
                  color: Colors.grey.shade800),
            ),
          ),
          Expanded(
            flex: 5,
            child: label == "Reference"
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          letterSpacing: .2,
                          height: 1.450,
                          color: Color(0xff2A0079),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: value));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Copy to clipboard",
                              style: TextStyle(
                                fontFamily: 'Karla',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.00,
                                height: 1.450,
                                color: Colors.grey.shade800,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.copy,
                              color: Colors.grey.shade800,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      label == "Status" ? value.capitalizeFirst() : value,
                      style: GoogleFonts.spaceGrotesk(
                        // fontFamily: 'Karla',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: .2,
                        height: 1.450,
                        color: label == "Status"
                            ? value == 'Successful'
                                ? Colors.green.shade800
                                : value == 'pending'
                                    ? Colors.yellow.shade800
                                    : Colors.red.shade800
                            : Color(0xff2A0079),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  TransactionDetailsViewModel viewModelBuilder(BuildContext context) =>
      TransactionDetailsViewModel();
}
