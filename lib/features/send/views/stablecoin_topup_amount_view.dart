import 'package:dayfi/common/utils/number_formatter.dart';
import 'package:dayfi/common/utils/string_utils.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/common/utils/kyc_flow_navigation.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Amount entry before crypto channel / network selection (stablecoin / YC flow).
class StablecoinTopupAmountView extends ConsumerStatefulWidget {
  const StablecoinTopupAmountView({super.key, this.routeArgs = const {}});

  /// From [AppRoute.stablecoinTopupAmountView] `arguments`, e.g. XLM reserve prefill.
  final Map<String, dynamic> routeArgs;

  @override
  ConsumerState<StablecoinTopupAmountView> createState() =>
      _StablecoinTopupAmountViewState();
}

class _StablecoinTopupAmountViewState
    extends ConsumerState<StablecoinTopupAmountView> {
  static const double _xlmReserveMinimum = 1.5;

  late final TextEditingController _amountController;
  final FocusNode _amountFocus = FocusNode();
  String _amountError = '';
  String? _previousSendCurrency;
  bool _didCurrencyOverride = false;
  bool _leftViaContinue = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final vm = ref.read(sendViewModelProvider.notifier);
      final sendState = ref.read(sendViewModelProvider);

      final entryCurrency =
          (widget.routeArgs['amountEntryCurrency'] as String?)?.trim();
      if (entryCurrency != null && entryCurrency.isNotEmpty) {
        _previousSendCurrency = sendState.sendCurrency;
        _didCurrencyOverride = true;
        vm.setSendCurrencyForStablecoinAmountStep(entryCurrency);
        vm.updateSendAmount('');
      }

      final prefillRaw = widget.routeArgs['prefillAmount'] as String?;
      final prefill =
          prefillRaw != null && prefillRaw.trim().isNotEmpty
              ? prefillRaw.trim()
              : null;

      if (prefill != null) {
        _amountController.text = NumberFormatterUtils.addCommas(prefill);
      } else {
        final sendAmount = ref.read(sendViewModelProvider).sendAmount;
        if (sendAmount.isNotEmpty) {
          _amountController.text = NumberFormatterUtils.addCommas(sendAmount);
        }
      }

      _validateAmount(_amountController.text);
    });
  }

  @override
  void dispose() {
    if (_didCurrencyOverride &&
        _previousSendCurrency != null &&
        !_leftViaContinue) {
      ref
          .read(sendViewModelProvider.notifier)
          .restoreSendCurrencyAfterStablecoinAmountStep(_previousSendCurrency!);
    }
    _amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _validateAmount(String value) {
    final sendState = ref.read(sendViewModelProvider);
    final viewModel = ref.read(sendViewModelProvider.notifier);
    final currency = sendState.sendCurrency;

    setState(() {
      _amountError = '';

      if (value.isEmpty) {
        _amountError = 'Please enter an amount';
        return;
      }

      final cleanValue = NumberFormatterUtils.removeCommas(value);
      final amount = double.tryParse(cleanValue);

      if (amount == null || amount <= 0) {
        _amountError = 'Please enter a valid amount';
        return;
      }

      if (currency == 'NGN') {
        const double minAmount = 500;
        if (amount < minAmount) {
          _amountError = 'Amount must be at least 500 NGN';
          return;
        }
        const double maxAmount = 5000000;
        if (amount > maxAmount) {
          _amountError = 'Amount must be less than 5000000 NGN';
          return;
        }
      }

      if (widget.routeArgs['enforceXlmMinAmount'] == true && currency == 'XLM') {
        if (amount < _xlmReserveMinimum) {
          _amountError =
              'Use at least $_xlmReserveMinimum XLM for Stellar reserve and fees';
          return;
        }
      }

      final minLimit = viewModel.sendMinimumLimit;
      if (minLimit != null && amount < minLimit) {
        final minAmountFormatted =
            StringUtils.formatCurrency(
              minLimit.toStringAsFixed(2),
              currency,
            ).split('.')[0];
        _amountError = 'Minimum amount is $minAmountFormatted';
      }
    });
  }

  bool _isAmountValid() {
    final sendState = ref.read(sendViewModelProvider);
    final viewModel = ref.read(sendViewModelProvider.notifier);
    final currency = sendState.sendCurrency;

    if (_amountController.text.isEmpty) return false;

    final cleanValue = NumberFormatterUtils.removeCommas(
      _amountController.text,
    );
    final amount = double.tryParse(cleanValue);

    if (amount == null || amount <= 0) return false;

    if (currency == 'NGN') {
      if (amount < 500 || amount > 5000000) return false;
    }

    if (widget.routeArgs['enforceXlmMinAmount'] == true && currency == 'XLM') {
      if (amount < _xlmReserveMinimum) return false;
    }

    final minLimit = viewModel.sendMinimumLimit;
    if (minLimit != null && amount < minLimit) return false;

    return true;
  }

  void _onContinue() {
    FocusManager.instance.primaryFocus?.unfocus();

    final profileState = ref.read(profileViewModelProvider);
    final user = profileState.user;
    final userTierLevel = TierUtils.getCurrentTierLevel(user);
    if (userTierLevel == 1) {
      KycFlowNavigation.startUpgrade(
        context,
        ref: ref,
        showBackButton: true,
        showIntro: false,
      );
      return;
    }

    final cleanValue = NumberFormatterUtils.removeCommas(
      _amountController.text,
    );
    ref.read(sendViewModelProvider.notifier).updateSendAmount(cleanValue);
    _leftViaContinue = true;

    Navigator.pushNamed(context, AppRoute.cryptoChannelsView);
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);
    final isAmountValid = _isAmountValid();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: .5,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leadingWidth: 72,
          leading: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
              FocusScope.of(context).unfocus();
            },
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/svgs/notificationn.svg',
                  height: 40,
                  color: Theme.of(context).colorScheme.surface,
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            'Enter amount',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 600;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 500 : double.infinity,
                ),
                child: SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 24 : 18,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'How much do you want to fund in '
                          '${sendState.sendCurrency}?',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Chirp',
                            letterSpacing: -.25,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Amount',
                          style: AppTypography.titleMedium.copyWith(
                            fontFamily: 'Chirp',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -.25,
                            height: 1.45,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color!.withOpacity(.75),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neutral500.withOpacity(0.1),
                              ),
                            ],
                          ),
                          child: TextField(
                            cursorColor: Theme.of(context).colorScheme.primary,
                            controller: _amountController,
                            focusNode: _amountFocus,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [NumberWithCommasFormatter()],
                            onChanged: _validateAmount,
                            style: AppTypography.bodyLarge.copyWith(
                              fontFamily: 'Chirp',
                              fontSize: 27,
                              letterSpacing: -.70,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: AppTypography.bodyLarge.copyWith(
                                fontFamily: 'Chirp',
                                fontSize: 27,
                                letterSpacing: -.25,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(.15),
                              ),
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.only(
                                right: 16,
                                top: 16,
                                bottom: 16,
                                left: -4,
                              ),
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    sendState.sendCurrency,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontFamily: 'Chirp',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_amountError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 4,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _amountError,
                                style: const TextStyle(
                                  color: AppColors.error400,
                                  fontSize: 13,
                                  fontFamily: 'Chirp',
                                  letterSpacing: -.25,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          borderRadius: 38,
                          text: 'Continue',
                          onPressed: isAmountValid ? _onContinue : null,
                          backgroundColor:
                              isAmountValid
                                  ? AppColors.purple500
                                  : AppColors.purple500.withOpacity(.15),
                          height: 48,
                          textColor:
                              isAmountValid
                                  ? AppColors.neutral0
                                  : AppColors.neutral0.withOpacity(.20),
                          fontFamily: 'Chirp',
                          letterSpacing: -.70,
                          fontSize: 18,
                          width: double.infinity,
                          fullWidth: true,
                        ),
                        const SizedBox(height: 40),
                      ],
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
}
