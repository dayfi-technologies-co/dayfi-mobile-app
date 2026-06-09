import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared layout pieces for Add money tabs — aligned with lock/transaction detail views.
class ReceiveTabScroll extends StatelessWidget {
  final List<Widget> children;

  const ReceiveTabScroll({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 18,
                16,
                isWide ? 24 : 18,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReceiveHeroHeader extends StatelessWidget {
  final Widget icon;
  final String headline;
  final String title;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;

  const ReceiveHeroHeader({
    super.key,
    required this.icon,
    required this.headline,
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final statusColor = badgeColor ?? AppColors.primary400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'FunnelDisplay',
                fontSize: 24,
                letterSpacing: -.25,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 40, height: 40, child: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.bodyLarge.copyWith(
                            fontFamily: 'Chirp',
                            fontSize: 16,
                            letterSpacing: -.25,
                            fontWeight: FontWeight.w500,
                            color: onSurface,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontFamily: 'Chirp',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.bodyMedium.copyWith(
                        fontFamily: 'Chirp',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.4,
                        height: 1.45,
                        color: onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ReceiveStatusCard extends StatelessWidget {
  final String message;
  final bool isReady;
  final String? dateLabel;

  const ReceiveStatusCard({
    super.key,
    required this.message,
    this.isReady = true,
    this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor =
        isReady ? AppColors.primary400 : Theme.of(context).colorScheme.onSurface.withOpacity(0.35);
    final day = dateLabel ??
        [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ][DateTime.now().weekday - 1];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isReady
                  ? Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 12.5,
                    letterSpacing: -.25,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 14,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiveSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ReceiveSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              letterSpacing: -.25,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class ReceiveDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  final bool truncate;
  final Color? valueColor;

  const ReceiveDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.copyable = false,
    this.truncate = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final display = truncate && value.length > 16
        ? '${value.substring(0, 8)}…${value.substring(value.length - 6)}'
        : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: 'Chirp',
                fontSize: 14,
                letterSpacing: -.4,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    display,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 16,
                      letterSpacing: -.4,
                      fontWeight: FontWeight.w500,
                      color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                if (copyable && value.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Copied',
                            style: TextStyle(fontFamily: 'Chirp'),
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiveAccountIcon extends StatelessWidget {
  final String overlayAsset;
  final Color color;

  const ReceiveAccountIcon({
    super.key,
    required this.overlayAsset,
    this.color = AppColors.primary400,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/svgs/account.svg',
          height: 40,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        Center(
          child: SvgPicture.asset(
            overlayAsset,
            height: 22,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}
