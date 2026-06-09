import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/string_utils.dart';
import 'package:dayfi/common/utils/ui_helpers.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_compact_chip_row.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/common/widgets/dayfi_selection_grid.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/budget/constants/budget_copy.dart';
import 'package:dayfi/features/budget/widgets/budget_date_field.dart';
import 'package:dayfi/features/budget/widgets/budget_time_field.dart';
import 'package:dayfi/features/dayearn/dayearn_flow.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/features/pay/widgets/bill_package_bottom_sheet.dart';
import 'package:dayfi/features/dayearn/helpers/dayearn_format.dart';
import 'package:dayfi/features/dayearn/services/dayearn_summary_cache.dart';
import 'package:dayfi/services/remote/dayearn_service.dart';
import 'package:dayfi/features/pay/constants/bill_category_presets.dart';
import 'package:dayfi/features/pay/constants/flutterwave_bill_presets.dart';
import 'package:dayfi/features/pay/models/bill_models.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_grid_tile.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_icon_badge.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/features/recipients/helpers/recipients_list_cache.dart';
import 'package:dayfi/features/recipients/widgets/recipient_avatar_badge.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/common/services/feature_activity_service.dart';
import 'package:dayfi/services/remote/budget_service.dart';
import 'package:dayfi/services/remote/bills_service.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum BudgetCreateKind {
  send,
  bill,
  spendingCap,
  dailyEarn,
  oneTimeSend,
  oneTimeBill,
}

class CreateBudgetView extends StatefulWidget {
  final BudgetCreateKind kind;
  final bool forDayFlowAutomation;

  const CreateBudgetView({
    super.key,
    required this.kind,
    this.forDayFlowAutomation = false,
  });

  @override
  State<CreateBudgetView> createState() => _CreateBudgetViewState();
}

class _CreateBudgetViewState extends State<CreateBudgetView> {
  final _amountCtrl = TextEditingController();
  final _billNumberCtrl = TextEditingController();

