import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/helpers/transaction_completion_flow.dart';
import 'package:dayfi/common/helpers/transaction_pin_flow.dart';
import 'package:dayfi/common/services/feature_activity_service.dart';
import 'package:dayfi/common/utils/api_error_message.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/common/widgets/dayfi_circle_check_icon.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_setup_launcher.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/pay/constants/flutterwave_bill_presets.dart';
import 'package:dayfi/features/pay/constants/pay_copy.dart';
import 'package:dayfi/features/pay/models/bill_models.dart';
import 'package:dayfi/features/pay/widgets/bill_package_bottom_sheet.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/services/remote/bills_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
class BillPayView extends ConsumerStatefulWidget {
  final BillCategory category;
  final BillBiller biller;
  final bool usePreviewFlow;
  final String? initialCustomerId;
  final double? initialAmount;
  final DayFlowScheduleSetupContext? dayflowSetup;

  const BillPayView({
    super.key,
    required this.category,
    required this.biller,
    this.usePreviewFlow = false,
    this.initialCustomerId,
    this.initialAmount,
    this.dayflowSetup,
  });

  @override
  ConsumerState<BillPayView> createState() => _BillPayViewState();
}

class _BillPayViewState extends ConsumerState<BillPayView> {
  final _billsService = locator<BillsService>();
  final _customerController = TextEditingController();
  final _amountController = TextEditingController();
  final _packageController = TextEditingController();

  late List<BillItem> _items;
  BillItem? _selected;
  bool _validating = false;
  bool _loadingItems = false;
  bool _offlineItems = false;
  String? _validatedName;
  String? _validateError;

  bool get _previewFlow =>
      widget.usePreviewFlow ||
      isFlutterwavePreviewBiller(widget.biller) ||
      _offlineItems;

  bool get _skipValidate {
    final c = widget.category.code.toUpperCase();
    return c == 'AIRTIME' || c == 'MOBILEDATA' || _previewFlow;
  }

  bool get _isCustomerValidated => _skipValidate || _validatedName != null;

  String get _paymentBillerCode => resolveFlutterwaveBillerCode(widget.biller);

