import 'package:dayfi/data/models/transaction_history_model.dart';
import 'package:dayfi/ui/components/create_wallet_dashed_box.dart';
import 'package:dayfi/ui/views/digital_dollar/digital_dollar_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/ui/common/amount_formatter.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/outlined_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/ui/views/dayfI_app.dart';
import 'package:dayfi/ui/views/home/bottom_sheets/dayfi_id_bottomsheet.dart';
import 'package:dayfi/ui/views/home/bottom_sheets/success_bottomsheet.dart';
import 'package:dayfi/ui/views/main/main_viewmodel.dart';
import 'package:dayfi/ui/views/recipient_details/recipient_details_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../components/buttons/filled_btn_small.dart';
import '../../components/input_fields/custom_text_field.dart';
import 'bottom_sheets/dayfi_transfer_id_bottomsheet.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  HomeView({super.key, required this.mainModel});

  final MainViewModel mainModel;

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return ViewModelBuilder<MainViewModel>.reactive(
      viewModelBuilder: () => MainViewModel(),
      onViewModelReady: (model) {
        model.loadWalletDetails();
        model.startPolling();
      },
      onDispose: (model) {},
      builder: (context, model, child) {
        return AppScaffold(
          backgroundColor: Color(0xffF6F5FE),
          body: SafeArea(
              child: model.isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : model.hasError
                      ? Center(child: Text(model.error.toString()))
                      : (model.wallets?.isEmpty ?? true)
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
                              model)
                          : _buildBody(
                              context, viewModel, model.wallets![0], model)),
        );
      },
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    HomeViewModel viewModel,
    Wallet wallet,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xffF6F5FE),
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        onTap: () => viewModel.navigationService.navigateToProfileView(),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                backgroundImage: const NetworkImage(
                    'https://avatar.iran.liara.run/public/52'),
              ),
            ),
            horizontalSpaceSmall,
            Text(
              'Hi, ${viewModel.user?.firstName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Boldonse',
                letterSpacing: 0.3,
                color: Color(0xff2A0079),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            onTap: () =>
                _showNotificationsBottomSheet(context, viewModel, wallet),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: SvgPicture.asset(
                'assets/svgs/notifications_unread_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                height: 22,
                color: const Color(0xff5645F5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularActionButtons(
    BuildContext context,
    HomeViewModel viewModel,
    List<Wallet> wallets,
  ) {
    return wallets.isEmpty
        ? const SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Send
              Expanded(
                child: _buildCircularActionButton(
                  context,
                  viewModel,
                  'Send',
                  'assets/svgs/arrow-narrow-down.svg',
                  () {
                    viewModel.user?.phoneNumber != null
                        ? _showSelectTransferMethodBottomSheet(
                            context, viewModel, wallets[0])
                        : _showKYCNoticeBottomSheet(
                            context, viewModel, wallets[0]);
                  },
                ),
              ),

              horizontalSpaceTiny,
              horizontalSpaceTiny,
              horizontalSpaceTiny,
              horizontalSpaceTiny,

              // Swap
              Expanded(
                child: _buildCircularActionButton(
                  context,
                  viewModel,
                  'Swap',
                  'assets/svgs/swap.svg',
                  () {
                    viewModel.navigationService
                        .navigateToSwapView(wallets: wallets);
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildCircularActionButton(
    BuildContext context,
    HomeViewModel viewModel,
    String label,
    String iconAsset,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        // width: double.infinity,
        // width: MediaQuery.of(context).size.width * .4165,
        decoration: BoxDecoration(
          color: const Color(0xffF6F5FE),
          border: Border.all(
            width: 0.25,
            color: const Color(0xff5645F5),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 0,
              spreadRadius: 0,
              color: Colors.orangeAccent.shade100,
              offset: label == "Send"
                  ? const Offset(-1.5, 2.5)
                  : label == "Fund"
                      ? const Offset(0, 2.5)
                      : label == "Swap"
                          ? const Offset(1.5, 2.5)
                          : label == "Buy"
                              ? const Offset(0.75, 2.5)
                              : const Offset(1.5, 2.5),
            )
          ],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: EdgeInsets.all(label == "Swap" ? 0 : 0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildRotatedIcon(label, iconAsset),
              const SizedBox(width: 12),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center, // center the text since stretched
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  fontFamily: 'Boldonse',
                  letterSpacing: 0.5,
                  color: const Color(0xff5645F5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRotatedIcon(String label, String iconAsset) {
    final icon = SvgPicture.asset(
      iconAsset,
      height: 22,
      color: const Color(0xff5645F5),
    );

    if (label == "Send") {
      return Transform.rotate(
        angle: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 17.0),
          child: icon,
        ),
      );
    } else if (label == "Swap") {
      return Transform.rotate(
        angle: 3.12 / 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 17.0),
          child: icon,
        ),
      );
    } else {
      return Transform.rotate(
        angle: 3.12,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 17.0),
          child: icon,
        ),
      );
    }
  }

  Widget _buildBody(
    BuildContext context,
    HomeViewModel viewModel,
    Wallet wallet,
    MainViewModel model,
  ) {
    final grouped = groupTransactionsByDate(viewModel.transactions);

    final List<dynamic> items = [];
    grouped.forEach((date, txList) {
      items.add(date); // add the date header
      items.addAll(txList); // add the transactions under it
    });

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          verticalSpaceTiny,
          _buildAppBar(
              context,
              viewModel,
              model.wallets?.isEmpty ?? true
                  ? Wallet(
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
                    )
                  : model.wallets![0]),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Wallets (${model.wallets?.length})",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Boldonse',
                    letterSpacing: 0.3,
                    color: Color(0xff2A0079),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showBeforeCreatingWalletNoticeBottomSheet(
                    context,
                    viewModel,
                    model.wallets ?? [],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/svgs/add-sign.svg",
                        color: Color(0xff5645F5),
                        height: 12,
                      ),
                      SizedBox(width: 12.h),
                      Text(
                        "Add New Wallet",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.450,
                          fontFamily: 'Boldonse',
                          letterSpacing: .255,
                          color: Color(0xff5645F5), // innit
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          model.wallets!.isEmpty
              ? CreateWalletDashedBox()
              : _buildBalanceCardsPageView(
                  context, viewModel, model.wallets ?? []),
          model.wallets!.isEmpty ? const SizedBox() : verticalSpaceMedium,
          model.wallets!.isEmpty ? const SizedBox() : verticalSpaceSmall,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // verticalSpaceMedium,
                _buildCircularActionButtons(
                  context,
                  viewModel,
                  model.wallets ?? [],
                ),
                verticalSpaceMedium,
                verticalSpaceTiny,
                letsGetYouStarted(context, viewModel, model.wallets ?? []),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  viewModel.transactions.isEmpty ? "" : "NGN transaction(s)",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "SpaceGrotesk",
                    color: Color(0xff2A0079),
                    letterSpacing: -.02,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.3, end: 0, delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic)
              .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 4),
          if (viewModel.isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: CupertinoActivityIndicator(
                  color: Color(0xff5645F5), // innit
                ),
              ),
            )
          else if (viewModel.transactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 24, right: 24),
                child: Text(
                  "",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "SpaceGrotesk",
                    color: Color(0xff2A0079),
                  ),
                ),
              ),
            )
            else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item is String) {
                  // this is a date header
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 24.0,
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF302D53),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (300 + (index * 100)).ms, duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.3, end: 0, delay: (300 + (index * 100)).ms, duration: 500.ms, curve: Curves.easeOutCubic)
                      .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: (300 + (index * 100)).ms, duration: 500.ms, curve: Curves.easeOutCubic);
                } else if (item is WalletTransaction) {
                  final tx = item;

                  return Column(
                    children: [
                      ListTile(
                        onTap: () => viewModel.navigationService
                            .navigateToTransactionDetailsView(
                          wallet: wallet,
                          transaction: item,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: tx.type == 'card_to_wallet'
                              ? Color(0xff00AFF5).withOpacity(.1)
                              : Color(0xffFFB97D).withOpacity(.25),
                          child: Transform.rotate(
                            angle:
                                !tx.type.contains("card_to_wallet") ? 0 : 3.12,
                            child: SvgPicture.asset(
                              'assets/svgs/arrow-narrow-down.svg',
                              color: tx.type == 'card_to_wallet'
                                  ? Color(0xff00AFF5)
                                  : Color(0xffFF897D),
                              height: 14,
                            ),
                          ),
                        ),
                        title: Text(
                          tx.recipientWalletId.toString() == "null"
                              ? "Bale Gary"
                              : tx.recipientWalletId.toString(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.450,
                            fontFamily: 'Boldonse',
                            letterSpacing: .255,
                            color: Color(0xff2A0079),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        subtitle: Text(
                          tx.status == 'success'
                              ? "Successful".toUpperCase()
                              : tx.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.450,
                            fontFamily: 'Karla',
                            letterSpacing: 0.00,
                            color: tx.status == 'success'
                                ? Colors.green.shade800
                                : tx.status == 'pending'
                                    ? Colors.yellow.shade800
                                    : Colors.red.shade800,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${tx.type == 'card_to_wallet' ? '+' : '-'} ₦${NumberFormat("#,##0.${'0' * 2}", 'en_US').format(double.parse(tx.amount))}",
                              style: GoogleFonts.spaceGrotesk(
                                color: tx.status == 'success' &&
                                        tx.type == 'card_to_wallet'
                                    ? Colors.green.shade800
                                    : tx.status == 'pending'
                                        ? Colors.yellow.shade800
                                        : Colors.red.shade800,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.450,
                                letterSpacing: .255,

                                // overflow: TextOverflow.ellipsis,
                                // fontFamily: 'Karla',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat.jm()
                                  .format(DateTime.parse(tx.createdAt)),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: .1,
                                height: 1.450,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey.shade300,
                        height: 1,
                        indent: 24,
                        endIndent: 24,
                        thickness: 1,
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: (400 + (index * 100)).ms, duration: 500.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.3, end: 0, delay: (400 + (index * 100)).ms, duration: 500.ms, curve: Curves.easeOutCubic)
                      .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: (400 + (index * 100)).ms, duration: 500.ms, curve: Curves.easeOutCubic);
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    HomeViewModel viewModel, {
    required String currencyCode,
    required String currencyName,
    required String balance,
    required String flagAsset,
    required bool isLocal,
    required List<Wallet> wallets,
    double? width,
    Wallet? wallet,
  }) {
    return GestureDetector(
      onTap: () {
        if (wallet != null) {
          viewModel.navigationService.navigateToWalletView(
            wallet: wallet,
            walletTransactions: viewModel.transactions,
            wallets: wallets,
          );
        }
      },
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * .77,
        margin: EdgeInsets.only(
          top: 8,
          right: 8,
          left: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: const Color(0xff5645F5).withOpacity(1),
            width: 1.0,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/images/backgroud.png',
                fit: BoxFit.cover,
                color: Colors.orangeAccent.shade200,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // currency + flag
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    " $currencyCode",
                                    style: const TextStyle(
                                      fontFamily: 'Karla',
                                      fontSize: 12,
                                      color: Color(0xff2A0079),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -.04,
                                      height: 1.450,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Image.asset(
                                    flagAsset,
                                    height: 14,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                isLocal ? " Local wallet" : " ",
                                style: const TextStyle(
                                  fontFamily: 'Karla',
                                  fontSize: 12,
                                  color: Color(0xff5645F5), // innit
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -.04,
                                  overflow: TextOverflow.ellipsis,
                                  height: 1.450,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      // if (currencyCode == "NGN")
                      FilledBtnSmall2(
                        onPressed: () {
                          // if (currencyCode == "NGN") {
                          viewModel.user?.phoneNumber != null
                              ? _showSelectPaymentMethodBottomSheet(
                                  context, viewModel, wallet!)
                              : _showReceiveFundsNoticeBottomSheet(
                                  context, viewModel, wallet!);
                          // }
                        },
                        text: 'Fund Wallet',
                        backgroundColor: const Color(0xff5645F5),
                      ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    "Your balance  ",
                    style: TextStyle(
                      fontFamily: 'Karla',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.04,
                      height: 1.450,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AmountFormatter.formatDecimal(
                              num.tryParse(balance) ?? 0.0),
                          style: TextStyle(
                            fontFamily: 'Boldonse',
                            fontSize: 28.sp,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff2A0079),
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      Image.asset('assets/images/logoo.png', height: 28),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCardsPageView(
    BuildContext context,
    HomeViewModel viewModel,
    List<Wallet> wallets,
  ) {
    // Sort wallets by currency in alphabetical order
    final sortedWallets = List<Wallet>.from(wallets)
      ..sort((a, b) => a.currency.compareTo(b.currency));

    // Handle empty wallets case
    if (sortedWallets.isEmpty) {
      return AspectRatio(
        aspectRatio: 15 / 5.65,
        child: Center(
          child: Text(
            "No wallets available. Create one to get started!",
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'Boldonse',
              color: Color(0xff2A0079),
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 15 / 5.65,
      child: SizedBox(
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: sortedWallets.length,
          itemBuilder: (context, index) {
            final wallet = sortedWallets[index];

            // Calculate balance to show (no conversion for now)
            final displayedBalance = double.tryParse(wallet.balance) ?? 0.0;

            return _buildBalanceCard(
              context,
              viewModel,
              currencyCode: wallet.currency,
              currencyName: wallet.bankName.isNotEmpty
                  ? wallet.bankName
                  : "${wallet.currency} Wallet",
              balance: displayedBalance.toStringAsFixed(2),
              flagAsset: _resolveWalletFlag(wallet.currency),
              isLocal: wallet.currency == "NGN",
              wallet: wallet,
              wallets: wallets,
              width: sortedWallets.length == 1
                  ? MediaQuery.of(context).size.width - 48
                  : MediaQuery.of(context).size.width * 0.77,
            )
                .animate()
                .fadeIn(delay: (300 + (index * 100)).ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .slideY(begin: 0.3, end: 0, delay: (300 + (index * 100)).ms, duration: 500.ms, curve: Curves.easeOutCubic)
                .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: (300 + (index * 100)).ms, duration: 500.ms, curve: Curves.easeOutCubic);
          },
        ),
      ),
    );
  }

  String _resolveWalletFlag(String currency) {
    switch (currency.toUpperCase()) {
      case "NGN":
        return "assets/images/nigeria.png";
      case "USD":
        return "assets/images/united-states.png";
      case "EUR":
        return "assets/images/european-union.png";
      case "GBP":
        return "assets/images/united-kingdom.png";
      default:
        return "assets/images/default-flag.png";
    }
  }

  Widget letsGetYouStarted(
    BuildContext context,
    HomeViewModel viewModel,
    List<Wallet> wallets, {
    double horizontal = 0,
  }) {
    return Container(
      padding: EdgeInsets.all(14.0),
      margin: EdgeInsets.symmetric(horizontal: horizontal),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: const Color(0xff5645F5).withOpacity(.15),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          Text(
            "Let's get you started",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              height: 1.450,
              fontFamily: 'Boldonse',
              letterSpacing: .255,
              color: Color(0xff2A0079),
              overflow: TextOverflow.ellipsis,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.3, end: 0, delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic)
              .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic),
          SizedBox(height: 6),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: viewModel.letsGetYouStartedCheckList.length,
            separatorBuilder: (_, __) => SizedBox(height: 0),
            itemBuilder: (context, index) {
              final item = viewModel.letsGetYouStartedCheckList[index];
              // Check wallet and user conditions
              bool hasValidWallet =
                  wallets.isNotEmpty && wallets[0].dayfiId != null;
              bool hasGender = viewModel.user?.gender != null;

              // Hide item if conditions are met
              if ((hasValidWallet && item.title == "Get a unique username") ||
                  (hasGender && item.title == "Complete verification")) {
                return const SizedBox();
              }

              // Use empty wallet if wallets is empty
              Wallet walletToPass = wallets.isNotEmpty
                  ? wallets[0]
                  : Wallet(
                      walletId: '',
                      userId: '',
                      walletReference: '',
                      accountName: '',
                      accountNumber: '',
                      bankName: '',
                      balance: '0',
                      currency: '',
                      provider: '',
                      createdAt: '',
                      updatedAt: '');

              return GestureDetector(
                onTap: () {
                  switch (item.title) {
                    case "Get a unique username":
                      _showDayfiBottomSheet(context, viewModel, walletToPass);
                      break;
                    case "Complete verification":
                      _showKYCNoticeBottomSheet(
                          context, viewModel, walletToPass);
                      break;
                    case "Invest in stable coins":
                      viewModel.navigationService.navigateToPrepaidInfoView();
                      break;
                    case "Add new wallet":
                      _showBeforeCreatingWalletNoticeBottomSheet(
                          context, viewModel, wallets);
                      break;
                    default:
                      print("Unknown menu item tapped: ${item.title}");
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Color(0xffF6F5FE),
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: const Color(0xff5645F5).withOpacity(.25),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: SvgPicture.asset(
                                item.icon,
                                color: Color(0xff5645F5),
                                height: 22,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      height: 1.450,
                                      fontFamily: 'Boldonse',
                                      letterSpacing: .255,
                                      color: Color(0xff2A0079),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    item.description,
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
                            ),
                            SizedBox(width: 6),
                          ],
                        ),
                      ),
                      Container(
                        height: 19,
                        width: 19,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xff5645F5),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (300 + (index * 100)).ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.3, end: 0, delay: (300 + (index * 100)).ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: (300 + (index * 100)).ms, duration: 500.ms, curve: Curves.easeOutCubic);
            },
          ),
        ],
      ),
    );
  }

  Map<String, List<WalletTransaction>> groupTransactionsByDate(
      List<WalletTransaction> txs) {
    final Map<String, List<WalletTransaction>> grouped = {};
    for (var tx in txs) {
      final dateKey = DateFormat.yMMMEd().format(DateTime.parse(tx.createdAt));
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }
    return grouped;
  }

  void _showReceiveFundsNoticeBottomSheet(
    BuildContext context,
    HomeViewModel viewModel,
    Wallet wallet,
  ) {
    showModalBottomSheet(
      barrierColor: const Color(0xff5645F5).withOpacity(0.5),
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.00),
        ),
      ),
      builder: (context) {
        return _buildBottomSheetContent(
          Colors.white,
          context,
          viewModel,
          _buildReceiveFundsContent,
          wallet,
        );
      },
    );
  }

  void _showNotificationsBottomSheet(
    BuildContext context,
    HomeViewModel viewModel,
    Wallet wallet,
  ) {
    showModalBottomSheet(
      barrierColor: const Color(0xff5645F5).withOpacity(0.5),
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.00))),
      builder: (context) {
        return _buildBottomSheetContent(Colors.white, context, viewModel,
            _buildNotificationsContent, wallet);
      },
    );
  }

  Widget _buildNotificationsContent(
    BuildContext context,
    HomeViewModel viewModel,
    StateSetter setState,
    Wallet wallet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Notifications",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            height: 1.2,
            fontFamily: 'Boldonse',
            letterSpacing: 0.00,
            color: const Color(0xff2A0079),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showCreateWalletBottomSheet(
    BuildContext context,
    HomeViewModel viewModel,
    List<Wallet> wallets,
  ) {
    showModalBottomSheet(
      barrierColor: const Color(0xff5645F5).withOpacity(0.5),
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.00))),
      builder: (context) {
        return StatefulBuilder(builder: (
          BuildContext context,
          StateSetter setState,
        ) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.00),
                  topRight: Radius.circular(28.00),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBottomSheetHandle(context),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => viewModel.navigationService.back(),
                        child: SvgPicture.asset(
                          'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                          color: const Color(0xff5645F5), // innit
                          height: 28,
                        ),
                      ),
                    ),
                    _buildCreateWalletContent(
                        context, viewModel, setState, wallets),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildCreateWalletContent(
    BuildContext context,
    HomeViewModel viewModel,
    StateSetter setState,
    List<Wallet> wallets,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Create new wallet",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            height: 1.2,
            fontFamily: 'Boldonse',
            letterSpacing: 0.00,
            color: const Color(0xff2A0079),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        verticalSpace(40),
        CustomTextField(
          label: "Currency",
          hintText: "Select currency",
          controller: viewModel.currencySelected,
          shouldReadOnly: true,
          onChanged: (value) {},
          onTap: () {
            setState(() =>
                viewModel.showCurrencyOptions = !viewModel.showCurrencyOptions);
          },
          enableInteractiveSelection: false,
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: viewModel.showCurrencyOptions ? 1 : 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: AnimatedContainer(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Color(0xff2A0079).withOpacity(0.15),
                ),
              ),
              duration: const Duration(milliseconds: 250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: viewModel.currencies.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final currency = entry.value;
                    final isUsd = currency.name == "USD";
                    return InkWell(
                      onTap: () {
                        if (isUsd) {
                          setState(() => viewModel.showCurrencyOptions = false);
                          viewModel.currencySelected.text = "USD";
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          vertical: isUsd ? 10 : 10,
                          horizontal: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  currency.icon,
                                  height: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  currency.name,
                                  style: const TextStyle(
                                    fontFamily: 'Karla',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -.04,
                                    height: 1.450,
                                    color: Color(0xff2A0079),
                                  ),
                                ),
                              ],
                            ),
                            isUsd
                                ? SvgPicture.asset(
                                    "assets/svgs/circle-check.svg",
                                    color:
                                        const Color.fromARGB(255, 123, 0, 231),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.5, vertical: 4.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff2A0079)
                                          .withOpacity(.075),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Coming soon",
                                      style: TextStyle(
                                        fontFamily: 'karla',
                                        fontSize: 12,
                                        color: const Color(0xff5645F5), // innit
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.2,
                                        height: 1.450,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (200 + (index * 50)).ms, duration: 500.ms, curve: Curves.easeOutCubic)
                        .slideY(begin: 0.3, end: 0, delay: (200 + (index * 50)).ms, duration: 500.ms, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: (200 + (index * 50)).ms, duration: 500.ms, curve: Curves.easeOutCubic);
                  },
                ).toList(),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 24.h),
              FilledBtn(
                onPressed: () => viewModel.createNewWallet(
                  context,
                  // wallets[0].dayfiId!
                ),
                backgroundColor: const Color(0xff5645F5),
                text: "Next - Wallet created",
                isLoading: viewModel.isBusy,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ],
    );
  }

  void showDayfieIdInputBottomSheet(
    BuildContext context,
    HomeViewModel viewModel,
    Wallet wallet,
  ) {
    showModalBottomSheet(
      barrierColor: const Color(0xff2A0079).withOpacity(0.5),
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      elevation: 0,
      // sheetAnimationStyle: AnimationStyle(duration: Duration.zero),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.00))),
      builder: (context) => DayfiTransferIDBottomSheet(
        viewModel: viewModel,
        wallet: wallet,
      ),
    );
  }

  Widget _buildBottomSheetContent(
    Color? color,
    BuildContext context,
    HomeViewModel viewModel,
    Widget Function(
      BuildContext,
      HomeViewModel,
      StateSetter,
      Wallet,
    ) contentBuilder,
    Wallet wallet,
  ) {
    return StatefulBuilder(builder: (
      BuildContext context,
      StateSetter setState,
    ) {
      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 8.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28.00),
              topRight: Radius.circular(28.00),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBottomSheetHandle(context),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => viewModel.navigationService.back(),
                    child: SvgPicture.asset(
                      'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                      color: const Color(0xff5645F5), // innit
                      height: 28,
                    ),
                  ),
                ),
                // SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                contentBuilder(context, viewModel, setState, wallet),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBottomSheetHandle(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 88,
        height: 4,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color:
              Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.25),
        ),
      ),
    );
  }

  Widget _buildReceiveFundsContent(
    BuildContext context,
    HomeViewModel viewModel,
    StateSetter setState,
    Wallet wallet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildBottomSheetHeader(
          context,
          icon: Image.asset(
            "assets/images/accept.png",
            height: MediaQuery.of(context).size.width * .2,
          ),
          title: "Before receiving funds",
          subtitle:
              "Here are a few things you need to note before receiving funds on dayfi",
        ),
        const SizedBox(height: 24),
        _buildNoticeList(context, viewModel.beforeReceivingFunds),
        const SizedBox(height: 8),
        _buildBottomSheetButton(
          context,
          viewModel,
          text: "Agree and continue",
          onPressed: () {
            viewModel.navigationService.back();
            viewModel.user?.phoneNumber == null
                ? _showKYCNoticeBottomSheet(context, viewModel, wallet)
                : _showSelectPaymentMethodBottomSheet(
                    context, viewModel, wallet);
          },
        ),
      ],
    );
  }

  Widget _buildBottomSheetButton(
    BuildContext context,
    HomeViewModel viewModel, {
    required String text,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: 8.h),
          FilledBtn(
            onPressed: onPressed,
            backgroundColor: const Color(0xff5645F5),
            text: text,
            // textColor: Colors.white,
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildNoticeList(BuildContext context, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xffF6F5FE),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xff5645F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  index == 0 ? "${index + 1} " : "${index + 1}",
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.04,
                      height: 1.450,
                      color: Color(0xff5645F5), // innit
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showSelectPaymentMethodBottomSheet(
    BuildContext context,
    HomeViewModel viewModel,
    Wallet wallet,
  ) {
    showModalBottomSheet(
      barrierColor: const Color(0xff5645F5).withOpacity(0.5),
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      // sheetAnimationStyle: AnimationStyle(
      // duration: Duration.zero),
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.00))),
      builder: (context) {
        return _buildBottomSheetContent(Color(0xffF6F5FE), context, viewModel,
            _buildSelectPaymentMethodContent, wallet);
      },
    );
  }

  void _showSelectTransferMethodBottomSheet(
      BuildContext context, HomeViewModel viewModel, Wallet wallet) {
    showModalBottomSheet(
      barrierColor: const Color(0xff5645F5).withOpacity(0.5),
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 0,
      // sheetAnimationStyle: AnimationStyle(
      // duration: Duration.zero),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.00))),
      builder: (context) {
        return _buildBottomSheetContent(Color(0xffF6F5FE), context, viewModel,
            _buildSelectTransferMethodContent, wallet);
      },
    );
  }

  void _showBankTransferDetailsBottomSheet(
      BuildContext context, HomeViewModel viewModel, Wallet wallet) {
    showModalBottomSheet(
      barrierColor: const Color(0xff5645F5).withOpacity(0.5),
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 0,
      // sheetAnimationStyle: AnimationStyle(
      // duration: Duration.zero),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.00))),
      builder: (context) {
        return _buildBottomSheetContent(Color(0xffF6F5FE), context, viewModel,
            _buildShowWalletBankDetails, wallet);
      },
    );
  }

  void _showDayfiBottomSheet(
    BuildContext context,
    HomeViewModel model,
    Wallet wallet,
  ) {
    showModalBottomSheet(
      context: context,
      barrierColor: const Color(0xff5645F5).withOpacity(0.5),
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.00))),
      // sheetAnimationStyle: AnimationStyle(
      // duration: Duration.zero),
      builder: (context) => DayfiIDBottomSheet(
        viewModel: model,
        wallet: wallet,
      ),
    );
  }

  Widget _buildSelectPaymentMethodContent(
    BuildContext context,
    HomeViewModel viewModel,
    StateSetter setState,
    Wallet wallet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildBottomSheetHeader(
          context,
          title: "Select a receiving method",
          subtitle: "Choose your preferred way to receive funds with dayfi",
        ),
        const SizedBox(height: 24),
        // Text(
        //   viewModel.isNfcAvailable == null
        //       ? "Checking NFC availability..."
        //       : viewModel.isNfcAvailable!
        //           ? "NFC is available on this device"
        //           : "NFC is not available or disabled",
        //   style: TextStyle(
        //     fontSize: 16,
        //     color: viewModel.isNfcAvailable == null
        //         ? Colors.grey
        //         : viewModel.isNfcAvailable!
        //             ? Colors.green.shade600
        //             : Colors.red.shade800,
        //   ),
        // ),
        // const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: paymentMethods.map((paymentMethod) {
            return wallet.currency == "NGN" &&
                    paymentMethod.name == "Via Digital Dollars"
                ? const SizedBox.shrink()
                : wallet.currency == "USD" &&
                        (paymentMethod.name == "Via Debit Card" ||
                            paymentMethod.name == "Via Bank Transfer")
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          setState(() => viewModel.selectedPaymentMethod =
                              paymentMethod.name);
                          paymentMethod.name == "Via Debit Card" ||
                                  paymentMethod.name == "Via Scan to Pay"
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DayfiApp(
                                      selectedPaymentMethod: paymentMethod.name,
                                    ),
                                  ),
                                )
                              : paymentMethod.name == "Via Dayfi-ID"
                                  ? _showDayfiBottomSheet(
                                      context, viewModel, wallet)
                                  : paymentMethod.name == "Via Bank Transfer"
                                      ? _showBankTransferDetailsBottomSheet(
                                          context,
                                          viewModel,
                                          wallet,
                                        )
                                      : Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DigitalDollarView(),
                                          ),
                                        );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            // color: viewModel.selectedPaymentMethod == paymentMethod.name
                            //     ? const Color(0xff5645F5).withOpacity(0.1)
                            //     : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xff5645F5).withOpacity(.35),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          Color(0xff5645F5).withOpacity(.1),
                                      child: paymentMethod.icon.contains("svg")
                                          ? SvgPicture.asset(
                                              paymentMethod.icon,
                                              height: 22,
                                              color: Color(0xff5645F5), // innit
                                            )
                                          : Image.asset(
                                              paymentMethod.icon,
                                              height: 22,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(paymentMethod.name,
                                                    style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.450,
                                                        fontFamily:
                                                            'SpaceGrotesk',
                                                        letterSpacing: .255,
                                                        color:
                                                            Color(0xff2A0079),
                                                        overflow: TextOverflow
                                                            .ellipsis)),
                                              ),
                                              // const SizedBox(width: 12),
                                              // Align(
                                              //   alignment: Alignment.bottomRight,
                                              //   child: paymentMethod.name ==
                                              //               "Via Debit Card" ||
                                              //           paymentMethod.name ==
                                              //               "Via Scan to Pay"
                                              //       ? Image.asset(
                                              //           'assets/images/paystack-badge-cards-.png',
                                              //           width: 64)
                                              //       : const SizedBox.shrink(),
                                              // ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .05),
                                            child: Text(
                                              paymentMethod.description,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                height: 1.450,
                                                fontFamily: 'Karla',
                                                letterSpacing: .1,
                                                color: Color(0xff304463),
                                              ),
                                            ),
                                          ),
                                          // paymentMethod.name ==
                                          //         "Via debit card — Tap or Scan"
                                          //     ? Align(
                                          //         alignment: Alignment.centerRight,
                                          //         child: Padding(
                                          //           padding: const EdgeInsets.only(
                                          //               bottom: 8.0),
                                          //           child: _buildComingSoonTag(),
                                          //         ))
                                          //     : const SizedBox.shrink(),
                                          SizedBox(
                                              height: paymentMethod.name !=
                                                      "Via Dayfi-ID"
                                                  ? 0
                                                  : 4),
                                          paymentMethod.name != "Via Dayfi-ID"
                                              ? const SizedBox.shrink()
                                              : _buildComingSoonTag(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSelectTransferMethodContent(
    BuildContext context,
    HomeViewModel viewModel,
    StateSetter setState,
    Wallet wallet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildBottomSheetHeader(
          context,
          title: "Select a sending method",
          subtitle: "How would you like to send money with dayfi?",
        ),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: transferMethods.map((paymentMethod) {
            return InkWell(
              onTap: paymentMethod.name == "Via Dayfi-ID"
                  ? () =>
                      showDayfieIdInputBottomSheet(context, viewModel, wallet)
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecipientDetailsView())),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                decoration: BoxDecoration(
                  // color: viewModel.selectedPaymentMethod == paymentMethod.name
                  //     ? const Color(0xff5645F5).withOpacity(0.1)
                  //     : Colors.transparent,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xff5645F5).withOpacity(.35),
                    width: 1.0,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xff5645F5).withOpacity(.1),
                            child: paymentMethod.icon.contains("svg")
                                ? SvgPicture.asset(
                                    paymentMethod.icon,
                                    height: 22,
                                    color: Color(0xff5645F5), // innit
                                  )
                                : Image.asset(
                                    paymentMethod.icon,
                                    height: 22,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      paymentMethod.name,
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          height: 1.450,
                                          fontFamily: 'Boldonse',
                                          letterSpacing: .255,
                                          color: Color(0xff2A0079),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          .05),
                                  child: Text(
                                    paymentMethod.description,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      height: 1.450,
                                      fontFamily: 'Karla',
                                      letterSpacing: .1,
                                      color: Color(0xff304463),
                                    ),
                                  ),
                                ),
                                // paymentMethod.name ==
                                //         "Via debit card — Tap or Scan"
                                //     ? Align(
                                //         alignment: Alignment.centerRight,
                                //         child: Padding(
                                //           padding: const EdgeInsets.only(
                                //               bottom: 8.0),
                                //           child: _buildComingSoonTag(),
                                //         ))
                                //     : const SizedBox.shrink(),
                                // Align(
                                //   alignment: Alignment.bottomRight,
                                //   child: paymentMethod.name == "Via Bank"
                                //       ? Image.asset(
                                //           'assets/images/paystack-badge-cards-.png',
                                //           width: MediaQuery.of(context)
                                //                   .size
                                //                   .width *
                                //               0.14)
                                //       : const SizedBox.shrink(),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildShowWalletBankDetails(
    BuildContext context,
    HomeViewModel viewModel,
    StateSetter setState,
    Wallet wallet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildBottomSheetHeader(
          context,
          title: "Bank transfer",
          subtitle: "Use the account details below to fund your wallet.",
        ),
        const SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(14.0),
          // margin: EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: Color(0xffF6F5FE),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Color(0xff5645F5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Account number',
                          style: TextStyle(
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.00,
                            height: 1.450,
                            color: Color(0xff2A0079),
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: wallet.accountNumber));
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.copy,
                                color: Color(0xff5645F5), // innit
                                size: 20,
                              ),
                              SizedBox(width: 3),
                              Text(
                                wallet.accountNumber,
                                style: TextStyle(
                                  fontFamily: 'Karla',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: 0.00,
                                  height: 1.450,
                                  color: Color(0xff5645F5), // innit
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Account name',
                          style: TextStyle(
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.00,
                            height: 1.450,
                            color: Color(0xff2A0079),
                          ),
                        ),
                        Spacer(),
                        Text(
                          wallet.accountName,
                          style: TextStyle(
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.00,
                            height: 1.450,
                            color: Color(0xff2A0079),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Bank Name',
                          style: TextStyle(
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.00,
                            height: 1.450,
                            color: Color(0xff2A0079),
                          ),
                        ),
                        Spacer(),
                        Text(
                          wallet.bankName.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Karla',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.00,
                            height: 1.450,
                            color: Color(0xff2A0079),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 245, 252, 254),
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Color.fromARGB(255, 26, 77, 104)),
                ),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/idea.png",
                      height: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Charge for funding your NGN wallet is 1% capped at 50.00',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Karla',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          height: 1.450,
                          color: Color.fromARGB(255, 26, 77, 104),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        FilledBtn(
          onPressed: () => viewModel.navigationService.back(),
          text: 'Okay, close',
          backgroundColor: const Color(0xff5645F5),
        ),
        SizedBox(height: 20),
        FilledBtn(
          onPressed: () {},
          text: 'Do you need help?',
          backgroundColor: Colors.transparent,
          textColor: Color(0xff5645F5), // innit
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildComingSoonTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 4.5),
      decoration: BoxDecoration(
        color: const Color(0xff5645F5).withOpacity(.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Zero fees",
        style: TextStyle(
          fontFamily: 'Boldonse',
          fontSize: 12,
          color: Color(0xff5645F5), // innit
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          height: 1.450,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showKYCNoticeBottomSheet(
      BuildContext context, HomeViewModel viewModel, Wallet wallet) {
    showModalBottomSheet(
      // backgroundColor: Colors.white,
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      elevation: 0,
      barrierColor: const Color(0xff2A0079).withOpacity(.5),
      // sheetAnimationStyle: AnimationStyle(
      // duration: Duration.zero), // Set animation duration to zero
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.00),
        ),
      ),
      builder: (context) {
        return _buildBottomSheetContent(
          Colors.white,
          context,
          viewModel,
          _buildKYCContent,
          wallet,
        );
      },
    );
  }

  Widget _buildKYCContent(
    BuildContext context,
    HomeViewModel viewModel,
    StateSetter setState,
    Wallet wallet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildBottomSheetHeader(
          context,
          title: "Dayfi needs your permission",
          subtitle:
              "Read our KYC data collection statement and provide consent to proceed. Dayfi will collect the following for KYC Level 1 verification:",
        ),
        const SizedBox(height: 8),
        _buildNoticeList(context, viewModel.kycLevel1Verification),
        const SizedBox(height: 8),
        const Text(
          "By continuing, you acknowledge that you have read and understood the KYC data collection statement and agree to the terms to proceed with KYC Level 1 Verification.",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            height: 1.450,
            color: Color(0xFF302D53), // innit
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlineBtn(
                onPressed: () => viewModel.navigationService.back(),
                text: "Reject",
                textColor: const Color(0xff5645F5),
                borderColor: const Color(0xff5645F5),
              ),
            ),
            horizontalSpaceSmall,
            Expanded(
              child: FilledBtn(
                onPressed: () {
                  viewModel.navigationService.back();
                  viewModel.navigationService.navigateToLevelOnePartAView();
                },
                backgroundColor: const Color(0xff5645F5),
                text: "Accept",
                // textColor: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  void _showBeforeCreatingWalletNoticeBottomSheet(
    BuildContext context,
    HomeViewModel viewModel,
    List<Wallet> wallets,
  ) {
    showModalBottomSheet(
      // backgroundColor: Colors.white,
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      elevation: 0,
      barrierColor: const Color(0xff2A0079).withOpacity(.5),
      // sheetAnimationStyle: AnimationStyle(
      // duration: Duration.zero), // Set animation duration to zero
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.00),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (
          BuildContext context,
          StateSetter setState,
        ) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.00),
                  topRight: Radius.circular(28.00),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBottomSheetHandle(context),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => viewModel.navigationService.back(),
                        child: SvgPicture.asset(
                          'assets/svgs/close_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                          color: const Color(0xff5645F5), // innit
                          height: 28,
                        ),
                      ),
                    ),
                    // SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    _buildBeforeCreatingWalletContent(
                      context,
                      viewModel,
                      setState,
                      wallets,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildBeforeCreatingWalletContent(
    BuildContext context,
    HomeViewModel viewModel,
    StateSetter setState,
    List<Wallet> wallets,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildBottomSheetHeader(
          context,
          title: "Before you add a new wallet",
          subtitle:
              "Discover the advantages of using a multi-currency wallet for global payments, storage, and swaps.",
        ),
        const SizedBox(height: 8),
        _buildNoticeList(context, viewModel.multiCurrencyWalletBenefits),
        const SizedBox(height: 8),
        const Text(
          "I understand and agree with all the Terms & Conditions for creating wallets on dayfi",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            height: 1.450,
            color: Color(0xFF302D53), // innit
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlineBtn(
                onPressed: () => viewModel.navigationService.back(),
                text: "Reject",
                textColor: const Color(0xff5645F5),
                borderColor: const Color(0xff5645F5),
              ),
            ),
            horizontalSpaceSmall,
            Expanded(
              child: FilledBtn(
                onPressed: () {
                  viewModel.navigationService.back();
                  _showCreateWalletBottomSheet(context, viewModel, wallets);
                },
                backgroundColor: const Color(0xff5645F5),
                text: "Accept",
                // textColor: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) async {
    await viewModel.loadUser();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   viewModel.checkNFCAvailability();
    // });
    await mainModel.loadWalletDetails();
    await viewModel.fetchWalletTransactions();
    super.onViewModelReady(viewModel);
  }
}
