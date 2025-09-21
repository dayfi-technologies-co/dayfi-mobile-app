import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class Loader extends StatelessWidget {
  final String? message;
  final bool showMessage;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const Loader({
    super.key,
    this.message,
    this.showMessage = false,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Color(0xff5645F5).withOpacity(.5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shimmer loading indicator
            Shimmer.fromColors(
              baseColor: indicatorColor ?? Colors.white.withOpacity(0.3),
              highlightColor: indicatorColor ?? Colors.white,
              period: const Duration(milliseconds: 1500),
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 30.w,
                  color: Colors.white,
                ),
              ),
            ),
            if (showMessage && message != null) ...[
              SizedBox(height: 24.h),
              Text(
                message!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Karla',
                ),
                textAlign: TextAlign.center,
              ),
            ],
            // Fallback to CupertinoActivityIndicator if needed
            SizedBox(height: 24.h),
            CupertinoActivityIndicator(
              color: indicatorColor ?? Colors.white,
              radius: 12.w,
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleLoader extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;

  const SimpleLoader({
    super.key,
    this.message,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: color ?? const Color(0xFFE0E0E0),
            highlightColor: color ?? const Color(0xFFF5F5F5),
            period: const Duration(milliseconds: 1500),
            child: Container(
              width: size ?? 40.w,
              height: size ?? 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: TextStyle(
                color: color ?? const Color(0xFF666666),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Karla',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
