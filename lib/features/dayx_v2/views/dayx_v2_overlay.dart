import 'dart:async';
import 'dart:math' as math;
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayx/constants/dayx_copy.dart';
import 'package:dayfi/features/dayx/models/dayx_flow.dart';
import 'package:dayfi/features/dayx/models/dayx_intent.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_executor.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_pin_retry.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_service.dart';
import 'package:dayfi/features/dayx/services/dayx_flow_voice_match.dart';
import 'package:dayfi/features/dayx/services/dayx_quick_routes.dart';
import 'package:dayfi/features/dayx/services/dayx_response_executor.dart';
import 'package:dayfi/features/dayx/services/dayx_chat_service.dart';
import 'package:dayfi/features/dayx/services/dayx_voice_service.dart';
import 'package:dayfi/features/dayx/widgets/dayx_navigation.dart';
import 'package:dayfi/features/dayx_v2/constants/dayx_v2_phrases.dart';
import 'package:dayfi/features/dayx_v2/constants/dayx_v2_voices.dart';
import 'package:dayfi/features/dayx_v2/services/dayx_v2_chat_service.dart';
import 'package:dayfi/features/dayx_v2/services/dayx_v2_prefs.dart';
import 'package:dayfi/features/dayx_v2/services/dayx_v2_tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class DayxV2Overlay extends ConsumerStatefulWidget {
  final DayxChangeTab onChangeTab;
  final void Function(String target)? onNavigate;
  final bool fromNavHold;

  const DayxV2Overlay({
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
      barrierLabel: 'Dismiss DayX',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder:
          (_, __, ___) => DayxV2Overlay(
            onChangeTab: onChangeTab,
            onNavigate: onNavigate,
            fromNavHold: fromNavHold,
          ),
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<DayxV2Overlay> createState() => _DayxV2OverlayState();
}

class _DayxV2OverlayState extends ConsumerState<DayxV2Overlay>
    with TickerProviderStateMixin {
  final _chat = DayxV2ChatService();
  final _flow = DayxFlowService();
  final _stt = DayxVoiceService();
  final _tts = DayxV2TtsService();

  late final AnimationController _pulse;
  late final AnimationController _wave;

  DayxVadPhase _phase = DayxVadPhase.idle;
  String _caption = '';
  bool _preparingVoice = false;
  bool _handlingUtterance = false;
  bool _flowBusy = false;
  bool _sessionOpen = true;
  DayxFlowSession? _flowSession;
  DayxFlowUi? _flowUi;
  int _pinFailures = 0;
  final List<DayxHistoryMessage> _history = [];

  DayxV2VoiceProfile get _voiceProfile =>
      DayxV2Voices.byId(DayxV2Prefs.selectedVoiceId ?? 'Idera');

  @override
  void initState() {
    super.initState();
    DayxV2Overlay._finalizeListeningHandler = _onNavHoldReleased;
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    _stt.setBargeInHandler(() {
      if (mounted) unawaited(_beginListening());
    });
    unawaited(_openSession());
  }

  Future<void> _openSession() async {
    await Future.wait([_stt.init(), _tts.init()]);
    if (!mounted || !_sessionOpen) return;
    HapticFeedback.lightImpact();

    if (widget.fromNavHold) {
      setState(() {
        _phase = DayxVadPhase.listening;
        _caption = DayxCopy.voiceListeningHint;
      });
      await _beginListening();
      return;
    }

    setState(() => _phase = DayxVadPhase.speaking);
    final greeting =
        DayxV2Prefs.shouldShowIntro
            ? 'Hey! I\'m ${_voiceProfile.label}. I go be your personal money assistant inside DayFi. Wetin you wan do today?'
            : 'Wetin you wan do today?';
    await _speakAssistant(greeting, recordHistory: false);
    await DayxV2Prefs.markIntroShown();
    // Bake the fixed confirmation/error phrases into the cache in the
    // background so they later play instantly in the YarnGPT voice.
    unawaited(_tts.prewarm(DayxV2Phrases.prewarmSet));
    if (mounted && _sessionOpen) await _scheduleListenAfterTurn();
  }

  Future<void> _onNavHoldReleased() async {
    if (!widget.fromNavHold || !_sessionOpen || !mounted) return;
    if (_phase != DayxVadPhase.listening) return;
    final text = await _stt.endListenAndCollect();
    if (!mounted || !_sessionOpen) return;
    if (text != null && text.isNotEmpty) {
      await _handleUtterance(text);
    }
  }

  Future<void> _beginListening() async {
    if (!_sessionOpen || !mounted || _phase == DayxVadPhase.executing) return;

    if (!_stt.isReady) {
      setState(() {
        _phase = DayxVadPhase.waiting;
        _caption = 'Mic not available. Check Settings permissions.';
      });
      return;
    }

    await _tts.stop();
    await _stt.stopSpeaking();
    setState(() {
      _phase = DayxVadPhase.listening;
      _caption = DayxCopy.voiceListeningHint;
    });

    final started = await _stt.startConversationListen(
      onPartial: (text) {
        if (!mounted || text.trim().isEmpty) return;
        setState(() => _caption = text.trim());
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
        _caption = _stt.lastListenError ?? 'Could not start microphone.';
      });
    }
  }

  bool _isCancelPhrase(String text) {
    final t = text.trim().toLowerCase();
    return t == 'cancel' || t == 'close' || t == 'exit' || t == 'stop';
  }

  Future<void> _speakAssistant(String text, {bool recordHistory = true}) async {
    if (!mounted) return;
    final spoken = DayxVoiceService.trimForSpeech(text);
    setState(() {
      _phase = DayxVadPhase.speaking;
      _caption = spoken;
      _preparingVoice = true;
    });
    if (recordHistory) {
      _history.add(DayxHistoryMessage(role: 'assistant', content: spoken));
      if (_history.length > 20) _history.removeAt(0);
    }
    await _tts.speak(
      spoken,
      onAudioStart: () {
        if (mounted) setState(() => _preparingVoice = false);
      },
    );
    if (mounted) setState(() => _preparingVoice = false);
  }

  Future<void> _scheduleListenAfterTurn() async {
    if (!_sessionOpen || !mounted || _phase == DayxVadPhase.executing) return;
    setState(() {
      _phase = DayxVadPhase.waiting;
      _caption = 'Tap the orb to speak';
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted && _sessionOpen && !widget.fromNavHold) {
      await _beginListening();
    }
  }

  Future<void> _handleUtterance(String text) async {
    if (_handlingUtterance) return;
    _handlingUtterance = true;
    await _stt.stopListening();
    _history.add(DayxHistoryMessage(role: 'user', content: text.trim()));
    if (_history.length > 20) _history.removeAt(0);

    setState(() {
      _phase = DayxVadPhase.thinking;
      _caption = 'One moment…';
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

      final response = await _chat.chat(
        message: text,
        history: _history,
        ref: ref,
      );
      if (!mounted) return;

      final spoken =
          response.voiceReply?.trim().isNotEmpty == true
              ? response.voiceReply!.trim()
              : DayxVoiceService.trimForSpeech(response.reply);

      await _speakAssistant(spoken);

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
      setState(() => _caption = msg);
      await _speakAssistant('Something no work. Try again.');
      await _scheduleListenAfterTurn();
    } finally {
      _handlingUtterance = false;
    }
  }

  String? _flowIdFromStartFlow(String? startFlow) {
    switch (startFlow?.toLowerCase()) {
      case 'send':
        return DayxFlowId.send;
      case 'add_money':
        return DayxFlowId.addMoney;
      case 'pay':
        return DayxFlowId.pay;
      default:
        return null;
    }
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

  Future<void> _startFlow(String flowId, {required String text}) async {
    _pinFailures = 0;
    setState(() {
      _phase = DayxVadPhase.thinking;
      _flowBusy = true;
    });
    try {
      final result = await _flow.turn(
        flow: flowId,
        action: 'start',
        utterance: text,
        ref: ref,
      );
      await _applyFlowResult(result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _flowBusy = false);
      await _speakAssistant('Could not start. Try again.');
      await _scheduleListenAfterTurn();
    }
  }

  Future<void> _applyFlowResult(DayxFlowTurnResult result) async {
    if (!mounted) return;
    final shouldExecute = DayxFlowPinRetry.shouldRunExecute(result);
    setState(() {
      _flowSession = result.session;
      _flowUi = result.ui;
      _flowBusy = false;
    });

    if (!shouldExecute) {
      await _speakAssistant(result.reply);
      if (mounted && _sessionOpen) await _scheduleListenAfterTurn();
      return;
    }

    await _runFlowExecute(
      execute: result.execute!,
      pinSession: result.session,
      pinUi: result.ui,
    );
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
      });
      await _speakAssistant('Done! Transaction successful.');
      if (mounted && _sessionOpen) await _scheduleListenAfterTurn();
      return;
    }

    if (!outcome.invalidPin) {
      setState(() {
        _flowSession = null;
        _flowUi = null;
      });
      await _speakAssistant(outcome.message ?? 'Transaction failed.');
      if (mounted && _sessionOpen) await _scheduleListenAfterTurn();
      return;
    }

    _pinFailures++;
    final retryMsg = DayxFlowPinRetry.messageAfterFailure(_pinFailures);
    if (_pinFailures >= DayxFlowPinRetry.maxAttempts) {
      setState(() {
        _flowSession = null;
        _flowUi = null;
      });
      await _speakAssistant(retryMsg ?? 'Too many wrong PINs.');
      if (mounted && _sessionOpen) await _scheduleListenAfterTurn();
      return;
    }

    setState(() {
      _flowSession = pinSession;
      _flowUi = pinUi;
    });
    await _speakAssistant(retryMsg ?? 'Wrong PIN. Try again.');
    if (mounted && _sessionOpen) await _scheduleListenAfterTurn();
  }

  Future<void> _flowSelect(DayxFlowSession session, DayxFlowOption opt) async {
    if (_flowBusy) return;
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
    } catch (_) {
      if (!mounted) return;
      setState(() => _flowBusy = false);
      await _speakAssistant('Try again.');
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
    } catch (_) {
      if (!mounted) return;
      setState(() => _flowBusy = false);
      await _speakAssistant('I no catch am. Say am again.');
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
        submitValue = double.tryParse(value.replaceAll(',', '')) ?? value;
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
    } catch (_) {
      if (!mounted) return;
      setState(() => _flowBusy = false);
      await _speakAssistant('Try again.');
      await _scheduleListenAfterTurn();
    }
  }

  void _dismiss() {
    _sessionOpen = false;
    unawaited(_stt.stopAll());
    unawaited(_tts.stop());
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _onOrbTap() {
    if (_phase == DayxVadPhase.speaking) {
      _stt.triggerBargeIn();
      _tts.stop();
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
    if (DayxV2Overlay._finalizeListeningHandler == _onNavHoldReleased) {
      DayxV2Overlay._finalizeListeningHandler = null;
    }
    _pulse.dispose();
    _wave.dispose();
    unawaited(_stt.stopAll());
    unawaited(_tts.dispose());
    super.dispose();
  }

  Color get _orbColor {
    switch (_phase) {
      case DayxVadPhase.listening:
        return const Color(0xFF4ADE80);
      case DayxVadPhase.thinking:
        return const Color(0xFFA78BFA);
      case DayxVadPhase.speaking:
        return Color(_voiceProfile.gradient[0]);
      case DayxVadPhase.executing:
        return AppColors.primary400;
      default:
        return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _voiceProfile;
    final scale = 1.0 + (_pulse.value * 0.06);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),

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
                    ],
                  ),
                ),
                Text(
                  "DayX AI",
                  style: const TextStyle(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const Spacer(),
                GestureDetector(
                  onTap: _onOrbTap,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_pulse, _wave]),
                    builder: (_, __) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 156,
                          height: 156,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(profile.gradient[0]),
                                Color(profile.gradient[1]),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _orbColor.withValues(alpha: 0.45),
                                blurRadius:
                                    40 +
                                    math.sin(_wave.value * math.pi * 2) * 12,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              _phase == DayxVadPhase.listening
                                  ? "assets/icons/svgs/microphone.svg"
                                  : _phase == DayxVadPhase.speaking
                                  ? "assets/icons/svgs/graphic-eq.svg"
                                  : "assets/icons/svgs/microphone-outline.svg",
                              height: 48,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _caption,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 16,
                      height: 1.45,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                if (_preparingVoice) ...[
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
                const Spacer(flex: 2),
                Text(
                  _phaseLabel,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _phaseLabel {
    switch (_phase) {
      case DayxVadPhase.listening:
        return 'Listening';
      case DayxVadPhase.thinking:
        return 'Thinking';
      case DayxVadPhase.speaking:
        return _preparingVoice ? 'Setting up the voice…' : 'Speaking';
      case DayxVadPhase.executing:
        return 'Processing';
      default:
        return 'Ready';
    }
  }
}