  @override
  void initState() {
    super.initState();
    final isPreview =
        widget.usePreviewFlow || isFlutterwavePreviewBiller(widget.biller);
    if (isPreview) {
      _items = sortBillItemsByAmount(
        flutterwavePreviewItemsFor(
          category: widget.category,
          biller: widget.biller,
        ),
      );
      _offlineItems = true;
    } else {
      final saved = sortBillItemsByAmount(
        billItemsFromRows(
          _billsService.getPersistedItems(_paymentBillerCode),
        ),
      );
      if (saved.isNotEmpty) {
        _items = saved;
        _offlineItems = false;
      } else {
        _items = sortBillItemsByAmount(
          flutterwavePreviewItemsFor(
            category: widget.category,
            biller: widget.biller,
          ),
        );
        _offlineItems = true;
      }
    }
    _selected = defaultBillItemFor(
      category: widget.category,
      biller: widget.biller,
      items: _items,
    );
    _syncPackageLabel();
    _syncAmountFromSelection();
    if (!isPreview) {
      _loadingItems = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadItems());
    }
    _customerController.addListener(_onCustomerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletHubProvider.notifier).load(showLoading: false);
    });
  }

  double _usdAvailableForBills() {
    return ref.read(walletHubProvider).hub?.totalAvailableBalance.amount ?? 0;
  }

  double _usdRequiredForNgnBill(double ngnAmount, {double feeNgn = 0}) {
    final hub = ref.read(walletHubProvider).hub;
    if (hub == null) return double.infinity;
    final usd = hub.totalAvailableBalance.amount;
    final ngnDisplay = hub.balanceInDisplayCurrency('NGN');
    if (usd <= 0 || ngnDisplay <= 0) return double.infinity;
    final totalNgn = ngnAmount + feeNgn;
    return totalNgn * (usd / ngnDisplay);
  }

  bool _isUserInsufficientBalanceMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('payment partner cannot process') ||
        lower.contains('insufficient funds in your wallet') ||
        lower.contains('insufficient funds in wallet')) {
      return false;
    }
    return lower.contains('insufficient balance') ||
        lower.contains('you need') && lower.contains('including fees');
  }

  @override
  void dispose() {
    _customerController.removeListener(_onCustomerChanged);
    _customerController.dispose();
    _amountController.dispose();
    _packageController.dispose();
    super.dispose();
  }

  void _onCustomerChanged() {
    if (_skipValidate) return;
    if (_validatedName != null || _validateError != null) {
      setState(() {
        _validatedName = null;
        _validateError = null;
      });
    }
  }

  void _syncPackageLabel() {
    final item = _selected;
    if (item == null) {
      _packageController.text = '';
      return;
    }
    _packageController.text = item.displayLabel;
    _syncAmountFromSelection();
  }

  bool get _isAmountFixedByPackage =>
      _selected != null && _selected!.amount > 0;

  void _syncAmountFromSelection() {
    final item = _selected;
    if (item == null || item.amount <= 0) return;
    final amount = item.amount;
    _amountController.text =
        amount == amount.roundToDouble()
            ? amount.toStringAsFixed(0)
            : amount.toStringAsFixed(2);
  }

  Future<void> _loadItems({bool forceRefresh = false}) async {
    if (widget.usePreviewFlow || isFlutterwavePreviewBiller(widget.biller)) {
      return;
    }

    if (mounted) setState(() => _loadingItems = true);
    try {
      final rows = await _billsService.fetchItems(
        _paymentBillerCode,
        forceRefresh: forceRefresh,
      );
      final fromApi = billItemsFromRows(rows);
      if (!mounted) return;
      if (fromApi.isNotEmpty) {
        final selected = defaultBillItemFor(
          category: widget.category,
          biller: widget.biller,
          items: fromApi,
        );
        setState(() {
          _items = sortBillItemsByAmount(fromApi);
          _offlineItems = false;
          _selected = selected;
          _syncPackageLabel();
          if (selected != null && selected.amount <= 0) {
            _amountController.clear();
          }
        });
        _applyInitialFields();
        if (mounted) setState(() => _loadingItems = false);
        return;
      }
    } catch (_) {
      /* keep preview items */
    }

    if (mounted) {
      setState(() {
        if (_items.isEmpty) {
          _offlineItems = true;
          _items = sortBillItemsByAmount(
            flutterwavePreviewItemsFor(
              category: widget.category,
              biller: widget.biller,
            ),
          );
          _selected = defaultBillItemFor(
            category: widget.category,
            biller: widget.biller,
            items: _items,
          );
          _syncPackageLabel();
        }
      });
      _applyInitialFields();
    }

    if (mounted) setState(() => _loadingItems = false);
  }

  void _applyInitialFields() {
    final customer = widget.initialCustomerId?.trim();
    if (customer != null &&
        customer.isNotEmpty &&
        _customerController.text.trim().isEmpty) {
      _customerController.text = customer;
    }
    final amount = widget.initialAmount;
    if (amount != null &&
        amount > 0 &&
        _amountController.text.trim().isEmpty) {
      _amountController.text = amount.toStringAsFixed(0);
    }
  }

  Future<void> _pickPackage() async {
    if (_items.length <= 1) return;
    final picked = await showBillPackageBottomSheet(
      context: context,
      items: _items,
      selected: _selected,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selected = picked;
      _validatedName = null;
      _validateError = null;
      _syncPackageLabel();
      if (picked.amount <= 0) {
        _amountController.clear();
      }
    });
  }

  Future<void> _validate() async {
    if (_selected == null) return;
    final customerId = _customerController.text.trim();
    if (customerId.isEmpty) {
      setState(() => _validateError = 'Enter ${_customerHint()}');
      return;
    }

    if (_skipValidate) return;

    setState(() {
      _validating = true;
      _validateError = null;
    });
    try {
      final data = await _billsService.validateBill(
        categoryCode: widget.category.code,
        billerCode: _paymentBillerCode,
        itemCode: _selected!.itemCode,
        customerId: customerId,
      );
      if (!mounted) return;
      setState(() {
        _validatedName =
            data['name']?.toString() ??
            data['response_message']?.toString() ??
            'Validated';
        _validateError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _validatedName = null;
        _validateError = messageFromApiError(
          e,
          fallback: 'Could not validate details',
        );
      });
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  Widget? _buildCustomerSuffixIcon() {
    if (_skipValidate) return null;

    if (_validating) {
      return Container(
        margin: const EdgeInsets.all(12),
        child: DayfiLoadingIndicator(
          color: AppColors.purple500ForTheme(context),
          size: 22,
        ),
      );
    }

    if (_validatedName != null && _validateError == null) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: DayfiCircleCheckIcon(
          size: 26,
          color: AppColors.success600,
        ),
      );
    }

    if (_validateError != null && _customerController.text.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          _customerController.clear();
          setState(() {
            _validateError = null;
            _validatedName = null;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            'assets/icons/svgs/circle-x.svg',
            width: 26,
            height: 26,
            color: AppColors.error600,
          ),
        ),
      );
    }

    if (!_skipValidate && _customerController.text.trim().isNotEmpty) {
      return GestureDetector(
        onTap: _validate,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Validate',
            style: TextStyle(
              fontFamily: 'Chirp',
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              letterSpacing: 0,
              height: 1.45,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildPackageSuffixIcon() {
    return Icon(
      Icons.keyboard_arrow_down,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      size: 24,
    );
  }

  Future<bool> _saveBillToBudget({bool showFeedback = true}) async {
    final setup = widget.dayflowSetup;
    if (setup == null || _selected == null) return false;

    final customerId = _customerController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (customerId.isEmpty || amount <= 0) {
      if (showFeedback) {
        TopSnackbar.show(
          context,
          message: 'Enter valid details and amount',
          isError: true,
        );
      }
      return false;
    }

    try {
      await dayFlowApiService.updateFlowSchedule(
        flowId: setup.flowId,
        scheduleId: setup.scheduleId,
        paymentType: 'bill',
        execution: {
          'bill': {
            'categoryCode': widget.category.code,
            'billerCode': _paymentBillerCode,
            'itemCode': _selected!.itemCode,
            'customerId': customerId,
            'billerName': widget.biller.displayName,
            'itemName': _selected!.displayLabel,
          },
        },
      );
      setup.onLinked?.call();
      if (showFeedback && mounted) {
        TopSnackbar.show(context, message: DayFlowCopy.scheduleLinkedToBudget);
      }
      return true;
    } catch (e) {
      if (showFeedback && mounted) {
        TopSnackbar.show(
          context,
          message: messageFromApiError(e),
          isError: true,
        );
      }
      return false;
    }
  }

  Future<void> _linkToBudget() async {
    final saved = await _saveBillToBudget();
    if (saved && mounted) Navigator.pop(context);
  }

  bool _hasInsufficientFunds(double amount) {
    final fee = _selected?.fee ?? 0;
    final usdAvailable = _usdAvailableForBills();
    final usdRequired = _usdRequiredForNgnBill(amount, feeNgn: fee);
    return usdAvailable < usdRequired;
  }

  Future<void> _pay() async {
    if (_selected == null) return;
    final customerId = _customerController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (customerId.isEmpty || amount <= 0) {
      TopSnackbar.show(
        context,
        message: 'Enter valid details and amount',
        isError: true,
      );
      return;
    }

    if (!_isCustomerValidated) {
      TopSnackbar.show(
        context,
        message: 'Please validate customer details first',
        isError: true,
      );
      return;
    }

    if (_hasInsufficientFunds(amount)) {
      TopSnackbar.show(
        context,
        message: 'Insufficient funds in your Dayfi balance',
        isError: true,
      );
      return;
    }

    if (_previewFlow) {
      final pin = await TransactionPinFlow.requestPin(
        context: context,
        ref: ref,
      );
      if (pin == null || !mounted) return;
      TopSnackbar.showSafe(
        context,
        message: kBillPaymentThirdPartyMessage,
        isError: true,
      );
      return;
    }

    final result = await TransactionPinFlow.requestPinAndRun<Map<String, dynamic>>(
      context: context,
      ref: ref,
      task: (pin) async {
        try {
          final payResult = await _billsService.payBill(
            categoryCode: widget.category.code,
            billerCode: _paymentBillerCode,
            itemCode: _selected!.itemCode,
            customerId: customerId,
            amount: amount,
            pin: pin,
            billerName: widget.biller.displayName,
            itemName: _selected!.displayLabel,
          );
          await ref.read(walletHubProvider.notifier).refresh();
          return payResult;
        } catch (e) {
          final msg = messageFromApiError(e);
          if (_isUserInsufficientBalanceMessage(msg)) {
            throw Exception('Insufficient funds in your Dayfi balance');
          }
          if (msg.toLowerCase().contains('payment partner cannot process') ||
              msg.toLowerCase().contains('insufficient funds in your wallet') ||
              msg.toLowerCase().contains('insufficient funds in wallet')) {
            throw Exception(kBillPartnerUnavailableMessage);
          }
          rethrow;
        }
      },
    );
    if (result == null || !mounted) return;

    final ngnAfter =
        ref.read(walletHubProvider).hub?.balanceInDisplayCurrency('NGN');

    final token = result['rechargeToken']?.toString();
    FeatureActivityService.instance.invalidate();
    if (widget.dayflowSetup != null) {
      await _saveBillToBudget(showFeedback: false);
    }
    await TransactionCompletionFlow.pushSuccess(
      context,
      screen: TransactionCompletionFlow.billSuccess(
        billerName: widget.biller.displayName,
        amount: amount,
        reference: result['reference']?.toString() ?? '',
        token: token,
        newBalance: ngnAfter,
      ),
    );
  }

  String _customerHint() {
    final code = widget.category.code.toUpperCase();
    if (code == 'AIRTIME' || code == 'MOBILEDATA') {
      return 'e.g. 08012345678';
    }
    if (code == 'CABLEBILLS') return 'Smartcard / IUC number';
    if (code == 'UTILITYBILLS') return 'Meter number';
    return 'Customer ID';
  }

  @override
  Widget build(BuildContext context) {
    final label = _selected?.labelName ?? _customerHint();
    final showPackagePicker = shouldShowBillPackagePicker(
      category: widget.category,
      biller: widget.biller,
      items: _items,
    );
    final ngnAvailable =
        ref.watch(walletHubProvider).hub?.balanceInDisplayCurrency('NGN') ??
        0;

    return Stack(
      children: [
        DayfiFeatureScaffold(
      title: widget.biller.displayName,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DayfiScreenDescription(text: kPayBillFormDescription),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                payBillsAvailableSubtitle(ngnAvailable),
                style: const TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (showPackagePicker) ...[
              CustomTextField(
                controller: _packageController,
                label: 'Package / plan',
                hintText: 'Select package',
                shouldReadOnly: true,
                onTap: _pickPackage,
                suffixIcon: _buildPackageSuffixIcon(),
              ),
              const SizedBox(height: 14),
            ],
            CustomTextField(
              controller: _customerController,
              label: label,
              hintText: _customerHint(),
              keyboardType: TextInputType.phone,
              suffixIcon: _buildCustomerSuffixIcon(),
              onChanged: (_) => setState(() {}),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  _validateError != null
                      ? Padding(
                        key: const ValueKey('error'),
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.error600,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _validateError!,
                                style: TextStyle(
                                  fontFamily: 'Chirp',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : _validatedName != null && !_skipValidate
                      ? Padding(
                        key: const ValueKey('success'),
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.success200,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _validatedName!,
                              style: const TextStyle(
                                fontFamily: 'Chirp',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success700,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(key: ValueKey('empty')),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _amountController,
              label: 'Amount (NGN)',
              hintText: _isAmountFixedByPackage ? '' : '0.00',
              keyboardType: TextInputType.number,
              shouldReadOnly: _isAmountFixedByPackage,
              shouldFaintFillColor: _isAmountFixedByPackage,
            ),
            if (_selected != null && _selected!.fee > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Service fee: ${formatBillNgnAmount(_selected!.fee)}',
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 12.5,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (widget.dayflowSetup != null) ...[
              SecondaryButton(
                text: DayFlowCopy.linkScheduleToBudget,
                onPressed: _linkToBudget,
                fullWidth: true,
                height: 48,
                borderRadius: 40,
              ),
              const SizedBox(height: 10),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 112),
              child: PrimaryButton(
                text: kPayBillButtonLabel,
                onPressed: _pay,
                fullWidth: true,
                height: 48,
                borderRadius: 50,
                backgroundColor: AppColors.purple500ForTheme(context),
                borderColor: AppColors.purple500ForTheme(context),
                textColor: AppColors.neutral0,
                fontFamily: 'Chirp',
                fontSize: 18,
                letterSpacing: -0.7,
              ),
            ),
          ],
        ),
      ),
    ),
        if (_loadingItems)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor.withValues(
                  alpha: 0.88,
                ),
                child: const DayfiLoadingCenter(size: 32),
              ),
            ),
          ),
      ],
    );
  }
}
