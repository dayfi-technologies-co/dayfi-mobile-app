import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/features/dayearn/helpers/dayearn_format.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Integer + decimal parts for home-style balance [RichText].
class DayfiBalanceAmountParts {
  final String symbol;
  final String integerPart;
  final String decimalPart;

  const DayfiBalanceAmountParts({
    required this.symbol,
    required this.integerPart,
    required this.decimalPart,
  });
}

DayfiBalanceAmountParts dayfiBalanceAmountParts(
  double amount, {
  required String currencySymbol,
  int? decimals,
  String? currency,
}) {
  final d = decimals ?? amountDisplayDecimals(currency ?? 'USD');
  final fixed = amount.toStringAsFixed(d);
  final parts = fixed.split('.');
  final intRaw = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < intRaw.length; i++) {
    if (i > 0 && (intRaw.length - i) % 3 == 0) buffer.write(',');
    buffer.write(intRaw[i]);
  }
  return DayfiBalanceAmountParts(
    symbol: currencySymbol,
    integerPart: buffer.toString(),
    decimalPart: d > 0 && parts.length > 1 ? parts[1] : '',
  );
}

/// Label, amount, and eye toggle — matches [HomeView] balance styling.
class DayfiBalanceHeader extends StatelessWidget {
  final String label;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final DayfiBalanceAmountParts? amountParts;
  final String? altVisibleText;
  final Widget? leading;
  final List<Widget> footer;

  const DayfiBalanceHeader({
    super.key,
    required this.label,
    required this.isVisible,
    required this.onToggleVisibility,
    this.amountParts,
    this.altVisibleText,
    this.leading,
    this.footer = const [],
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final labelColor = Theme.of(context).textTheme.bodyLarge?.color?.withValues(
          alpha: 0.85,
        ) ??
        onSurface.withValues(alpha: 0.85);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    '${label.toUpperCase()}   ',
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 12.5,
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.04,
                      height: 1,
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: onToggleVisibility,
                    child: Center(
                      child: SvgPicture.asset(
                        isVisible
                            ? 'assets/icons/svgs/eye.svg'
                            : 'assets/icons/svgs/eye-closed.svg',
                        height: 22,
                        color: labelColor.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (leading != null) ...[
          const SizedBox(height: 10),
          leading!,
        ],
        const SizedBox(height: 8),
        _buildAmount(context, onSurface),
        ...footer,
      ],
    );
  }

  Widget _buildAmount(BuildContext context, Color onSurface) {
    if (!isVisible) {
      return Text(
        '*****',
        style: TextStyle(
          fontSize: 40,
          height: 1,
          fontFamily: 'Chirp',
          fontWeight: FontWeight.w500,
          color: onSurface,
          letterSpacing: -1.2,
        ),
      );
    }

    if (altVisibleText != null) {
      return Text(
        altVisibleText!,
        style: TextStyle(
          fontFamily: 'Chirp',
          fontSize: 40,
          fontWeight: FontWeight.w600,
          height: 1,
          letterSpacing: -1,
          color: onSurface,
        ),
      );
    }

    final parts = amountParts;
    if (parts == null) return const SizedBox.shrink();

    TextStyle amountStyle(double size) => TextStyle(
          fontSize: size,
          height: 1,
          fontFamily: 'Chirp',
          fontWeight: FontWeight.w600,
          color: onSurface,
          letterSpacing: -1,
        );

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: parts.symbol, style: amountStyle(30)),
          TextSpan(text: parts.integerPart, style: amountStyle(40)),
          if (parts.decimalPart.isNotEmpty)
            TextSpan(text: '.${parts.decimalPart}', style: amountStyle(40)),
        ],
      ),
    );
  }
}

/// Surface card + persisted hide/show (same key as Home).
class DayfiBalanceHeaderCard extends StatefulWidget {
  final String label;
  final double? amount;
  final String currency;
  final String Function(String currency)? currencySymbolFor;
  final String? altVisibleText;
  final Widget? leading;
  final List<Widget> footer;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const DayfiBalanceHeaderCard({
    super.key,
    required this.label,
    this.amount,
    this.currency = 'NGN',
    this.currencySymbolFor,
    this.altVisibleText,
    this.leading,
    this.footer = const [],
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 18,
  });

  @override
  State<DayfiBalanceHeaderCard> createState() => _DayfiBalanceHeaderCardState();
}

class _DayfiBalanceHeaderCardState extends State<DayfiBalanceHeaderCard> {
  final _secureStorage = locator<SecureStorageService>();
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _loadVisibility();
  }

  Future<void> _loadVisibility() async {
    try {
      final hideBalance = await _secureStorage.read(StorageKeys.hideUserBalance);
      if (!mounted) return;
      if (hideBalance.isNotEmpty) {
        setState(() => _isVisible = hideBalance != 'true');
      }
    } catch (e) {
      AppLogger.error('Error loading balance visibility: $e');
    }
  }

  Future<void> _toggleVisibility() async {
    final next = !_isVisible;
    setState(() => _isVisible = next);
    try {
      await _secureStorage.write(
        StorageKeys.hideUserBalance,
        (!next).toString(),
      );
    } catch (e) {
      AppLogger.error('Error saving balance visibility: $e');
    }
  }

  String _symbol() {
    if (widget.currencySymbolFor != null) {
      return widget.currencySymbolFor!(widget.currency);
    }
    switch (widget.currency.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return widget.currency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final parts = widget.amount != null
        ? dayfiBalanceAmountParts(
            widget.amount!,
            currencySymbol: _symbol(),
            currency: widget.currency,
          )
        : null;

    return Container(
      width: double.infinity,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: DayfiBalanceHeader(
        label: widget.label,
        isVisible: _isVisible,
        onToggleVisibility: _toggleVisibility,
        amountParts: parts,
        altVisibleText: widget.altVisibleText,
        leading: widget.leading,
        footer: widget.footer,
      ),
    );
  }
}
