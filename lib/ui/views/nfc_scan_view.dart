import 'package:card_scanner/models/card_details.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show SizeExtension;
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/outlined_btn.dart';
import 'package:dayfi/ui/views/card_scan_view.dart';
import 'package:dayfi/ui/views/pin_entry_view.dart';
import 'package:dayfi/utilities.dart';

class NfcScanView extends StatefulWidget {
  final Function(WebViewEvent) onReceivedMessage;
  final String amount;

  const NfcScanView({
    super.key,
    required this.onReceivedMessage,
    required this.amount,
  });

  @override
  State<NfcScanView> createState() => _NfcScanViewState();
}

class _NfcScanViewState extends State<NfcScanView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> animation;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Map<String, dynamic>? _cardDetails;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onListenCardScan(CardDetails? value) {
    if (value != null) {
      _cardDetails = {
        "card_number": value.cardNumber,
        "expiration": value.expiryDate,
        "card_type": value.cardIssuer.isNotEmpty ? value.cardIssuer : "Unknown",
      };
      showSnackbar(const SnackBar(
        content: Text("Valid Debit Card"),
      ));
      _navigateToCardDetails(context);
    }
  }

  void _onScannerError(Exception exception) {
    if (kDebugMode) {
      print('Scanner Error: ${exception.toString()}');
    }
    Navigator.of(context).pop();
    showSnackbar(SnackBar(
      content: Text('Scan failed: ${exception.toString()}'),
    ));
  }

  void showSnackbar(SnackBar snackBar) {
    if (_scaffoldMessengerKey.currentState != null) {
      _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
    }
  }

  void _navigateToCardDetails(BuildContext context) {
    if (_cardDetails != null && _cardDetails!.containsKey('card_number')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PinEntryView(
            cardDetails: _cardDetails,
            onClose: () {
              setState(() {
                _cardDetails = null;
              });
            },
            amount: widget.amount,
          ),
        ),
      );
    } else {
      // Navigate Back !
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Color(0xffF7F7F7),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Color(0xffF7F7F7),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xff5645F5),
          ),
        ),
      ),
      body: StatefulBuilder(builder: (BuildContext context, setState) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          constraints: const BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      "N${widget.amount}",
                      style: TextStyle(
                        fontFamily: 'Karla',
                        fontSize: 28,
                        height: 1.2,
                        letterSpacing: 0.00,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2A066E),
                        // color: Color(0xff5645F5),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  verticalSpace(12),
                  Text(
                    "Tapping card details",
                    style: TextStyle(
                      fontFamily: 'Karla',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
              Lottie.asset(
                'assets/svgs/Animation - 1739115915964.json',
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // NFC Animation

                    Image.asset(
                      'assets/images/image 2.png',
                      width: 200.w,
                    ),
                    verticalSpace(48),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledBtn(
                            onPressed: () => Navigator.pop(context),
                            text: 'Cancel',
                            backgroundColor: Colors.red.shade700,
                            textColor: Colors.white,
                            // borderColor: Color(0xff5645F5),
                          ),
                          verticalSpace(12),
                          OutlineBtn(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CardScanView(
                                  amount: widget.amount,
                                  onCardScanned: _onListenCardScan,
                                  onScanError: _onScannerError,
                                ),
                              ),
                            ),
                            text: 'Try camera',
                            backgroundColor: Colors.transparent,
                            textColor: Color(0xff5645F5),
                            borderColor: Color(0xff5645F5),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
