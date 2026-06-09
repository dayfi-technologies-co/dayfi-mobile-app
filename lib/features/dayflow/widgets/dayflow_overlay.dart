import 'dart:async';
import 'dart:ui';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/agent_chat_layout.dart';
import 'package:dayfi/common/helpers/transaction_pin_flow.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/dayflow/daybudget_flow.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/models/dayflow_overlay_task.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_analytics.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_draft_details.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_draft_validation.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_welcome_builder.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/features/dayflow/services/dayflow_chat_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_conversation_store.dart';
import 'package:dayfi/features/dayflow/services/dayflow_income_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_local_store.dart';
import 'package:dayfi/features/dayflow/widgets/dayflow_allocation_builder.dart';
import 'package:dayfi/features/dayflow/widgets/dayflow_budget_strip.dart';
import 'package:dayfi/features/dayflow/widgets/dayflow_chat_ui.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_inline_flow_text.dart';
import 'package:dayfi/features/dayflow/widgets/dayflow_plan_card.dart';
import 'package:dayfi/features/dayx/models/dayx_flow.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_executor.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_pin_retry.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_service.dart';
import 'package:dayfi/features/dayx/widgets/dayx_inline_success.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class DayFlowChatMessage {
  final bool isUser;
  final String text;
  final DayFlowPlanDraft? planDraft;
  final bool suggestSwap;
  final bool offerSavedTemplate;
  final DayxFlowUi? flowUi;
  final DayxFlowSession? flowSession;
  final bool flowInteractive;
  final DayxInlineSuccess? successReceipt;
  final bool isTaskDivider;

  const DayFlowChatMessage({
    required this.isUser,
    required this.text,
    this.planDraft,
    this.suggestSwap = false,
    this.offerSavedTemplate = false,
    this.flowUi,
    this.flowSession,
    this.flowInteractive = false,
    this.successReceipt,
    this.isTaskDivider = false,
  });
}

class DayFlowOverlay extends ConsumerStatefulWidget {
  final VoidCallback? onPlanActivated;
  final String? initialPrompt;
  final String? prefillPrompt;
  final DayFlowOverlayTask task;
  final DayFlowIncomeEvent? initialIncome;
  final bool allowPendingIncomePrompt;
  final bool freshSession;
  final bool navigateToDashboardOnSuccess;

