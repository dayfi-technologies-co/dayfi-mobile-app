import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/filled_btn_small.dart';
import 'package:dayfi/ui/components/input_fields/amount_custom_text_field.dart';
import 'package:dayfi/ui/components/input_fields/pin_text_field.dart';
import 'package:dayfi/ui/views/payment_setup/payment_setup_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import 'swap_viewmodel.dart';

class SwapView extends StackedView<SwapViewModel> {
  final List<Wallet> wallets;

  const SwapView({super.key, required this.wallets});

  @override
  void onViewModelReady(SwapViewModel viewModel) {
    viewModel.initWallets(wallets);
    viewModel.loadUser();
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    SwapViewModel model,
    Widget? child,
  ) {
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
      body: SafeArea(child: _buildBody(context, model)),
    );
  }

  Widget _buildBody(BuildContext context, SwapViewModel viewModel) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Text(
            'Swap ${viewModel.selectedFromWallet.currency} for ${viewModel.selectedToWallet.currency}',
            style: const TextStyle(
              fontFamily: 'Boldonse',
              fontSize: 22.00,
              height: 1.2,
              letterSpacing: -0.2,
              fontWeight: FontWeight.w600,
              color: Color(0xff2A0079),
            ),
          ),
          verticalSpace(8),
          const Text(
            'Provide the amount you want to swap with',
            style: TextStyle(
              fontFamily: 'Karla',
              fontSize: 15,
              color: Color(0xFF302D53),
              fontWeight: FontWeight.w600,
              letterSpacing: -.02,
              height: 1.45,
            ),
          ),
          verticalSpace(24),
          _buildCurrencyConverter(viewModel, context),
          verticalSpace(100),
        ],
      ),
    );
  }

  Widget _buildCurrencyConverter(
      SwapViewModel viewModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // FROM Wallet input
        _buildCurrencyInput(
          label: "Swap ${viewModel.selectedFromWallet.currency}",
          controller: viewModel.amountToSwapController,
          onChanged: _handleAmountToSwapChange(viewModel),
          currency: viewModel.selectedFromWallet.currency,
          flagAsset: viewModel.selectedFromWallet.currency == "USD"
              ? "assets/images/united-states.png"
              : "assets/images/nigeria.png",
          viewModel: viewModel,
          suffixIcon: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<Wallet>(
              value: viewModel.selectedFromWallet,
              items: viewModel.wallets.map((Wallet wallet) {
                return DropdownMenuItem<Wallet>(
                  value: wallet,
                  child: Row(
                    children: [
                      Image.asset(
                        wallet.currency == "USD"
                            ? "assets/images/united-states.png"
                            : "assets/images/nigeria.png",
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        wallet.currency,
                        style: const TextStyle(
                          fontFamily: 'Karla',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Wallet? newValue) {
                if (newValue != null) {
                  viewModel.updateFromWallet(newValue);
                }
              },
              underline: const SizedBox(),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xff2A0079),
                size: 20,
              ),
            ),
          ),
        ),
        verticalSpace(2),
        Text(
          "Your ${viewModel.selectedFromWallet.currency} balance",
          style: TextStyle(
            fontFamily: 'Karla',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -.1,
            height: 1.45,
            color: Color(0xFF302D53).withOpacity(.65),
          ),
        ),
        Text(
          "${viewModel.selectedFromWallet.currency == "USD" ? "\$" : "₦"}${NumberFormat("#,##0.${'0' * 2}", 'en_US').format(double.tryParse(viewModel.selectedFromWallet.balance) ?? 0.0)}",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.45,
            color: const Color(0xff2A0079),
          ),
        ),
        const SizedBox(height: 24),
        Center(child: _buildExchangeIcon(viewModel)),
        const SizedBox(height: 24),
        // TO Wallet input
        _buildCurrencyInput(
          label: "To ${viewModel.selectedToWallet.currency}",
          controller: viewModel.walletWillReceiveController,
          onChanged: _handleWalletReceiveChange(viewModel),
          currency: viewModel.selectedToWallet.currency,
          flagAsset: viewModel.selectedToWallet.currency == "USD"
              ? "assets/images/united-states.png"
              : "assets/images/nigeria.png",
          isReadOnly: true,
          viewModel: viewModel,
          suffixIcon: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<Wallet>(
              value: viewModel.selectedToWallet,
              items: viewModel.wallets.map((Wallet wallet) {
                return DropdownMenuItem<Wallet>(
                  value: wallet,
                  child: Row(
                    children: [
                      Image.asset(
                        wallet.currency == "USD"
                            ? "assets/images/united-states.png"
                            : "assets/images/nigeria.png",
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        wallet.currency,
                        style: const TextStyle(
                          fontFamily: 'Karla',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Wallet? newValue) {
                if (newValue != null) {
                  viewModel.updateToWallet(newValue);
                }
              },
              underline: const SizedBox(),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xff2A0079),
                size: 20,
              ),
            ),
          ),
        ),
        verticalSpace(2),
        Text(
          "Your ${viewModel.selectedToWallet.currency} balance",
          style: TextStyle(
            fontFamily: 'Karla',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -.1,
            height: 1.45,
            color: Color(0xFF302D53).withOpacity(.65),
          ),
        ),
        Text(
          "${viewModel.selectedToWallet.currency == "USD" ? "\$" : "₦"}${NumberFormat("#,##0.${'0' * 2}", 'en_US').format(double.tryParse(viewModel.selectedToWallet.balance) ?? 0.0)}",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.45,
            color: const Color(0xff2A0079),
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 18),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xff2A0079).withOpacity(.075),
                border: Border.all(color: const Color(0xff5645F5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        viewModel.rate != null
                            ? "1 ${viewModel.selectedFromWallet.currency} = ${NumberFormat("#,###.####", 'en_US').format(viewModel.rate)} ${viewModel.selectedToWallet.currency}"
                            : "-",
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Our fee",
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
                        viewModel.fee != null
                            ? "${viewModel.selectedFromWallet.currency == "USD" ? "\$" : "₦"}${NumberFormat("#,###.##", 'en_US').format(viewModel.fee)}"
                            : "-",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          color: const Color(0xff2A0079),
                        ),
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
                          height: 1.45,
                          fontFamily: "Karla",
                          color: Color(0xff2A0079),
                        ),
                      ),
                      Text(
                        viewModel.amountToSwapController.text.isNotEmpty
                            ? "${viewModel.selectedFromWallet.currency == "USD" ? "\$" : "₦"}${viewModel.amountToSwapController.text}"
                            : "-",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          color: const Color(0xff2A0079),
                        ),
                      ),
                    ],
                  ),
                  verticalSpace(8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Amount to receive",
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
                        viewModel.convertedAmount != null
                            ? "${viewModel.selectedToWallet.currency == "USD" ? "\$" : "₦"}${NumberFormat("#,###.##", 'en_US').format(viewModel.convertedAmount)}"
                            : "-",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          color: const Color(0xff2A0079),
                        ),
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
                          height: 1.45,
                          fontFamily: "Karla",
                          color: Color(0xff2A0079),
                        ),
                      ),
                      Text(
                        viewModel.totalLeaving != null
                            ? "${viewModel.selectedFromWallet.currency == "USD" ? "\$" : "₦"}${NumberFormat("#,###.##", 'en_US').format(viewModel.totalLeaving)}"
                            : "-",
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
          onPressed: viewModel.isLoading
              ? null
              : () => _showPinBottomSheet(context, viewModel),
          backgroundColor: const Color(0xff5645F5),
          isLoading: viewModel.isLoading,
          text: "Next - Transaction PIN",
        ),
        verticalSpace(40.h),
      ],
    );
  }

  void _showPinBottomSheet(BuildContext context, SwapViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      barrierColor: const Color(0xff2A0079).withOpacity(0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _PinBottomSheet(viewModel: viewModel),
      ),
    );
  }

  Widget _buildCurrencyInput({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required String currency,
    required String flagAsset,
    bool isReadOnly = false,
    required SwapViewModel viewModel,
    required Widget suffixIcon,
  }) {
    return AmountCustomTextField(
      label: label,
      hintText: "0.0",
      labelText: isReadOnly ? "Destination Amount" : "Source Amount",
      controller: controller,
      shouldReadOnly: isReadOnly,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      formatter: [NumberFormatter(viewModel)],
      onChanged: onChanged,
      enableInteractiveSelection: false,
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildExchangeIcon(SwapViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.swapWallets(),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xff5645F5)),
        ),
        child: SvgPicture.asset(
          "assets/svgs/swap_vert_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
          color: const Color(0xff5645F5),
          height: 24,
        ),
      ),
    );
  }

  Function(String) _handleAmountToSwapChange(SwapViewModel viewModel) {
    return (value) {
      final cursorPosition = viewModel.amountToSwapController.selection.start;
      final beforeCommas = _countCommas(
        viewModel.amountToSwapController.text.substring(0, cursorPosition),
      );

      final formatted = _formatNumber(value);
      final newCommas = _countCommas(formatted.substring(0, cursorPosition));

      viewModel.amountToSwapController.text = formatted;
      _updateCursorPosition(
        viewModel.amountToSwapController,
        cursorPosition,
        newCommas - beforeCommas,
        formatted,
      );

      final amount = double.tryParse(formatted.replaceAll(',', '')) ?? 0.0;
      viewModel.calculateConvertedAmount(amount);
    };
  }

  Function(String) _handleWalletReceiveChange(SwapViewModel viewModel) {
    return (value) {
      final cursorPosition =
          viewModel.walletWillReceiveController.selection.start;
      final beforeCommas = _countCommas(
        viewModel.walletWillReceiveController.text.substring(0, cursorPosition),
      );

      final formatted = _formatNumber(value);
      final newCommas = _countCommas(formatted.substring(0, cursorPosition));

      viewModel.walletWillReceiveController.text = formatted;
      _updateCursorPosition(
        viewModel.walletWillReceiveController,
        cursorPosition,
        newCommas - beforeCommas,
        formatted,
      );
    };
  }

  int _countCommas(String text) => ','.allMatches(text).length;

  void _updateCursorPosition(
    TextEditingController controller,
    int cursorPosition,
    int commasDiff,
    String formatted,
  ) {
    final newPosition = cursorPosition + commasDiff;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newPosition.clamp(0, formatted.length)),
    );
  }

  String _formatNumber(String value) {
    value = value.replaceAll(RegExp(r'[^\d]'), '');
    if (value.isEmpty) return '';

    final number = double.tryParse(value);
    if (number == null) return '';

    return NumberFormat("#,###.##", 'en_US').format(number);
  }

  @override
  SwapViewModel viewModelBuilder(BuildContext context) => SwapViewModel();
}

