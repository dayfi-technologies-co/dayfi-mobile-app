import 'dart:convert';
import 'dart:developer';

import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/models/transaction_history_model.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/services/api/database_service.dart';
import 'package:dayfi/ui/common/amount_formatter.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn_small.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import 'wallet_viewmodel.dart';

class WalletView extends StackedView<WalletViewModel> {
  const WalletView(
    this.wallet,
    this.walletTransactions,
    this.wallets, {
    super.key,
  });

  final Wallet wallet;
  final List<WalletTransaction> walletTransactions;
  final List<Wallet> wallets;

  @override
  Widget builder(
    BuildContext context,
    WalletViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => viewModel.navigationService.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff5645F5)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: FilledBtnSmall(
              textColor: const Color(0xff5645F5),
              backgroundColor: Colors.white,
              onPressed: () {},
              text: "Need Help?",
            ),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(context, viewModel)),
    );
  }

  Map<String, List<WalletTransaction>> groupTransactionsByDate(
    List<WalletTransaction> txs,
  ) {
    final Map<String, List<WalletTransaction>> grouped = {};
    for (var tx in txs) {
      try {
        final dateKey = DateFormat.yMMMEd().format(
          DateTime.parse(tx.createdAt),
        );
        grouped.putIfAbsent(dateKey, () => []).add(tx);
      } catch (e) {
        // Skip invalid dates
        debugPrint('Error parsing date for transaction ${tx.id}: $e');
      }
    }
    return grouped;
  }

  Widget _buildBody(BuildContext context, WalletViewModel viewModel) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future:
          wallet.currency == "USD"
              ? viewModel.user != null
                  ? DatabaseService().getCachedUSDTransactions(
                    viewModel.user!.userId,
                  )
                  : Future.value([])
              : Future.value(
                walletTransactions.map((tx) => tx.toJson()).toList(),
              ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint('Error loading transactions: ${snapshot.error}');
          return const Center(
            child: Text(
              'Error loading transactions',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        List<WalletTransaction> transactions = [];
        if (snapshot.hasData && snapshot.data != null) {
          transactions =
              snapshot.data!.map((json) {
                // Create a mutable copy of the json map
                final mutableJson = Map<String, dynamic>.from(json);
                if (wallet.currency == "USD" &&
                    mutableJson['metadata'] is String) {
                  try {
                    mutableJson['metadata'] = jsonDecode(
                      mutableJson['metadata'] ?? '{}',
                    );
                  } catch (e) {
                    debugPrint('Error decoding metadata for transaction: $e');
                    mutableJson['metadata'] = {};
                  }
                }
                return WalletTransaction.fromJson(mutableJson);
              }).toList();
        }

        final grouped = groupTransactionsByDate(transactions);
        final List<dynamic> items = [];
        grouped.forEach((date, txList) {
          items.add(date);
          items.addAll(txList);
        });

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpace(12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: Text(
                  "Your ${wallet.currency} Wallet",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Boldonse',
                    letterSpacing: 0.3,
                    color: Color(0xff2A0079),
                  ),
                ),
              ),
              verticalSpace(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: _buildBalanceCard(
                  context,
                  viewModel,
                  currencyCode: wallet.currency,
                  currencyName: wallet.currency,
                  balance: wallet.balance,
                  flagAsset:
                      wallet.currency != "NGN"
                          ? "assets/images/united-states.png"
                          : "assets/images/nigeria.png",
                  isLocal: wallet.currency == "NGN",
                  wallet: wallet,
                ),
              ),
              verticalSpaceMedium,
              verticalSpaceSmall,
              _buildCircularActionButtons(context, viewModel, wallets),
              const SizedBox(height: 40),
              if (transactions.isNotEmpty)
                Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22.0),
                          child: Text(
                            "${wallet.currency} transaction(s)",
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: "SpaceGrotesk",
                              color: Color(0xff2A0079),
                              letterSpacing: -0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 320.ms, curve: Curves.easeInOutCirc)
                    .slideY(begin: 0.45, end: 0, duration: 600.ms),
              const SizedBox(height: 4),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item is String) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 24.0,
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF302D53),
                        ),
                      ),
                    );
                  } else if (item is WalletTransaction) {
                    final tx = item;
                    final isUSD = wallet.currency == "USD";
                    final currencySymbol = isUSD ? '\$' : '₦';
                    final amount = double.tryParse(tx.amount) ?? 0.0;

                    return Column(
                      children: [
                        ListTile(
                          onTap:
                              () => viewModel.navigationService
                                  .navigateToTransactionDetailsView(
                                    wallet: wallet,
                                    transaction: item,
                                  ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                tx.type == 'card_to_wallet' ||
                                        wallet.currency == "USD"
                                    ? const Color(0xff00AFF5).withOpacity(0.1)
                                    : const Color(0xffFFB97D).withOpacity(0.25),
                            child: Transform.rotate(
                              angle:
                                  !tx.type.contains("card_to_wallet")
                                      ? 0
                                      : 3.12,
                              child: SvgPicture.asset(
                                'assets/svgs/arrow-narrow-down.svg',
                                color:
                                    tx.type == 'card_to_wallet' ||
                                            wallet.currency == "USD"
                                        ? const Color(0xff00AFF5)
                                        : const Color(0xffFF897D),
                                height: 14,
                              ),
                            ),
                          ),
                          title: Text(
                            tx.recipientWalletId?.toString() ?? "Bale Gary",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                              fontFamily: 'Boldonse',
                              letterSpacing: 0.255,
                              color: const Color(0xff2A0079),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          subtitle: Text(
                            tx.status == 'success'
                                ? "SUCCESSFUL"
                                : tx.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                              fontFamily: 'Karla',
                              letterSpacing: -0.2,
                              color:
                                  tx.status == 'success' ||
                                          wallet.currency == "USD"
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
                                "${tx.type == 'card_to_wallet' || wallet.currency == "USD" ? '+' : '-'}$currencySymbol${NumberFormat("#,##0.00", 'en_US').format(amount)}",
                                style: GoogleFonts.spaceGrotesk(
                                  color:
                                      tx.status == 'success' &&
                                                  tx.type == 'card_to_wallet' ||
                                              wallet.currency == "USD"
                                          ? Colors.green.shade800
                                          : tx.status == 'pending'
                                          ? Colors.yellow.shade800
                                          : Colors.red.shade800,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.45,
                                  letterSpacing: 0.255,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat.jm().format(
                                  DateTime.tryParse(tx.createdAt) ??
                                      DateTime.now(),
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                  height: 1.45,
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
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 200),
            ],
          ),
        );
      },
    );
  }

  Future<bool> hasVirtualCard(String userId) async {
    try {
      final dbService = DatabaseService();
      final cards = await dbService.getCachedVirtualCards(userId);
      log('Checked virtual cards for user $userId: ${cards.length} found');
      return cards.isNotEmpty;
    } catch (e) {
      log('Error checking virtual cards for user $userId: $e');
      return false; // Return false on error to avoid blocking UI
    }
  }

  Widget _buildBalanceCard(
    BuildContext context,
    WalletViewModel viewModel, {
    required String currencyCode,
    required String currencyName,
    required String balance,
    required String flagAsset,
    required bool isLocal,
    required Wallet wallet,
    double? width,
  }) {
    return AspectRatio(
      aspectRatio: 14.5 / 6,
      child: Container(
        width: width ?? MediaQuery.of(context).size.width,
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
                // color: Colors.orangeAccent.shade200,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Currency + flag
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 3,
                                horizontal: 6,
                              ),
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
                                  Image.asset(flagAsset, height: 14),
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
                                  color: Color(0xff5645F5),
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
                      const SizedBox(width: 10),
                      FutureBuilder<bool>(
                        future: hasVirtualCard(wallet.userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          final hasVC = snapshot.data ?? false;
                          return FilledBtnSmall2(
                            onPressed: () {
                              if (currencyCode == "NGN") {
                                viewModel.navigationService
                                    .navigateToWalletDetailsView(
                                      wallet: wallet,
                                    );
                              } else if (hasVC) {
                                viewModel.navigationService
                                    .navigateToVirtualCardDetailsView();
                              } else {
                                viewModel.navigationService
                                    .navigateToPrepaidInfoView(isVCard: true);
                              }
                            },
                            text:
                                currencyCode == "NGN"
                                    ? 'See wallet details'
                                    : hasVC
                                    ? "View card details"
                                    : "Get a USD virtual card",
                            backgroundColor: const Color(0xff5645F5),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AmountFormatter.formatDecimal(
                            num.tryParse(balance) ?? 0.0,
                          ),
                          style: TextStyle(
                            fontFamily: 'Boldonse',
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff2A0079),
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      Image.asset('assets/images/logoo.png', height: 28),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularActionButtons(
    BuildContext context,
    WalletViewModel viewModel,
    List<Wallet> wallets,
  ) {
    return wallets.isEmpty
        ? const SizedBox()
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Row(
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
                    // _showSelectTransferMethodBottomSheet(
                    //     context, viewModel, wallets[0]);
                  },
                ),
              ),

              // Send
              Expanded(
                child: _buildCircularActionButton(
                  context,
                  viewModel,
                  'Fund',
                  'assets/svgs/arrow-narrow-down.svg',
                  () {
                    // _showSelectTransferMethodBottomSheet(
                    //     context, viewModel, wallets[0]);
                  },
                ),
              ),

              // Swap
              Expanded(
                child: _buildCircularActionButton(
                  context,
                  viewModel,
                  'Swap',
                  'assets/svgs/swap.svg',
                  () {
                    viewModel.navigationService.navigateToSwapView(
                      wallets: wallets,
                    );
                  },
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildCircularActionButton(
    BuildContext context,
    WalletViewModel viewModel,
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
          border: Border.all(width: 0.25, color: const Color(0xff5645F5)),
          boxShadow: [
            BoxShadow(
              blurRadius: 0,
              spreadRadius: 0,
              color: Colors.orangeAccent.shade100,
              offset:
                  label == "Send"
                      ? const Offset(-1.5, 2.5)
                      : label == "Fund"
                      ? const Offset(0, 2.5)
                      : label == "Swap"
                      ? const Offset(1.5, 2.5)
                      : label == "Buy"
                      ? const Offset(0.75, 2.5)
                      : const Offset(1.5, 2.5),
            ),
          ],
          // borderRadius: BorderRadius.circular(0),
        ),
        child: Padding(
          padding: EdgeInsets.all(label == "Swap" ? 0 : 0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildRotatedIcon(label, iconAsset),
              const SizedBox(width: 4),
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

  @override
  WalletViewModel viewModelBuilder(BuildContext context) => WalletViewModel();

  @override
  void onViewModelReady(WalletViewModel viewModel) {
    viewModel.loadUser();
    super.onViewModelReady(viewModel);
  }
}
