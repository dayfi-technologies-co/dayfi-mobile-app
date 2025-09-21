import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'linked_banks_viewmodel.dart';

class LinkedBanksView extends StackedView<LinkedBanksViewModel> {
  const LinkedBanksView({super.key});

  @override
  Widget builder(
    BuildContext context,
    LinkedBanksViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Color(0xffF6F5FE),
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => viewModel.navigationService.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xff5645F5), // innit
          ),
        ),
      ),
      body: StatefulBuilder(builder: (BuildContext context, setState) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          constraints: const BoxConstraints.expand(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    verticalSpace(10),
                    const Text(
                      "Saved Banks",
                      style: TextStyle(
                        fontFamily: 'Boldonse',
                        fontSize: 27.5,
                        height: 1.2,
                        letterSpacing: 0.00,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2A0079),
                      ),
                      textAlign: TextAlign.start,
                    ).animate().fadeIn(
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ).slideY(
                      begin: -0.1,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ).scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
                    verticalSpace(10),
                    const Text(
                      "Your list of withdrawal banks",
                      style: TextStyle(
                        fontFamily: 'Karla',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        height: 1.450,
                        color: Color(0xFF302D53),
                      ),
                      textAlign: TextAlign.start,
                    ).animate().fadeIn(
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                      delay: 100.ms,
                    ).slideY(
                      begin: 0.1,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                      delay: 100.ms,
                    ),
                  ],
                ),
                verticalSpace(40),
                viewModel.isLoading
                    ? const Center(
                        child: CupertinoActivityIndicator(
                          color: Color(0xff5645F5), // innit
                        ),
                      ).animate().fadeIn(
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                        delay: 200.ms,
                      ).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                        delay: 200.ms,
                      )
                    : viewModel.savedAccounts.isEmpty
                        ? Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 40),
                                  SvgPicture.asset(
                                    "assets/svgs/receipt-2.svg",
                                    height: 48,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "No banks yet",
                                    style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 0.00,
                                      color:
                                          const Color.fromARGB(255, 49, 17, 34)
                                              .withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                            delay: 200.ms,
                          ).slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                            delay: 200.ms,
                          )
                        : Column(
                            children: viewModel.savedAccounts.asMap().entries.map((entry) {
                              final index = entry.key;
                              final account = entry.value;
                              return Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xff2A0079)
                                        .withOpacity(.15),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      4.0), // Optional: for rounded corners
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 19,
                                      backgroundColor:
                                          const Color(0xff5645F5), // innit
                                      child: Text(
                                        "${account.accountName.split(" ")[0][0]}${account.accountName.split(" ")[1][0]}",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          height: 1.450,
                                          fontFamily: 'Boldonse',
                                          letterSpacing: 0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    horizontalSpaceSmall,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            account.accountNumber,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              height: 1.450,
                                              fontFamily: 'Boldonse',
                                              letterSpacing: .255,
                                              color: Color(0xff2A0079),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            account.accountName,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              height: 1.450,
                                              fontFamily: 'Karla',
                                              letterSpacing: .1,
                                              color: Color(0xFF302D53),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            account.bankName,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              height: 1.450,
                                              fontFamily: 'Karla',
                                              letterSpacing: .2,
                                              color: Color.fromARGB(
                                                  255, 31, 29, 55),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red.shade800,
                                      ),
                                      onTap: () {
                                        viewModel.deleteAccount(account.id!);
                                      },
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                                delay: Duration(milliseconds: 200 + (index * 100)),
                              ).slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                                delay: Duration(milliseconds: 200 + (index * 100)),
                              ).scale(
                                begin: const Offset(0.98, 0.98),
                                end: const Offset(1.0, 1.0),
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                                delay: Duration(milliseconds: 200 + (index * 100)),
                              );
                            }).toList(),
                          ),
                verticalSpace(40),
                !viewModel.isLoading
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(height: 24.h),
                            FilledBtn(
                              onPressed: () {
                                viewModel.navigationService
                                    .navigateToLinkABankView();
                              },
                              backgroundColor: const Color(0xff5645F5),
                              text: "Add a new bank",
                            ).animate().fadeIn(
                              duration: 500.ms,
                              curve: Curves.easeOutCubic,
                              delay: 300.ms,
                            ).slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 500.ms,
                              curve: Curves.easeOutCubic,
                              delay: 300.ms,
                            ).shimmer(
                              duration: 2000.ms,
                              color: Colors.white.withOpacity(0.3),
                              delay: 500.ms,
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      )
                    : verticalSpace(0),
                verticalSpace(40),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  LinkedBanksViewModel viewModelBuilder(BuildContext context) =>
      LinkedBanksViewModel();
}
