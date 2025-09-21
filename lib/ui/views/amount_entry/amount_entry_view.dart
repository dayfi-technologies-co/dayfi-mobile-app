import 'package:dayfi/ui/common/amount_formatter.dart';
import 'package:dayfi/ui/views/tranfers_details_selection/tranfers_details_selection_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/filled_btn_small.dart';
import 'package:dayfi/ui/components/input_fields/amount_custom_text_field.dart';
import 'package:dayfi/ui/components/input_fields/pin_text_field.dart';
import 'package:dayfi/ui/views/amount_entry/amount_entry_viewmodel.dart';
import 'package:dayfi/ui/views/home/bottom_sheets/success_bottomsheet.dart';
import 'package:dayfi/ui/views/recipient_details/recipient_account_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';

import '../payment_setup/payment_setup_view.dart';

// AmountEntryView
class AmountEntryView extends StackedView<AmountEntryViewModel> {
  AmountEntryView({
    super.key,
    required this.accountNumber,
    required this.bankCode,
    required this.accountName,
    required this.bankName,
    required this.beneficiaryName,
    required this.wallet,
  });

  final _formKey = GlobalKey<FormState>();

  final String accountNumber;
  final String bankCode;
  final String accountName;
  final String bankName;
  final String beneficiaryName;
  final Wallet wallet;

