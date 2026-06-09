import 'package:dayfi/common/constants/wallet_flag_assets.dart';
import 'package:dayfi/common/utils/ui_helpers.dart';
import 'package:dayfi/common/widgets/dayfi_circle_check_icon.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Amount + currency picker grouped like the swap screen.
class BudgetAmountCurrencyField extends StatelessWidget {
  final TextEditingController amountController;
  final String currency;
  final List<String> currencies;
  final ValueChanged<String>? onCurrencyChanged;

  static const Map<String, String> _flags = {
    'USD': 'assets/icons/svgs/world_flags/united states.svg',
    'GBP': 'assets/icons/svgs/world_flags/united kingdom.svg',
    'EUR': WalletFlagAssets.eur,
    'NGN': 'assets/icons/svgs/world_flags/nigeria.svg',
  };

  static const Map<String, String> _symbols = {
    'USD': '\$',
    'GBP': '£',
    'EUR': '€',
    'NGN': '₦',
  };

  const BudgetAmountCurrencyField({
    super.key,
    required this.amountController,
    required this.currency,
    required this.currencies,
    this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = _symbols[currency] ?? currency;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final currencySelectable = currencies.length > 1;

    final currencyChip = SizedBox(
      // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      // decoration: BoxDecoration(
      //   color: onSurface.withOpacity(0.06),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_flags[currency] != null)
            ClipOval(
              child: SvgPicture.asset(
                _flags[currency]!,
                width: 20,
                height: 20,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(width: 6),
          Text(
            currency,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
          if (currencySelectable) ...[
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: onSurface.withOpacity(0.45),
            ),
          ],
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: onSurface.withOpacity(0.55),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: onSurface.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: onSurface.withOpacity(0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              currencySelectable
                  ? GestureDetector(
                    onTap: () => _pickCurrency(context),
                    child: currencyChip,
                  )
                  : currencyChip,
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  style: TextStyle(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 24,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                  cursorColor: AppColors.purple400,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                    prefixText: symbol,
                    prefixStyle: TextStyle(
                      fontFamily: 'FunnelDisplay',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontFamily: 'FunnelDisplay',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      color: onSurface.withOpacity(0.25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickCurrency(BuildContext context) async {
    if (currencies.length <= 1) return;
    final picked = await showAppBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => _CurrencySheet(
            currencies: currencies,
            selected: currency,
            flags: _flags,
          ),
    );
    if (picked != null) onCurrencyChanged?.call(picked);
  }
}

class _CurrencySheet extends StatelessWidget {
  final List<String> currencies;
  final String selected;
  final Map<String, String> flags;

  const _CurrencySheet({
    required this.currencies,
    required this.selected,
    required this.flags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'Currency',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'FunnelDisplay',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Navigator.pop(context);
                      FocusScope.of(context).unfocus();
                    },
                    child: Stack(
                      alignment: Alignment.center,
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
                            child: Image.asset(
                              'assets/icons/pngs/cancelicon.png',
                              height: 20,
                              width: 20,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...currencies.map((code) {
              final isSel = code == selected;
              return ListTile(
                leading:
                    flags[code] != null
                        ? SvgPicture.asset(flags[code]!, width: 28, height: 28)
                        : null,
                title: Text(
                  code,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                trailing:
                    isSel
                        ? const DayfiCircleCheckIcon(color: AppColors.primary400)
                        : null,
                onTap: () => Navigator.pop(context, code),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
