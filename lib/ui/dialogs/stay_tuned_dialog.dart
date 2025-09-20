// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showStayTunedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        backgroundColor: const Color(0xffF7F7F7),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CupertinoActivityIndicator(
              //   color: Color(0xff5645F5),
              // ),
              const SizedBox(height: 24),
              Text(
                "🚀 Stay Tuned!",
                style: const TextStyle(
                  fontFamily: 'Karla', //
                  fontSize: 30,
                  height: 1.2,
                  color: Color(0xff011B33),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Dayfi is bringing crypto buying & selling soon! We're excited about our upcoming partnership with Stellar—stay tuned for updates! ✨",
                textAlign: TextAlign.center,
                style: TextStyle(
                    letterSpacing: 0.00,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(.85),
                    fontSize: 15),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff011B33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  "Got it!",
                  style: TextStyle(
                    fontFamily: 'Karla',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .2,
                    height: 1.450,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      );
    },
  );
}
