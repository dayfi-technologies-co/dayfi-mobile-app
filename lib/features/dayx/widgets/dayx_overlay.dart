import 'dart:ui';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/agent_chat_layout.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/dayx/models/dayx_intent.dart';
import 'package:dayfi/features/dayx/services/dayx_response_executor.dart';
import 'package:dayfi/features/dayx/widgets/dayx_navigation.dart';
import 'package:dayfi/features/dayx/services/dayx_chat_service.dart';
import 'package:dayfi/features/dayx/services/dayx_quick_routes.dart';
import 'package:dayfi/features/dayx/constants/dayx_copy.dart';
import 'package:dayfi/features/dayx/helpers/dayx_welcome_builder.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/dayx/constants/dayx_product_knowledge.dart';
import 'package:dayfi/features/dayx/services/dayx_conversation_store.dart';
import 'package:dayfi/features/dayx/models/dayx_flow.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_service.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_executor.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_pin_retry.dart';
import 'package:dayfi/features/dayx/widgets/dayx_inline_success.dart';
import 'package:dayfi/features/dayx/widgets/dayx_suggestion_chips.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:dayfi/services/local/intercom_support_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class DayxOverlay extends ConsumerStatefulWidget {
  final DayxChangeTab onChangeTab;
  final void Function(String target)? onNavigate;

  const DayxOverlay({super.key, required this.onChangeTab, this.onNavigate});

  static Future<void> show(
    BuildContext context, {
    required DayxChangeTab onChangeTab,
    void Function(String target)? onNavigate,
  }) {
    return showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: 'Dismiss DayX',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return DayxOverlay(onChangeTab: onChangeTab, onNavigate: onNavigate);
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
  ConsumerState<DayxOverlay> createState() => _DayxOverlayState();
}

