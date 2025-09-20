import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/input_fields/custom_text_field.dart';
import 'package:dayfi/ui/views/recipient_details/recipient_account_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../main/main_viewmodel.dart';
import 'recipient_details_viewmodel.dart';

class RecipientDetailsView extends StackedView<RecipientDetailsViewModel> {
  const RecipientDetailsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    RecipientDetailsViewModel model,
    Widget? child,
  ) {
    return ViewModelBuilder<MainViewModel>.reactive(
      viewModelBuilder: () => MainViewModel(),
      onViewModelReady: (mainModel) {
        mainModel.loadWalletDetails();
        mainModel.startPolling();
      },
      onDispose: (mainModel) {},
      builder: (context, mainModel, child) {
        return AppScaffold(
          backgroundColor: const Color(0xffF6F5FE),
          appBar: AppBar(
            backgroundColor: const Color(0xffF6F5FE),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xff2A0079)),
              onPressed: () => model.navigationService.back(),
            ),
          ),
          body: SafeArea(
            child: mainModel.isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : mainModel.hasError
                    ? Center(child: Text(mainModel.error.toString()))
                    : (mainModel.wallets?.isEmpty ?? true)
                        ? _buildBody(
                            context,
                            model,
                            mainModel,
                          )
                        : _buildBody(
                            context,
                            model,
                            mainModel,
                          ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    RecipientDetailsViewModel model,
    MainViewModel mainModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpace(8.h),
          const Text(
            "Send NGN",
            style: TextStyle(
              fontFamily: 'Boldonse',
              fontSize: 27.5,
              height: 1.2,
              letterSpacing: 0.00,
              fontWeight: FontWeight.w600,
              color: Color(0xff2A0079),
            ),
          ),
          verticalSpace(8.h),
          const Text(
            "Enter recipient account details",
            style: TextStyle(
              fontFamily: 'Karla',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: .3,
              height: 1.450,
              color: Color(0xFF302D53),
            ),
          ),
          verticalSpace(24.h),
          if (model.savedAccounts.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Saved Accounts",
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: .3,
                    height: 1.450,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff2A0079),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      barrierColor: const Color(0xff2A0079).withOpacity(0.5),
                      context: context,
                      isDismissible: false,
                      enableDrag: false,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28.00),
                        ),
                      ),
                      builder: (context) => SelectBeneficiaryBankSheet(
                        model: model,
                        banks: model.savedAccounts,
                        onSelected: (value) {
                          model.setBankCode(value ?? '');
                          if (model.accountNumber.length == 10 &&
                              value != null &&
                              value.isNotEmpty) {
                            model.resolveAccount();
                          }
                        },
                      ),
                    );
                  },
                  child: const Text(
                    "View all",
                    style: TextStyle(
                      color: Color(0xff5645F5), // innit
                      fontSize: 14,
                      letterSpacing: -.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            verticalSpace(8.h),
            Row(
              children: [
                ...model.savedAccounts.map(
                  (account) => GestureDetector(
                    onTap: () => model.selectSavedAccount(account),
                    child: SizedBox(
                      width: 92,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 19,
                            backgroundColor: const Color(0xff5645F5), // innit
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
                          const SizedBox(height: 4),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text(
                              account.accountName,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.450,
                                fontFamily: 'Karla',
                                letterSpacing: .3,
                                overflow: TextOverflow.ellipsis,
                                color: Color(0xFF302D53),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            verticalSpace(24.h),
          ],
          CustomTextField(
            label: "Bank name",
            hintText: "Select bank",
            shouldReadOnly: true,
            suffixIcon: model.isLoading
                ? model.accountNumber.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 12.0),
                        child: SvgPicture.asset(
                            height: 22,
                            'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                            color: const Color(0xff2A0079)),
                      )
                    : SizedBox(
                        height: 48,
                        width: 48,
                        child: const Center(
                          child: CupertinoActivityIndicator(
                            color: Color(0xff5645F5), // innit
                          ),
                        ),
                      )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0),
                    child: SvgPicture.asset(
                        height: 22,
                        'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                        color: const Color(0xff2A0079)),
                  ),
            onTap: model.isLoading
                ? null
                : () {
                    showModalBottomSheet(
                      barrierColor: const Color(0xff2A0079).withOpacity(0.5),
                      context: context,
                      isDismissible: false,
                      enableDrag: false,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28.00))),
                      builder: (context) => SelectBankSheet(
                        banks: model.banks,
                        onSelected: (value) {
                          model.accountNam = "";
                          model.notifyListeners();

                          //

                          model.setBankCode(value ?? '');
                          if (model.accountNumber.length == 10 &&
                              value != null &&
                              value.isNotEmpty) {
                            model.resolveAccount();
                          }
                        },
                      ),
                    );
                  },
            controller: TextEditingController(text: model.selectedBank),
          ),
          verticalSpace(16.h),
          CustomTextField(
            label: "Account number",
            hintText: "Enter your account number",
            maxLength: 10,
            minLines: 1,
            onChanged: (value) {
              model.setAccountNumber(value);
              if (value.length == 10 && model.bankCode.isNotEmpty) {
                model.resolveAccount();
              } else {
                model.accountNam = "";
                model.notifyListeners();
              }
            },
            keyboardType: TextInputType.number,
            suffixIcon: model.isLoading
                ? model.accountNumber.isEmpty
                    ? const SizedBox()
                    : const CupertinoActivityIndicator(
                        color: Color(0xff5645F5), // innit
                      )
                : model.accountNumberController.text == ""
                    ? TextButton(
                        onPressed: () async {
                          final clipboardData =
                              await Clipboard.getData('text/plain');
                          if (clipboardData != null &&
                              clipboardData.text != null) {
                            String pastedText = clipboardData.text!.trim();

                            // Remove any non-digit characters (letters, symbols, etc.)
                            pastedText =
                                pastedText.replaceAll(RegExp(r'\D'), '');

                            if (pastedText.length == 10) {
                              model.setAccountNumber(pastedText);

                              // Ensure bank code is selected before resolving
                              if (model.bankCode.isNotEmpty) {
                                model.resolveAccount();
                              } else {
                                // Optionally: Show a message to the user to select a bank
                              }
                            } else {
                              // Optionally: Show a validation message (e.g., "Enter a valid 10-digit account number")
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: const Text(
                          "Paste",
                          style: TextStyle(
                            color: Color(0xff2A0079),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : const SizedBox(),
            errorText: model.showAccountError && !model.isValidAccount
                ? model.accountNumberController.text.length != 10
                    ? "Account number must be 10 digits"
                    : model.isLoading
                        ? ""
                        : "Invalid bank details"
                : null,
            controller: model.accountNumberController,
          ),
          if (model.accountName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                model.accountName == "Pastor Bright"
                    ? "Bale Gary"
                    : model.accountName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.450,
                  letterSpacing: .255,
                  color: Colors.green.shade600,
                ),
              ),
            ),
          verticalSpace(16.h),
          Row(
            children: [
              CustomToggleSwitch(
                initialValue: model.saveAccount,
                onChanged: model.toggleSaveAccount,
                activeTrackColor: const Color(0xff5645F5), // innit
                // inactiveTrackColor: Colors.grey[300]!,
                thumbColor: Colors.white,
                width: 50.0,
                height: 28.0,
                animationDuration: const Duration(milliseconds: 300),
              ),
              const SizedBox(width: 8.0),
              const Text(
                "Save account details",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.1,
                  height: 1.450,
                  fontFamily: "Karla",
                ),
              ),
            ],
          ),
          verticalSpace(48.h),
          FilledBtn(
            onPressed: model.isValidAccount
                ? () => model.navigateToAmountEntry(mainModel.wallets![0])
                : null,
            text: "Next - Enter Amount",
            backgroundColor: model.isValidAccount
                ? const Color(0xff5645F5)
                : const Color(0xffCAC5FC),
          ),
          verticalSpace(40.h),
        ],
      ),
    );
  }

  @override
  RecipientDetailsViewModel viewModelBuilder(BuildContext context) =>
      RecipientDetailsViewModel();

  @override
  void onViewModelReady(RecipientDetailsViewModel viewModel) async {
    await viewModel.loadBanks();
    await viewModel.loadUser();
    await viewModel.loadSavedAccounts();
    viewModel.resetValidation();
  }
}

