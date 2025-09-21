import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/views/prepaid_info/prepaid_info_viewmodel.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrepaidInfoView extends StatelessWidget {
  // final String coinId;
  // final String coinName;
  // final dynamic coinPrice;
  // final double priceChange;
  // final dynamic marketCap;
  // final dynamic popularity;

  final bool isVCard;

  const PrepaidInfoView({
    super.key,
    // required this.coinId,
    // required this.coinName,
    // required this.coinPrice,
    // required this.priceChange,
    // required this.marketCap,
    // required this.popularity,

    this.isVCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PrepaidInfoViewModel>.reactive(
        viewModelBuilder: () => PrepaidInfoViewModel(),
        builder: (context, model, child) {
          final items = isVCard ? model.items2 : model.items;

          return AppScaffold(
            backgroundColor: const Color(0xffF6F5FE),
            appBar: AppBar(
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: Color(0xffF6F5FE),
              leading: IconButton(
                onPressed: () => model.navigationService.back(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xff5645F5), // innit
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpace(10),
                        Text(
                          isVCard
                              ? "Before creating your prepaid dollar card"
                              : "Before you buy digital currencies",
                          style: TextStyle(
                            fontFamily: 'Boldonse',
                            fontSize: 27.5,
                            height: 1.2,
                            letterSpacing: -0.2,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff2A0079),
                          ),
                        ),
                        verticalSpace(10),
                        Text(
                          isVCard
                              ? "Here are a few things you need to note before creating a prepaid dollar card"
                              : 'Key information to understand before acquiring digital currencies, including stablecoins, on the platform',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            height: 1.450,
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withOpacity(.85),
                          ),
                        ),
                        verticalSpace(24.h),
                        Container(
                          padding: const EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xff5645F5).withOpacity(.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xff5645F5),
                              width: .65,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      index == 0
                                          ? "${index + 1} "
                                          : "${index + 1}",
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
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -.04,
                                          height: 1.450,
                                          color: Color(0xff2A0079), // innit
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        verticalSpace(6.h),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            isVCard
                                ? "I understand and agree to all the Terms & Condition of creating a Virtual card on dayfi."
                                : 'I understand and agree with all the Terms & Conditions for buying and selling digital currencies on dayfi.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -.04,
                              height: 1.450,
                              color: Color(0xff304463),
                            ),
                          ),
                          value: model.isAgreed,
                          activeColor: const Color(0xff5645F5), // innit
                          onChanged: (value) => model.setAgreed(value ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        verticalSpace(40.h),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FilledBtn(
                          onPressed: model.isAgreed
                              ? () => isVCard
                                  ? model.navigationService
                                      .navigateToPersonaliseCardView()
                                  : model.navigationService.navigateToCoinsView(
                                      // coinId: coinId,
                                      // coinName: coinName,
                                      // coinPrice: coinPrice,
                                      // priceChange: priceChange,
                                      // marketCap: marketCap,
                                      // popularity: popularity,
                                      )
                              : null,
                          text: isVCard
                              ? "Agree and continue"
                              : 'Confirm and proceed',
                          backgroundColor: model.isAgreed
                              ? const Color(0xff5645F5)
                              : const Color(0xffCAC5FC),
                        ),
                        verticalSpace(25.h),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