class _DayxOverlayState extends ConsumerState<DayxOverlay> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _composerScrollCtrl = ScrollController();
  final _inputFocus = FocusNode();
  final _chat = DayxChatService();
  final _flow = DayxFlowService();
  final _speech = stt.SpeechToText();

  final _messages = <DayxChatMessage>[];
  bool _thinking = false;
  bool _flowBusy = false;
  int _pinFailures = 0;
  int _pinFieldGeneration = 0;
  bool _loadingHistory = false;
  bool _listening = false;
  bool _speechReady = false;
  DayxStatus? _status;
  WalletHubSnapshot? _cachedHub;
  String? _lastSubmittedText;
  DateTime? _lastSubmittedAt;
  bool _showWelcomeSuggestions = true;

  DayxChatMessage? get _activeFlowMessage {
    for (var i = _messages.length - 1; i >= 0; i--) {
      final m = _messages[i];
      if (m.flowInteractive && m.flowSession != null && m.flowUi != null) {
        return m;
      }
    }
    return null;
  }

  bool get _inActiveFlow => _activeFlowMessage != null;

  static final _flowAckPrefix = RegExp(r'^Got it — .*?\.\s*', dotAll: true);
  static final _accountVerifiedPrefix = RegExp(
    r'^Account verified:\s*[^.]+\.\s*',
    caseSensitive: false,
  );
  static final _trailingFlowGuide = RegExp(
    r'\s+Popular banks are at the top.*$',
    caseSensitive: false,
  );

  String _bubbleDisplayText(DayxChatMessage msg) {
    var text = msg.text.trim();
    for (final re in [_flowAckPrefix, _accountVerifiedPrefix]) {
      if (re.hasMatch(text)) {
        text = text.replaceFirst(re, '').trim();
      }
    }
    text = text.replaceFirst(_trailingFlowGuide, '').trim();

    final ui = msg.flowUi;
    if (ui == null) {
      return text.isEmpty ? msg.text.trim() : text;
    }

    final lower = text.toLowerCase();
    final buf = StringBuffer(text.isEmpty ? msg.text.trim() : text);

    if (ui.rateLine != null && ui.rateLine!.isNotEmpty) {
      buf.writeln('\n${ui.rateLine}');
    }

    if (ui.review.isNotEmpty) {
      buf.writeln('');
      for (final line in ui.review) {
        buf.writeln('${line.label}: ${line.value}');
      }
      if (!lower.contains('confirm')) {
        final flow = msg.flowSession?.flow ?? '';
        final verb = flow == 'pay' ? 'pay this bill' : 'send';
        buf.writeln('\nReply confirm to $verb, or cancel to stop.');
      }
    } else if (ui.options.isNotEmpty && ui.input == null) {
      buf.writeln('');
      final selectable =
          ui.options
              .where((o) => o.id != 'confirm' && o.id != 'cancel')
              .toList();
      for (var i = 0; i < selectable.length; i++) {
        final opt = selectable[i];
        final subtitle =
            opt.subtitle != null && opt.subtitle!.isNotEmpty
                ? ' — ${opt.subtitle}'
                : '';
        buf.writeln('${i + 1}. ${opt.label}$subtitle');
      }
      if (ui.options.any((o) => o.id == 'confirm')) {
        if (!lower.contains('confirm')) {
          buf.writeln('\nReply confirm when ready, or cancel.');
        }
      } else {
        buf.writeln('\nReply with a number or name.');
      }
    }

    final input = ui.input;
    if (input != null) {
      final body = buf.toString().toLowerCase();
      if (input.isPin && !body.contains('pin')) {
        buf.writeln('\nEnter your 4-digit PIN.');
      } else if (input.isAmount && !body.contains('amount')) {
        buf.writeln('\nEnter the amount.');
      } else if (input.placeholder != null &&
          input.placeholder!.isNotEmpty &&
          !body.contains(input.placeholder!.toLowerCase())) {
        buf.writeln('\n${input.placeholder}');
      }
    }

    return buf.toString().trim();
  }

  static bool _isCasualMessage(String text) {
    final q = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
    const casual = {
      'hey',
      'hi',
      'hello',
      'yo',
      'cool',
      'thanks',
      'thank you',
      'thx',
      'ok',
      'okay',
      'great',
      'nice',
      'good',
      'perfect',
      'awesome',
      'bet',
      'alright',
      'sure',
    };
    return casual.contains(q);
  }

  bool _isDuplicateRapidSubmit(String text) {
    final now = DateTime.now();
    if (_lastSubmittedText == text &&
        _lastSubmittedAt != null &&
        now.difference(_lastSubmittedAt!) <
            const Duration(milliseconds: 900)) {
      return true;
    }
    _lastSubmittedText = text;
    _lastSubmittedAt = now;
    return false;
  }

  Future<void> _tryStartFlowFromChat(String flowId, String userText) async {
    if (_isCasualMessage(userText)) return;
    await _startFlow(flowId, userLabel: userText, skipUserBubble: true);
  }

  String _userBubbleForOption(DayxFlowOption option, {String? typed}) {
    final raw = typed?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    switch (option.id) {
      case 'confirm':
        return 'Confirm';
      case 'cancel':
        return 'Cancel';
      default:
        return option.label;
    }
  }

  String _formatBalanceMessage(WalletHubSnapshot hub) {
    final rows = hub.displayRows.take(4).toList();
    final lines = StringBuffer('Your balance:\n\n');
    lines.writeln('Total: ${hub.totalAvailableBalance.formatted}');
    if (rows.isNotEmpty) {
      lines.writeln('');
      lines.writeln('View as:');
      for (final row in rows) {
        lines.writeln('${row.currency}: ${row.formattedBalance}');
      }
    }
    return lines.toString().trim();
  }

  void _dismissTryAsking() {
    if (!_showWelcomeSuggestions) return;
    setState(() => _showWelcomeSuggestions = false);
  }

  bool get _shouldShowWelcomeSuggestions {
    if (!_showWelcomeSuggestions) return false;
    if (_inActiveFlow || _thinking || _flowBusy) return false;
    if (_messages.isEmpty || _messages.first.isUser) return false;
    return DayxWelcomeBuilder.isWelcomeGreeting(_messages.first.text);
  }

  Widget _welcomeSuggestionsPanel() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final headingStyle = TextStyle(
      fontFamily: 'Chirp',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: onSurface.withValues(alpha: 0.72),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DayxCopy.trySayingHeading, style: headingStyle),
          const SizedBox(height: 8),
          DayxSuggestionChips(
            suggestions: DayxCopy.voiceTryPhrases,
            onSelected: _submit,
          ),
          const SizedBox(height: 16),
          Text(DayxCopy.actionHeading, style: headingStyle),
          const SizedBox(height: 8),
          DayxSuggestionChips(
            suggestions: DayxCopy.starterSuggestions,
            onSelected: _submit,
          ),
        ],
      ),
    );
  }

  String get _composerHint {
    final input = _activeFlowMessage?.flowUi?.input;
    if (input != null) {
      if (input.isPin) return 'Enter your 4-digit PIN';
      if (input.isAmount) return 'Enter amount';
      return input.placeholder ?? input.label;
    }
    final step = _activeFlowMessage?.flowUi?.step ?? '';
    if (step == 'review') return 'Type confirm';
    if (step == 'select_bank') return 'Type bank name (e.g. Opay, GTBank)';
    if (step == 'input_amount') return 'Enter amount';
    if (_inActiveFlow) return 'Reply to DayX…';
    return 'Ask DayX…';
  }

  void _keepInputFocused() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_inputFocus.hasFocus) {
        _inputFocus.requestFocus();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _inputFocus.addListener(_onInputFocusChange);
    final user = ref.read(profileViewModelProvider).user;
    _messages.add(
      DayxChatMessage(
        isUser: false,
        text: DayxWelcomeBuilder.greetingLine(user?.firstName),
      ),
    );
    _messages.add(
      DayxChatMessage(
        isUser: false,
        text: DayxWelcomeBuilder.introPlaceholder(),
      ),
    );
    _bootstrap();
    _initSpeech();
    _loadStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToEnd(delayMs: 80);
    });
  }

  Future<void> _bootstrap() async {
    await DayxConversationStore.instance.clear();
    if (!mounted) return;
    try {
      final welcomeMessages = await DayxWelcomeBuilder.buildChatWelcomeMessages(
        ref,
      );
      if (!mounted) return;
      setState(() {
        if (_messages.length >= 2 &&
            !_messages[0].isUser &&
            !_messages[1].isUser) {
          _messages[0] = DayxChatMessage(
            isUser: false,
            text: welcomeMessages[0],
          );
          _messages[1] = DayxChatMessage(
            isUser: false,
            text: welcomeMessages[1],
          );
        } else {
          _messages
            ..clear()
            ..addAll(
              welcomeMessages.map(
                (text) => DayxChatMessage(isUser: false, text: text),
              ),
            );
        }
      });
    } catch (_) {}
    if (!mounted) return;
    await _persistMessages();
  }

  Future<void> _persistMessages() async {
    await DayxConversationStore.instance.save(_messages);
  }

  Future<void> _loadStatus() async {
    final status = await _chat.fetchStatus();
    if (!mounted) return;
    setState(() => _status = status);
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

  void _onInputFocusChange() {
    if (!_inputFocus.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToEnd(delayMs: 80);
    });
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

  @override
  void dispose() {
    _inputFocus.removeListener(_onInputFocusChange);
    _speech.stop();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _composerScrollCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _dismiss() {
    FocusScope.of(context).unfocus();
    Navigator.of(context, rootNavigator: true).pop();
  }

  List<DayxHistoryMessage> _buildHistory() {
    final history = <DayxHistoryMessage>[];
    for (final msg in _messages) {
      if (msg.isUser) {
        history.add(DayxHistoryMessage(role: 'user', content: msg.text));
      } else if (!msg.text.startsWith('Hi —') &&
          !msg.text.startsWith('Hi,') &&
          !DayxWelcomeBuilder.isWelcomeMessage(msg.text)) {
        history.add(DayxHistoryMessage(role: 'assistant', content: msg.text));
      }
    }
    return history.length > 20 ? history.sublist(history.length - 20) : history;
  }

  void _deactivateFlowCards() {
    for (var i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      if (m.flowInteractive) {
        _messages[i] = DayxChatMessage(
          isUser: m.isUser,
          text: m.text,
          response: m.response,
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

    if (result.session != null || result.ui != null) {
      _dismissTryAsking();
    }

    if (result.ui?.step == 'review') {
      _pinFailures = 0;
    }

    final shouldExecute = DayxFlowPinRetry.shouldRunExecute(result);
    final pinSession = result.session;
    final pinUi = result.ui;

    setState(() {
      _deactivateFlowCards();
      _messages.add(
        DayxChatMessage(
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
    await _persistMessages();

    if (!shouldExecute) return;

    final outcome = await DayxFlowExecutor.run(
      context: context,
      ref: ref,
      execute: result.execute!,
    );
    if (!mounted) return;

    if (outcome.success) {
      _pinFailures = 0;
      final receipt = outcome.receipt;
      setState(() {
        _deactivateFlowCards();
        _messages.add(
          DayxChatMessage(
            isUser: false,
            text:
                receipt != null
                    ? 'Done! Need anything else?'
                    : 'All set — your transaction went through.',
            successReceipt: receipt,
          ),
        );
      });
      await _persistMessages();
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
          DayxChatMessage(
            isUser: false,
            text: outcome.message ?? 'Transaction failed. Please try again.',
          ),
        );
      });
      await _persistMessages();
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
          DayxChatMessage(
            isUser: false,
            text: retryMsg ?? 'Too many wrong PINs. Please start again.',
          ),
        );
      } else {
        _messages.add(
          DayxChatMessage(
            isUser: false,
            text: retryMsg ?? 'Wrong PIN. Try again.',
            flowUi: pinUi,
            flowSession: pinSession,
            flowInteractive: pinSession != null && pinUi != null,
          ),
        );
        _pinFieldGeneration++;
      }
    });
    await _persistMessages();
    _scrollToEnd();
  }

  String? _flowIdFromStartFlow(String? startFlow) {
    if (startFlow == null || startFlow.isEmpty) return null;
    switch (startFlow.toLowerCase()) {
      case 'send':
        return DayxFlowId.send;
      case 'add_money':
      case 'top_up':
        return DayxFlowId.addMoney;
      case 'pay':
        return DayxFlowId.pay;
      default:
        return null;
    }
  }

  String? _flowIdForNavigateTarget(String target) {
    switch (target.toLowerCase().replaceAll(' ', '_')) {
      case 'send':
      case 'withdraw':
        return DayxFlowId.send;
      case 'pay':
        return DayxFlowId.pay;
      case 'add_money':
        return DayxFlowId.addMoney;
      default:
        return null;
    }
  }

  Future<void> _startFlow(
    String flowId, {
    required String userLabel,
    bool skipUserBubble = false,
  }) async {
    if (_flowBusy || _thinking) return;
    _dismissTryAsking();
    _pinFailures = 0;
    setState(() {
      if (!skipUserBubble) {
        _messages.add(DayxChatMessage(isUser: true, text: userLabel));
      }
      _flowBusy = true;
      _inputCtrl.clear();
      _listening = false;
    });
    _scrollToEnd();
    await _persistMessages();
    try {
      final result = await _flow.turn(
        flow: flowId,
        action: 'start',
        utterance: userLabel,
        ref: ref,
      );
      await _applyFlowResult(result);
    } on DayxFlowException catch (e) {
      if (!mounted) return;
      setState(() {
        _flowBusy = false;
        _messages.add(DayxChatMessage(isUser: false, text: e.message));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _flowBusy = false;
        _messages.add(
          const DayxChatMessage(
            isUser: false,
            text: 'Could not start that flow. Try again.',
          ),
        );
      });
    }
  }

  Future<void> _flowSelect(
    DayxFlowSession session,
    DayxFlowOption option, {
    String? userText,
  }) async {
    if (_flowBusy) return;
    _dismissTryAsking();
    if (option.id == 'top_up') {
      await _startFlow(DayxFlowId.addMoney, userLabel: 'Top up wallet');
      return;
    }
    setState(() {
      _messages.add(
        DayxChatMessage(
          isUser: true,
          text: _userBubbleForOption(option, typed: userText),
        ),
      );
      _flowBusy = true;
    });
    _scrollToEnd();
    try {
      final result = await _flow.turn(
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
          DayxChatMessage(
            isUser: false,
            text: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      });
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
      _messages.add(DayxChatMessage(isUser: true, text: bubbleText));
      _flowBusy = true;
    });
    _scrollToEnd();
    try {
      Object? submitValue = value;
      if (field == 'amount') {
        submitValue = double.tryParse(value.replaceAll(',', '')) ?? value;
      }
      final result = await _flow.turn(
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
          DayxChatMessage(
            isUser: false,
            text: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      });
    }
  }

  Future<void> _flowUtterance(DayxFlowSession session, String utterance) async {
    if (_flowBusy) return;
    setState(() {
      _messages.add(DayxChatMessage(isUser: true, text: utterance));
      _flowBusy = true;
      _inputCtrl.clear();
    });
    _scrollToEnd();
    try {
      final result = await _flow.turn(
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
          DayxChatMessage(
            isUser: false,
            text: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      });
      _scrollToEnd();
    }
  }

  DayxFlowOption? _matchFlowOption(DayxFlowUi ui, String text) {
    final q = text.toLowerCase().trim();
    if (q.isEmpty) return null;

    final numbered = RegExp(r'^(\d+)$').firstMatch(q);
    if (numbered != null) {
      final idx = int.tryParse(numbered.group(1)!);
      final selectable =
          ui.options
              .where((o) => o.id != 'confirm' && o.id != 'cancel')
              .toList();
      if (idx != null && idx >= 1 && idx <= selectable.length) {
        return selectable[idx - 1];
      }
      if (idx != null && idx >= 1 && idx <= ui.options.length) {
        return ui.options[idx - 1];
      }
    }

    if (q == 'confirm' ||
        q == 'yes' ||
        q == 'send' ||
        q == 'ok' ||
        q.startsWith('confirm')) {
      for (final opt in ui.options) {
        if (opt.id == 'confirm') return opt;
      }
    }
    if (q == 'cancel' || q == 'stop' || q == 'no') {
      for (final opt in ui.options) {
        if (opt.id == 'cancel') return opt;
      }
    }

    for (final opt in ui.options) {
      final label = opt.label.toLowerCase();
      final id = opt.id.toLowerCase();
      if (label == q || id == q || label.contains(q) || q.contains(label)) {
        return opt;
      }
    }
    return null;
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
        _messages.add(DayxChatMessage(isUser: true, text: trimmed));
      });
      await _flowCancel(session);
      return;
    }

    final switchFlow = DayxQuickRoutes.flowIdFor(trimmed);
    if (switchFlow != null && switchFlow != session.flow) {
      _deactivateFlowCards();
      await _startFlow(switchFlow, userLabel: trimmed);
      return;
    }

    final input = ui.input;
    if (input != null) {
      await _flowSubmit(session, input.field, trimmed);
      return;
    }

    final matched = _matchFlowOption(ui, trimmed);
    if (matched != null) {
      await _flowSelect(session, matched, userText: trimmed);
      return;
    }

    await _flowUtterance(session, trimmed);
  }

  Future<void> _flowCancel(DayxFlowSession session) async {
    if (_flowBusy) return;
    setState(() => _flowBusy = true);
    try {
      final result = await _flow.turn(
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

  Future<void> _submit([String? raw]) async {
    final text = (raw ?? _inputCtrl.text).trim();
    if (text.isEmpty || _thinking || _flowBusy) return;
    if (_isDuplicateRapidSubmit(text)) return;

    _dismissTryAsking();

    if (_listening) await _speech.stop();

    if (_inActiveFlow && raw == null) {
      await _submitActiveFlowInput(text);
      return;
    }

    final knowledge = DayxQuickRoutes.productKnowledgeReplyFor(text);
    if (knowledge != null) {
      setState(() {
        _messages.add(DayxChatMessage(isUser: true, text: text));
        _inputCtrl.clear();
        _listening = false;
        _messages.add(DayxChatMessage(isUser: false, text: knowledge));
      });
      await _persistMessages();
      _scrollToEnd();
      return;
    }

    final flowId = DayxQuickRoutes.flowIdFor(text);
    if (flowId != null) {
      await _startFlow(flowId, userLabel: text);
      return;
    }

    final quickTarget = DayxQuickRoutes.navigateTargetFor(text);
    if (quickTarget != null) {
      final flowId = _flowIdForNavigateTarget(quickTarget);
      if (flowId != null) {
        await _startFlow(flowId, userLabel: text);
        return;
      }

      setState(() {
        _messages.add(DayxChatMessage(isUser: true, text: text));
        _inputCtrl.clear();
        _listening = false;
      });
      _scrollToEnd();

      if (quickTarget == '__balance__') {
        final hub = await _loadHub();
        if (!mounted) return;
        setState(() {
          _messages.add(
            DayxChatMessage(
              isUser: false,
              text: _formatBalanceMessage(hub),
            ),
          );
          _cachedHub = hub;
        });
        await _persistMessages();
        _scrollToEnd();
        return;
      }

      if (quickTarget == DayxNavigateTargets.support) {
        setState(() {
          _messages.add(
            const DayxChatMessage(
              isUser: false,
              text: 'Opening customer support — you can keep this chat open.',
            ),
          );
        });
        await _persistMessages();
        await IntercomSupportService.openContactSupport();
        return;
      }

      setState(() {
        _messages.add(
          DayxChatMessage(
            isUser: false,
            text:
                'Tell me what you want to do — for example "send 5000 to mom" or "pay my electricity bill". I\'ll handle it right here in chat.',
          ),
        );
      });
      await _persistMessages();
      _scrollToEnd();
      return;
    }

    setState(() {
      _messages.add(DayxChatMessage(isUser: true, text: text));
      _thinking = true;
      _inputCtrl.clear();
      _listening = false;
    });
    _scrollToEnd();
    await _persistMessages();

    try {
      final response = await _chat.chat(
        message: text,
        history: _buildHistory(),
      );
      if (!mounted) return;

      WalletHubSnapshot? hub;
      String replyText = response.reply;
      if (DayxProductKnowledge.matches(text) &&
          replyText.trim().length < 120) {
        replyText = DayxProductKnowledge.appOverview;
      } else if (response.intent?.action == DayxIntentActions.showBalance) {
        hub = await _loadHub();
        replyText = _formatBalanceMessage(hub);
      } else if (response.spendingInsights != null &&
          response.spendingInsights!.isNotEmpty) {
        final insightLines = response.spendingInsights!
            .map((i) => '${i.title}: ${i.message}')
            .join('\n');
        replyText = '$replyText\n\n$insightLines';
      }

      setState(() {
        _messages.add(
          DayxChatMessage(
            isUser: false,
            text: replyText,
            response: response,
          ),
        );
        _thinking = false;
        if (hub != null) _cachedHub = hub;
        if (response.meta.isFullMode) {
          _status = DayxStatus(
            enabled: true,
            mode: 'full',
            provider: response.meta.provider,
            model: null,
          );
        }
      });
      _scrollToEnd();
      _keepInputFocused();
      await _persistMessages();

      final intent = response.intent;
      if (DayxResponseExecutor.isSupportIntent(intent)) {
        setState(() {
          _messages.add(
            const DayxChatMessage(
              isUser: false,
              text: 'Opening customer support — you can keep this chat open.',
            ),
          );
        });
        await _persistMessages();
        await IntercomSupportService.openContactSupport();
        return;
      }
      final sf = _flowIdFromStartFlow(response.startFlow);
      if (sf != null) {
        await _tryStartFlowFromChat(sf, text);
        return;
      }
      if (response.transferProposal != null) {
        await _tryStartFlowFromChat(DayxFlowId.send, text);
        return;
      }
      if (intent?.action == DayxIntentActions.proposeTransfer) {
        await _tryStartFlowFromChat(DayxFlowId.send, text);
        return;
      }
      if (intent?.action == DayxIntentActions.navigate) {
        final target = intent?.params['target']?.toString() ?? '';
        final flowId = _flowIdForNavigateTarget(target);
        if (flowId != null) {
          await _tryStartFlowFromChat(flowId, text);
          return;
        }
        setState(() {
          _messages.add(
            const DayxChatMessage(
              isUser: false,
              text:
                  'Tell me what you need — send money, pay a bill, or add money — and I\'ll do it here in chat.',
            ),
          );
        });
        await _persistMessages();
      }
    } on DayxChatException catch (e) {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _messages.add(DayxChatMessage(isUser: false, text: e.message));
      });
      _keepInputFocused();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _thinking = false;
        _messages.add(
          DayxChatMessage(
            isUser: false,
            text:
                msg.contains('503') ||
                        msg.toLowerCase().contains('not configured')
                    ? 'DayX AI isn\'t available right now. Make sure the server has GROQ_API_KEY set, then try again.'
                    : 'Something went wrong. Check your connection and try again.',
          ),
        );
      });
      _keepInputFocused();
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

  Future<WalletHubSnapshot> _loadHub() async {
    if (_cachedHub != null) return _cachedHub!;
    final hub = await walletService.fetchWalletHub();
    _cachedHub = hub;
    return hub;
  }

  void _scrollToEnd({int delayMs = 0}) {
    void jump({int pass = 0}) {
      if (!mounted || !_scrollCtrl.hasClients) return;
      // reverse: true → offset 0 is the newest messages at the bottom.
      _scrollCtrl.jumpTo(0);
      if (pass < 2) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          jump(pass: pass + 1);
        });
      }
    }

    if (delayMs <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => jump());
      return;
    }
    Future<void>.delayed(Duration(milliseconds: delayMs), () => jump());
  }

  @override
  Widget build(BuildContext context) {
    final modeLabel = _status?.displayLabel ?? '…';

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
                    _header(context, modeLabel),
                    const SizedBox(height: 8),
                    Expanded(
                      child: AgentChatHorizontalPadding(
                        child:
                            _loadingHistory
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap:
                                      () => FocusScope.of(context).unfocus(),
                                  child: ListView.builder(
                                    controller: _scrollCtrl,
                                    reverse: true,
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior.manual,
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      8,
                                      0,
                                      8,
                                    ),
                                    itemCount:
                                        _messages.length +
                                        (_thinking ? 1 : 0) +
                                        (_shouldShowWelcomeSuggestions ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      final welcomeExtra =
                                          _shouldShowWelcomeSuggestions ? 1 : 0;
                                      final thinkingExtra = _thinking ? 1 : 0;
                                      final total =
                                          _messages.length +
                                          welcomeExtra +
                                          thinkingExtra;
                                      final dataIndex = total - 1 - index;

                                      if (_shouldShowWelcomeSuggestions &&
                                          dataIndex == 0) {
                                        return _welcomeSuggestionsPanel();
                                      }

                                      final slot =
                                          dataIndex -
                                          (_shouldShowWelcomeSuggestions
                                              ? 1
                                              : 0);

                                      if (_thinking &&
                                          slot == _messages.length) {
                                        return _typingIndicator();
                                      }

                                      return _messageBubble(
                                        _messages[slot],
                                      );
                                    },
                                  ),
                                ),
                      ),
                    ),
                    AgentChatHorizontalPadding(
                      child: _composerSection(
                        context,
                        canSend:
                            _inputCtrl.text.trim().isNotEmpty &&
                            !_thinking &&
                            !_flowBusy,
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

  Widget _composerSection(
    BuildContext context, {
    required bool canSend,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.transparent,  border: Border(
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
                  color: AppColors.primary400,
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
                    autofocus: false,
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
                      _scrollToEnd(delayMs: 40);
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 8),
                _composerIconButton(
                  context,
                  onTap: _speechReady ? _toggleVoice : null,
                  color:
                      _listening
                          ? AppColors.primary400.withValues(alpha: 0.2)
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.08),
                  icon: Icon(
                    _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    size: 22,
                    color:
                        _listening
                            ? AppColors.primary400
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(width: 8),
                _composerIconButton(
                  context,
                  onTap: canSend ? () => _submit() : null,
                  color:
                      canSend
                          ? AppColors.purple500ForTheme(context)
                          : AppColors.purple500ForTheme(
                            context,
                          ).withValues(alpha: 0.15),
                  icon: Icon(
                    Icons.arrow_upward_rounded,
                    color:
                        canSend
                            ? AppColors.neutral0
                            : AppColors.neutral0.withValues(alpha: 0.25),
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

  Widget _composerIconButton(
    BuildContext context, {
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

  Widget _header(BuildContext context, String modeLabel) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DayX',
                      style: AppTypography.titleLarge.copyWith(
                        fontFamily: 'FunnelDisplay',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // const SizedBox(width: 8),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 8,
                    //     vertical: 3,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: _status?.isFullMode == true
                    //         ? AppColors.primary400.withValues(alpha: 0.15)
                    //         : Theme.of(context)
                    //             .colorScheme
                    //             .onSurface
                    //             .withValues(alpha: 0.08),
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Text(
                    //     modeLabel,
                    //     style: TextStyle(
                    //       fontFamily: 'Chirp',
                    //       fontSize: 11,
                    //       fontWeight: FontWeight.w600,
                    //       color: _status?.isFullMode == true
                    //           ? AppColors.primary400
                    //           : Theme.of(context)
                    //               .colorScheme
                    //               .onSurface
                    //               .withValues(alpha: 0.55),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Close DayX',
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: _dismiss,
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

  Widget _messageBubble(DayxChatMessage msg) {
    final align = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bg =
        msg.isUser
            ? AppColors.primary400
            : Theme.of(context).colorScheme.surface;
    final displayText = msg.isUser ? msg.text : _bubbleDisplayText(msg);

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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                msg.isUser
                    ? AppColors.primary400.withValues(alpha: 0.35)
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
                'DayX',
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary400,
                ),
              ),
            if (!msg.isUser) const SizedBox(height: 4),
            if (displayText.isNotEmpty)
              Text(
                displayText,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 15,
                  height: 1.35,
                  color:
                      msg.isUser
                          ? AppColors.neutral0
                          : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            if (msg.successReceipt != null) ...[
              const SizedBox(height: 12),
              DayxChatSuccessReceipt(receipt: msg.successReceipt!),
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
          borderRadius: BorderRadius.circular(14),
        ),
        child: LoadingAnimationWidget.horizontalRotatingDots(
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
    );
  }
}
