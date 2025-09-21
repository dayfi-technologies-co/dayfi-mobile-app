import 'dart:async';
import 'package:card_scanner/card_scanner.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' show SizeExtension;
import 'package:dayfi/ui/common/app_scaffold.dart';

class CardScanView extends StatefulWidget {
  final String amount;
  final Function(CardDetails?) onCardScanned;
  final Function(Exception) onScanError;

  const CardScanView({
    super.key,
    required this.amount,
    required this.onCardScanned,
    required this.onScanError,
  });

  @override
  State<CardScanView> createState() => _CardScanViewState();
}

class _CardScanViewState extends State<CardScanView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _scanCard();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _scanCard() async {
    try {
      final CardDetails? cardDetails = await CardScanner.scanCard(
        scanOptions: const CardScanOptions(
          scanCardHolderName: true,
          // scanCardIssuer: true,
          scanExpiryDate: true,
        ),
      );

      if (cardDetails != null) {
        widget.onCardScanned(cardDetails);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card scanning cancelled or failed')),
        );
        widget.onScanError(Exception('Card scanning cancelled or failed'));

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning card: $e')),
      );

      Navigator.pop(context);
      widget.onScanError(e as Exception);
    }
  }

  Widget verticalSpace(double height) => SizedBox(height: height);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppScaffold(
          body: Container(
            color: Colors.black,
            child: const Center(
              child: Text(
                "Scanning card...",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
        AppScaffold(
          backgroundColor: Colors.transparent,
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
          body: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      color: Color(0xffF7F7F7),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                                color: Color(0xff011B33),
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          verticalSpace(12),
                          Text(
                            "Scanning card details",
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
                                  .withOpacity(.85),
                            ),
                            textAlign: TextAlign.start,
                          ),
                          verticalSpace(40),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/image 2.png',
                          width: 200.w,
                        ),
                        verticalSpace(32),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
