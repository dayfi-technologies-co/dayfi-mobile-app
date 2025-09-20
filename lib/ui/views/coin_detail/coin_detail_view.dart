// coin_details_view.dart
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart';
import 'package:dayfi/ui/components/buttons/filled_btn_small.dart';
import 'package:dayfi/ui/components/buttons/outlined_btn.dart';
import 'package:flutter/cupertino.dart';
import 'package:dayfi/ui/common/amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:fl_chart/fl_chart.dart';
import 'coin_detail_viewmodel.dart';

class CoinDetailView extends StackedView<CoinDetailViewModel> {
  final String coinId;
  final String coinName;
  final dynamic coinPrice;
  final double priceChange;
  final dynamic marketCap;
  final dynamic popularity;

  const CoinDetailView({
    super.key,
    required this.coinId,
    required this.coinName,
    required this.coinPrice,
    required this.priceChange,
    required this.marketCap,
    required this.popularity,
  });

  @override
  Widget builder(
    BuildContext context,
    CoinDetailViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => viewModel.navigationService.back(),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff5645F5), // innit
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: FilledBtnSmall(
              textColor: Color(0xff5645F5), // innit
              backgroundColor: Colors.white,
              onPressed: () {},
              text: "Need Help?",
            ),
          ),
        ],
      ),
      body: viewModel.isBusy
          ? Center(
              child: CupertinoActivityIndicator(
                color: Color(0xff5645F5), // innit
              ),
            )
          : viewModel.hasError
              ? _buildErrorView(context, viewModel)
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, viewModel),
                      Center(
                          child: _buildTimeframeSelector(context, viewModel)),
                      _buildPriceChart(context, viewModel),
                      _buildFYI(context, viewModel),
                      _buildAboutSection(context, viewModel),
                      _buildMarketStats(context, viewModel),
                      // _buildResources(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  @override
  CoinDetailViewModel viewModelBuilder(BuildContext context) =>
      CoinDetailViewModel(
        coinId: coinId,
        initialName: coinName,
        initialPrice: coinPrice is double ? coinPrice : coinPrice,
        initialPriceChange: priceChange,
        initialMarketCap: marketCap is double ? marketCap : marketCap,
        initialPopularity: popularity is int ? popularity : popularity,
      );

  @override
  void onViewModelReady(CoinDetailViewModel viewModel) {
    viewModel.initialize();
  }

  Widget _buildErrorView(BuildContext context, CoinDetailViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.modelError.toString(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5645F5),
                foregroundColor: Color(0xff5645F5),
              ),
              onPressed: viewModel.retry,
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

  Widget _buildHeader(BuildContext context, CoinDetailViewModel viewModel) {
    final coin = viewModel.coinDetail;
    final initialPrice = viewModel.initialPrice;
    final priceChange = viewModel.initialPriceChange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                verticalSpace(10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${coin?.symbol.toUpperCase() ?? ''} ',
                      style: TextStyle(
                        fontFamily: 'Boldonse',
                        fontSize: 27.5,
                        height: 1.2,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2A0079),
                      ),
                    ),
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
                            image: coin?.imageUrl.toString() ?? '',
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
                  ],
                ),
                verticalSpace(24),
                Text(
                  "Current price",
                  style: TextStyle(
                    fontFamily: 'Boldonse',
                    fontSize: 16,
                    color: Color(0xFF302D53),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    height: 1.450,
                  ),
                  textAlign: TextAlign.center,
                ),
                // verticalSpace(4),
                Text(
                  "\$${AmountFormatter.formatDecimal(_parseNum(initialPrice) ?? 0.0)}",
                  style: GoogleFonts.roboto(
                    // fontFamily: 'Boldonse',
                    fontSize: 34,
                    color: _getPriceChangeColor(_parseNum(priceChange) ?? 0.0),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    height: 1.450,
                  ),
                  textAlign: TextAlign.center,
                ),
                verticalSpace(8),

                Text(
                  "${_formatPriceChange(_parseNum(priceChange) ?? 0.0)} / 24hrs",
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
              ],
            ),
          ),
        ],
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

  Widget _buildTimeframeSelector(
      BuildContext context, CoinDetailViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: viewModel.timeframes.map((timeframe) {
          final isSelected = viewModel.selectedTimeframe == timeframe;
          return InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => viewModel.setTimeframe(timeframe),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                    color: isSelected
                        ? const Color(0xff5645F5).withOpacity(.1)
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                height: 36,
                width: 36,
                child: Center(
                  child: Text(
                    timeframe,
                    style: TextStyle(
                      color: isSelected ? Color(0xff5645F5) : Color(0xff2A0079),
                      fontWeight: FontWeight.w600,
                      height: .1,
                      fontSize: 16,
                      letterSpacing: -.1,
                      fontFamily: "Karla",
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFYI(BuildContext context, CoinDetailViewModel viewModel) {
    return // Buy
        Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(),
          const SizedBox(),

          // Buy
          Expanded(
            child: _buildCircularActionButton(
              context,
              viewModel,
              'Buy',
              'assets/svgs/add-sign.svg',
              () => {
                // TODO: Replace with proper action
              },
            ),
          ),

          horizontalSpaceTiny,
          horizontalSpaceTiny,
          horizontalSpaceTiny,
          horizontalSpaceTiny,

          // Sell
          Expanded(
            child: _buildCircularActionButton(
              context,
              viewModel,
              'Sell',
              'assets/svgs/subtract-sign.svg',
              () => {
                // TODO: Replace with proper action
              },
            ),
          ),

          const SizedBox(),
          const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildCircularActionButton(
    BuildContext context,
    CoinDetailViewModel viewModel,
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
                  color: const Color(0xff2A0079),
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

  Widget _buildAboutSection(
      BuildContext context, CoinDetailViewModel viewModel) {
    final coin = viewModel.coinDetail;
    final description = coin?.description ?? 'No description available.';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            "About ${viewModel.initialName}",
            style: TextStyle(
              fontSize: 16,
              fontFamily: "SpaceGrotesk",
              color: Color(0xff2A0079),
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: viewModel.isDescriptionExpanded ? null : 3,
            overflow:
                viewModel.isDescriptionExpanded ? null : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              height: 1.6,
              fontFamily: 'Karla',
              letterSpacing: .1,
              color: Color(0xff304463),
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: viewModel.toggleDescriptionExpanded,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                viewModel.isDescriptionExpandedValue
                    ? "Hide".toUpperCase()
                    : 'See all'.toUpperCase(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.450,
                  fontFamily: 'Boldonse',
                  letterSpacing: .255,
                  color: Color(0xff5645F5), // innit
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStats(
    BuildContext context,
    CoinDetailViewModel viewModel,
  ) {
    final marketCap = viewModel.initialMarketCap;
    final priceChange = viewModel.initialPriceChange;
    final popularity = viewModel.initialPopularity;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Market stats",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "SpaceGrotesk",
                  color: Color(0xff2A0079),
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
            ],
          ),
          const SizedBox(height: 16),
          _marketStatItem(
            "Market Cap",
            "USD ${AmountFormatter.formatDecimal(num.parse((double.parse(marketCap) / 1e9).toStringAsFixed(1)))}B",
            "assets/svgs/bar_chart_4_bars_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
          ),
          _marketStatItem(
            "24h change",
            "${priceChange.toStringAsFixed(2)}%",
            "assets/svgs/avg_time_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
          ),
          _marketStatItem(
            "Popularity",
            "$popularity",
            "assets/svgs/local_fire_department_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
          ),
        ],
      ),
    );
  }

  Widget _marketStatItem(String label, String value, String icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: SvgPicture.asset(
              icon,
              height: 22,
              color: const Color(0xff5645F5), // innit
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              height: 1.6,
              fontFamily: 'Karla',
              letterSpacing: .1,
              color: Color(0xff2A0079),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              height: 1.6,
              fontFamily: 'Karla',
              letterSpacing: .1,
              color: Color(0xff304463),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildResources(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.all(18.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const SizedBox(height: 12),
  //         Text(
  //           "Resources",
  //           style: TextStyle(
  //             fontSize: 17.sp,
  //             fontWeight: FontWeight.w600,
  //             height: 1.2,
  //             fontFamily: 'Karla
  //             letterSpacing: 0.00,
  //             color: Color(0xff2A0079),
  //           ),
  //           textAlign: TextAlign.start,
  //         ),
  //         const SizedBox(height: 16),
  //         InkWell(
  //           onTap: () {
  //             // Handle whitepaper tap
  //           },
  //           child: const Row(
  //             children: [
  //               Icon(Icons.description_outlined, color: Color(0xFF6E3AA7)),
  //               SizedBox(width: 8),
  //               Text(
  //                 "WHITEPAPER",
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPriceChart(BuildContext context, CoinDetailViewModel viewModel) {
    final chartData = viewModel.chartData;

    if (chartData == null || chartData.spots.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("Chart data unavailable")),
      );
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        // color: Color.fromARGB(255, 249, 254, 255),
        // border: Border.all(
        //   color: Color.fromARGB(255, 26, 77, 104),
        // ),
      ),
      child: Stack(
        children: [
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(4.r),
          //   child: Image.asset(
          //     'assets/images/backgroud.png',
          //     fit: BoxFit.cover,
          //     color: Colors.orangeAccent,
          //     width: MediaQuery.of(context).size.width,
          //   ),
          // ),
          LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                ),
              ),
              // gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              // borderData: FlBorderData(
              //   show: true,
              //   border: Border.all(color: Colors.grey.withOpacity(0.3)),
              // ),
              lineBarsData: [
                LineChartBarData(
                  spots: chartData.spots,
                  isCurved: true,
                  color: const Color(0xFF2ECC71),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: const Color(0xFF2ECC71),
                      strokeWidth: 1,
                      strokeColor: Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2ECC71).withOpacity(0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              minY: chartData.minY * 0.98,
              maxY: chartData.maxY * 1.02,
            ),
          ),
        ],
      ),
    );
  }
}
