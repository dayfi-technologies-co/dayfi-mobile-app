import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/Share_plus.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/models/payment_response.dart' as payment;

class SendPaymentSuccessView extends ConsumerStatefulWidget {
  final Map<String, dynamic> recipientData;
  final Map<String, dynamic> selectedData;
  final Map<String, dynamic> paymentData;
  final payment.PaymentData? collectionData;
  final String? transactionId;

  const SendPaymentSuccessView({
    super.key,
    required this.recipientData,
    required this.selectedData,
    required this.paymentData,
    this.collectionData,
    this.transactionId,
  });

  @override
  ConsumerState<SendPaymentSuccessView> createState() =>
      _SendPaymentSuccessViewState();
}

class _SendPaymentSuccessViewState extends ConsumerState<SendPaymentSuccessView>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  WalletTransaction? _transaction;
  late AnimationController _successAnimationController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _amountSlideAnimation;
  late Animation<double> _buttonsFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize success animation controller
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create staggered animations for success view
    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _amountSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _buttonsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Show loading for 4 seconds, then fetch transaction and show success
    Future.delayed(const Duration(seconds: 4), () async {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        await _fetchTransaction();
        // Start success animations
        _successAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _successAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransaction() async {
    if (widget.transactionId == null) return;

    try {
      // Fetch transactions and find the specific one
      final transactionsNotifier = ref.read(transactionsProvider.notifier);
      await transactionsNotifier.loadTransactions();
      final transactions = ref.read(transactionsProvider).transactions;

      final matching = transactions.where(
        (txn) => txn.id == widget.transactionId,
      );
      _transaction = matching.isNotEmpty ? matching.first : null;

      if (_transaction != null) {
        AppLogger.info(
          'Transaction fetched successfully: ${widget.transactionId}',
        );
      } else {
        AppLogger.error('Transaction not found: ${widget.transactionId}');
      }
    } catch (e) {
      AppLogger.error('Failed to fetch transaction: $e');
    }
  }

  String _getNotificationProvider() {
    final method =
        widget.selectedData['recipientDeliveryMethod']?.toLowerCase();
    if (method == 'bank' || method == 'p2p') {
      return 'the bank';
    } else if (method == 'mobile_money' || method == 'momo') {
      return 'the mobile money provider';
    } else if (method == 'dayfi_tag') {
      return 'Dayfi';
    }
    return 'the provider';
  }

  void _shareReceipt() {
    final sendState = ref.read(sendViewModelProvider);
    final amount = double.tryParse(sendState.sendAmount.toString()) ?? 0.0;
    final recipient = widget.recipientData['name'] ?? 'Recipient';
    final txnId = widget.transactionId ?? 'N/A';
    final date = DateTime.now().toString();

    final details = '''
Transfer Successful!
Amount: ₦${amount.toStringAsFixed(2)}
Recipient: $recipient
Transaction ID: $txnId
Date: $date
''';

    Share.share(details, subject: 'Transfer Receipt');
  }

  void _done() {
    // Navigate to main view index 1 (Transactions tab)
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoute.mainView,
      (Route route) => false,
      arguments: 1,
    );
  }

  // Helper method to get currency symbol from currency code
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'RWF':
        return 'RWF ';
      case 'GHS':
        return 'GH₵';
      case 'KES':
        return 'KSh';
      case 'UGX':
        return 'USh';
      case 'TZS':
        return 'TSh';
      case 'ZAR':
        return 'R';
      default:
        return '$currencyCode ';
    }
  }

  // Helper method to format amount with commas
  String _formatAmount(double amount) {
    // Format with 2 decimal places and add thousand separators
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$integerPart.${parts[1]}';
  }
  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);
    final amount = double.tryParse(sendState.sendAmount.toString()) ?? 0.0;
    final receiveAmount = double.tryParse(sendState.receiverAmount.toString()) ?? 0.0;
    final currency = sendState.sendCurrency;
    final receiveCurrency = sendState.receiverCurrency;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.purple900,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 600;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 500 : double.infinity,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 24 : 18,
                      vertical: 8,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      switchInCurve: Curves.easeInOutCubic,
                      switchOutCurve: Curves.easeInOutCubic,
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        final fadeAnimation = Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                        );

                        final slideAnimation = Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        );

                        final scaleAnimation = Tween<double>(
                          begin: 0.95,
                          end: 1.0,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                        );

                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: SlideTransition(
                            position: slideAnimation,
                            child: ScaleTransition(
                              scale: scaleAnimation,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child:
                          _isLoading
                              ? _buildLoadingView()
                              : _buildSuccessView(amount, currency, receiveAmount, receiveCurrency),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: MediaQuery.of(context).size.width),
        SizedBox(
          width: 32,
          height: 32,
          child: LoadingAnimationWidget.horizontalRotatingDots(
            color: Colors.white,
            size: 32,
          ),
        ),
        SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'Securely processing your transaction',
            style: AppTypography.bodyLarge.copyWith(
              fontFamily: 'Chirp',
              fontSize: 16,
              color: AppColors.neutral0.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(double amount, String currency, double receiveAmount, String receiveCurrency) {
    final sendSymbol = _getCurrencySymbol(currency);
    final receiveSymbol = _getCurrencySymbol(receiveCurrency);
    final isSameCurrency = currency == receiveCurrency;
    
    return Column(
      key: const ValueKey('success'),
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(height: 12),
        Column(
          children: [
            ScaleTransition(
              scale: _iconScaleAnimation,
              child: SizedBox(
                width: 132,
                height: 132,
                child: SvgPicture.asset('assets/icons/svgs/successs.svg'),
              ),
            ),
            SizedBox(height: 32),
            FadeTransition(
              opacity: _textFadeAnimation,
              child: Text(
                'Transfer Successful',
                style: AppTypography.headlineLarge.copyWith(
                  fontFamily: 'FunnelDisplay',
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral0,
                  letterSpacing: -0.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            SlideTransition(
              position: _amountSlideAnimation,
              child: FadeTransition(
                opacity: _textFadeAnimation,
                child: Column(
                  children: [
                    // You sent
                    Text(
                      'You sent',
                      style: AppTypography.bodyMedium.copyWith(
                        fontFamily: 'Chirp',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutral0.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$sendSymbol${_formatAmount(amount)}',
                      style: AppTypography.headlineLarge.copyWith(
                        fontFamily: 'FunnelDisplay',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Show recipient amount only if different currency
                    if (!isSameCurrency && receiveAmount > 0) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.neutral0.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Recipient gets',
                              style: AppTypography.bodyMedium.copyWith(
                                fontFamily: 'Chirp',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.neutral0.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '$receiveSymbol${_formatAmount(receiveAmount)}',
                              style: AppTypography.headlineLarge.copyWith(
                                fontFamily: 'FunnelDisplay',
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            FadeTransition(
              opacity: _textFadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'The recipient account is expected to be credited within 5 minutes, subject to notification by ${_getNotificationProvider()}',
                  style: AppTypography.bodyLarge.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 16,
                    color: AppColors.neutral0.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        FadeTransition(
          opacity: _buttonsFadeAnimation,
          child: Column(
            children: [
              SecondaryButton(
                text: 'Share Receipt',
                onPressed: _shareReceipt,
                backgroundColor: Colors.white,
                textColor: AppColors.purple500,
                borderColor: AppColors.neutral0,
                borderRadius: 38,
                height: 48.00000,
                width: double.infinity,
                fullWidth: true,
                fontFamily: 'Chirp',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.8,
              ),
              // SizedBox(height: 12),
              // SecondaryButton(
              //   text: 'View Details',
              //   onPressed: _viewDetails,
              //   backgroundColor: Colors.transparent,
              //   textColor: AppColors.neutral0,
              //   borderColor: AppColors.neutral0,
              //   borderRadius: 38,
              //   height: 48.00000,
              //   width: double.infinity,
              //   fullWidth: true,
              //   fontFamily: 'Chirp',
              //   fontSize: 18,
              //   fontWeight: FontWeight.w600,
              //   letterSpacing: -0.8,
              // ),
              SizedBox(height: 12),
              SecondaryButton(
                text: 'View Transactions',
                onPressed: _done,
                backgroundColor: Colors.transparent,
                textColor: AppColors.neutral0,
                borderColor: AppColors.neutral0,
                borderRadius: 38,
                height: 48.00000,
                width: double.infinity,
                fullWidth: true,
                fontFamily: 'Chirp',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