class SelectBankSheet extends StatelessWidget {
  final List<dynamic> banks;
  final Function(String?) onSelected;

  const SelectBankSheet({
    required this.banks,
    required this.onSelected,
    super.key,
  });

  Widget buildBottomSheetHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Boldonse',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xff2A0079),
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Karla',
              fontSize: 16,
              color: Color(0xFF302D53),
            ),
          ),
        verticalSpace(16.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => dismissKeyboard(),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28.00),
                topRight: Radius.circular(28.00),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 16,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 88,
                    height: 4,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                      color: const Color(0xff5645F5), // innit
                      height: 28.00,
                    ),
                  ),
                ),
                buildBottomSheetHeader(
                  context,
                  title: "Select Bank",
                  subtitle: '',
                ),
                CustomTextField(
                  label: "",
                  hintText: "Search banks ...",
                  minLines: 1,
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xff5645F5), // innit
                  ),
                  onChanged: (value) {
                    // Implement search functionality if needed
                  },
                ),
                verticalSpace(8.h),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .375,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: banks.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xff2A0079).withOpacity(.15),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(
                              4.0), // Optional: for rounded corners
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xff5645F5),
                            child: const Icon(
                              Icons.account_balance,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            banks[index]['bankname'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              height: 1.450,
                              color: Color(0xFF302D53),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Color(0xff5645F5), // innit
                          ),
                          onTap: () {
                            onSelected(banks[index]['bankcode']);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SelectBeneficiaryBankSheet extends StatelessWidget {
  final List<RecipientAccount> banks;
  final Function(String?) onSelected;
  final RecipientDetailsViewModel model;

  const SelectBeneficiaryBankSheet({
    required this.banks,
    required this.onSelected,
    super.key,
    required this.model,
  });

  Widget buildBottomSheetHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Boldonse',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xff2A0079),
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Karla',
              fontSize: 16,
              color: Color(0xFF302D53),
            ),
          ),
        verticalSpace(16.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => dismissKeyboard(),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28.00),
                topRight: Radius.circular(28.00),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 16,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 88,
                    height: 4,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                      height: 22,
                      color: const Color(0xff5645F5), // innit
                    ),
                  ),
                ),
                buildBottomSheetHeader(
                  context,
                  title: "Saved Accounts",
                  subtitle: '',
                ),
                CustomTextField(
                  label: "",
                  hintText: "Search by name or bank",
                  minLines: 1,
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xff5645F5), // innit
                  ),
                  onChanged: (value) {
                    // Implement search functionality if needed
                  },
                ),
                verticalSpace(8.h),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .375,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: banks.length,
                    itemBuilder: (context, index) => InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        model.selectSavedAccount(banks[index]);
                        model.navigationService.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xff2A0079).withOpacity(.15),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(
                              4.0), // Optional: for rounded corners
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 19,
                              backgroundColor: const Color(0xff5645F5),
                              child: Text(
                                "${banks[index].accountName.split(" ")[0][0]}${banks[index].accountName.split(" ")[1][0]}",
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    banks[index].accountNumber,
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
                                    banks[index].accountName,
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
                                    banks[index].bankName,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      height: 1.450,
                                      fontFamily: 'Karla',
                                      letterSpacing: .2,
                                      color: Color.fromARGB(255, 31, 29, 55),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "NGN",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.450,
                                fontFamily: 'Karla',
                                letterSpacing: .1,
                                color: Color(0xFF302D53),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomToggleSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color thumbColor;
  final double width;
  final double height;
  final Duration animationDuration;

  const CustomToggleSwitch({
    super.key,
    this.initialValue = false,
    this.onChanged,
    this.activeTrackColor = const Color(0xFF6200EA),
    this.inactiveTrackColor = const Color.fromARGB(255, 193, 193, 193),
    this.thumbColor = Colors.white,
    this.width = 60.0,
    this.height = 30.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  CustomToggleSwitchState createState() => CustomToggleSwitchState();
}

class CustomToggleSwitchState extends State<CustomToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialValue;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
    if (_isActive) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _isActive = widget.initialValue;
      _controller.animateTo(_isActive ? 1.0 : 0.0,
          duration: widget.animationDuration);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    setState(() {
      _isActive = !_isActive;
      widget.onChanged?.call(_isActive);
    });
    _controller.animateTo(_isActive ? 1.0 : 0.0,
        duration: widget.animationDuration);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _ToggleSwitchPainter(
              animationValue: _animation.value,
              isActive: _isActive,
              activeTrackColor: widget.activeTrackColor,
              inactiveTrackColor: widget.inactiveTrackColor,
              thumbColor: widget.thumbColor,
              height: widget.height,
            ),
          );
        },
      ),
    );
  }
}

