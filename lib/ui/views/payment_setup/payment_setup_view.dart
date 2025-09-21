import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../common/app_scaffold.dart';
import '../../common/ui_helpers.dart';
import '../../components/buttons/filled_btn.dart';
import '../../components/input_fields/amount_custom_text_field.dart';
import 'payment_setup_viewmodel.dart';

class PaymentSetupView extends StackedView<PaymentSetupViewModel> {
  final Future<bool> Function() readCard;
  final String selectedPaymentMethod;
  final TextEditingController amount;
  final bool isReceive;

  const PaymentSetupView({
    super.key,
    required this.readCard,
    required this.selectedPaymentMethod,
    required this.amount,
    this.isReceive = true,
  });

  @override
  Widget builder(
    BuildContext context,
    PaymentSetupViewModel viewModel,
    Widget? child,
  ) {
    final formKey = GlobalKey<FormState>();

    return WillPopScope(
      onWillPop: () async {
        viewModel.navigationService.back();
        return false;
      },
      child: AppScaffold(
        backgroundColor: const Color(0xffF6F5FE),
        appBar: AppBar(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: const Color(0xffF6F5FE),
          leading: IconButton(
            onPressed: () => viewModel.navigationService.back(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xff5645F5), // innit
            ),
          ),
        ),
        body: StatefulBuilder(builder: (BuildContext context, setState) {
          // Determine if the button should be enabled
          final isAmountValid = viewModel.isAmountValid(amount.text);

          return Form(
            key: formKey,
            child: Container(
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
                            selectedPaymentMethod,
                            style: const TextStyle(
                              fontFamily: 'Boldonse',
                              fontSize: 27.5,
                              height: 1.2,
                              letterSpacing: 0.00,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff2A0079),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ).animate().fadeIn(
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ).slideY(
                          begin: -0.1,
                          end: 0,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ).scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1.0, 1.0),
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
                        verticalSpace(12),
                        Text(
                          isReceive
                              ? "Select the currency and amount you want to receive."
                              : "Select the currency you want to send and amount.",
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
                                .withOpacity(.85),
                          ),
                          textAlign: TextAlign.start,
                        ).animate().fadeIn(
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                          delay: 100.ms,
                        ).slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                          delay: 100.ms,
                        ),
                      ],
                    ),
                    verticalSpace(40),
                    AmountCustomTextField(
                      label: "Receive NGN",
                      hintText: "0",
                      labelText: "Amount to receive",
                      controller: amount,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: viewModel.validateAmount,
                      formatter: [
                        // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        NumberFormatter(viewModel),
                      ],
                      onChanged: (value) {
                        setState(() {}); // Update button state
                        if (viewModel.onValueChanged != null) {
                          viewModel.onValueChanged!(value.replaceAll(',', ''));
                        }
                      },
                      enableInteractiveSelection: false,
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() => viewModel.showCurrencyOptions =
                              !viewModel.showCurrencyOptions);
                        },
                        child: Container(
                          constraints: const BoxConstraints.tightForFinite(),
                          margin: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 10.0,
                          ),
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
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
                              const SizedBox(width: 4),
                              SvgPicture.asset(
                                'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                                height: 22,
                                color: const Color(0xff5645F5), // innit
                              ),
                              const SizedBox(width: 3),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                      delay: 200.ms,
                    ).slideY(
                      begin: 0.1,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                      delay: 200.ms,
                    ).scale(
                      begin: const Offset(0.98, 0.98),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                      delay: 200.ms,
                    ),
                    const SizedBox(height: 8),
                    viewModel.showCurrencyOptions
                        ? AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: AnimatedContainer(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Color(0xff2A0079).withOpacity(0.15),
                                ),
                              ),
                              duration: const Duration(milliseconds: 250),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: viewModel.currencies.map(
                                  (currency) {
                                    final isNgn = currency.name == "NGN";
                                    return InkWell(
                                      onTap: () {
                                        if (isNgn) {
                                          setState(() => viewModel
                                              .showCurrencyOptions = false);
                                        }
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.transparent,
                                        padding: EdgeInsets.symmetric(
                                          vertical: isNgn ? 10 : 10,
                                          horizontal: 12,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(
                                                  currency.icon,
                                                  height: 22,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  currency.name,
                                                  style: const TextStyle(
                                                    fontFamily: 'Karla',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: -.04,
                                                    height: 1.450,
                                                    color: Color(0xff2A0079),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            isNgn
                                                ? SvgPicture.asset(
                                                    "assets/svgs/circle-check.svg",
                                                    color: const Color.fromARGB(
                                                        255, 123, 0, 231),
                                                  )
                                                : Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6.5,
                                                        vertical: 4.5),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xff2A0079)
                                                          .withOpacity(.075),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: const Text(
                                                      "Coming soon",
                                                      style: TextStyle(
                                                        fontFamily: 'karla',
                                                        fontSize: 12,
                                                        color: const Color(
                                                            0xff5645F5), // innit
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: -0.2,
                                                        height: 1.450,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    )
                                        .animate()
                                        .fadeIn(
                                            duration: 500.ms,
                                            curve: Curves.easeOutCubic,
                                            delay: Duration(milliseconds: 300 + (viewModel.currencies.indexOf(currency) * 100)))
                                        .slideY(
                                            begin: -0.1,
                                            end: 0,
                                            duration: 500.ms,
                                            curve: Curves.easeOutCubic,
                                            delay: Duration(milliseconds: 300 + (viewModel.currencies.indexOf(currency) * 100)))
                                        .scale(
                                            begin: const Offset(0.98, 0.98),
                                            end: const Offset(1.0, 1.0),
                                            duration: 500.ms,
                                            curve: Curves.easeOutCubic,
                                            delay: Duration(milliseconds: 300 + (viewModel.currencies.indexOf(currency) * 100)));
                                  },
                                ).toList(),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(height: 24.h),
                          FilledBtn(
                            onPressed: isAmountValid
                                ? () async {
                                    if (formKey.currentState!.validate()) {
                                      final success = await readCard();
                                      if (!success) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Card reading cancelled or failed'),
                                            backgroundColor:
                                                Colors.red.shade800,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                : null, // Disable button if amount is invalid
                            backgroundColor: isAmountValid
                                ? const Color(0xff5645F5)
                                : Color(0xffCAC5FC),
                            text: "Next - Tap to Retrieve Card",
                          ).animate().fadeIn(
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                            delay: 400.ms,
                          ).slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                            delay: 400.ms,
                          ).shimmer(
                            duration: 2000.ms,
                            color: Colors.white.withOpacity(0.3),
                            delay: 600.ms,
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                    verticalSpace(40),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  PaymentSetupViewModel viewModelBuilder(BuildContext context) =>
      PaymentSetupViewModel();
}

// Custom TextInputFormatter for number formatting
class NumberFormatter extends TextInputFormatter {
  final dynamic viewModel;

  NumberFormatter(this.viewModel);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Handle empty input
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-digits
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Parse and format the number
    final number = int.tryParse(digits);
    if (number == null) {
      return oldValue; // Revert to old value if parsing fails
    }

    // Format with thousand separators
    final formatter = NumberFormat("#,###", 'en_US');
    String formatted = formatter.format(number);

    // Calculate cursor position
    int cursorOffset = newValue.selection.baseOffset;
    String oldTextBeforeCursor =
        oldValue.text.substring(0, oldValue.selection.baseOffset);
    String newTextBeforeCursor =
        formatted.substring(0, cursorOffset.clamp(0, formatted.length));

    int commasBeforeOldCursor = ','.allMatches(oldTextBeforeCursor).length;
    int commasBeforeNewCursor = ','.allMatches(newTextBeforeCursor).length;

    int newCursorPosition =
        cursorOffset + (commasBeforeNewCursor - commasBeforeOldCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: newCursorPosition.clamp(0, formatted.length),
      ),
    );
  }
}

class MoneyFormatter {
  static double parseAmount(dynamic amount) {
    if (amount is double) return amount;

    if (amount is String) {
      String cleanNumber = amount.replaceAll(RegExp(r'[^\d.]'), '');
      try {
        return double.parse(cleanNumber);
      } catch (e) {
        return 0.0;
      }
    }

    return 0.0;
  }

  static String formatAmount(double amount) {
    return NumberFormat('#,###.##', 'en_US').format(amount);
  }
}