class _PinBottomSheet extends StatefulWidget {
  final SwapViewModel viewModel;

  const _PinBottomSheet({required this.viewModel});

  @override
  __PinBottomSheetState createState() => __PinBottomSheetState();
}

class __PinBottomSheetState extends State<_PinBottomSheet> {
  final TextEditingController _pinController = TextEditingController();
  bool _isSubmitting = false;
  bool _isPinValid = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_validatePin);
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _validatePin() {
    setState(() {
      _isPinValid = _pinController.text.length == 4;
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: _dismissKeyboard,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const Text(
                "Transaction PIN",
                style: TextStyle(
                  fontFamily: 'Boldonse',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2A0079),
                ),
              ),
              verticalSpace(4),
              const Text(
                "Provide your transaction PIN",
                style: TextStyle(
                  fontFamily: 'Karla',
                  fontSize: 15,
                  color: Color(0xFF302D53),
                  fontWeight: FontWeight.w600,
                ),
              ),
              verticalSpace(24),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.125),
                child: PinTextField(
                  length: 4,
                  obscureText: true,
                  controller: _pinController,
                  onTextChanged: (value) {},
                ),
              ),
              verticalSpace(MediaQuery.of(context).size.height * 0.15),
              FilledBtn(
                text: _isSubmitting ? "Processing..." : "Complete Transaction",
                onPressed: (_isPinValid && !_isSubmitting)
                    ? () async {
                        setState(() => _isSubmitting = true);
                        await widget.viewModel
                            .swapCurrencyFunc(_pinController.text, context);
                        setState(() => _isSubmitting = false);
                        if (widget.viewModel.swapSuccess) {
                          Navigator.pop(context);
                        }
                      }
                    : null,
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
    );
  }
}
