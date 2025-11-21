import 'package:flutter/material.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/routes/route.dart';

class SoftposView extends StatelessWidget {
  const SoftposView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? Theme.of(context).scaffoldBackgroundColor 
          : const Color(0xffF7F7F7),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'SoftPOS',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                       fontFamily: 'CabinetGrotesk',
                          letterSpacing: -0.2,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * .14,
                ),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * .15),
                    Text(
                      'Accept Payments with NFC',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.6.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.450,
                     fontFamily: 'CabinetGrotesk',
                        letterSpacing: 0,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Turn your phone into a payment terminal. Accept contactless card payments instantly using NFC technology—no extra hardware needed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.450,
                        fontFamily: 'Karla',
                        letterSpacing: .2,
                        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.85),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 18.0,
                ),
                child: Column(
                  children: [
                    PrimaryButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoute.softposInfoView,
                        );
                      },
                      text: 'Get Started with SoftPOS',
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      textColor: Theme.of(context).colorScheme.surface,
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Theme.of(context).colorScheme.surface
                              : const Color.fromARGB(255, 245, 252, 254),
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: isDark
                                ? Theme.of(context).colorScheme.outline
                                : const Color.fromARGB(255, 26, 77, 104),
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.5),
                              child: Image.asset(
                                "assets/images/idea.png",
                                height: 22,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Accept card payments directly on your phone using NFC. Fast, secure, and no additional devices required.",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Karla',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                  height: 1.450,
                                  color: isDark
                                      ? Theme.of(context).colorScheme.onSurface.withOpacity(.85)
                                      : const Color.fromARGB(255, 26, 77, 104),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