  @override
  Widget builder(
    BuildContext context,
    AmountEntryViewModel viewModel,
    Widget? child,
  ) {
    return ViewModelBuilder<AmountEntryViewModel>.reactive(
      viewModelBuilder: () => AmountEntryViewModel(),
      builder: (context, model, child) => AppScaffold(
        backgroundColor: const Color(0xffF6F5FE),
        appBar: AppBar(
          backgroundColor: const Color(0xffF6F5FE),
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
        body: _buildBody(
          context,
          viewModel,
          wallet,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AmountEntryViewModel model,
    Wallet wallet,
  ) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpace(8.h),
            
            // Title with smooth entrance
            Text(
              "Send to $accountName",
              style: TextStyle(
                fontSize: 27.5,
                fontFamily: "SpaceGrotesk",
                height: 1.2,
                letterSpacing: 0.00,
                fontWeight: FontWeight.w600,
                color: const Color(0xff2A0079),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            
            verticalSpace(8.h),
            
            // Subtitle with smooth entrance
            const Text(
              "Provide the amount you want to send",
              style: TextStyle(
                fontFamily: 'Karla',
                fontWeight: FontWeight.w600,
                letterSpacing: .3,
                height: 1.450,
                color: Color(0xFF302D53),
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            
            verticalSpace(24.h),
            
            // Amount input field with animation
            AmountCustomTextField(
              label: "Send NGN",
              hintText: "0.0",
              labelText: "Amount to send",
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value.replaceAll(',', ''));
                if (amount == null) return 'Please enter a valid number';
                if (amount >= double.parse(wallet.balance)) {
                  return 'Insufficient funds in wallet';
                }
                if (amount < 100) return 'Amount can\'t be less than 100';
                if (amount > 300000) {
                  return 'Amount can\'t be more than 300,000';
                }
                return null;
              },
              onChanged: (value) {
                final numeric = value.replaceAll(',', '');
                model.setAmount(numeric, wallet.balance);
                _formKey.currentState?.validate();
              },
              formatter: [
                NumberFormatter(model),
              ],
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
                  const SizedBox(width: 14),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            verticalSpace(16),
            
            // Balance section with animation
            Text(
              "Your NGN balance",
              style: TextStyle(
                fontFamily: 'Karla',
                fontSize: 11.8,
                fontWeight: FontWeight.w600,
                letterSpacing: -.1,
                height: 1.450,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withOpacity(.85),
              ),
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            
            Text(
              "₦${AmountFormatter.formatDecimal(double.parse(wallet.balance))}",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.450,
                color: const Color(0xff2A0079),
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .slideY(begin: 0.2, end: 0, delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            verticalSpace(48.h),
            
            // Transaction summary with animation
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 18),
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff2A0079).withOpacity(.075),
                    border: Border.all(
                      color: const Color(0xff5645F5),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Account number",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -.1,
                              height: 1.450,
                              fontFamily: "Karla",
                              color: Color(0xff2A0079),
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            accountNumber,
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
                      ),
                      verticalSpace(8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Account name",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -.1,
                              height: 1.450,
                              fontFamily: "Karla",
                              color: Color(0xff2A0079),
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            accountName,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              // letterSpacing: -.1,
                              height: 1.450,
                              color: Color(0xff2A0079),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      verticalSpace(8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Bank name",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -.1,
                              height: 1.450,
                              fontFamily: "Karla",
                              color: Color(0xff2A0079),
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            bankName,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              // letterSpacing: -.1,
                              height: 1.450,
                              color: Color(0xff2A0079),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      verticalSpace(8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Amount",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -.1,
                              height: 1.450,
                              fontFamily: "Karla",
                              color: Color(0xff2A0079),
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            "₦${AmountFormatter.formatDecimal(model.amount)}",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              // letterSpacing: -.1,
                              height: 1.450,
                              color: Color(0xff2A0079),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      verticalSpace(8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Fee",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -.1,
                              height: 1.450,
                              fontFamily: "Karla",
                              color: Color(0xff2A0079),
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            "₦${AmountFormatter.formatDecimal(model.fee)}",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              // letterSpacing: -.1,
                              height: 1.450,
                              color: Color(0xff2A0079),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total leaving your wallet",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -.1,
                              height: 1.450,
                              fontFamily: "Karla",
                              color: Color(0xff2A0079),
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            "₦${AmountFormatter.formatDecimal(model.total)}",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              // letterSpacing: -.1,
                              height: 1.450,
                              color: Color(0xff2A0079),
                            ),
                            textAlign: TextAlign.start,
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
                      padding: const EdgeInsets.all(6.5),
                      child: Image.asset(
                        "assets/images/idea.png",
                        height: 22,
                      ),
                    ),
                  ),
                )
              ],
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .slideY(begin: 0.3, end: 0, delay: 800.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 800.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            
            verticalSpace(32.h),
            
            // Submit button with enhanced animation
            FilledBtn(
              onPressed: (model.isAmountValid &&
                      (_formKey.currentState?.validate() ?? false))
                  ? () => model.user?.transactionPin == null
                      ? model.navigationService
                          .navigateToTransactionPinNewView(oldPIN: null)
                      : model.navigateToTransactionPin(
                          context,
                          accountNumber: accountNumber,
                          accountName: accountName,
                          bankName: bankName,
                          bankCode: bankCode,
                          beneficiaryName: beneficiaryName,
                          model: model,
                        )
                  : null,
              text: model.user?.transactionPin == null
                  ? "Create - Transaction PIN"
                  : "Next - Transaction PIN",
              backgroundColor: (model.isAmountValid &&
                      (_formKey.currentState?.validate() ?? false))
                  ? const Color(0xff5645F5)
                  : const Color(0xffCAC5FC),
              semanticLabel: model.user?.transactionPin == null
                  ? 'Create transaction PIN'
                  : 'Continue with transaction PIN',
            )
                .animate()
                .fadeIn(delay: 900.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .slideY(begin: 0.3, end: 0, delay: 900.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 900.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .shimmer(delay: 1000.ms, duration: 1000.ms, color: Colors.white.withOpacity(0.3)),
            verticalSpace(40.h),
          ],
        ),
      ),
    );
  }

  @override
  AmountEntryViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AmountEntryViewModel();

  @override
  void onViewModelReady(AmountEntryViewModel viewModel) async {
    await viewModel.loadUser();
    super.onViewModelReady(viewModel);
  }
}

class TransactionPinBottomSheet extends StatefulWidget {
  final VoidCallback onConfirm;
  final TextEditingController pinController;
  final AmountEntryViewModel? amountEntryViewModel;
  final TransfersDetailsSelectionViewModel? transfersDetailsSelectionViewModel;
  final bool isBankTransfer;

  const TransactionPinBottomSheet({
    required this.onConfirm,
    required this.pinController,
    this.amountEntryViewModel,
    this.transfersDetailsSelectionViewModel,
    this.isBankTransfer = false,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TransactionPinBottomSheetState createState() =>
      _TransactionPinBottomSheetState();
}

class _TransactionPinBottomSheetState extends State<TransactionPinBottomSheet> {
  bool _isPinValid = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    widget.pinController.addListener(() {
      setState(() {
        _isPinValid = widget.pinController.text.length == 4;
      });
    });
  }

  Future<void> _handleConfirm() async {
    if (!_isPinValid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      try {
        widget.onConfirm(); // no await
      } catch (e) {
        debugPrint('Error: $e');
      }
    } catch (e) {
      // you can log or show error
      debugPrint('Error submitting transaction: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: InkWell(
          onTap: () => dismissKeyboard(),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28.00),
                topRight: Radius.circular(28.00),
              ),
            ),
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
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      widget.pinController.text = "";
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset(
                      'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                      color: const Color(0xff5645F5),
                      height: 28.00,
                    ),
                  ),
                ),
                buildBottomSheetHeader(
                  context,
                  title: "Transaction PIN",
                  subtitle: "Provide your transaction PIN",
                ),
                verticalSpace(24),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.125),
                  child: PinTextField(
                    length: 4,
                    obscureText: true,
                    controller: widget.pinController,
                    onTextChanged: (value) {},
                  ),
                ),
                verticalSpace(MediaQuery.of(context).size.height * 0.15),
                FilledBtn(
                  text: _isSubmitting
                      ? "Processing..."
                      : "Next - Complete transaction",
                  onPressed:
                      (_isPinValid && !_isSubmitting) ? _handleConfirm : null,
                  isLoading: _isSubmitting,
                  backgroundColor: (_isPinValid && !_isSubmitting)
                      ? const Color(0xff5645F5)
                      : const Color(0xffCAC5FC),
                ),
                verticalSpace(40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TransferSuccessView extends StatelessWidget {
  final RecipientAccount account;
  final double amount;
  final double fee;
  final AmountEntryViewModel model;

  const TransferSuccessView({
    super.key,
    required this.account,
    required this.amount,
    required this.fee,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xff5645F5),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/backgroud.png',
            fit: BoxFit.cover,
            color: const Color(0xff2A0079),
            width: MediaQuery.of(context).size.width,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .05),
              _buildBody(context),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildNextStepButton(),
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
                  "Your funds are on the way!",
                  style: TextStyle(
                    fontFamily: 'Boldonse',
                    fontSize: 22.00, // Slightly larger for a bold welcome
                    height: 1.15, // Tighter for a sleek look
                    letterSpacing: 0.00, // Refined kerning
                    fontWeight: FontWeight.w600, // Extra bold for impact
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(0, 2),
                      ),
                    ], // Subtle shadow for depth
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16), // Slightly more space for balance
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "See transaction details below",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Karla', // Consistent font
                    fontSize: 15.5, // Slightly larger for readability
                    fontWeight: FontWeight.w600, // Bolder for emphasis
                    letterSpacing: 0.3, // Adjusted for clarity
                    height: 1.450, // Comfortable line height
                    color: Colors.white, // Softer, modern grey
                  ),
                ),
              ),
            ],
          ),
        ),
        verticalSpace(40.h),
        Container(
          padding: const EdgeInsets.all(14),
          margin: EdgeInsets.symmetric(horizontal: 24.0),
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
                    "Amount",
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
                    AmountFormatter.formatCurrency((amount + fee)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Account number",
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
                    account.accountNumber,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Bank name",
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
                    account.bankName,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Account name",
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
                    account.accountName,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 32.0),
      child: SizedBox(
        child: FilledBtn(
          onPressed: () => model.navigationService.navigateToMainView(),
          text: "Close, I'm done",
          backgroundColor: Colors.white,
          textColor: const Color(0xff5645F5), // innit
        ),
      ),
    );
  }
}