class _ToggleSwitchPainter extends CustomPainter {
  final double animationValue;
  final bool isActive;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color thumbColor;
  final double height;

  _ToggleSwitchPainter({
    required this.animationValue,
    required this.isActive,
    required this.activeTrackColor,
    required this.inactiveTrackColor,
    required this.thumbColor,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double thumbRadius = height * 0.4;
    final double trackHeight = height * 0.4;
    final double trackWidth = size.width - thumbRadius * 1.75;
    final double thumbPosition =
        thumbRadius + (trackWidth - thumbRadius * 1) * animationValue;

    // Draw track
    final trackPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          isActive ? activeTrackColor.withOpacity(0.8) : inactiveTrackColor,
          isActive ? activeTrackColor : inactiveTrackColor.withOpacity(0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final trackPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              5, (size.height - trackHeight) / 2, trackWidth, trackHeight),
          Radius.circular(trackHeight / 2),
        ),
      );

    canvas.drawShadow(trackPath, Colors.black.withOpacity(0.2), 4.0, false);
    canvas.drawPath(trackPath, trackPaint);

    // Draw thumb
    final thumbPaint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(thumbPosition, size.height / 2),
      thumbRadius,
      thumbPaint,
    );

    // Draw subtle glow effect when active
    if (isActive) {
      final glowPaint = Paint()
        ..color = activeTrackColor.withOpacity(0.0)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      canvas.drawCircle(
        Offset(thumbPosition, size.height / 2),
        thumbRadius * 1.2,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ToggleSwitchPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isActive != isActive ||
        oldDelegate.activeTrackColor != activeTrackColor ||
        oldDelegate.inactiveTrackColor != inactiveTrackColor ||
        oldDelegate.thumbColor != thumbColor;
  }
}
