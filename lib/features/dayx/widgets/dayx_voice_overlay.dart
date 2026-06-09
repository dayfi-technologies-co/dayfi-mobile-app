import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayx/constants/dayx_copy.dart';
import 'package:dayfi/features/dayx/models/dayx_intent.dart';
import 'package:dayfi/features/dayx/models/dayx_flow.dart';
import 'package:dayfi/features/dayx/services/dayx_chat_service.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_executor.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_pin_retry.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_service.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_voice_match.dart';
import 'package:dayfi/features/dayx/services/dayx_quick_routes.dart';
import 'package:dayfi/features/dayx/services/dayx_response_executor.dart';
import 'package:dayfi/features/dayx/services/dayx_voice_service.dart';
import 'package:dayfi/features/dayx/widgets/dayx_flow_step_card.dart';
import 'package:dayfi/features/dayx/widgets/dayx_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class _TranscriptLine {
  final bool isUser;
  final String text;

  const _TranscriptLine({required this.isUser, required this.text});
}

class DayxVoiceOverlay extends ConsumerStatefulWidget {
  final DayxChangeTab onChangeTab;
  final void Function(String target)? onNavigate;
  final bool fromNavHold;

  const DayxVoiceOverlay({
    super.key,
    required this.onChangeTab,
    this.onNavigate,
    this.fromNavHold = false,
  });

  static void Function()? _finalizeListeningHandler;

  static void requestFinalizeListening() {
    _finalizeListeningHandler?.call();
  }

  static Future<void> show(
    BuildContext context, {
    required DayxChangeTab onChangeTab,
    void Function(String target)? onNavigate,
    bool fromNavHold = false,
  }) {
    return showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: 'Dismiss DayX voice',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder:
          (_, __, ___) => DayxVoiceOverlay(
            onChangeTab: onChangeTab,
            onNavigate: onNavigate,
            fromNavHold: fromNavHold,
          ),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  @override
  ConsumerState<DayxVoiceOverlay> createState() => _DayxVoiceOverlayState();
}

class _DayxVoiceOverlayState extends ConsumerState<DayxVoiceOverlay>
    with TickerProviderStateMixin {
  final _chat = DayxChatService();
  final _flow = DayxFlowService();
  final _voice = DayxVoiceService();
  final _transcriptScroll = ScrollController();

  late final AnimationController _pulse;
  late final AnimationController _wave;

  DayxVadPhase _phase = DayxVadPhase.idle;
  String _assistantLine = DayxCopy.voiceReadyLine;
  final List<_TranscriptLine> _lines = [];
  DayxTransferProposal? _pendingTransfer;
  bool _handlingUtterance = false;
  bool _flowBusy = false;
  DayxFlowSession? _flowSession;
  DayxFlowUi? _flowUi;
  int _pinFailures = 0;
  int _pinFieldGeneration = 0;
  bool _sessionOpen = true;

  @override
  void initState() {
    super.initState();
    DayxVoiceOverlay._finalizeListeningHandler = _onNavHoldReleased;
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _voice.setBargeInHandler(() {
      if (!mounted) return;
      unawaited(_beginListening());
    });
    unawaited(_openSession());
  }

  void _pushLine({required bool isUser, required String text}) {
    final t = text.trim();
    if (t.isEmpty) return;
    if (_lines.isNotEmpty &&
        _lines.last.isUser == isUser &&
        _lines.last.text == t) {
      return;
    }
    setState(() => _lines.add(_TranscriptLine(isUser: isUser, text: t)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_transcriptScroll.hasClients) {
        _transcriptScroll.jumpTo(0);
      }
    });
  }

  Future<void> _openSession() async {
    await _voice.init();
    if (!mounted || !_sessionOpen) return;
    HapticFeedback.lightImpact();
    if (widget.fromNavHold) {
      setState(() {
        _phase = DayxVadPhase.listening;
        _assistantLine = DayxCopy.voiceListeningHint;
      });
      await _beginListening();
      return;
    }
    setState(() {
      _phase = DayxVadPhase.speaking;
      _assistantLine = DayxCopy.voiceGreetingShort;
    });
    await _speakAssistant(DayxCopy.voiceGreetingShort);
    if (mounted && _sessionOpen) await _scheduleListenAfterTurn();
  }

