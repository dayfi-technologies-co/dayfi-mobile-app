import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading widgets for different components
class ShimmerWidgets {
  // ─────────────────────────────────────────────────────────────────────────────
  // BASE
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget shimmerEffect({
    required Widget child,
    required BuildContext context,
    Color? baseColor,
    Color? highlightColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor:
          baseColor ??
          (isDark
              ? Colors.grey[800]!.withOpacity(.35)
              : Colors.grey[300]!.withOpacity(.35)),
      highlightColor:
          highlightColor ??
          (isDark ? Colors.grey[700]! : Colors.grey[100]!.withOpacity(.35)),
      child: child,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PRIMITIVES  (used as building blocks everywhere)
  // ─────────────────────────────────────────────────────────────────────────────

  /// A filled circle.
  static Widget circle({required double size, BuildContext? context}) {
    return Builder(
      builder: (ctx) {
        final c = context ?? ctx;
        return shimmerEffect(
          context: c,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Theme.of(c).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  /// A filled rounded rectangle — also used for wallet chips.
  static Widget roundedRect({
    required double width,
    required double height,
    double radius = 12,
    BuildContext? context,
  }) {
    return Builder(
      builder: (ctx) {
        final c = context ?? ctx;
        return shimmerEffect(
          context: c,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Theme.of(c).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }

  /// A single horizontal line of text-placeholder height.
  static Widget line({
    required double width,
    required double height,
    BuildContext? context,
    double radius = 4,
  }) {
    return Builder(
      builder: (ctx) {
        final c = context ?? ctx;
        return shimmerEffect(
          context: c,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Theme.of(c).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // WALLET CHIPS  (horizontal scroll on HomeView)
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget walletChipShimmer(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    final fg = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        width: 130,
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Flag circle placeholder
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            // Balance + currency placeholders
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 13,
                  decoration: BoxDecoration(
                    color: fg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 36,
                  height: 10,
                  decoration: BoxDecoration(
                    color: fg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget walletChipsRowShimmer(
    BuildContext context, {
    int itemCount = 4,
  }) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, _) => walletChipShimmer(ctx),
      ),
    );
  }

  /// Single home promo banner — matches [_PromoBanner] on HomePromoBannersRow.
  static Widget homePromoBannerTileShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: SizedBox(
          height: 118,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: shimmerEffect(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container(
                  //   width: 40,
                  //   height: 40,
                  //   decoration: BoxDecoration(
                  //     color: shimmerColor,
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  // ),
                  // const Spacer(),
                  // Container(
                  //   width: double.infinity,
                  //   height: 15,
                  //   decoration: BoxDecoration(
                  //     color: shimmerColor,
                  //     borderRadius: BorderRadius.circular(4),
                  //   ),
                  // ),
                  // const SizedBox(height: 4),
                  // Container(
                  //   width: 72,
                  //   height: 12,
                  //   decoration: BoxDecoration(
                  //     color: shimmerColor,
                  //     borderRadius: BorderRadius.circular(4),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Tap to Pay + Earn row above Assets on Home.
  static Widget homePromoBannersRowShimmer(BuildContext context) {
    return Row(
      children: [
        Expanded(child: homePromoBannerTileShimmer(context)),
        const SizedBox(width: 10),
        Expanded(child: homePromoBannerTileShimmer(context)),
      ],
    );
  }

  /// Single home Assets row — matches [_buildWalletRow] on HomeView.
  static Widget walletAssetRowShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Stacked Assets list on Home — separate cards with 8px gaps, no dividers.
  static Widget walletAssetListShimmer(
    BuildContext context, {
    int itemCount = 4,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < itemCount; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          walletAssetRowShimmer(context),
        ],
      ],
    );
  }

  /// Promo banners + Assets list — matches Home assets block while loading.
  static Widget homeAssetsSectionShimmer(
    BuildContext context, {
    int assetRowCount = 4,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        homePromoBannersRowShimmer(context),
        const SizedBox(height: 32),
        walletAssetListShimmer(context, itemCount: assetRowCount),
      ],
    );
  }

  /// DayEarn home — balance card, CTA, list area (container-only shimmers).
  static Widget dayEarnMainShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          cardShimmer(context, height: 132, borderRadius: 16),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: cardShimmer(context, height: 48, borderRadius: 38),
          ),
          const SizedBox(height: 20),
          cardShimmer(context, height: 168, borderRadius: 14),
        ],
      ),
    );
  }

  /// DayBudget dashboard — summary + schedule rows (container-only shimmers).
  static Widget dayBudgetMainShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          cardShimmer(context, height: 48, borderRadius: 8),
          const SizedBox(height: 24),
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            cardShimmer(context, height: 56, borderRadius: 14),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PAY BILLS — category grid (PayView)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Single Pay category card — matches [_PayCategoryTile] on PayView.
  static Widget payCategoryTileShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 72,
              height: 12,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2-column Pay category grid — matches [_PayCategoryGroup] on PayView.
  static Widget payCategoryGridShimmer(
    BuildContext context, {
    int itemCount = 6,
    int crossAxisCount = 2,
    double crossAxisSpacing = 8,
    double mainAxisSpacing = 8,
    double childAspectRatio = 1.6,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => payCategoryTileShimmer(context),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // QUICK SEND CHIPS  (horizontal scroll on HomeView)
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget quickSendChipShimmer(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    final fg = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        height: 44,
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Container(
              width: 52,
              height: 11,
              decoration: BoxDecoration(
                color: fg,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget quickSendListShimmer(
    BuildContext context, {
    int itemCount = 5,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, _) => quickSendChipShimmer(ctx),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SEND AGAIN CHIPS  (horizontal scroll on HomeView)
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget sendAgainChipShimmer(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    final fg = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar stack placeholder
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: fg,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Name + sub
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 13,
                  decoration: BoxDecoration(
                    color: fg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 72,
                  height: 10,
                  decoration: BoxDecoration(
                    color: fg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget sendAgainListShimmer(
    BuildContext context, {
    int itemCount = 4,
  }) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, _) => sendAgainChipShimmer(ctx),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TRANSACTION LIST  (grouped by date — WalletDetailView style)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Single transaction row shimmer — matches the real _buildTxRow layout.
  static Widget transactionItemShimmer(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    final fg = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            // Direction icon circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            // Title + date lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: fg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 100,
                    height: 11,
                    decoration: BoxDecoration(
                      color: fg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Amount + status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 72,
                  height: 14,
                  decoration: BoxDecoration(
                    color: fg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 52,
                  height: 18,
                  decoration: BoxDecoration(
                    color: fg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A single grouped section shimmer (date header + N rows inside a card).
  static Widget transactionSectionShimmer(
    BuildContext context, {
    int rowCount = 3,
  }) {
    final bg = Theme.of(context).colorScheme.surface;
    final fg = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date label placeholder
        shimmerEffect(
          context: context,
          child: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Container(
              width: 80,
              height: 11,
              decoration: BoxDecoration(
                color: fg,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        // Card containing rows
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: List.generate(rowCount, (i) {
              return Column(
                children: [
                  transactionItemShimmer(context),
                  if (i < rowCount - 1)
                    Divider(
                      height: 1,
                      indent: 60,
                      color: Theme.of(context).dividerColor.withOpacity(0.06),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  /// Full transaction list shimmer — renders multiple grouped sections.
  static Widget transactionListShimmer(
    BuildContext context, {
    int itemCount = 5,
  }) {
    // Spread itemCount rows across 2 fake sections
    final section1 = (itemCount / 2).ceil();
    final section2 = itemCount - section1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        transactionSectionShimmer(context, rowCount: section1),
        if (section2 > 0)
          transactionSectionShimmer(context, rowCount: section2),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // WALLET BALANCE (HomeView top area)
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget walletBalanceShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 28,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // RECIPIENT / BENEFICIARY LIST
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget recipientItemShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 4, right: 4),
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 140,
                    height: 11,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 68,
              height: 30,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget recipientListShimmer(
    BuildContext context, {
    int itemCount = 5,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? const EdgeInsets.only(bottom: 112),
      itemCount: itemCount,
      itemBuilder: (context, _) => recipientItemShimmer(context),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // COUNTRY / CURRENCY SELECTION
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget countryItemShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: shimmerColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Container(
              width: 48,
              height: 38,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget countryListShimmer(BuildContext context, {int itemCount = 10}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemCount,
      itemBuilder: (context, _) => countryItemShimmer(context),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DELIVERY METHOD
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget deliveryMethodCardShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 14,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 11,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget deliveryMethodListShimmer(
    BuildContext context, {
    int itemCount = 4,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, _) => deliveryMethodCardShimmer(context),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PROFILE CARD
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget profileCardShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: shimmerColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 150,
              height: 18,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 13,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GENERIC HELPERS
  // ─────────────────────────────────────────────────────────────────────────────

  static Widget cardShimmer(
    BuildContext context, {
    double? width,
    double? height,
    double? borderRadius,
  }) {
    return shimmerEffect(
      context: context,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
    );
  }

  static Widget textShimmer(
    BuildContext context, {
    double? width,
    double? height,
    double? borderRadius,
  }) {
    return shimmerEffect(
      context: context,
      child: Container(
        width: width ?? 100,
        height: height ?? 14,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius ?? 4),
        ),
      ),
    );
  }

  static Widget gridShimmer(
    BuildContext context, {
    int itemCount = 4,
    int crossAxisCount = 2,
    double childAspectRatio = 1.5,
  }) {
    return shimmerEffect(
      context: context,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: itemCount,
        itemBuilder:
            (context, _) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
      ),
    );
  }
}
