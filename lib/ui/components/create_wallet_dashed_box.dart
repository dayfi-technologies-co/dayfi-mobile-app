import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class CreateWalletDashedBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 12.0,
        left: 24.0,
        right: 24.0,
      ),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: Radius.circular(4),
          color: const Color(0xff5645F5), // border color
          strokeWidth: 1,
          dashPattern: [6, 3], // 6px dash, 3px space
        ),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/background.png',
              ),
              fit: BoxFit.cover,
              opacity: .1,
              // // color: Colors.OrangeAccent.shade200,
            ),
          ),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 40),
          alignment: Alignment.center,
          child: Text(
            "You don't have any wallets yet",
            style: TextStyle(
              fontFamily: 'Karla',
              fontSize: 16,
              color: Color(0xff5645F5), // innit
              fontWeight: FontWeight.w600,
              letterSpacing: -.04,
              height: 1.450,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}