  Future<void> _onNavHoldReleased() async {
    if (!widget.fromNavHold || !_sessionOpen || !mounted) return;
    if (_phase != DayxVadPhase.listening) return;
    final text = await _voice.endListenAndCollect();
    if (!mounted || !_sessionOpen) return;
    if (text != null && text.isNotEmpty) {
      await _handleUtterance(text);
    }
  }

  Future<void> _beginListening() async {
    if (!_sessionOpen || !mounted) return;
    if (_phase == DayxVadPhase.executing) return;

    if (!_voice.isReady) {
      setState(() {
        _phase = DayxVadPhase.waiting;
        _assistantLine =
            'Voice isn\'t available on this device. Try chat mode.';
      });
      return;
    }

    await _voice.stopSpeaking();
    final listenHint =
        _flowUi != null && _flowUi!.options.isNotEmpty
            ? DayxFlowVoiceMatch.listenHintForStep(_flowUi!.step)
            : DayxCopy.voiceListeningHint;
    setState(() {
      _phase = DayxVadPhase.listening;
      _assistantLine = listenHint;
    });

    final started = await _voice.startConversationListen(
      onPartial: (text) {
        if (!mounted) return;
        if (text.trim().isNotEmpty) {
          setState(() {
            _phase = DayxVadPhase.listening;
            _assistantLine = text.trim();
          });
        }
      },
      onFinal: (text) {
        if (text.isEmpty || !mounted || _handlingUtterance) return;
        if (_isCancelPhrase(text)) {
          _dismiss();
          return;
        }
        unawaited(_handleUtterance(text));
      },
    );

    if (!started && mounted) {
      setState(() {
        _phase = DayxVadPhase.waiting;
        _assistantLine =
            _voice.lastListenError ??
            'Microphone unavailable. Allow mic access in Settings, or use chat.';
      });
    }
  }

  bool _isCancelPhrase(String text) {
    final t = text.trim().toLowerCase();
    return t == 'cancel' ||
        t == 'close' ||
        t == 'exit' ||
        t == 'stop' ||
        t.contains('close dayx');
  }

  Future<void> _speakAssistant(String text) async {
    if (!mounted) return;
    setState(() {
      _phase = DayxVadPhase.speaking;
      _assistantLine = text;
    });
    _pushLine(isUser: false, text: text);
    await _voice.speak(DayxVoiceService.trimForSpeech(text));
  }

