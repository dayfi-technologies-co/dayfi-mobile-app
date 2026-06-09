import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TransactionSuccessDetail {
  final String label;
  final String value;

  const TransactionSuccessDetail({required this.label, required this.value});
}

/// Shared success screen after bill pay, swap, invest, send, etc.
class TransactionSuccessView extends StatefulWidget {
  final String headline;
  final String title;
  final String? amountText;
  final String? subtitle;
  final List<TransactionSuccessDetail> details;
  final String doneLabel;
  final VoidCallback? onDone;
  final int? mainTabIndex;

  const TransactionSuccessView({
    super.key,
    required this.headline,
    required this.title,
    this.amountText,
    this.subtitle,
    this.details = const [],
    this.doneLabel = 'Done',
    this.onDone,
    this.mainTabIndex,
  });

  @override
  State<TransactionSuccessView> createState() => _TransactionSuccessViewState();
}

class _TransactionSuccessViewState extends State<TransactionSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _done() {
    if (widget.onDone != null) {
      widget.onDone!();
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoute.mainView,
      (_) => false,
      arguments: widget.mainTabIndex ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.purple900,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: FadeTransition(
              opacity: curve,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(curve),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.6, end: 1).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/svgs/circle-check.svg',
                        height: 72,
                        color: AppColors.success500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.headline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'FunnelDisplay',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    if (widget.amountText != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.amountText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'FunnelDisplay',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          widget.subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ],
                    if (widget.details.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children:
                              widget.details
                                  .map(
                                    (d) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              d.label,
                                              style: TextStyle(
                                                fontFamily: 'Chirp',
                                                fontSize: 13,
                                                color: Colors.white.withValues(
                                                  alpha: 0.55,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              d.value,
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                fontFamily: 'Chirp',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ],
                    const Spacer(flex: 3),
              PrimaryButton(
                        text: widget.doneLabel,
                        onPressed: _done,
                        fullWidth: true,
                        borderRadius: 38,
                        height: 48,
                        backgroundColor: AppColors.purple500,
                        textColor: AppColors.neutral0,
                        fontFamily: 'Chirp',
                        fontSize: 18,
                        letterSpacing: -.2,
                      ),
                    
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
