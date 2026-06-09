import 'package:dayfi/common/widgets/dayfi_circle_check_icon.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/constants/username_copy.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/common/utils/kyc_flow_navigation.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Send USDC (Stellar or Ethereum) or USDT (Ethereum only) — currency then network.
class DigitalDollarSendView extends ConsumerStatefulWidget {
  const DigitalDollarSendView({super.key});

  @override
  ConsumerState<DigitalDollarSendView> createState() =>
      _DigitalDollarSendViewState();
}

class _DigitalDollarSendViewState extends ConsumerState<DigitalDollarSendView> {
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  String _currencyCode = 'USDC';
  String _networkKey = 'stellar';

  static const _usdcSvg = 'assets/icons/svgs/usd-coin-usdc-logo.svg';
  static const _usdtSvg = 'assets/icons/svgs/tether-usdt-logo.svg';

  List<String> get _networksForCurrency {
    if (_currencyCode == 'USDT') return const ['ethereum'];
    return const ['stellar', 'ethereum'];
  }

  void _setCurrency(String code) {
    setState(() {
      _currencyCode = code;
      if (code == 'USDT') {
        _networkKey = 'ethereum';
      } else if (!_networksForCurrency.contains(_networkKey)) {
        _networkKey = 'stellar';
      }
    });
  }

  String _settlementHint() {
    if (_currencyCode == 'USDT') return 'USDT on Ethereum';
    if (_networkKey == 'ethereum') return 'USDC on Ethereum';
    return 'USDC on Stellar';
  }

  Future<void> _openCurrencyPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    'Currency',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Chirp',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              ListTile(
                leading: SvgPicture.asset(_usdcSvg, height: 28, width: 28),
                title: const Text('USDC'),
                subtitle: const Text('Stellar or Ethereum'),
                trailing:
                    _currencyCode == 'USDC'
                        ? DayfiCircleCheckIcon(
                          color: AppColors.purple500ForTheme(ctx),
                        )
                        : null,
                onTap: () {
                  _setCurrency('USDC');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: SvgPicture.asset(_usdtSvg, height: 28, width: 28),
                title: const Text('USDT'),
                subtitle: const Text('Ethereum only'),
                trailing:
                    _currencyCode == 'USDT'
                        ? DayfiCircleCheckIcon(
                          color: AppColors.purple500ForTheme(ctx),
                        )
                        : null,
                onTap: () {
                  _setCurrency('USDT');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openNetworkPicker() async {
    final nets = _networksForCurrency;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    'Network',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Chirp',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              ...nets.map((key) {
                final title = key == 'stellar' ? 'Stellar' : 'Ethereum';
                return ListTile(
                  leading:
                      key == 'stellar'
                          ? SvgPicture.asset(
                            'assets/icons/svgs/stellar-xlm-logo.svg',
                            height: 28,
                            width: 28,
                          )
                          : Icon(
                            Icons.currency_bitcoin,
                            size: 28,
                            color: Theme.of(ctx).colorScheme.onSurface,
                          ),
                  title: Text(title),
                  trailing:
                      _networkKey == key
                          ? DayfiCircleCheckIcon(
                            color: AppColors.purple500ForTheme(ctx),
                          )
                          : null,
                  onTap: () {
                    setState(() => _networkKey = key);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerChip({
    required String label,
    required Widget? leading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: leading != null ? 8 : 14,
          vertical: leading != null ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 8)],
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Chirp',
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _currencyLeading() {
    if (_currencyCode == 'USDT') {
      return SvgPicture.asset(_usdtSvg, height: 22, width: 22);
    }
    return SvgPicture.asset(_usdcSvg, height: 22, width: 22);
  }

  Widget _networkLeading() {
    if (_networkKey == 'stellar') {
      return SvgPicture.asset(
        'assets/icons/svgs/stellar-xlm-logo.svg',
        height: 22,
        width: 22,
      );
    }
    return Icon(
      Icons.currency_bitcoin,
      size: 22,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  bool _canContinue() {
    final to = _toController.text.trim();
    final amt = double.tryParse(_amountController.text.trim());
    return to.length >= 3 && amt != null && amt > 0;
  }

  void _onContinue() {
    final profileState = ref.read(profileViewModelProvider);
    final user = profileState.user;
    if (TierUtils.getCurrentTierLevel(user) == 1) {
      KycFlowNavigation.startUpgrade(
        context,
        ref: ref,
        showBackButton: true,
        showIntro: false,
      );
      return;
    }

    final amount = _amountController.text.trim();
    if (!_canContinue()) {
      TopSnackbar.show(
        context,
        message: 'Enter a valid recipient and amount',
        isError: true,
      );
      return;
    }

    final vm = ref.read(sendViewModelProvider.notifier);
    vm.setSendCurrencyForStablecoinAmountStep(_currencyCode);
    vm.updateSendAmount(amount);

    Navigator.pushNamed(context, AppRoute.cryptoChannelsView);
  }

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final networkLabel = _networkKey == 'stellar' ? 'Stellar' : 'Ethereum';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0.5,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Text(
          'Via digital dollar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                UsernameCopy.recipientOrAddress,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'Chirp',
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _toController,
                onChanged: (_) => setState(() {}),
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'Address or @username',
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _pickerChip(
                      label: _currencyCode,
                      leading: _currencyLeading(),
                      onTap: _openCurrencyPicker,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _pickerChip(
                      label: networkLabel,
                      leading: _networkLeading(),
                      onTap: _openNetworkPicker,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 60.ms),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _settlementHint(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.45),
                    fontFamily: 'Chirp',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Amount',
                  suffixText: _currencyCode,
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ).animate().fadeIn(delay: 90.ms),
              const SizedBox(height: 16),
              TextField(
                controller: _memoController,
                maxLength: 28,
                decoration: InputDecoration(
                  hintText: 'Memo (optional)',
                  counterText: '',
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ).animate().fadeIn(delay: 110.ms),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _canContinue() ? _onContinue : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: AppTypography.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontFamily: 'Chirp',
                  ),
                ),
              ).animate().fadeIn(delay: 130.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
