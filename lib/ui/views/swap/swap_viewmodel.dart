import 'dart:convert';

import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/models/transaction_history_model.dart';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/services/api/database_service.dart';
import 'package:dayfi/ui/common/amount_formatter.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:http/http.dart' as http;

class SwapViewModel extends BaseViewModel {
  final NavigationService navigationService = locator<NavigationService>();
  final SecureStorageService secureStorage = locator<SecureStorageService>();

  final amountToSwapController = TextEditingController();
  final walletWillReceiveController = TextEditingController();

  bool isLoading = false;
  bool swapSuccess = false;
  List<Wallet> wallets = [];
  late Wallet selectedFromWallet;
  late Wallet selectedToWallet;

  final SecureStorageService _storageService = SecureStorageService();
  User? user;
  double? rate;
  double? fee;
  double? convertedAmount;
  double? totalLeaving;

  Future<void> loadUser() async {
    final userJson = await _storageService.read('user');
    if (userJson != null) {
      user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  void initWallets(List<Wallet> incomingWallets) {
    wallets = incomingWallets;
    selectedFromWallet = wallets.firstWhere(
      (w) => w.currency == "NGN",
      orElse: () => wallets.first,
    );
    selectedToWallet = wallets.firstWhere(
      (w) => w.currency == "USD",
      orElse: () => wallets.last,
    );
    notifyListeners();
  }

  void updateFromWallet(Wallet wallet) {
    if (wallet != selectedToWallet) {
      selectedFromWallet = wallet;
      final amount =
          double.tryParse(amountToSwapController.text.replaceAll(',', '')) ??
              0.0;
      if (amount > 0) {
        calculateConvertedAmount(amount);
      } else {
        walletWillReceiveController.clear();
        rate = null;
        fee = null;
        convertedAmount = null;
        totalLeaving = null;
      }
      notifyListeners();
    }
  }

  void updateToWallet(Wallet wallet) {
    if (wallet != selectedFromWallet) {
      selectedToWallet = wallet;
      final amount =
          double.tryParse(amountToSwapController.text.replaceAll(',', '')) ??
              0.0;
      if (amount > 0) {
        calculateConvertedAmount(amount);
      } else {
        walletWillReceiveController.clear();
        rate = null;
        fee = null;
        convertedAmount = null;
        totalLeaving = null;
      }
      notifyListeners();
    }
  }

  void swapWallets() {
    final tempWallet = selectedFromWallet;
    selectedFromWallet = selectedToWallet;
    selectedToWallet = tempWallet;
    amountToSwapController.clear();
    walletWillReceiveController.clear();
    rate = null;
    fee = null;
    convertedAmount = null;
    totalLeaving = null;
    notifyListeners();
  }

  String? validateAmount(String amount) {
    final value = double.tryParse(amount.replaceAll(',', '')) ?? 0;
    final availableBalance = double.tryParse(selectedFromWallet.balance) ?? 0;

    if (value <= 0) return "Amount must be greater than zero";
    if (value > availableBalance) return "Insufficient balance";

    return null;
  }

  void calculateConvertedAmount(double amount) {
    if (amount <= 0) {
      walletWillReceiveController.clear();
      this.rate = null;
      fee = null;
      convertedAmount = null;
      totalLeaving = null;
      notifyListeners();
      return;
    }

    double rate = 0.00064935; // Hardcoded rate: 1 NGN = 0.00064935 USD
    if (selectedFromWallet.currency == "USD" &&
        selectedToWallet.currency == "NGN") {
      rate = 1540.0; // Hardcoded rate: 1 USD = 1,540 NGN
    } else if (selectedFromWallet.currency == selectedToWallet.currency) {
      rate = 1.0; // Same currency swap
    }
    this.rate = rate;
    fee = amount * 0.01; // Assume 1% fee
    convertedAmount = amount * rate;
    totalLeaving = amount + fee!;

    walletWillReceiveController.text =
        NumberFormat("#,###.##", 'en_US').format(convertedAmount);
    notifyListeners();
  }

  bool _isSwapInProgress = false;

  Future<void> swapCurrencyFunc(String pin, BuildContext context) async {
    if (_isSwapInProgress) return;
    _isSwapInProgress = true;

    final amountStr = amountToSwapController.text.replaceAll(',', '');
    if (amountStr.isEmpty) {
      print("Error: Amount is required");
      _isSwapInProgress = false;
      return;
    }

    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      print("Error: Invalid amount");
      _isSwapInProgress = false;
      return;
    }

    final validationError = validateAmount(amountStr);
    if (validationError != null) {
      print("Error: $validationError");
      _isSwapInProgress = false;
      return;
    }

    isLoading = true;
    swapSuccess = false;
    notifyListeners();

    try {
      final uri = Uri.parse(
        "https://dayfi-app-31eb033892cf.herokuapp.com/api/v1/payments/wallets/swap",
      );
      final token = await secureStorage.read('user_token');
      final body = jsonEncode({
        "fromCurrency": selectedFromWallet.currency,
        "toCurrency": selectedToWallet.currency,
        "amount": amount,
      });

      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json["data"];
        convertedAmount = data["convertedAmount"]?.toDouble();
        rate = data["rate"]?.toDouble();
        fee = data["fee"]?.toDouble() ?? 0.0;
        totalLeaving = amount + (fee ?? 0.0);

        // Prepare to save the transaction
        final databaseService =
            DatabaseService(); // Adjust based on your DI method
        final transaction = WalletTransaction(
          id: data["transactionId"] ??
              DateTime.now()
                  .millisecondsSinceEpoch
                  .toString(), // Use server-provided ID or generate one
          walletTransactionsId: data["walletTransactionId"] ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user!.userId,
          senderWalletId: selectedToWallet.walletId,
          recipientWalletId: selectedFromWallet.walletId,
          externalAccountNumber: null,
          externalBankCode: null,
          externalBankName: null,
          amount: (amount / 1540.0).toString(),
          balance: data["newBalance"]?.toString() ??
              '0.00', // Adjust based on API response
          fees: fee.toString(),
          type: 'swap',
          status: 'success',
          reference: data["reference"] ??
              'SWAP-${DateTime.now().millisecondsSinceEpoch}',
          narration:
              'Currency swap from ${selectedFromWallet.currency} to ${selectedToWallet.currency}',
          metadata: {
            'rate': rate,
            'convertedAmount': convertedAmount,
          },
          initiatedBy: 'user',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          cardLast4: null,
          cardType: null,
          cardBrand: null,
          cardCountry: null,
          cardToken: null,
          cardTransactionRef: null,
        );

        // Save the transaction to the database
        await databaseService.cacheUSDTransactions([transaction]);

        walletWillReceiveController.text =
            NumberFormat("#,###.##", 'en_US').format(convertedAmount);
        swapSuccess = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SwapSuccessView(
                fromWallet: selectedFromWallet,
                toWallet: selectedToWallet,
                amount: amount,
                fee: fee,
                convertedAmount: convertedAmount,
                model: this,
              ),
            ),
          );
        });
      } else {
        print("Error: Swap failed: ${response.body}");
      }
    } catch (e) {
      print("Error: Swap error: $e");
    } finally {
      isLoading = false;
      _isSwapInProgress = false;
      notifyListeners();
    }
  }
}

class SwapSuccessView extends StatelessWidget {
  final Wallet fromWallet;
  final Wallet toWallet;
  final double amount;
  final double? fee;
  final double? convertedAmount;
  final SwapViewModel model;

  const SwapSuccessView({
    super.key,
    required this.fromWallet,
    required this.toWallet,
    required this.amount,
    required this.fee,
    required this.convertedAmount,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xff5645F5),
      body: Stack(
        children: [
          Opacity(
            opacity: 1,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              color: const Color(0xff2A0079),
              width: MediaQuery.of(context).size.width,
            ),
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
                  "Your swap is complete!",
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
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "See swap details below",
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
              ),
            ],
          ),
        ),
        SizedBox(height: 40),
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
                    "From Currency",
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
                    fromWallet.currency,
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "To Currency",
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
                    toWallet.currency,
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Amount Sent",
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
                    AmountFormatter.formatCurrency(amount),
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Amount Received",
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
                    AmountFormatter.formatCurrency(convertedAmount ?? 0.0),
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Fee",
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
                    AmountFormatter.formatCurrency(fee ?? 0.0),
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
          textColor: const Color(0xff5645F5),
        ),
      ),
    );
  }
}