  String _frequency = 'monthly';
  bool _saving = false;
  late DateTime _startDate;
  DateTime? _endDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);

  static const _currency = 'USD';

  // Send
  String? _recipientId;
  String? _recipientLabel;
  String? _recipientChannelLabel;

  // Bills
  BillCategory? _billCategory;
  BillBiller? _biller;
  String? _billerCode;
  String? _billerName;
  String? _billerShortName;
  List<BillItem> _billItems = [];
  BillItem? _billPackage;
  bool _loadingBillPackages = false;
  final Map<String, List<BillBiller>> _billersByCategory = {};

  // Spending cap
  String _spendingCategory = BudgetCopy.spendingCategories.first;

  // Daily Earn
  String? _potId;
  String? _potName;

  static const _frequencyChips = [
    DayfiCompactChipOption(value: 'weekly', label: 'Weekly'),
    DayfiCompactChipOption(value: 'biweekly', label: 'Biweekly'),
    DayfiCompactChipOption(value: 'monthly', label: 'Monthly'),
  ];

  static final _spendingCategoryChips = [
    for (final name in BudgetCopy.spendingCategories)
      DayfiCompactChipOption(value: name, label: name),
  ];

  bool get _isOneTime =>
      widget.kind == BudgetCreateKind.oneTimeSend ||
      widget.kind == BudgetCreateKind.oneTimeBill;

  bool get _isSendFlow =>
      widget.kind == BudgetCreateKind.send ||
      widget.kind == BudgetCreateKind.oneTimeSend;

  bool get _isBillFlow =>
      widget.kind == BudgetCreateKind.bill ||
      widget.kind == BudgetCreateKind.oneTimeBill;

  bool get _isSpendingCap => widget.kind == BudgetCreateKind.spendingCap;

  bool get _isDailyEarn => widget.kind == BudgetCreateKind.dailyEarn;

  bool get _showFrequency => !_isOneTime && !_isSpendingCap;

  bool get _showEndDate => !_isOneTime;

  bool get _showStartTime => widget.forDayFlowAutomation && !_isOneTime;

  bool get _showBillPackagePicker {
    final category = _billCategory;
    final biller = _biller;
    if (!widget.forDayFlowAutomation || category == null || biller == null) {
      return false;
    }
    return shouldShowBillPackagePicker(
      category: category,
      biller: biller,
      items: _billItems,
    );
  }

  String get _apiType {
    switch (widget.kind) {
      case BudgetCreateKind.spendingCap:
        return 'category_spend';
      case BudgetCreateKind.dailyEarn:
        return 'invest_allocation';
      case BudgetCreateKind.bill:
      case BudgetCreateKind.oneTimeBill:
        return 'bill_reminder';
      case BudgetCreateKind.send:
      case BudgetCreateKind.oneTimeSend:
        return 'recurring_send';
    }
  }

  String get _effectiveFrequency {
    if (_isOneTime) return 'once';
    if (_isSpendingCap) return 'monthly';
    return _frequency;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    if (_isBillFlow) {
      _billCategory = billCategoryPresets.first;
      _warmBillersForCategory(_billCategory!.code);
    } else if (_isSendFlow) {
      _prefetchRecipients();
    } else if (_isDailyEarn) {
      _prefetchPots();
    }
  }

  void _prefetchPots() {
    dayEarnService.fetchSummary();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _billNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _prefetchRecipients() async {
    if (RecipientsListCache.read() != null) return;

    try {
      final results = await Future.wait([
        locator<WalletService>().getUniqueBeneficiariesWithSource(),
        walletService.fetchSavedBeneficiaries(),
      ]);
      final merged = RecipientHistoryHelper.mergeRecipients(
        results[0],
        results[1],
      );
      await RecipientsListCache.write(merged);
    } catch (_) {}
  }

  void _warmBillersForCategory(String categoryCode) {
    final code = categoryCode.toUpperCase();
    if (_billersByCategory.containsKey(code)) return;

    final billsService = locator<BillsService>();
    final persisted = billBillersFromRows(
      billsService.getPersistedBillers(code),
    );
    final initial =
        persisted.isNotEmpty ? persisted : flutterwavePreviewBillersFor(code);
    if (initial.isNotEmpty) {
      _billersByCategory[code] = initial;
    }

    billsService
        .fetchBillers(code)
        .then((rows) {
          final fromApi = billBillersFromRows(rows);
          if (!mounted || fromApi.isEmpty) return;
          setState(() => _billersByCategory[code] = fromApi);
        })
        .catchError((_) {});
  }

  Future<void> _pickRecipient() async {
    final picked = await showAppBottomSheet<BeneficiaryWithSource>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _RecipientPickerSheet(),
    );
    if (picked != null) {
      setState(() {
        _recipientId = picked.beneficiary.id;
        _recipientLabel = RecipientHistoryHelper.primaryLabel(
          picked.beneficiary,
          picked.source,
        );
        _recipientChannelLabel = RecipientHistoryHelper.recipientChannelLabel(
          picked,
        );
      });
    }
  }

  Future<void> _pickDayEarnPot() async {
    final picked = await showAppBottomSheet<DayEarnPot>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _DayEarnPotPickerSheet(),
    );
    if (picked != null) {
      setState(() {
        _potId = picked.id;
        _potName = picked.name;
      });
    }
  }

  Future<void> _pickBiller() async {
    final category = _billCategory;
    if (category == null) return;
    _warmBillersForCategory(category.code);

    final picked = await showAppBottomSheet<BillBiller>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => _BillerPickerSheet(
            categoryCode: category.code,
            categoryName: category.name,
            initialBillers: _billersByCategory[category.code.toUpperCase()],
          ),
    );
    if (picked != null) {
      setState(() {
        _biller = picked;
        _billerCode = picked.billerCode;
        _billerName = picked.name;
        _billerShortName = picked.shortName;
        _billItems = [];
        _billPackage = null;
      });
      if (widget.forDayFlowAutomation) {
        _loadBillPackages();
      }
    }
  }

  Future<void> _loadBillPackages() async {
    final category = _billCategory;
    final biller = _biller;
    if (category == null || biller == null) return;

    setState(() => _loadingBillPackages = true);
    final paymentCode = resolveFlutterwaveBillerCode(biller);
    final billsService = locator<BillsService>();

    try {
      try {
        final rows = await billsService.fetchItems(paymentCode);
        final fromApi = billItemsFromRows(rows);
        if (!mounted) return;
        if (fromApi.isNotEmpty) {
          final selected = defaultBillItemFor(
            category: category,
            biller: biller,
            items: fromApi,
          );
          setState(() {
            _billItems = sortBillItemsByAmount(fromApi);
            _billPackage = selected;
          });
          return;
        }
      } catch (_) {}

      if (!mounted) return;
      final preview = sortBillItemsByAmount(
        flutterwavePreviewItemsFor(category: category, biller: biller),
      );
      setState(() {
        _billItems = preview;
        _billPackage = defaultBillItemFor(
          category: category,
          biller: biller,
          items: preview,
        );
      });
    } finally {
      if (mounted) setState(() => _loadingBillPackages = false);
    }
  }

  Future<void> _pickBillPackage() async {
    if (_billItems.length <= 1) return;
    final picked = await showBillPackageBottomSheet(
      context: context,
      items: _billItems,
      selected: _billPackage,
    );
    if (picked != null) {
      setState(() => _billPackage = picked);
    }
  }

  String _frequencyLabel(String value) {
    return _frequencyChips
        .firstWhere((c) => c.value == value, orElse: () => _frequencyChips[2])
        .label;
  }

  String _autoBudgetName() {
    if (_isSpendingCap) {
      return 'Monthly $_spendingCategory cap';
    }
    if (_isDailyEarn) {
      final freq = _frequencyLabel(_frequency);
      final pot = _potName?.trim();
      if (pot != null && pot.isNotEmpty) {
        return '$freq Daily Earn — $pot';
      }
      return '$freq Daily Earn';
    }
    if (_isOneTime) {
      if (_isSendFlow) {
        final who = _recipientLabel?.trim();
        if (who != null && who.isNotEmpty) {
          return 'Reminder: send to $who';
        }
        return 'Reminder: send';
      }
      final provider =
          _billerShortName?.trim().isNotEmpty == true
              ? _billerShortName!.trim()
              : _billerName?.trim();
      final cat = _billCategory?.name ?? 'Bill';
      if (provider != null && provider.isNotEmpty) {
        return 'Reminder: $provider $cat';
      }
      return 'Reminder: $cat payment';
    }

    final freq = _frequencyLabel(_frequency);
    if (_isSendFlow) {
      final who = _recipientLabel?.trim();
      if (who != null && who.isNotEmpty) {
        return '$freq send to $who';
      }
      return '$freq send';
    }
    final provider =
        _billerShortName?.trim().isNotEmpty == true
            ? _billerShortName!.trim()
            : _billerName?.trim();
    final cat = _billCategory?.name ?? 'Bill';
    if (provider != null && provider.isNotEmpty) {
      return '$freq $provider $cat';
    }
    return '$freq $cat payment';
  }

  bool _validate() {
    if (_isSendFlow) {
      if (_recipientId == null || _recipientId!.isEmpty) {
        TopSnackbar.show(
          context,
          message: 'Select who to send to',
          isError: true,
        );
        return false;
      }
    } else if (_isBillFlow) {
      if (_billCategory == null) {
        TopSnackbar.show(context, message: 'Select a bill type', isError: true);
        return false;
      }
      if (_billerCode == null) {
        TopSnackbar.show(context, message: 'Select a provider', isError: true);
        return false;
      }
      if (_billNumberCtrl.text.trim().length < 4) {
        TopSnackbar.show(
          context,
          message: 'Enter phone or account number',
          isError: true,
        );
        return false;
      }
      if (widget.forDayFlowAutomation) {
        if (_billPackage == null && _billItems.isEmpty && _biller != null) {
          TopSnackbar.show(
            context,
            message: 'Loading packages — try again in a moment',
            isError: true,
          );
          return false;
        }
        if (_showBillPackagePicker && _billPackage == null) {
          TopSnackbar.show(
            context,
            message: 'Select a package',
            isError: true,
          );
          return false;
        }
      }
    } else if (_isDailyEarn) {
      if (_potId == null || _potId!.isEmpty) {
        TopSnackbar.show(
          context,
          message: 'Select a Daily Earn pot',
          isError: true,
        );
        return false;
      }
    }

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      TopSnackbar.show(
        context,
        message:
            _isSpendingCap
                ? 'Enter a valid monthly limit'
                : _isDailyEarn
                ? 'Enter a valid deposit amount'
                : 'Enter a valid amount',
        isError: true,
      );
      return false;
    }

    if (_showEndDate && _endDate != null && !_endDate!.isAfter(_startDate)) {
      TopSnackbar.show(
        context,
        message: 'End date must be after start date',
        isError: true,
      );
      return false;
    }

    return true;
  }

  Map<String, dynamic> _buildMetadata(double amount) {
    if (_isSpendingCap) {
      return {
        'categoryName': _spendingCategory,
        if (_endDate != null) 'endsAt': BudgetDateField.toIsoDate(_endDate!),
      };
    }
    if (_isDailyEarn) {
      return {
        'potId': _potId,
        'potName': _potName,
        'amountPerDeposit': amount,
        if (_endDate != null) 'endsAt': BudgetDateField.toIsoDate(_endDate!),
      };
    }
    if (_isSendFlow) {
      return {
        'amountPerSend': amount,
        if (_recipientLabel != null) 'recipientName': _recipientLabel,
        if (_isOneTime) 'reminder': true,
        if (_endDate != null) 'endsAt': BudgetDateField.toIsoDate(_endDate!),
      };
    }

    return {
      'billCategoryCode': _billCategory!.code,
      'billCategoryName': _billCategory!.name,
      'billerCode': _billerCode,
      'billerName': _billerName,
      'customerReference': _billNumberCtrl.text.trim(),
      'amountPerTransaction': amount,
      if (_isOneTime) 'reminder': true,
      if (_endDate != null) 'endsAt': BudgetDateField.toIsoDate(_endDate!),
    };
  }

  Future<void> _save() async {
    if (widget.forDayFlowAutomation) {
      return _saveDayFlowAutomation();
    }

    if (!_validate()) return;

    final amount = double.parse(_amountCtrl.text.replaceAll(',', ''));
    final nextRunAt = '${BudgetDateField.toIsoDate(_startDate)}T09:00:00.000Z';

    setState(() => _saving = true);
    try {
      await budgetService.createBudget(
        name: _autoBudgetName(),
        type: _apiType,
        amount: amount,
        currency: _currency,
        frequency: _effectiveFrequency,
        categories:
            _isSpendingCap
                ? [
                  {'name': _spendingCategory, 'limit': amount},
                ]
                : null,
        recipientId: _isSendFlow ? _recipientId : null,
        nextRunAt: nextRunAt,
        metadata: _buildMetadata(amount),
      );
      FeatureActivityService.instance.invalidate();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        TopSnackbar.show(context, message: '$e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveDayFlowAutomation() async {
    if (!_validate()) return;

    final amount = double.parse(_amountCtrl.text.replaceAll(',', ''));
    final startAt = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    Map<String, dynamic>? execution;
    String? recipientHint;
    String? recipientId;
    late final String paymentType;

    if (_isSendFlow) {
      paymentType = 'send';
      recipientId = _recipientId;
      final channel = _recipientChannelLabel?.trim();
      recipientHint =
          channel != null && channel.isNotEmpty
              ? '${_recipientLabel ?? ''} · $channel'.trim()
              : _recipientLabel;
      execution = const {'toCurrency': 'NGN'};
    } else {
      paymentType = 'bill';
      final provider =
          _billerShortName?.trim().isNotEmpty == true
              ? _billerShortName!.trim()
              : _billerName?.trim() ?? '';
      recipientHint = '$provider · ${_billNumberCtrl.text.trim()}';
      final biller = _biller;
      final category = _billCategory;
      if (biller == null || category == null) return;

      final item =
          _billPackage ??
          defaultBillItemFor(
            category: category,
            biller: biller,
            items: _billItems,
          );
      if (item == null) {
        TopSnackbar.show(
          context,
          message: 'Select a package',
          isError: true,
        );
        return;
      }

      execution = {
        'bill': {
          'categoryCode': category.code,
          'billerCode': resolveFlutterwaveBillerCode(biller),
          'itemCode': item.itemCode,
          'customerId': _billNumberCtrl.text.trim(),
          'billerName': biller.name,
          'itemName': item.displayLabel,
        },
      };
    }

    setState(() => _saving = true);
    try {
      await dayFlowApiService.createAutomation(
        title: _autoBudgetName(),
        paymentType: paymentType,
        amount: amount,
        frequency: _frequency,
        startAt: startAt,
        endAt:
            _endDate != null
                ? DateTime(
                  _endDate!.year,
                  _endDate!.month,
                  _endDate!.day,
                  23,
                  59,
                )
                : null,
        recipientId: recipientId,
        recipientHint: recipientHint,
        execution: execution,
      );
      DayflowDashboardCache.instance.invalidate();
      FeatureActivityService.instance.invalidate();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        TopSnackbar.show(context, message: '$e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _screenTitle {
    switch (widget.kind) {
      case BudgetCreateKind.send:
        return 'Send to someone';
      case BudgetCreateKind.bill:
        return 'Pay a bill';
      case BudgetCreateKind.spendingCap:
        return 'Spending cap';
      case BudgetCreateKind.dailyEarn:
        return 'Daily Earn';
      case BudgetCreateKind.oneTimeSend:
        return 'Remind me to send';
      case BudgetCreateKind.oneTimeBill:
        return 'Remind me to pay';
    }
  }

  String get _screenDescription {
    if (widget.forDayFlowAutomation) {
      switch (widget.kind) {
        case BudgetCreateKind.send:
          return DayFlowCopy.sendAutomationDescription;
        case BudgetCreateKind.bill:
          return DayFlowCopy.billAutomationDescription;
        default:
          break;
      }
    }
    switch (widget.kind) {
      case BudgetCreateKind.send:
        return 'Schedule repeat sends from your USD balance.';
      case BudgetCreateKind.bill:
        return 'Schedule repeat bill payments — same providers as Pay bills.';
      case BudgetCreateKind.spendingCap:
        return 'Set a monthly spending limit by category. Track how much you spend — payments are not blocked automatically yet.';
      case BudgetCreateKind.dailyEarn:
        return 'Schedule repeat deposits from your USD wallet into a Daily Earn pot.';
      case BudgetCreateKind.oneTimeSend:
        return 'Set a one-time reminder to send money. Payment is not automatic — you\'ll need to complete the send yourself.';
      case BudgetCreateKind.oneTimeBill:
        return 'Set a one-time reminder to pay a bill. Payment is not automatic — you\'ll pay from Pay bills when ready.';
    }
  }

  String get _amountFieldLabel {
    if (_isSpendingCap) return 'Monthly limit (USD)';
    if (_isDailyEarn) return 'Amount per deposit (USD)';
    if (_isOneTime) return 'Amount (USD)';
    return 'Amount per payment (USD)';
  }

  String get _startDateLabel => _isOneTime ? 'Reminder date' : 'Start date';

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width - 36;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxSchedule = today.add(const Duration(days: 730));

    return DayfiFeatureScaffold(
      title: _screenTitle,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              children: [
                DayfiScreenDescription(text: _screenDescription),
                const SizedBox(height: 16),
                if (_isSendFlow)
                  ..._sendFields(context, w)
                else if (_isBillFlow)
                  ..._billFields(context, w)
                else if (_isSpendingCap)
                  ..._spendingCapFields(context)
                else if (_isDailyEarn)
                  ..._dailyEarnFields(context),
                const SizedBox(height: 16),
                CustomTextField(
                  label: _amountFieldLabel,
                  hintText: '50.00',
                  controller: _amountCtrl,
                  width: w,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  formatter: FilteringTextInputFormatter.allow(
                    RegExp(r'[\d.]'),
                  ),
                ),
                if (_showFrequency) ...[
                  const SizedBox(height: 20),
                  _label(context, 'Frequency'),
                  const SizedBox(height: 10),
                  DayfiCompactChipRowMapped(
                    options: _frequencyChips,
                    selectedValue: _frequency,
                    onSelected: (v) => setState(() => _frequency = v),
                  ),
                ],
                const SizedBox(height: 20),
                BudgetDateField(
                  label: _startDateLabel,
                  hintText:
                      _isOneTime ? 'Select reminder date' : 'Select start date',
                  value: _startDate,
                  width: w,
                  firstDate: today,
                  lastDate: maxSchedule,
                  pickerTitle: _startDateLabel,
                  onDateSelected: (d) => setState(() => _startDate = d),
                ),
                if (_showStartTime) ...[
                  const SizedBox(height: 16),
                  BudgetTimeField(
                    label: 'Time',
                    value: _startTime,
                    width: w,
                    onTimeSelected: (t) => setState(() => _startTime = t),
                  ),
                ],
                if (_showEndDate) ...[
                  const SizedBox(height: 16),
                  BudgetDateField(
                    label: 'End date (optional)',
                    hintText: 'No end date',
                    value: _endDate,
                    width: w,
                    firstDate: _startDate.add(const Duration(days: 1)),
                    lastDate: maxSchedule,
                    pickerTitle: 'End date',
                    onDateSelected: (d) => setState(() => _endDate = d),
                    onClear: () => setState(() => _endDate = null),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 12),
              child: PrimaryButton(
                text:
                    widget.forDayFlowAutomation
                        ? DayFlowCopy.automatePaymentButton
                        : 'Create budget',
                onPressed: _saving ? null : _save,
                isLoading: _saving,
                fullWidth: true,
                borderRadius: 38,
                height: 48,
                backgroundColor: AppColors.purple500ForTheme(context),
                textColor: AppColors.neutral0,
                fontFamily: 'Chirp',
                letterSpacing: -.2,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _spendingCapFields(BuildContext context) {
    return [
      _label(context, 'Category'),
      const SizedBox(height: 10),
      DayfiCompactChipRowMapped(
        options: _spendingCategoryChips,
        selectedValue: _spendingCategory,
        onSelected: (v) => setState(() => _spendingCategory = v),
      ),
    ];
  }

  List<Widget> _dailyEarnFields(BuildContext context) {
    return [
      _PickerTile(
        label: _potName ?? 'Select pot',
        hint: 'Daily Earn pot',
        onTap: _pickDayEarnPot,
      ),
    ];
  }

  List<Widget> _sendFields(BuildContext context, double w) {
    return [
      _PickerTile(
        label: _recipientLabel ?? 'Select recipient',
        hint: 'Recipient',
        detail: _recipientChannelLabel,
        onTap: _pickRecipient,
      ),
    ];
  }

  List<Widget> _billFields(BuildContext context, double w) {
    return [
      _label(context, 'Bill type'),
      DayfiSelectionGrid<BillCategory>(
        options: billCategoryPresets,
        isSelected: (cat) => _billCategory?.code == cat.code,
        label: (cat) => cat.name,
        onSelected: (cat) {
          setState(() {
            _billCategory = cat;
            _biller = null;
            _billerCode = null;
            _billerName = null;
            _billerShortName = null;
            _billItems = [];
            _billPackage = null;
          });
          _warmBillersForCategory(cat.code);
        },
      ),
      const SizedBox(height: 8),
      _PickerTile(
        label: _billerName ?? 'Select provider',
        hint: 'Provider',
        onTap: _pickBiller,
      ),
      if (_showBillPackagePicker) ...[
        const SizedBox(height: 14),
        _PickerTile(
          label: _billPackage?.displayLabel ?? 'Select package',
          hint: 'Package',
          onTap: _loadingBillPackages ? () {} : _pickBillPackage,
        ),
      ],
      const SizedBox(height: 14),
      CustomTextField(
        label: 'Phone / account number',
        hintText: '08012345678',
        controller: _billNumberCtrl,
        width: w,
        keyboardType: TextInputType.phone,
      ),
    ];
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Chirp',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final String hint;
  final String? detail;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    required this.hint,
    this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isPlaceholder = label.startsWith('Select');

    return Material(
      color: onSurface.withOpacity(0.04),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: onSurface.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hint,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 12.5,
                        color: onSurface.withOpacity(0.45),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isPlaceholder
                                ? onSurface.withOpacity(0.35)
                                : onSurface,
                      ),
                    ),
                    if (detail != null && detail!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail!,
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 13,
                          color: onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetSheetHeader extends StatelessWidget {
  final String title;

  const _BudgetSheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'FunnelDisplay',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          _BudgetSheetCloseButton(onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

class _BudgetSheetCloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BudgetSheetCloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        onPressed();
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
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _budgetFlagPath(String? countryCode) {
  switch (countryCode?.toUpperCase()) {
    case 'NG':
      return 'assets/icons/svgs/world_flags/nigeria.svg';
    case 'GH':
      return 'assets/icons/svgs/world_flags/ghana.svg';
    case 'KE':
      return 'assets/icons/svgs/world_flags/kenya.svg';
    case 'UG':
      return 'assets/icons/svgs/world_flags/uganda.svg';
    case 'TZ':
      return 'assets/icons/svgs/world_flags/tanzania.svg';
    case 'RW':
      return 'assets/icons/svgs/world_flags/rwanda.svg';
    case 'ZA':
      return 'assets/icons/svgs/world_flags/south africa.svg';
    case 'US':
      return 'assets/icons/svgs/world_flags/united states.svg';
    case 'GB':
      return 'assets/icons/svgs/world_flags/united kingdom.svg';
    case 'EU':
      return 'assets/icons/svgs/world_flags/european-union.svg';
    default:
      return 'assets/icons/svgs/world_flags/nigeria.svg';
  }
}

class _RecipientPickerSheet extends StatefulWidget {
  const _RecipientPickerSheet();

  @override
  State<_RecipientPickerSheet> createState() => _RecipientPickerSheetState();
}

class _RecipientPickerSheetState extends State<_RecipientPickerSheet> {
  List<BeneficiaryWithSource> _recipients = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _hydrateFromCache();
    _loadRecipients(silent: _recipients.isNotEmpty);
  }

  List<BeneficiaryWithSource> _filterRecipients(
    List<BeneficiaryWithSource> list,
  ) {
    return list
        .where(
          (e) =>
              RecipientHistoryHelper.isSendRecipient(e) &&
              !RecipientHistoryHelper.isDayflowRecipient(e) &&
              !RecipientHistoryHelper.isDayEarnRecipient(e),
        )
        .toList();
  }

  void _hydrateFromCache() {
    final fromCache = RecipientsListCache.read();
    if (fromCache == null) return;
    final filtered = _filterRecipients(fromCache);
    if (filtered.isEmpty) return;
    _recipients = filtered;
    _loading = false;
  }

  Future<void> _loadRecipients({bool silent = false}) async {
    if (!silent && _recipients.isEmpty && mounted) {
      setState(() => _loading = true);
    }
    try {
      final results = await Future.wait([
        locator<WalletService>().getUniqueBeneficiariesWithSource(),
        walletService.fetchSavedBeneficiaries(),
      ]);
      if (!mounted) return;
      final merged = _filterRecipients(
        RecipientHistoryHelper.mergeRecipients(results[0], results[1]),
      );
      await RecipientsListCache.write(merged);
      setState(() {
        _recipients = merged;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final sheetHeight = MediaQuery.of(context).size.height * 0.72;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const _BudgetSheetHeader(title: 'Select recipient'),
          const SizedBox(height: 12),
          Expanded(
            child:
                _loading && _recipients.isEmpty
                    ? const Center(child: DayfiLoadingIndicator())
                    : _recipients.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Add a recipient first from Send or Recipients',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 14,
                            color: onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      itemCount: _recipients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final entry = _recipients[i];
                        final name = StringUtils.toTitleCase(
                          RecipientHistoryHelper.primaryLabel(
                            entry.beneficiary,
                            entry.source,
                          ),
                        );
                        final channel =
                            RecipientHistoryHelper.recipientChannelLabel(entry);
                        return Material(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => Navigator.pop(context, entry),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  RecipientAvatarBadge(
                                    entry: entry,
                                    flagPathForCountry: _budgetFlagPath,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Chirp',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: onSurface,
                                          ),
                                        ),
                                        if (channel.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            channel,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Chirp',
                                              fontSize: 13,
                                              color: onSurface.withValues(
                                                alpha: 0.6,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _BillerPickerSheet extends StatefulWidget {
  final String categoryCode;
  final String categoryName;
  final List<BillBiller>? initialBillers;

  const _BillerPickerSheet({
    required this.categoryCode,
    required this.categoryName,
    this.initialBillers,
  });

  @override
  State<_BillerPickerSheet> createState() => _BillerPickerSheetState();
}

class _BillerPickerSheetState extends State<_BillerPickerSheet> {
  late List<BillBiller> _billers;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialBillers ?? const <BillBiller>[];
    if (initial.isNotEmpty) {
      _billers = initial;
    } else {
      final persisted = billBillersFromRows(
        locator<BillsService>().getPersistedBillers(widget.categoryCode),
      );
      _billers =
          persisted.isNotEmpty
              ? persisted
              : flutterwavePreviewBillersFor(widget.categoryCode);
    }
    if (_billers.isEmpty) {
      _refreshBillers();
    } else {
      _refreshBillers(silent: true);
    }
  }

  Future<void> _refreshBillers({bool silent = false}) async {
    if (!silent && mounted) setState(() => _refreshing = true);
    try {
      final rows = await locator<BillsService>().fetchBillers(
        widget.categoryCode,
      );
      final fromApi = billBillersFromRows(rows);
      if (!mounted) return;
      if (fromApi.isNotEmpty) {
        setState(() {
          _billers = fromApi;
          _refreshing = false;
        });
        return;
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      if (_billers.isEmpty) {
        _billers = flutterwavePreviewBillersFor(widget.categoryCode);
      }
      _refreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final sheetHeight = MediaQuery.of(context).size.height * 0.72;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _BudgetSheetHeader(title: widget.categoryName),
          if (_refreshing)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: SizedBox(
                height: 18,
                width: 18,
                child: DayfiLoadingIndicator(),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child:
                _billers.isEmpty
                    ? const Center(child: DayfiLoadingIndicator())
                    : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.5,
                          ),
                      itemCount: _billers.length,
                      itemBuilder: (context, index) {
                        final biller = _billers[index];
                        return PayBillGridTile(
                          title: biller.shortName ?? biller.name,
                          innerIconAsset: billerInnerIconAsset(
                            biller,
                            widget.categoryCode,
                          ),
                          brandImageAsset: billerBrandImageAsset(biller),
                          plainBillerBrandIcon: true,
                          onTap: () => Navigator.pop(context, biller),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _DayEarnPotPickerSheet extends StatefulWidget {
  const _DayEarnPotPickerSheet();

  @override
  State<_DayEarnPotPickerSheet> createState() => _DayEarnPotPickerSheetState();
}

class _DayEarnPotPickerSheetState extends State<_DayEarnPotPickerSheet> {
  List<DayEarnPot> _pots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final cached = DayEarnSummaryCache.instance.peek();
    if (cached != null && cached.pots.isNotEmpty) {
      _pots = cached.pots;
      _loading = false;
    }
    _loadPots();
  }

  Future<void> _loadPots() async {
    try {
      final summary = await dayEarnService.fetchSummary();
      if (!mounted) return;
      setState(() {
        _pots = summary.pots;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createPot() async {
    final created = await DayEarnFlow.openCreate(context);
    if (!mounted) return;
    if (created) {
      await _loadPots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final sheetHeight = MediaQuery.of(context).size.height * 0.72;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const _BudgetSheetHeader(title: 'Select Daily Earn pot'),
          const SizedBox(height: 12),
          Expanded(
            child:
                _loading && _pots.isEmpty
                    ? const Center(child: DayfiLoadingIndicator())
                    : _pots.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Create a Daily Earn pot first',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Chirp',
                                fontSize: 14,
                                color: onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: PrimaryButton(
                                text: 'Create pot',
                                onPressed: _createPot,
                                fullWidth: false,
                                borderRadius: 38,
                                height: 44,
                                backgroundColor: AppColors.purple500ForTheme(
                                  context,
                                ),
                                textColor: AppColors.neutral0,
                                fontFamily: 'Chirp',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      itemCount: _pots.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final pot = _pots[i];
                        return Material(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => Navigator.pop(context, pot),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  PayBillIconBadge(
                                    innerIconAsset:
                                        'assets/icons/svgs/clock-dollar.svg',
                                    size: 40,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pot.name,
                                          style: TextStyle(
                                            fontFamily: 'Chirp',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          formatDayEarnAmount(
                                            pot.balance,
                                            kDayEarnCurrency,
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Chirp',
                                            fontSize: 13,
                                            color: onSurface.withValues(
                                              alpha: 0.6,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
