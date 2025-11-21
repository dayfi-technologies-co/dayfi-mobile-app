import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Before using SoftPOS",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 19.sp, // height: 1.6,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            // color: AppColors.purple500ForTheme(context),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Text(
                    'Key information to understand before accepting contactless payments with your device using NFC technology',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Karla',
                      letterSpacing: 0.3,
                      height: 1.450,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withOpacity(.85),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _infoItems.asMap().entries.map((entry) {
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -.04,
                                      height: 1.5,
                                      color: Colors.orangeAccent.shade400,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Karla',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.4,
                                        height: 1.5,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  SizedBox(height: 12.h),
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
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.color!.withOpacity(.85),
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
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 32.h),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed:
                    _isAgreed
                        ? () {
                          Navigator.pop(context);
                          Future.delayed(const Duration(milliseconds: 300), () {
                            TopSnackbar.show(
                              context,
                              message: 'SoftPOS feature is coming soon! We\'re working hard to bring contactless payment acceptance to your device.',
                              isError: false,
                            );
                          });
                        }
                        : null,
                text: 'Confirm and proceed',
                height: 48.000.h,
                borderRadius: 38,
                textColor:
                    _isAgreed
                        ? AppColors.neutral0
                        : AppColors.neutral0.withOpacity(.65),
                backgroundColor:
                    _isAgreed
                        ? AppColors.purple500
                        : AppColors.purple500ForTheme(context).withOpacity(.25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
