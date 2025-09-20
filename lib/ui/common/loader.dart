import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff5645F5).withOpacity(.5),
      body: Center(
        child: Container(
          width: 32.0.h,
          height: 32.0.h,
          alignment: Alignment.center,
          child: const CupertinoActivityIndicator(
            color: Colors.white, // innit
          ),
        ),
      ),
    );
  }
}
