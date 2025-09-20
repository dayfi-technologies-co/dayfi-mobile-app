import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/ui/common/amount_formatter.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn_small.dart';
import 'package:dayfi/ui/views/coins/coins_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';

class CoinsView extends StackedView<CoinsViewModel> {
  const CoinsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    CoinsViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      // appBar: AppBar(
      //   elevation: 0,
      //   surfaceTintColor: Colors.transparent,
      //   backgroundColor: Color(0xffF6F5FE),
      //   leading: IconButton(
      //     onPressed: () => viewModel.navigationService.back(),
      //     icon: const Icon(
      //       Icons.arrow_back,
      //       color: Color( 0xff5645F5), // innit
      //     ),
      //   ),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(right: 20.0),
      //       child: FilledBtnSmall(
      //         textColor: Color( 0xff5645F5), // innit
      //         backgroundColor: Colors.white,
      //         onPressed: () {},
      //         text: "Need Help?",
      //       ),
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.refreshData,
          child: viewModel.isBusy
              ? _buildLoadingView()
              : viewModel.errorMessage != null
                  ? _buildCoinListView(context, viewModel)
                  : _buildCoinListView(context, viewModel),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: SizedBox(
        height: 22,
        width: 20,
        child: CupertinoActivityIndicator(
          color: Color(0xff5645F5), // innit
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, CoinsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF311122),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.fetchCoins,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5645F5),
                foregroundColor: const Color(0xff5645F5),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Karla',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  height: 1.450,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinListView(BuildContext context, CoinsViewModel model) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Digital Currencies',
              style: TextStyle(
                fontFamily: 'Boldonse',
                fontSize: 22.00,
                height: 1.2,
                letterSpacing: -0.2,
                fontWeight: FontWeight.w600,
                color: Color(0xff2A0079),
              ),
            ),
          ),
          verticalSpace(8),
          Padding(
            padding: EdgeInsets.fromLTRB(
                24.0, 0, MediaQuery.of(context).size.width * .3, 0),
            child: Text(
              "Pick a coin you like — start trading or holding with just a 0.5% transaction fee.",
              style: TextStyle(
                fontFamily: 'Karla',
                fontSize: 13,
                color: Color(0xFF302D53),
                fontWeight: FontWeight.w600,
                letterSpacing: -.02,
                height: 1.450,
              ),
            ),
          ),
          verticalSpaceSmall,
          verticalSpaceMedium,
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 245, 252, 254),
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: Color.fromARGB(255, 26, 77, 104),
              ),
            ),
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 8),
                Image.asset(
                  "assets/images/idea.png",
                  height: 22,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Be part of the 6% that own digital assets.",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontFamily: 'Karla',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.02,
                      height: 1.450,
                      color: Color.fromARGB(255, 26, 77, 104),
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate(
                key: ValueKey(4),
              )
              .fadeIn(
                  duration: 320.00.ms, curve: Curves.fastEaseInToSlowEaseOut)
              .slideY(begin: 0.45, end: 0, duration: 320.00.ms),
          // verticalSpaceMedium,
          verticalSpaceSmall,
          _buildAvailableCoinsSection(context, model),
        ],
      ),
    );
  }

  Widget _buildAvailableCoinsSection(
      BuildContext context, CoinsViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        model.coins.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    "",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "SpaceGrotesk",
                      color: Color(0xff2A0079),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: model.coins.length,
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                itemBuilder: (context, index) {
                  final coin = model.coins[index];

                  return _buildCoinListItem(
                    context,
                    coin,
                    model,
                    showDivider: index != model.coins.length - 1,
                  )
                      .animate(
                        key: ValueKey(2 + index),
                      )
                      .fadeIn(duration: 320.00.ms, curve: Curves.easeInOutCirc)
                      .slideY(
                          begin: 0.45,
                          end: 0,
                          duration: (500 + (50 * (index + 1))).ms);
                },
              ),
      ],
    );
  }

  Widget _buildCoinListItem(
    BuildContext context,
    Map<String, dynamic> coin,
    CoinsViewModel model, {
    required bool showDivider,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      onTap: () => model.navigationService.navigateToCoinDetailView(
        coinId: coin['id']?.toString() ?? '',
        coinName: coin['name']?.toString() ?? 'Unknown',
        coinPrice: _parseNum(coin['price_usd']) ?? 0.0,
        priceChange: (_parseNum(coin['price_change']) ?? 0).toDouble(),
        marketCap: coin['market_cap']?.toString() ?? '0',
        popularity: coin['popularity']?.toString() ?? '#N/A',
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
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
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xff5645F5).withOpacity(.05),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInImage.assetNetwork(
                        fadeInDuration: const Duration(milliseconds: 100),
                        fadeOutDuration: const Duration(milliseconds: 100),
                        placeholder: 'assets/images/placeholder_coin.png',
                        image: coin['icon']?.toString() ?? '',
                        width: 24,
                        height: 22,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          '',
                          width: 24,
                          height: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                horizontalSpaceSmall,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // coin['name']?.toString() ?? 'Unknown',
                      coin['abbv']?.toString() ?? "",
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
                      "Price: \$${AmountFormatter.formatDecimal(_parseNum(coin['price_usd']) ?? 0.0)}",
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
              ],
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.5, vertical: 4.5),
              decoration: BoxDecoration(
                color:
                    _getPriceChangeColor(_parseNum(coin['price_change']) ?? 0.0)
                        .withOpacity(0.075),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_formatPriceChange(_parseNum(coin['price_change']) ?? 0.0)} (24h)',
                style: TextStyle(
                  fontFamily: 'Boldonse',
                  fontSize: 12,
                  // color: const Color( 0xff5645F5), // innit
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  height: 1.450,
                  color: _getPriceChangeColor(
                      _parseNum(coin['price_change']) ?? 0.0),
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatPriceChange(num priceChange) {
    return priceChange == 0 || priceChange.toStringAsFixed(2) == "-0.00"
        ? "0.00%"
        : "${priceChange.toStringAsFixed(2)}%";
  }

  Color _getPriceChangeColor(num priceChange) {
    if (priceChange == 0 || priceChange.toStringAsFixed(2) == "-0.00") {
      return const Color(0xff5645F5);
    }
    return priceChange > 0 ? Colors.green.shade600 : Colors.red.shade800;
  }

  num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) {
      try {
        return num.parse(value);
      } catch (e) {
        debugPrint('Error parsing number from string: $value, error: $e');
        return null;
      }
    }
    return null;
  }

  @override
  CoinsViewModel viewModelBuilder(BuildContext context) => CoinsViewModel();

  @override
  void onViewModelReady(CoinsViewModel viewModel) {
    viewModel.init();
    super.onViewModelReady(viewModel);
  }
}