  Future<void> _scheduleListenAfterTurn() async {
    if (!_sessionOpen || !mounted) return;
    if (_phase == DayxVadPhase.executing) return;
    setState(() {
      _phase = DayxVadPhase.waiting;
      _assistantLine = DayxCopy.voiceReadyLine;
    });
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (mounted && _sessionOpen) await _beginListening();
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
      _flowSession = result.session;
      _flowUi = result.ui;
      _flowBusy = false;
    });

    if (!shouldExecute) {
      final optsOnly =
          result.ui != null &&
          result.ui!.input == null &&
          result.ui!.options.isNotEmpty;

      if (optsOnly) {
        setState(() => _assistantLine = result.reply);
        _pushLine(isUser: false, text: result.reply);
        final cue = DayxFlowVoiceMatch.shortVoiceCue(result.ui!.step);
        if (cue.isNotEmpty) {
          await _voice.speak(cue);
        }
      } else {
        await _speakAssistant(result.reply);
      }
    }

    if (shouldExecute && mounted) {
      await _runFlowExecute(
        execute: result.execute!,
        pinSession: pinSession,
        pinUi: pinUi,
      );
      return;
    }

    if (mounted && _sessionOpen && _phase != DayxVadPhase.executing) {
      await _scheduleListenAfterTurn();
    }
  }

  Future<void> _runFlowExecute({
    required Map<String, dynamic> execute,
    DayxFlowSession? pinSession,
    DayxFlowUi? pinUi,
  }) async {
    if (!mounted) return;
    setState(() => _phase = DayxVadPhase.executing);
    final outcome = await DayxFlowExecutor.run(
      context: context,
      ref: ref,
      execute: execute,
    );
    if (!mounted) return;

    if (outcome.success) {
      _pinFailures = 0;
      setState(() {
        _flowSession = null;
        _flowUi = null;
        _phase = DayxVadPhase.completed;
      });
      await _speakAssistant('Done. Transaction successful.');
      if (mounted && _sessionOpen) {
        await _scheduleListenAfterTurn();
      }
      return;
    }

    if (!outcome.invalidPin) {
      setState(() {
        _flowSession = null;
        _flowUi = null;
        _phase = DayxVadPhase.waiting;
        _assistantLine =
            outcome.message ?? 'Transaction failed. Please try again.';
      });
      await _speakAssistant(_assistantLine);
      if (mounted && _sessionOpen) {
        await _scheduleListenAfterTurn();
      }
      return;
    }

    _pinFailures++;
    final retryMsg = DayxFlowPinRetry.messageAfterFailure(_pinFailures);
    if (_pinFailures >= DayxFlowPinRetry.maxAttempts) {
      setState(() {
        _flowSession = null;
        _flowUi = null;
        _phase = DayxVadPhase.waiting;
        _assistantLine = retryMsg ?? 'Too many wrong PINs.';
      });
      await _speakAssistant(_assistantLine);
      if (mounted && _sessionOpen) {
        await _scheduleListenAfterTurn();
      }
      return;
    }

    setState(() {
      _flowSession = pinSession;
      _flowUi = pinUi;
      _phase = DayxVadPhase.listening;
      _assistantLine = retryMsg ?? 'Wrong PIN. Try again.';
      _pinFieldGeneration++;
    });
    await _speakAssistant(_assistantLine);
    if (mounted && _sessionOpen) {
      await _scheduleListenAfterTurn();
    }
  }

  Future<void> _flowSelect(DayxFlowSession session, DayxFlowOption opt) async {
    if (_flowBusy) return;
    if (opt.id == 'done') {
      setState(() {
        _flowSession = null;
        _flowUi = null;
        _assistantLine = DayxCopy.voiceGreeting;
      });
      await _scheduleListenAfterTurn();
      return;
    }
    setState(() => _flowBusy = true);
    try {
      final result = await _flow.turn(
        flow: session.flow,
        action: 'select',
        session: session,
        optionId: opt.id,
        ref: ref,
      );
      await _applyFlowResult(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _flowBusy = false);
      await _speakAssistant(e.toString().replaceFirst('Exception: ', ''));
      await _scheduleListenAfterTurn();
    }
  }

  Future<void> _flowUtterance(DayxFlowSession session, String text) async {
    if (_flowBusy) return;
    setState(() => _flowBusy = true);
    try {
      final result = await _flow.turn(
        flow: session.flow,
        action: 'utterance',
        session: session,
        utterance: text,
        ref: ref,
      );
      await _applyFlowResult(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _flowBusy = false);
      await _speakAssistant('I didn\'t catch that. Try again.');
      await _scheduleListenAfterTurn();
    }
  }

  Future<void> _flowSubmit(
    DayxFlowSession session,
    String field,
    String value,
  ) async {
    if (_flowBusy) return;
    setState(() => _flowBusy = true);
    try {
      Object? submitValue = value;
      if (field == 'amount') {
        submitValue =
            double.tryParse(value.replaceAll(',', '')) ?? value;
      }
      final result = await _flow.turn(
        flow: session.flow,
        action: 'submit',
        session: session,
        field: field,
        value: submitValue,
        utterance: value,
        ref: ref,
      );
      await _applyFlowResult(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _flowBusy = false);
      await _speakAssistant(e.toString().replaceFirst('Exception: ', ''));
      await _scheduleListenAfterTurn();
    }
  }

  Future<void> _startFlow(String flowId, {required String text}) async {
    _pinFailures = 0;
    setState(() {
      _phase = DayxVadPhase.thinking;
      _assistantLine = 'One moment…';
      _flowBusy = true;
    });
    _pushLine(isUser: true, text: text);
    try {
      final result = await _flow.turn(
        flow: flowId,
        action: 'start',
        utterance: text,
        ref: ref,
      );
      await _applyFlowResult(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _flowBusy = false);
      await _speakAssistant('Could not start. Try again.');
      await _scheduleListenAfterTurn();
    }
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

  Future<void> _handleUtterance(String text) async {
    if (_handlingUtterance) return;
    _handlingUtterance = true;
    await _voice.stopListening();
    _pushLine(isUser: true, text: text);
    setState(() {
      _phase = DayxVadPhase.thinking;
      _assistantLine = 'One moment…';
    });

    try {
      if (_flowSession != null && _flowUi != null) {
        if (_flowUi!.input != null) {
          await _flowSubmit(_flowSession!, _flowUi!.input!.field, text);
          return;
        }

        if (_flowUi!.options.isNotEmpty) {
          final matched = DayxFlowVoiceMatch.matchOption(
            _flowUi!.options,
            text,
          );
          if (matched != null) {
            await _flowSelect(_flowSession!, matched);
            return;
          }
          await _flowUtterance(_flowSession!, text);
          return;
        }
      }

      final flowId = DayxQuickRoutes.flowIdFor(text);
      if (flowId != null) {
        await _startFlow(flowId, text: text);
        return;
      }

      final response = await _chat.chat(message: text);
      if (!mounted) return;

      _pendingTransfer = response.transferProposal;

      final spoken = _spokenLine(response);

      if (response.transferProposal?.needsConfirmation == true) {
        await _speakAssistant(spoken);
        await _scheduleListenAfterTurn();
        return;
      }

      await _speakAssistant(spoken);

      if (!mounted) return;

      final sf = _flowIdFromStartFlow(response.startFlow);
      if (sf != null) {
        await _startFlow(sf, text: text);
        return;
      }

      final intent = response.intent;

      if (intent?.action == DayxIntentActions.proposeTransfer) {
        await _startFlow(DayxFlowId.send, text: text);
        return;
      }
      if (DayxResponseExecutor.isSupportIntent(intent)) {
        setState(() => _phase = DayxVadPhase.executing);
        await DayxResponseExecutor.openSupport(dismissOverlay: _dismiss);
        return;
      }
      if (intent?.action == DayxIntentActions.navigate) {
        final target = intent?.params['target']?.toString() ?? '';
        final flowFromNav = _flowIdForNavigate(target);
        if (flowFromNav != null) {
          await _startFlow(flowFromNav, text: text);
          return;
        }
        setState(() => _phase = DayxVadPhase.executing);
        await DayxResponseExecutor.handleNavigateIntent(
          context: context,
          intent: intent!,
          changeTab: widget.onChangeTab,
          onNavigate: widget.onNavigate,
          dismissOverlay: _dismiss,
        );
        return;
      }

      await _scheduleListenAfterTurn();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      final friendly =
          msg.contains('503') || msg.toLowerCase().contains('not configured')
              ? 'DayX AI is not available. Check the server configuration.'
              : msg.contains('Null') && msg.contains('bool')
              ? 'Voice had a glitch. Tap retry below.'
              : 'Something went wrong. Try again.';
      setState(() => _assistantLine = friendly);
      await _scheduleListenAfterTurn();
    } finally {
      _handlingUtterance = false;
    }
  }

  Future<void> _confirmPendingTransfer() async {
    if (_pendingTransfer == null) return;
    await _startFlow(DayxFlowId.send, text: 'Send money');
  }

  String? _flowIdForNavigate(String target) {
    switch (target.toLowerCase()) {
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

  String _spokenLine(DayxResponse response) {
    final voice = response.voiceReply?.trim();
    if (voice != null && voice.isNotEmpty) return voice;
    return DayxVoiceService.trimForSpeech(response.reply);
  }

  void _dismiss() {
    _sessionOpen = false;
    unawaited(_voice.stopAll());
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _onOrbTap() {
    if (_phase == DayxVadPhase.speaking) {
      _voice.triggerBargeIn();
      return;
    }
    if (_phase == DayxVadPhase.waiting ||
        _phase == DayxVadPhase.completed ||
        _phase == DayxVadPhase.idle) {
      unawaited(_beginListening());
    }
  }

  @override
  void dispose() {
    _sessionOpen = false;
    if (DayxVoiceOverlay._finalizeListeningHandler == _onNavHoldReleased) {
      DayxVoiceOverlay._finalizeListeningHandler = null;
    }
    _pulse.dispose();
    _wave.dispose();
    _transcriptScroll.dispose();
    unawaited(_voice.stopAll());
    super.dispose();
  }

  String get _stateLabel {
    switch (_phase) {
      case DayxVadPhase.idle:
        return 'Idle';
      case DayxVadPhase.waiting:
        return 'Ready';
      case DayxVadPhase.listening:
        return 'Listening';
      case DayxVadPhase.thinking:
        return 'Thinking';
      case DayxVadPhase.speaking:
        return 'Speaking';
      case DayxVadPhase.executing:
        return 'Processing';
      case DayxVadPhase.completed:
        return 'Done';
    }
  }

  Color get _phaseColor {
    switch (_phase) {
      case DayxVadPhase.idle:
        return Colors.white38;
      case DayxVadPhase.waiting:
        return Colors.white54;
      case DayxVadPhase.listening:
        return const Color(0xFF4ADE80);
      case DayxVadPhase.thinking:
        return const Color(0xFFA78BFA);
      case DayxVadPhase.speaking:
        return const Color(0xFF60A5FA);
      case DayxVadPhase.executing:
        return AppColors.primary400;
      case DayxVadPhase.completed:
        return AppColors.orange500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            if (_phase == DayxVadPhase.speaking) {
              _voice.triggerBargeIn();
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(color: Colors.black.withValues(alpha: 0.72)),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
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
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(onTap: _onOrbTap, child: _orb()),
                    const SizedBox(height: 32),
                    _waveform(),
                    const SizedBox(height: 12),
                    Text(
                      _stateLabel.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: _phaseColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _assistantLine,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 18,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (_lines.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: _transcriptScroll,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _lines.length,
                          itemBuilder: (context, index) {
                            final line = _lines[_lines.length - 1 - index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Align(
                                alignment: line.isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.sizeOf(context).width * 0.78,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: line.isUser
                                        ? AppColors.primary400.withValues(
                                            alpha: 0.25,
                                          )
                                        : Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    line.text,
                                    style: TextStyle(
                                      fontFamily: 'Chirp',
                                      fontSize: 14,
                                      height: 1.35,
                                      color: Colors.white.withValues(
                                        alpha: line.isUser ? 0.95 : 0.85,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else
                      const Spacer(),
                    if (_flowUi != null && _flowSession != null) ...[
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                            // border: Border.all(
                            //   color: Colors.white.withValues(alpha: 0.12),
                            // ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                            child: DayxFlowStepCard(
                              key: ValueKey(
                                '${_flowUi!.step}-$_pinFieldGeneration',
                              ),
                              ui: _flowUi!,
                              busy: _flowBusy,
                              hideInlineInput: true,
                              onSelect: (o) => _flowSelect(_flowSession!, o),
                              onSubmit:
                                  (f, v) => _flowSubmit(_flowSession!, f, v),
                              onCancel: () {
                                setState(() {
                                  _flowSession = null;
                                  _flowUi = null;
                                  _assistantLine = DayxCopy.voiceListeningHint;
                                });
                                unawaited(_beginListening());
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (_pendingTransfer?.needsConfirmation == true)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _confirmPendingTransfer,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary400,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Confirm transfer'),
                          ),
                        ),
                      ),
                    if (_phase == DayxVadPhase.waiting &&
                        (_voice.lastListenError != null))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                        child: TextButton(
                          onPressed: _beginListening,
                          child: const Text('Tap to retry microphone'),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _phase == DayxVadPhase.speaking
                            ? 'Tap orb to interrupt · say "cancel" to close'
                            : _phase == DayxVadPhase.listening
                            ? 'Speak now — pause ~2s when done'
                            : 'Say "cancel" or tap ✕ to close',
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4),
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
  }

  Widget _orb() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final scale =
            _phase == DayxVadPhase.listening
                ? 1.0 + (_pulse.value * 0.18)
                : 1.0 + (_pulse.value * 0.08);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _phaseColor.withValues(alpha: 0.95),
                  AppColors.orange500,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _phaseColor.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: const Center(
        child: Text(
          'X',
          style: TextStyle(
            fontFamily: 'FunnelDisplay',
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _waveform() {
    return SizedBox(
      height: 36,
      child: AnimatedBuilder(
        animation: _wave,
        builder: (context, _) {
          final active =
              _phase == DayxVadPhase.listening ||
              _phase == DayxVadPhase.speaking;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(12, (i) {
              final h =
                  active
                      ? 8 + (math.sin((_wave.value * math.pi * 2) + i) + 1) * 12
                      : 6.0;
              return Container(
                width: 4,
                height: h,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _phaseColor.withValues(alpha: active ? 0.85 : 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
