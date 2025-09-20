import 'package:dayfi/app/app.router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/ui/common/amount_formatter.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/views/main/main_viewmodel.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../../data/models/transaction_history_model.dart';
import 'wallets_viewmodel.dart';

class WalletsView extends StackedView<WalletsViewModel> {
  WalletsView({super.key, required this.mainModel});

  final MainViewModel mainModel;

  @override
  Widget builder(
    BuildContext context,
    WalletsViewModel viewModel,
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
                    : _buildBody(
                        context,
                        viewModel,
                        model,
                      ),
          ),
        );
      },
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

  Widget _buildBody(
    BuildContext context,
    WalletsViewModel viewModel,
    MainViewModel model,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          verticalSpaceSmall,
          
          // App bar with smooth entrance
          AppBar(
            elevation: 0,
            backgroundColor: const Color(0xffF6F5FE),
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text(
                'All Wallets',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Boldonse',
                  letterSpacing: 0.3,
                  color: Color(0xff2A0079),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic)
              .slideY(begin: -0.2, end: 0, delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic),
          // Main content with staggered animations
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance section with smooth entrance
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "\$",
                      style: GoogleFonts.roboto(
                        fontSize: 25.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xff2A0079),
                        letterSpacing: -1,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      AmountFormatter.formatDecimal(
                        model.wallets != null &&
                                model.wallets!.isNotEmpty &&
                                model.wallets?.length == 2
                            ? num.parse(
                                    (double.parse(model.wallets![0].balance) /
                                            1540)
                                        .toString()) +
                                num.parse(
                                    (double.parse(model.wallets![1].balance))
                                        .toString())
                            : model.wallets != null && model.wallets!.isNotEmpty
                                ? num.parse(
                                    (double.parse(model.wallets![0].balance) /
                                            1540)
                                        .toString())
                                : 0.0,
                      ),
                      style: GoogleFonts.roboto(
                        fontSize: 28.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xff2A0079),
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                    .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                
                Text(
                  "Your consolidated balance",
                  style: TextStyle(
                    fontFamily: 'Karla',
                    fontSize: 13,
                    color: const Color(0xFF302D53).withOpacity(.75),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.02,
                    height: 1.450,
                  ),
                  textAlign: TextAlign.start,
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                    .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                verticalSpaceMedium,
                verticalSpaceTiny,
                
                // Add wallet button with enhanced animation
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 48.h,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: const Color(0xffF6F5FE),
                            border: Border.all(
                              width: .2500,
                              color: const Color(0xff5645F5).withOpacity(1.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 0,
                                  spreadRadius: 0,
                                  color: Colors.orangeAccent.shade100,
                                  offset: const Offset(1.5, 2.5))
                            ],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 17.0),
                                child: SvgPicture.asset(
                                  "assets/svgs/add-sign.svg",
                                  height: 22,
                                  color: const Color(0xff5645F5),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "ADD NEW WALLET",
                                textAlign: TextAlign.center,
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
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                    .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                    .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                    .shimmer(delay: 600.ms, duration: 1000.ms, color: Colors.white.withOpacity(0.3)),
                verticalSpaceSmall,
                buildWalletListView(model.wallets ?? [], viewModel),
                verticalSpaceMedium,
              ],
            ),
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Widget buildWalletListView(List<Wallet> wallets, WalletsViewModel viewModel) {
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

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sortedWallets.length,
      itemBuilder: (context, index) {
        final wallet = sortedWallets[index];

        return GestureDetector(
          onTap: () {
            viewModel.navigationService.navigateToWalletView(
              wallet: wallet,
              walletTransactions: viewModel.transactions,
              wallets: wallets,
            );
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                width: .2500,
                color: Color(0xff5645F5).withOpacity(1.0),
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xff2A0079).withOpacity(.05),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          _resolveWalletFlag(wallet.currency),
                          height: 22,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${wallet.currency} Wallet",
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
                              "Your balance: ${NumberFormat("#,##0.${'0' * 2}", 'en_US').format(double.tryParse(wallet.balance) ?? 0.0)}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.450,
                                fontFamily: 'Karla',
                                overflow: TextOverflow.ellipsis,
                                letterSpacing: .1,
                                color: Color(0xff304463),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (wallet.accountName.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.5, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: const Color(0xff5645F5).withOpacity(.075),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          wallet.currency == "NGN" ? "Local wallet" : "",
                          style: TextStyle(
                            fontFamily: 'Karla',
                            fontSize: 12.5,
                            color: Color(0xff5645F5),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -.04,
                            height: 1.450,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(width: 4),
                    Transform.rotate(
                      angle: 4.74,
                      child: SvgPicture.asset(
                        'assets/svgs/stat_minus_1_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
                        height: 22,
                        color: const Color(0xff5645F5),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
              .animate()
              .fadeIn(delay: (600 + (100 * index)).ms, duration: 500.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.3, end: 0, delay: (600 + (100 * index)).ms, duration: 500.ms, curve: Curves.easeOutCubic)
              .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: (600 + (100 * index)).ms, duration: 500.ms, curve: Curves.easeOutCubic),
        );
      },
    );
  }

  String _resolveWalletFlag(String currency) {
    switch (currency) {
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

  @override
  WalletsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      WalletsViewModel();

  @override
  void onViewModelReady(WalletsViewModel viewModel) async {
    await viewModel.fetchWalletTransactions();
    super.onViewModelReady(viewModel);
  }
}
