// import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/outlined_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/ui/views/main/main_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:dayfi/app/app.router.dart';
import 'settings_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StackedView<SettingsViewModel> {
  const SettingsView({super.key, required this.mainModel});

  final MainViewModel mainModel;

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    return ViewModelBuilder<MainViewModel>.reactive(
      viewModelBuilder: () => MainViewModel(),
      onViewModelReady: (model) {
        model.loadWalletDetails();
        model.startPolling();
      },
      onDispose: (model) {
        // model.st(); // Assuming stopPolling exists to clean up
      },
      builder: (context, model, child) {
        return AppScaffold(
          backgroundColor: const Color(0xffF6F5FE),
          body: SafeArea(
            child:
                model.isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : model
                        .hasError // Use hasError for cleaner error checking
                    ? Center(
                      child: Text(model.error.toString()),
                    ) // Consider improving error display
                    : (model.wallets?.isEmpty ?? true) // Safer null check
                    ? _buildBody(
                      context,
                      viewModel,
                      Wallet(
                        walletId: "",
                        userId: "",
                        walletReference: "",
                        accountName: "",
                        accountNumber: "",
                        bankName: "",
                        balance: "0",
                        currency: "",
                        provider: "",
                        createdAt: "",
                        updatedAt: "",
                      ),
                    )
                    : _buildBody(context, viewModel, model.wallets![0]),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    SettingsViewModel viewModel,
    Wallet wallet,
  ) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 22.00,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    fontFamily: 'Boldonse',
                    letterSpacing: -0.2,
                    color: Color(0xff2A0079),
                  ),
                ),
                SizedBox(height: 8.h),
                _buildDescription(context),
                SizedBox(height: 40.h),
                _buildProfileHeader(viewModel, wallet),
                SizedBox(height: 30.h),
              ],
            ),
          ),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (int i = 0; i < viewModel.settingsSections.length; i++)
                Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 24.0,
                          ),
                          child: Text(
                            viewModel.settingsSections[i].header,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF302D53),
                            ),
                          ),
                        ),
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (
                              int j = 0;
                              j <
                                  viewModel
                                      .settingsSections[i]
                                      .settingsSectionTiles
                                      .length;
                              j++
                            )
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                splashFactory: NoSplash.splashFactory,
                                onTap: () {
                                  final title =
                                      viewModel
                                          .settingsSections[i]
                                          .settingsSectionTiles[j]
                                          .title;

                                  final actions = {
                                    "Profile Information":
                                        () =>
                                            viewModel.navigationService
                                                .navigateToProfileView(),
                                    "Log Out":
                                        () => _showLogOutBottomSheet(
                                          context,
                                          viewModel,
                                        ),
                                    "Reset Transaction PIN":
                                        () =>
                                            viewModel.navigationService
                                                .navigateToTransactionPinSetView(),
                                    "Change Transaction PIN":
                                        () =>
                                            viewModel.navigationService
                                                .navigateToTransactionPinChangeView(),
                                    "Change Password":
                                        () =>
                                            viewModel.navigationService
                                                .navigateToPasswordChangeView(),
                                    "Saved Banks":
                                        () =>
                                            viewModel.navigationService
                                                .navigateToLinkedBanksView(),
                                    "FAQs":
                                        () =>
                                            viewModel.navigationService
                                                .navigateToFaqsView(),
                                    "Latest Updates":
                                        () =>
                                            viewModel.navigationService
                                                .navigateToBlogView(),
                                    "Official Website": () async {
                                      final url = Uri.parse('https://dayfi.co');
                                      try {
                                        await launchUrl(
                                          url,
                                          mode: LaunchMode.inAppBrowserView,
                                        );
                                      } catch (e) {
                                        print('Error launching URL: $e');
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error launching URL: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  };
                                  final action = actions[title];
                                  if (action != null) action();
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.fromLTRB(
                                    0.0,
                                    18.0,
                                    0.0,
                                    22.5,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border:
                                        j !=
                                                viewModel
                                                        .settingsSections[i]
                                                        .settingsSectionTiles
                                                        .length -
                                                    1
                                            ? Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                            )
                                            : null,
                                  ),
                                  child: Row(
                                    children: [
                                      _buildLeadingIcon(
                                        viewModel
                                            .settingsSections[i]
                                            .settingsSectionTiles[j],
                                      ),
                                      const SizedBox(width: 12),
                                      _buildTitleAndDescription(
                                        viewModel
                                            .settingsSections[i]
                                            .settingsSectionTiles[j],
                                        context,
                                      ),
                                      _buildTrailingChevron(),
                                    ],
                                  ),
                                ),
                              ),
                            // .animate()
                            // .fadeIn(
                            //     duration: 320.00.ms, curve: Curves.easeInOutCirc)
                            // .slideY(begin: 0.45, end: 0, duration: (600).ms),
                          ],
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 300.ms, curve: Curves.easeInOutCirc)
                    .slideY(begin: 0.0, end: 0, duration: (300).ms),
              // .animate()
              // .fadeIn(duration: 320.00.ms, curve: Curves.easeInOutCirc)
              // .slideY(begin: 0.45, end: 0, duration: (600).ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(tile) {
    final isLogOut = tile.title == "Log Out";
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.white,
      child: SvgPicture.asset(
        tile.icon,
        height: 22,
        color:
            isLogOut ? Colors.red.shade800 : const Color(0xff5645F5), // innit
      ),
    );
  }

  Widget _buildTitleAndDescription(tile, BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tile.title,
            style: TextStyle(
              fontSize: 15.00.sp,
              fontWeight: FontWeight.w700,
              height: 1.450,
              fontFamily: 'Karla',
              letterSpacing: -.06,
              color: Color(0xff2A0079),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tile.description,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              height: 1.450,
              fontFamily: 'Karla',
              letterSpacing: .1,
              color: Color(0xff304463),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingChevron() {
    return Transform.rotate(
      angle: 4.74, // 1.58 + 3.16
      child: SvgPicture.asset(
        'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
        height: 22,
        color: const Color(0xff5645F5), // innit
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * .2),
      child: Text(
        'Personalise and modify your settings to fit your preferences.',
        style: TextStyle(
          fontFamily: 'Karla',
          fontSize: 13,
          color: Color(0xFF302D53),
          fontWeight: FontWeight.w600,
          letterSpacing: -.02,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildProfileHeader(SettingsViewModel viewModel, Wallet wallet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              backgroundImage: const NetworkImage(
                'https://avatar.iran.liara.run/public/52',
              ),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                wallet.dayfiId.toString() == "null"
                    ? const SizedBox()
                    : Text(
                      "@${wallet.dayfiId}",
                      style: TextStyle(
                        fontFamily: 'Boldonse',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.00,
                        height: 1.450,
                        color: Color(0xff2A0079),
                      ),
                    ),
                SizedBox(height: wallet.dayfiId.toString() == "null" ? 0 : 6),
                Text(
                  viewModel.user == null ||
                          viewModel.user!.gender == null ||
                          viewModel.user!.gender!.isEmpty ||
                          viewModel.user!.gender! == "" ||
                          viewModel.user!.gender!.toString() == "null"
                      ? ""
                      : "Level 1",
                  style: TextStyle(
                    fontFamily: 'Karla',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 0.00,
                    height: 1.450,
                    color: Color(0xff2A0079),
                  ),
                ),
              ],
            ),
          ],
        ),
        wallet.dayfiId.toString() == "null"
            ? const SizedBox()
            : GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: wallet.dayfiId!));
              },
              child: Row(
                children: [
                  Text(
                    "copy",
                    style: TextStyle(
                      fontFamily: 'Karla',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.00,
                      height: 1.450,
                      color: Color(0xff5645F5), // innit
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.copy,
                    color: Color(0xff5645F5), // innit
                    size: 17,
                  ),
                ],
              ),
            ),
      ],
    );
  }

  void _showLogOutBottomSheet(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    showModalBottomSheet(
      // barrierColor: ,
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 0,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.00)),
      ),
      builder: (context) => _buildLogOutBottomSheet(context, viewModel),
    );
  }

  Widget _buildLogOutBottomSheet(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomSheetHandle(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          _buildBottomSheetCloseButton(viewModel),
          SizedBox(height: 24.h),
          _buildBottomSheetContent(context),
          SizedBox(height: 36.h),
          _buildBottomSheetButtons(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildBottomSheetHandle(BuildContext context) {
    return Container(
      width: 48,
      height: 3.5,
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.25),
      ),
    );
  }

  Widget _buildBottomSheetCloseButton(SettingsViewModel viewModel) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () => viewModel.navigationService.back(),
        child: SvgPicture.asset(
          'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
          height: 28.00,
          color: Color(0xff5645F5),
        ),
      ),
    );
  }

  Widget _buildBottomSheetContent(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset('assets/svgs/caution.svg', height: 88),
        SizedBox(height: 24.h),
        Text(
          'Are you sure?',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.2,
            fontFamily: 'Boldonse',
            letterSpacing: -0.2,
            color: const Color(0xff2A0079),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'You are about to log out from your dayfi account, would you like to proceed?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              height: 1.450,
              color: Theme.of(context).textTheme.bodyLarge!.color!
              // ignore: deprecated_member_use
              .withOpacity(0.75),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheetButtons(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    return Column(
      children: [
        FilledBtn(
          onPressed: () => viewModel.logout(context),
          text: 'Log Out',
          backgroundColor: Colors.red.shade800,
          textColor: Colors.white,
          isLoading: viewModel.isLoading,
        ),
        SizedBox(height: 12.w),
        OutlineBtn(
          onPressed: () => viewModel.navigationService.back(),
          text: 'Cancel',
          textColor: const Color(0xff5645F5), // innit
          borderColor: const Color(0xff5645F5), // innit
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  @override
  SettingsViewModel viewModelBuilder(BuildContext context) =>
      SettingsViewModel();

  @override
  void onViewModelReady(SettingsViewModel viewModel) async {
    await viewModel.loadUser();
    super.onViewModelReady(viewModel);
  }
}