  const DayFlowOverlay({
    super.key,
    this.onPlanActivated,
    this.initialPrompt,
    this.prefillPrompt,
    this.task = DayFlowOverlayTask.general,
    this.initialIncome,
    this.allowPendingIncomePrompt = true,
    this.freshSession = false,
    this.navigateToDashboardOnSuccess = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onPlanActivated,
    String? initialPrompt,
    String? prefillPrompt,
    DayFlowOverlayTask task = DayFlowOverlayTask.general,
    DayFlowIncomeEvent? initialIncome,
    bool allowPendingIncomePrompt = true,
    bool freshSession = false,
    bool navigateToDashboardOnSuccess = false,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: 'Dismiss DayFlow',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return DayFlowOverlay(
          onPlanActivated: onPlanActivated,
          initialPrompt: initialPrompt,
          prefillPrompt: prefillPrompt,
          task: task,
          initialIncome: initialIncome,
          allowPendingIncomePrompt: allowPendingIncomePrompt,
          freshSession: freshSession,
          navigateToDashboardOnSuccess: navigateToDashboardOnSuccess,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<DayFlowOverlay> createState() => _DayFlowOverlayState();
}

class _DayFlowOverlayState extends ConsumerState<DayFlowOverlay> {
  final GlobalKey<DayFlowPlanCardState> _planCardKey =
      GlobalKey<DayFlowPlanCardState>();
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _composerScrollCtrl = ScrollController();
  final _inputFocus = FocusNode();
  final _chat = DayFlowChatService();
  final _dayxFlow = DayxFlowService();
  final _speech = stt.SpeechToText();

  final _messages = <DayFlowChatMessage>[];
  bool _thinking = false;
  bool _flowBusy = false;
  bool _listening = false;
  bool _speechReady = false;
  int _pinFailures = 0;
  bool _approving = false;
  bool _loadingHistory = false;
  DayFlowPlanDraft? _activeDraft;
  WalletHubSnapshot? _hub;
  DayFlowIncomeEvent? _incomeForAllocation;
  bool _showIncomeAllocation = false;
  DayFlowPlan? _existingPlan;
  DayFlowPlanDraft? _savedTemplate;

  static const _welcome = DayFlowCopy.budgetChatWelcome;

  DayFlowChatMessage? get _activeFlowMessage {
    for (var i = _messages.length - 1; i >= 0; i--) {
      final m = _messages[i];
      if (m.flowInteractive && m.flowSession != null && m.flowUi != null) {
        return m;
      }
    }
    return null;
  }

  bool get _inActiveFlow => _activeFlowMessage != null;

  @override
  void initState() {
    super.initState();
    _seedInstantWelcome();
    _bootstrap();
    _initSpeech();
  }

  void _seedInstantWelcome() {
    switch (widget.task) {
      case DayFlowOverlayTask.addItem:
        _messages.add(
          const DayFlowChatMessage(
            isUser: false,
            text: DayFlowCopy.chatTaskDividerAddItem,
            isTaskDivider: true,
          ),
        );
        _messages.add(
          const DayFlowChatMessage(
            isUser: false,
            text: DayFlowCopy.addItemTaskOpener,
          ),
        );
        return;
      case DayFlowOverlayTask.editBudget:
        _messages.add(
          const DayFlowChatMessage(
            isUser: false,
            text: DayFlowCopy.chatTaskDividerEditBudget,
            isTaskDivider: true,
          ),
        );
        _messages.add(
          const DayFlowChatMessage(
            isUser: false,
            text: DayFlowCopy.editBudgetTaskOpener,
          ),
        );
        return;
      case DayFlowOverlayTask.general:
        final income = widget.initialIncome;
        if (income != null) {
          _incomeForAllocation = income;
          _messages.add(
            DayFlowChatMessage(
              isUser: false,
              text: DayFlowCopy.incomeWelcome(
                formatDayFlowAmount(income.amount, income.currency),
              ),
            ),
          );
          return;
        }
        _messages.add(
          DayFlowChatMessage(
            isUser: false,
            text:
                widget.allowPendingIncomePrompt
                    ? _welcome
                    : DayFlowCopy.budgetChatWelcome,
          ),
        );
    }
  }

  String _resolveWelcomeText(WalletHubSnapshot? hub) {
    final income = _incomeForAllocation;
    if (income != null) {
      return DayFlowCopy.incomeWelcome(
        formatDayFlowAmount(income.amount, income.currency),
      );
    }
    if (widget.allowPendingIncomePrompt) {
      return _welcome;
    }
    return _walletPlannerWelcome(hub);
  }

  void _replaceFirstAssistantMessage(String text) {
    if (_messages.isEmpty || _messages.first.isUser) return;
    _messages[0] = DayFlowChatMessage(isUser: false, text: text);
  }

  void _replaceTaskOpenerIfNeeded() {
    if (widget.task == DayFlowOverlayTask.general) return;
    final openerIndex = _messages.indexWhere(
      (m) => !m.isUser && !m.isTaskDivider,
    );
    if (openerIndex < 0) return;
    _messages[openerIndex] = DayFlowChatMessage(
      isUser: false,
      text: _taskOpenerMessage(),
    );
  }

  Future<void> _initSpeech() async {
    try {
      _speechReady = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _listening = false);
          }
        },
      );
      if (mounted) setState(() {});
    } catch (_) {
      _speechReady = false;
    }
  }

  Future<void> _toggleVoice() async {
    if (!_speechReady) {
      await _initSpeech();
      if (!_speechReady) return;
    }

    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _listening = true);

    await _speech.listen(
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        _inputCtrl.text = result.recognizedWords;
        _inputCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: _inputCtrl.text.length),
        );
        setState(() {});
        _scrollComposerToEnd();
        if (result.finalResult) {
          setState(() => _listening = false);
        }
      },
    );
  }

  void _scrollComposerToEnd({int pass = 0}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_composerScrollCtrl.hasClients) return;
      final atEnd =
          _inputCtrl.selection.isCollapsed &&
          _inputCtrl.selection.baseOffset == _inputCtrl.text.length;
      if (atEnd) {
        _composerScrollCtrl.jumpTo(
          _composerScrollCtrl.position.maxScrollExtent,
        );
      }
      if (pass < 1) _scrollComposerToEnd(pass: pass + 1);
    });
  }

  Future<void> _bootstrap() async {
    final hubFuture = _refreshWalletBalance();
    _existingPlan = await DayFlowLocalStore.instance.loadPlan();

    final DayFlowConversationSnapshot snapshot;
    if (widget.freshSession || widget.task == DayFlowOverlayTask.addItem) {
      await DayFlowConversationStore.instance.clear();
      _activeDraft = null;
      snapshot = const DayFlowConversationSnapshot();
    } else {
      snapshot = await DayFlowConversationStore.instance.load();
    }

    if (_existingPlan == null && snapshot.messages.isEmpty) {
      _savedTemplate = await DayFlowLocalStore.instance.loadTemplate();
    }
    if (!mounted) return;

    if (widget.initialIncome == null && widget.allowPendingIncomePrompt) {
      _incomeForAllocation ??= await DayFlowIncomeService.instance
          .latestPending(preferCurrency: 'USD');
    }

    final hub = await hubFuture;
    if (!mounted) return;

    if (snapshot.messages.isNotEmpty) {
      setState(() {
        _messages
          ..clear()
          ..addAll(
            snapshot.messages.map(
              (m) => DayFlowChatMessage(
                isUser: m.isUser,
                text: m.text,
                planDraft: m.planDraft,
                suggestSwap: m.suggestSwap,
              ),
            ),
          );
        _activeDraft = snapshot.activeDraft;
        _hub = hub;
      });
    } else {
      setState(() {
        if (widget.task == DayFlowOverlayTask.general) {
          _replaceFirstAssistantMessage(_resolveWelcomeText(hub));
        } else {
          _replaceTaskOpenerIfNeeded();
        }
        _hub = hub;
      });
    }

    _applyComposerPrefill();
    _scrollToEnd(delayMs: 100);

    final prompt = widget.initialPrompt?.trim();
    if (prompt != null &&
        prompt.isNotEmpty &&
        _incomeForAllocation == null &&
        widget.task == DayFlowOverlayTask.general) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _submit(prompt));
    }
  }

  bool get _hasSavedPlanContext {
    final plan = _existingPlan;
    if (plan == null) return false;
    return plan.totalBudget > 0 ||
        plan.categories.isNotEmpty ||
        plan.upcoming.isNotEmpty;
  }

  DayFlowPlanDraft? get _draftForStrip {
    final draft = _activeDraft;
    if (draft == null) return null;
    if (draft.payments.isNotEmpty) return draft;
    if (draft.totalBudget > 0 &&
        draft.categories.any((c) => c.allocated > 0)) {
      return draft;
    }
    return null;
  }

  String _taskOpenerMessage() {
    switch (widget.task) {
      case DayFlowOverlayTask.addItem:
        return _hasSavedPlanContext
            ? DayFlowCopy.addItemWithPlanOpener
            : DayFlowCopy.addItemTaskOpener;
      case DayFlowOverlayTask.editBudget:
        return _hasSavedPlanContext
            ? DayFlowCopy.editBudgetWithPlanOpener
            : DayFlowCopy.editBudgetTaskOpener;
      case DayFlowOverlayTask.general:
        return '';
    }
  }

  String _planCategorySummary(DayFlowPlan plan) {
    final parts = <String>[];
    for (final c in plan.categories) {
      if (c.name.trim().isEmpty) continue;
      parts.add('${c.name} ${formatDayFlowAmount(c.allocated, plan.currency)}');
    }
    for (final u in plan.upcoming) {
      if (u.title.trim().isEmpty) continue;
      parts.add('${u.title} ${formatDayFlowAmount(u.amount, u.currency)}');
    }
    if (parts.isEmpty) return '';
    if (parts.length <= 4) return parts.join(' · ');
    return '${parts.take(3).join(' · ')} · +${parts.length - 3} more';
  }

  void _applyComposerPrefill() {
    final prefill =
        widget.prefillPrompt?.trim() ??
        (widget.task == DayFlowOverlayTask.editBudget
            ? 'Adjust my budget: '
            : null);
    if (prefill == null || prefill.isEmpty) return;
    _inputCtrl.text = prefill;
    _inputCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: prefill.length),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inputFocus.requestFocus();
        _scrollComposerToEnd();
      }
    });
  }

  String? get _chatMode {
    switch (widget.task) {
      case DayFlowOverlayTask.addItem:
        return 'addItem';
      case DayFlowOverlayTask.editBudget:
        return 'editBudget';
      case DayFlowOverlayTask.general:
        return null;
    }
  }

  bool _shouldShowPlanCard(DayFlowPlanDraft draft) {
    if (widget.task == DayFlowOverlayTask.addItem) {
      return draft.readyToApprove;
    }
    return true;
  }

  String get _composerHint {
    switch (widget.task) {
      case DayFlowOverlayTask.addItem:
        return DayFlowCopy.chatComposerHintAddItem;
      case DayFlowOverlayTask.editBudget:
        return DayFlowCopy.chatComposerHintEditBudget;
      case DayFlowOverlayTask.general:
        if (_inActiveFlow) return 'Message DayX…';
        return 'Message DayX…';
    }
  }

  String _walletPlannerWelcome(WalletHubSnapshot? hub) {
    final profile = ref.read(profileViewModelProvider).user;
    final createdAt = profile?.createdAt;
    int? accountAgeDays;
    if (createdAt != null && createdAt.isNotEmpty) {
      final created = DateTime.tryParse(createdAt);
      if (created != null) {
        accountAgeDays = DateTime.now().difference(created.toLocal()).inDays;
      }
    }
    return DayFlowWelcomeBuilder.build(
      firstName: profile?.firstName ?? '',
      hub: hub,
      transactionCount: ref.read(transactionsProvider).transactions.length,
      accountAgeDays: accountAgeDays,
    );
  }

  void _startIncomeAllocation() {
    setState(() => _showIncomeAllocation = true);
    _scrollToEnd();
  }

  void _focusAddItemComposer() {
    _inputCtrl.text = '';
    _inputFocus.requestFocus();
    _scrollToEnd();
  }

  void _applyAllocationDraft(DayFlowPlanDraft draft) {
    setState(() {
      _activeDraft = draft;
      _incomeForAllocation = null;
      _showIncomeAllocation = false;
      _messages.add(
        DayFlowChatMessage(
          isUser: false,
          text:
              'Here\'s a starter allocation for ${formatDayFlowAmount(draft.totalBudget, 'NGN')}. Tweak anything, then approve when ready.',
          planDraft: draft,
        ),
      );
    });
    _persistConversation();
    _scrollToEnd();
  }

  Future<void> _dismissIncomePrompt() async {
    final income = _incomeForAllocation;
    if (income != null) {
      await DayFlowIncomeService.instance.dismiss(income);
    }
    if (!mounted) return;
    setState(() {
      _incomeForAllocation = null;
      _showIncomeAllocation = false;
    });
  }

  Future<WalletHubSnapshot?> _refreshWalletBalance() async {
    try {
      final hub = await walletService.fetchWalletHub();
      if (mounted) {
        setState(() => _hub = hub);
      } else {
        _hub = hub;
      }
      return hub;
    } catch (_) {
      return _hub;
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _composerScrollCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _dismiss({bool? result}) {
    FocusScope.of(context).unfocus();
    Navigator.of(context, rootNavigator: true).pop(result);
  }

  Future<void> _persistConversation() async {
    await DayFlowConversationStore.instance.save(
      messages:
          _messages
              .map(
                (m) => DayFlowStoredMessage(
                  text: m.text,
                  isUser: m.isUser,
                  planDraft: m.planDraft,
                  suggestSwap: m.suggestSwap,
                ),
              )
              .toList(),
      activeDraft: _activeDraft,
    );
  }

  List<DayFlowHistoryMessage> _buildHistory() {
    final history = <DayFlowHistoryMessage>[];
    for (final msg in _messages) {
      if (msg.isTaskDivider) continue;
      if (msg.isUser) {
        history.add(DayFlowHistoryMessage(role: 'user', content: msg.text));
      } else if (msg.text != _welcome &&
          !DayFlowWelcomeBuilder.isWelcomeMessage(msg.text)) {
        var content = msg.text;
        if (msg.planDraft != null) {
          final draft = msg.planDraft!;
          final cats = draft.categories
              .map((c) => '${c.name} ₦${c.allocated.toStringAsFixed(0)}')
              .join(', ');
          final pays = draft.payments
              .map(
                (p) =>
                    '${p.title} ${p.amount}${p.dueLabel != null ? ' ${p.dueLabel}' : ''}'
                    '${p.recipientHint != null ? ' → ${p.recipientHint}' : ''}',
              )
              .join('; ');
          content +=
              '\n[Budget draft: ${formatDayFlowAmount(draft.totalBudget, 'NGN')} total'
              '${cats.isNotEmpty ? ' — $cats' : ''}'
              '${pays.isNotEmpty ? ' — payments: $pays' : ''}'
              '${msg.suggestSwap ? ' — needs more wallet balance' : ''}]';
        }
        history.add(
          DayFlowHistoryMessage(role: 'assistant', content: content),
        );
      }
    }
    return history.length > 20 ? history.sublist(history.length - 20) : history;
  }

  Future<void> _submit([String? raw]) async {
    final text = (raw ?? _inputCtrl.text).trim();
    if (text.isEmpty || _thinking || _flowBusy) return;

    if (_listening) await _speech.stop();

    if (_inActiveFlow && raw == null) {
      await _submitActiveFlowInput(text);
      return;
    }

    setState(() {
      _messages.add(DayFlowChatMessage(isUser: true, text: text));
      _thinking = true;
      _inputCtrl.clear();
      _listening = false;
    });
    _scrollToEnd();
    await _persistConversation();

    try {
      await _refreshWalletBalance();
      final response = await _chat.chat(
        message: text,
        history: _buildHistory(),
        mode: _chatMode,
      );
      if (!mounted) return;

      final draft = response.planDraft;
      if (draft != null) {
        _activeDraft = draft;
      }

      final visibleDraft =
          draft != null && _shouldShowPlanCard(draft) ? draft : null;

      setState(() {
        _messages.add(
          DayFlowChatMessage(
            isUser: false,
            text: response.reply,
            planDraft: visibleDraft,
            suggestSwap: response.suggestSwap,
          ),
        );
        _thinking = false;
      });
      await _persistConversation();
      _scrollToEnd();
    } on DayFlowChatException catch (e) {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _messages.add(DayFlowChatMessage(isUser: false, text: e.message));
      });
      await _persistConversation();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _thinking = false;
        _messages.add(
          DayFlowChatMessage(
            isUser: false,
            text:
                msg.contains('503') ||
                        msg.toLowerCase().contains('not configured')
                    ? 'DayFlow AI isn\'t available right now. Make sure the server has GROQ_API_KEY set, then try again.'
                    : 'Something went wrong. Check your connection and try again.',
          ),
        );
      });
      await _persistConversation();
    }
  }

  Future<void> _saveTemplate(DayFlowPlanDraft draft) async {
    try {
      await DayFlowLocalStore.instance.saveTemplate(draft);
      if (!mounted) return;
      TopSnackbar.showSafe(context, message: DayFlowCopy.templateSaved);
    } catch (e) {
      if (!mounted) return;
      TopSnackbar.showSafe(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  void _applySavedTemplate() {
    final template = _savedTemplate;
    if (template == null) return;
    setState(() {
      _activeDraft = template;
      _messages.add(
        DayFlowChatMessage(
          isUser: false,
          text:
              'Starting from your saved template (${formatDayFlowAmount(template.totalBudget, 'NGN')}). Adjust anything, then automate when ready.',
          planDraft: template,
        ),
      );
    });
    _persistConversation();
    _scrollToEnd();
  }

  void _editBudgetInChat() {
    _inputFocus.requestFocus();
    _inputCtrl.text = 'Adjust my budget: ';
    _inputCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _inputCtrl.text.length),
    );
    _scrollComposerToEnd();
  }

  Future<void> _approvePlan(DayFlowPlanDraft draft) async {
    if (_approving) return;
    if (dayFlowBudgetExceedsWallet(
      hub: _hub,
      budgetTotal: draft.totalBudget,
      budgetCurrency: kDayFlowWalletCurrency,
    )) {
      TopSnackbar.showSafe(
        context,
        message:
            'Heads up — upcoming autopays total ${formatDayFlowBudgetAmount(amount: draft.totalBudget, currency: draft.currency, sourceCurrency: draft.inputCurrency)}. '
            'We\'ll charge your wallet when each payment is due.',
        isError: false,
      );
    }
    final finalDraft = _activeDraft ?? draft;
    final validation = validateDraftBeforeCreate(finalDraft);
    if (!validation.ok) {
      TopSnackbar.showSafe(
        context,
        message: validation.message.isNotEmpty
            ? validation.message
            : DayFlowCopy.createValidationFailed,
        isError: true,
      );
      return;
    }
    setState(() => _approving = true);

    Future<void> activatePlan() async {
      final flow = await dayFlowApiService.createFlowFromDraft(finalDraft);
      final plan = await dayFlowApiService.syncPlanFromDraft(finalDraft);
      await DayFlowLocalStore.instance.savePlan(plan);
      DayflowDashboardCache.instance.put(
        DayFlowAnalytics.buildLocalDashboard(
          plan: plan,
          hub: _hub,
          flows: [flow],
        ),
      );
      if (_incomeForAllocation != null) {
        unawaited(DayFlowIncomeService.instance.dismiss(_incomeForAllocation!));
      }
      await DayFlowConversationStore.instance.clear();

      if (!mounted) return;
      setState(() {
        _approving = false;
        _messages.add(
          const DayFlowChatMessage(
            isUser: false,
            text: DayFlowCopy.flowActivated,
          ),
        );
      });
      widget.onPlanActivated?.call();
      if (mounted) {
        _dismiss(result: true);
        if (widget.navigateToDashboardOnSuccess) {
          await DayBudgetFlow.openDashboard(context);
        }
      }
    }

    try {
      if (widget.task == DayFlowOverlayTask.addItem) {
        final pinProcessing = ValueNotifier<bool>(false);
        final completed = await TransactionPinFlow.requestPinAndRun<bool>(
          context: context,
          ref: ref,
          isProcessing: pinProcessing,
          task: (_) async {
            await activatePlan();
            return true;
          },
        );
        if (completed != true && mounted) {
          setState(() => _approving = false);
        }
        return;
      }

      await activatePlan();
    } catch (e) {
      if (!mounted) return;
      setState(() => _approving = false);
      TopSnackbar.showSafe(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  void _deactivateFlowCards() {
    for (var i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      if (m.flowInteractive) {
        _messages[i] = DayFlowChatMessage(
          isUser: m.isUser,
          text: m.text,
          planDraft: m.planDraft,
          suggestSwap: m.suggestSwap,
          offerSavedTemplate: m.offerSavedTemplate,
          flowUi: m.flowUi,
          flowSession: m.flowSession,
          flowInteractive: false,
          successReceipt: m.successReceipt,
        );
      }
    }
  }

  Future<void> _applyFlowResult(DayxFlowTurnResult result) async {
    if (!mounted) return;

    if (result.ui?.step == 'review') {
      _pinFailures = 0;
    }

    final shouldExecute = DayxFlowPinRetry.shouldRunExecute(result);
    final pinSession = result.session;
    final pinUi = result.ui;

    setState(() {
      _deactivateFlowCards();
      _messages.add(
        DayFlowChatMessage(
          isUser: false,
          text: result.reply,
          flowUi: result.ui,
          flowSession: result.session,
          flowInteractive: result.session != null && result.ui != null,
        ),
      );
      _flowBusy = false;
    });
    _scrollToEnd();
    await _persistConversation();

    if (!shouldExecute) return;

    final outcome = await DayxFlowExecutor.run(
      context: context,
      ref: ref,
      execute: result.execute!,
    );
    if (!mounted) return;

    if (outcome.success) {
      _pinFailures = 0;
      await _refreshWalletBalance();
      final receipt = outcome.receipt;
      setState(() {
        _deactivateFlowCards();
        _messages.add(
          DayFlowChatMessage(
            isUser: false,
            text:
                receipt != null
                    ? 'Top-up complete. Your balance is now ${formatDayFlowAmount(dayFlowWalletBalance(_hub), kDayFlowWalletCurrency)}. We can continue when you\'re ready.'
                    : 'Your balance is now ${formatDayFlowAmount(dayFlowWalletBalance(_hub), kDayFlowWalletCurrency)}. We can continue when you\'re ready.',
            successReceipt: receipt,
          ),
        );
      });
      await _persistConversation();
      _scrollToEnd();
      return;
    }

    if (!outcome.invalidPin) {
      setState(() {
        _deactivateFlowCards();
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages.removeLast();
        }
        _messages.add(
          DayFlowChatMessage(
            isUser: false,
            text: outcome.message ?? 'Could not complete. Please try again.',
          ),
        );
      });
      await _persistConversation();
      _scrollToEnd();
      return;
    }

    _pinFailures++;
    final retryMsg = DayxFlowPinRetry.messageAfterFailure(_pinFailures);

    setState(() {
      _deactivateFlowCards();
      if (_messages.isNotEmpty && !_messages.last.isUser) {
        _messages.removeLast();
      }
      if (_pinFailures >= DayxFlowPinRetry.maxAttempts) {
        _messages.add(
          DayFlowChatMessage(
            isUser: false,
            text: retryMsg ?? 'Too many wrong PINs. Please start again.',
          ),
        );
      } else {
        _messages.add(
          DayFlowChatMessage(
            isUser: false,
            text: retryMsg ?? 'Wrong PIN. Try again.',
            flowUi: pinUi,
            flowSession: pinSession,
            flowInteractive: pinSession != null && pinUi != null,
          ),
        );
      }
    });
    await _persistConversation();
    _scrollToEnd();
  }

  Future<void> _flowSelect(
    DayxFlowSession session,
    DayxFlowOption option, {
    String? userText,
  }) async {
    if (_flowBusy) return;
    setState(() {
      _messages.add(
        DayFlowChatMessage(
          isUser: true,
          text: dayFlowUserBubbleForOption(option, typed: userText),
        ),
      );
      _flowBusy = true;
    });
    _scrollToEnd();
    try {
      final result = await _dayxFlow.turn(
        flow: session.flow,
        action: 'select',
        session: session,
        optionId: option.id,
        ref: ref,
      );
      await _applyFlowResult(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _flowBusy = false;
        _messages.add(
          DayFlowChatMessage(
            isUser: false,
            text: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      });
      await _persistConversation();
    }
  }

  Future<void> _flowSubmit(
    DayxFlowSession session,
    String field,
    String value,
  ) async {
    if (_flowBusy) return;
    final isPin = _activeFlowMessage?.flowUi?.input?.isPin == true;
    final bubbleText = isPin ? '••••' : value;
    setState(() {
      _messages.add(DayFlowChatMessage(isUser: true, text: bubbleText));
      _flowBusy = true;
    });
    _scrollToEnd();
    try {
      Object? submitValue = value;
      if (field == 'amount') {
        submitValue = double.tryParse(value.replaceAll(',', '')) ?? value;
      }
      final result = await _dayxFlow.turn(
        flow: session.flow,
        action: 'submit',
        session: session,
        field: field,
        value: submitValue,
        utterance: isPin ? null : value,
        ref: ref,
      );
      await _applyFlowResult(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _flowBusy = false;
        _messages.add(
          DayFlowChatMessage(
            isUser: false,
            text: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      });
      await _persistConversation();
    }
  }

  Future<void> _flowUtterance(DayxFlowSession session, String utterance) async {
    if (_flowBusy) return;
    setState(() {
      _messages.add(DayFlowChatMessage(isUser: true, text: utterance));
      _flowBusy = true;
      _inputCtrl.clear();
    });
    _scrollToEnd();
    try {
      final result = await _dayxFlow.turn(
        flow: session.flow,
        action: 'utterance',
        session: session,
        utterance: utterance,
        ref: ref,
      );
      await _applyFlowResult(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _flowBusy = false;
        _messages.add(
          DayFlowChatMessage(
            isUser: false,
            text: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      });
      await _persistConversation();
      _scrollToEnd();
    }
  }

  Future<void> _flowCancel(DayxFlowSession session) async {
    if (_flowBusy) return;
    setState(() => _flowBusy = true);
    try {
      final result = await _dayxFlow.turn(
        flow: session.flow,
        action: 'cancel',
        session: session,
        ref: ref,
      );
      await _applyFlowResult(result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _flowBusy = false);
    }
  }

  Future<void> _submitActiveFlowInput(String text) async {
    final active = _activeFlowMessage;
    if (active == null || active.flowSession == null || active.flowUi == null) {
      return;
    }
    _inputCtrl.clear();
    final session = active.flowSession!;
    final ui = active.flowUi!;
    final trimmed = text.trim();
    final lower = trimmed.toLowerCase();

    if (lower == 'cancel' || lower == 'stop') {
      setState(() {
        _messages.add(DayFlowChatMessage(isUser: true, text: trimmed));
      });
      await _flowCancel(session);
      return;
    }

    final input = ui.input;
    if (input != null) {
      await _flowSubmit(session, input.field, trimmed);
      return;
    }

    final matched = dayFlowMatchFlowOption(ui, trimmed);
    if (matched != null) {
      await _flowSelect(session, matched, userText: trimmed);
      return;
    }

    await _flowUtterance(session, trimmed);
  }

  Future<void> _openAddMoney() async {
    if (!mounted) return;
    await Navigator.pushNamed(context, AppRoute.addMoneySelectWalletView);
    await _refreshWalletBalance();
  }

  void _scrollToEnd({int delayMs = 0}) {
    Future<void>.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted || !_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withValues(alpha: 0.2)),
            ),
            Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Colors.transparent,
              body: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(context),
                    const SizedBox(height: 18),
                    Expanded(
                      child: AgentChatHorizontalPadding(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!_loadingHistory)
                              DayFlowBudgetStrip(
                                hub: _hub,
                                draft: _draftForStrip,
                              ),
                            Expanded(
                              child:
                                  _loadingHistory
                                      ? const DayfiLoadingCenter()
                                      : GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap:
                                            () =>
                                                FocusScope.of(context).unfocus(),
                                        child: ListView.builder(
                                          controller: _scrollCtrl,
                                          keyboardDismissBehavior:
                                              ScrollViewKeyboardDismissBehavior
                                                  .manual,
                                          padding: const EdgeInsets.fromLTRB(
                                            0,
                                            8,
                                            0,
                                            8,
                                          ),
                                          itemCount:
                                              _messages.length +
                                              ((_thinking || _flowBusy) ? 1 : 0),
                                          itemBuilder: (context, index) {
                                            if ((_thinking || _flowBusy) &&
                                                index == _messages.length) {
                                              return _typingIndicator();
                                            }
                                            return _messageBubble(
                                              _messages[index],
                                            );
                                          },
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AgentChatHorizontalPadding(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _inputCtrl,
                        builder: (context, value, _) {
                          return _composer(
                            canSend:
                                value.text.trim().isNotEmpty &&
                                !_thinking &&
                                !_flowBusy,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          const SizedBox(width: 48),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  DayFlowCopy.featureName,
                  style: AppTypography.titleLarge.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DayFlowCopy.poweredByDayX,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: 'Chirp',
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Close DayFlow',
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () => _dismiss(),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _composer({required bool canSend}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_listening)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Text(
                'Listening… tap mic to stop',
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 12.5,
                  color: AppColors.teal500,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: _composerHint,
                    controller: _inputCtrl,
                    scrollController: _composerScrollCtrl,
                    focusNode: _inputFocus,
                    keyboardType:
                        _activeFlowMessage?.flowUi?.input?.isPin == true
                            ? TextInputType.number
                            : _activeFlowMessage?.flowUi?.input?.isAmount ==
                                true
                            ? const TextInputType.numberWithOptions(
                              decimal: true,
                            )
                            : TextInputType.multiline,
                    textInputAction: TextInputAction.send,
                    textCapitalization: TextCapitalization.sentences,
                    capitalizeFirstLetter: false,
                    obscureText:
                        _activeFlowMessage?.flowUi?.input?.isPin == true,
                    minLines: 1,
                    maxLines: 3,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    onChanged: (_) {
                      setState(() {});
                      _scrollComposerToEnd();
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 8),
                _composerIconButton(
                  onTap: _speechReady ? _toggleVoice : null,
                  color:
                      _listening
                          ? AppColors.teal500.withValues(alpha: 0.2)
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.08),
                  icon: Icon(
                    _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    size: 22,
                    color:
                        _listening
                            ? AppColors.teal500
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(width: 8),
                _composerIconButton(
                  onTap: canSend ? () => _submit() : null,
                  color:
                      canSend
                          ? AppColors.teal700
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.08),
                  icon: Icon(
                    Icons.arrow_upward_rounded,
                    color:
                        canSend
                            ? AppColors.neutral0
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _composerIconButton({
    required VoidCallback? onTap,
    required Color color,
    required Widget icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 44, height: 44, child: Center(child: icon)),
        ),
      ),
    );
  }

  Widget _messageBubble(DayFlowChatMessage msg) {
    if (msg.isTaskDivider) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Divider(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      );
    }

    final align = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bg =
        msg.isUser
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surface;
    final displayText =
        msg.isUser
            ? msg.text
            : dayFlowInlineFlowBubbleText(text: msg.text, flowUi: msg.flowUi);

    return Align(
      alignment: align,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: AgentChatLayout.bubbleMaxWidth(context),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(DayFlowChatUi.bubbleRadius),
          border: Border.all(
            color:
                msg.isUser
                    ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1)
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!msg.isUser)
                Text(
                DayFlowCopy.featureName,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal700,
                ),
              ),
            if (!msg.isUser) const SizedBox(height: 4),
            if (displayText.isNotEmpty)
              Text(
                displayText,
                style: DayFlowChatUi.body(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            if (msg.successReceipt != null) ...[
              const SizedBox(height: 12),
              DayxChatSuccessReceipt(receipt: msg.successReceipt!),
            ],
            if (msg.suggestSwap && !msg.isUser) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: _openAddMoney,
                  child: Text(
                    'Add money →',
                    style: DayFlowChatUi.emphasis(
                      context,
                    ).copyWith(color: AppColors.teal500),
                  ),
                ),
              ),
            ],
            if (msg.offerSavedTemplate && !msg.isUser) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: _applySavedTemplate,
                  child: Text(
                    DayFlowCopy.useSavedTemplate,
                    style: DayFlowChatUi.emphasis(
                      context,
                    ).copyWith(color: AppColors.teal500),
                  ),
                ),
              ),
            ],
            if (msg.planDraft != null &&
                _shouldShowPlanCard(msg.planDraft!)) ...[
              const SizedBox(height: 12),
              DayFlowPlanCard(
                key: _planCardKey,
                draft: msg.planDraft!,
                hub: _hub,
                budgetCurrency: kDayFlowWalletCurrency,
                canApprove: true,
                reviewOnly: widget.task == DayFlowOverlayTask.addItem,
                approving: _approving,
                onApprove:
                    () => _approvePlan(
                      _planCardKey.currentState?.resolveForApproval(
                            _activeDraft ?? msg.planDraft!,
                          ) ??
                          _activeDraft ??
                          msg.planDraft!,
                    ),
                onAddMoney: _openAddMoney,
                onSaveTemplate: () => _saveTemplate(_activeDraft ?? msg.planDraft!),
                onEdit: _editBudgetInChat,
                onPaymentChanged: (index, payment) {
                  if (_activeDraft == null) return;
                  final payments = List<DayFlowPaymentDraft>.of(
                    _activeDraft!.payments,
                  );
                  if (index < payments.length) {
                    payments[index] = payment;
                    _activeDraft = _activeDraft!.copyWith(payments: payments);
                    _persistConversation();
                  }
                },
                onDraftResolved: (resolved) {
                  _activeDraft = resolved;
                  _persistConversation();
                },
              ),
            ],
            if (_incomeForAllocation != null &&
                !_showIncomeAllocation &&
                msg == _messages.last &&
                !msg.isUser) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: _startIncomeAllocation,
                  child: Text(
                    DayFlowCopy.startAutomatedBudget,
                    style: DayFlowChatUi.emphasis(
                      context,
                    ).copyWith(color: AppColors.teal500),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: _focusAddItemComposer,
                  child: Text(
                    DayFlowCopy.addItemFromIncome,
                    style: DayFlowChatUi.emphasis(
                      context,
                    ).copyWith(color: AppColors.teal500),
                  ),
                ),
              ),
              Center(
                child: DayFlowChatUi.cancelTextButton(
                  context,
                  label: DayFlowCopy.notNow,
                  onPressed: _dismissIncomePrompt,
                ),
              ),
            ],
            if (_showIncomeAllocation &&
                _incomeForAllocation != null &&
                msg == _messages.last &&
                !msg.isUser) ...[
              const SizedBox(height: 12),
              DayFlowAllocationBuilder(
                income: _incomeForAllocation!,
                existingPlan: _existingPlan,
                onConfirm: _applyAllocationDraft,
              ),
              Center(
                child: DayFlowChatUi.cancelTextButton(
                  context,
                  label: DayFlowCopy.notNow,
                  onPressed: _dismissIncomePrompt,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(DayFlowChatUi.bubbleRadius),
        ),
        child: const DayfiLoadingIndicator(),
      ),
    );
  }
}

/// Floating + entry for DayFlow (matches DayX orb pattern).
class DayFlowOrbButton extends StatelessWidget {
  final VoidCallback onTap;

  const DayFlowOrbButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open DayFlow',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.teal500,
            boxShadow: [
              BoxShadow(
                color: AppColors.teal500.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
