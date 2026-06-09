import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Enter amount step for on-chain crypto sends (after Add Recipient).
class WalletCryptoAmountView extends StatefulWidget {
  final Map<String, dynamic> draft;

  const WalletCryptoAmountView({super.key, required this.draft});

  @override
  State<WalletCryptoAmountView> createState() => _WalletCryptoAmountViewState();
}

class _WalletCryptoAmountViewState extends State<WalletCryptoAmountView> {
  final _amountController = TextEditingController();
  bool _balancesLoading = true;
  String? _amountError;
  Map<String, dynamic> _balances = {
    'stellar': <String, dynamic>{},
    'ethereum': <String, dynamic>{},
  };

  String get _asset => widget.draft['asset']?.toString() ?? 'USDC';
  String get _network => widget.draft['network']?.toString() ?? 'stellar';
  String get _to => widget.draft['to']?.toString() ?? '';

  String get _displayCurrency {
    switch (_asset.toUpperCase()) {
      case 'EURC':
        return 'EUR';
      default:
        return 'USD';
    }
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validateAmount);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBalances());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBalances() async {
    setState(() => _balancesLoading = true);
    try {
      final b = await walletService.fetchCryptoBalances();
      if (mounted) setState(() => _balances = b);
    } catch (_) {
      /* show zero balances */
    } finally {
      if (mounted) setState(() => _balancesLoading = false);
    }
  }

  double _availableBalance() {
    final bucket = _network == 'ethereum' ? 'ethereum' : 'stellar';
    final map = _balances[bucket];
    if (map is! Map) return 0;
    final raw = map[_asset]?.toString() ?? '0';
    var bal = double.tryParse(raw) ?? 0;
    if (_network == 'stellar' && _asset == 'XLM') {
      bal = (bal - 2.0).clamp(0.0, double.infinity);
    }
    if (_network == 'ethereum') {
      bal = (bal - 0.0001).clamp(0.0, double.infinity);
    }
    return bal;
  }

  void _validateAmount() {
    final amount = double.tryParse(_amountController.text.trim());
    final available = _availableBalance();
    setState(() {
      if (amount == null || _amountController.text.trim().isEmpty) {
        _amountError = null;
      } else if (amount <= 0) {
        _amountError = 'Amount must be greater than 0';
      } else if (amount > available + 0.000001) {
        _amountError = 'Insufficient on-chain balance';
      } else {
        _amountError = null;
      }
    });
  }

  bool get _canContinue {
    if (_amountError != null) return false;
    final amount = double.tryParse(_amountController.text.trim());
    return amount != null && amount > 0;
  }

  void _onContinue() {
    HapticHelper.mediumImpact();
    final amount = _amountController.text.trim();
    Navigator.pushNamed(
      context,
      AppRoute.walletCryptoSendReviewView,
      arguments: {
        'draft': {
          ...widget.draft,
          'amount': amount,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = _availableBalance();
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final recipientLabel = RecipientHistoryHelper.truncateAddress(_to);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: .5,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 72,
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => Navigator.pop(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/svgs/notificationn.svg',
                height: 40,
                color: Theme.of(context).colorScheme.surface,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: onSurface,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          'Enter Amount',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Sending $_displayCurrency to $recipientLabel on ${_network == 'ethereum' ? 'Ethereum' : 'Stellar'}.',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 14,
                    color: onSurface.withOpacity(0.55),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              CustomTextField(
                label: 'Amount',
                hintText: '0.00',
                controller: _amountController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                formatter: FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ),
              const SizedBox(height: 6),
              Center(
                child: _balancesLoading
                    ? const DayfiLoadingCenter()
                    : InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        _amountController.text = available.toStringAsFixed(2);
                        _validateAmount();
                      },
                      child: Text(
                        'Available: ${available.toStringAsFixed(2)} $_displayCurrency',
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 12.5,
                          color: onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
              ),
              if (_amountError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    _amountError!,
                    style: const TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 12.5,
                      color: AppColors.orange500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: PrimaryButton(
                  text: 'Review Transfer',
                  onPressed: _canContinue ? _onContinue : null,
                  fullWidth: true,
                  borderRadius: 40,
                  height: 48,
                  backgroundColor: AppColors.purple500ForTheme(context),
                  textColor: AppColors.neutral0,
                  fontFamily: 'Chirp',
                  letterSpacing: -.7,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
