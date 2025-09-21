import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';

class SuccessBottomSheet extends StatelessWidget {
  final String dayfiId;

  SuccessBottomSheet({required this.dayfiId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.00), topRight: Radius.circular(28.00)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 88,
              height: 3.5,
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
              onTap: () => {
                Clipboard.setData(ClipboardData(text: dayfiId)),
                Navigator.pop(context),
                Navigator.pop(context),
              },
              child: SvgPicture.asset(
                'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                color: const Color(0xff5645F5), // innit
                height: 28.00,
              ),
            ),
          ),
          Container(
            // padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  "assets/svgs/successcheck.svg",
                  height: 88,
                ),
                buildBottomSheetHeader(
                  context,
                  title: "Your Dayfi ID is all set",
                  subtitle:
                      "$dayfiId is your Dayfi id. It can be found on your profile page, and copied.",
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                FilledBtn(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: dayfiId));
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  text: 'Dayfi-ID copied',
                  backgroundColor: const Color(0xff5645F5),
                ),
                SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget buildBottomSheetHeader(
  BuildContext context, {
  Widget? icon,
  required String title,
  String? subtitle,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(height: 12.h),
      if (icon != null) ...[
        Center(child: Center(child: icon)),
        SizedBox(height: MediaQuery.of(context).size.height * 0.011),
      ],
      SizedBox(height: 8.h),
      Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          height: 1.2,
          fontFamily: 'Boldonse',
          letterSpacing: 0.00,
          color: const Color(0xff2A0079),
        ),
        textAlign: TextAlign.center,
      ),
      if (subtitle != null) ...[
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * .1),
          child: Text(
            subtitle,
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
      ],
    ],
  );
}
