import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SoftposInfoView extends StatefulWidget {
  const SoftposInfoView({super.key});

  @override
  State<SoftposInfoView> createState() => _SoftposInfoViewState();
}

class _SoftposInfoViewState extends State<SoftposInfoView> {
  bool _isAgreed = false;

  final List<String> _infoItems = [
    'Your device must have NFC capability enabled to accept contactless payments.',
    'SoftPOS transforms your phone into a secure payment terminal for tap-to-pay transactions.',
    'All transactions are encrypted and comply with PCI-DSS security standards.',
    'You can accept payments from major card networks including Visa, Mastercard, and Verve.',
    'Transaction fees apply based on your merchant agreement and payment type.',
    'Ensure stable internet connectivity for real-time transaction processing.',
    'Keep your device charged and NFC enabled during payment acceptance hours.',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? Theme.of(context).scaffoldBackgroundColor 
          : const Color(0xffF6F5FE),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: isDark 
            ? Theme.of(context).scaffoldBackgroundColor 
            : const Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.purple500ForTheme(context),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      "Before using SoftPOS",
                      style: TextStyle(
                     fontFamily: 'CabinetGrotesk',
                        fontSize: 13,
                        height: 1.2,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Theme.of(context).colorScheme.onSurface
                            : const Color(0xff2A0079),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Key information to understand before accepting contactless payments with your device using NFC technology',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Karla',
                        letterSpacing: 0.3,
                        height: 1.450,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(.85),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.purple500ForTheme(context).withOpacity(.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.purple500ForTheme(context),
                          width: .65,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _infoItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -.04,
                                    height: 1.450,
                                    color: Colors.orangeAccent.shade400,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -.04,
                                      height: 1.450,
                                      color: isDark
                                          ? Theme.of(context).colorScheme.onSurface
                                          : const Color(0xff2A0079),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'I understand and agree with all the Terms & Conditions for using SoftPOS payment acceptance on dayfi.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Karla',
                          fontWeight: FontWeight.w600,
                          letterSpacing: -.04,
                          height: 1.450,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .color!
                              .withOpacity(.85),
                        ),
                      ),
                      value: _isAgreed,
                      activeColor: AppColors.purple500ForTheme(context),
                      onChanged: (value) {
                        setState(() {
                          _isAgreed = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: PrimaryButton(
                onPressed: _isAgreed
                    ? () {
                        // TODO: Navigate to SoftPOS activation/setup screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('SoftPOS setup coming soon!'),
                            backgroundColor: AppColors.purple500ForTheme(context),
                          ),
                        );
                      }
                    : null,
                text: 'Confirm and proceed',
                backgroundColor: _isAgreed
                    ? AppColors.purple500ForTheme(context)
                    : (isDark 
                        ? AppColors.purple500ForTheme(context).withOpacity(.3)
                        : const Color(0xffCAC5FC)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
