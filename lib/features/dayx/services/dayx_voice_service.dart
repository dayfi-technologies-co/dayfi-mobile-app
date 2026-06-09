import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Conversation phases for the DayX voice overlay.
enum DayxVadPhase {
  idle,
  listening,
  thinking,
  speaking,
  waiting,
  executing,
  completed,
}

/// On-device STT + TTS tuned for hands-free DayX conversations.
class DayxVoiceService {
  DayxVoiceService();

  final _speech = stt.SpeechToText();
  final _tts = FlutterTts();
  bool _speechReady = false;
  bool _ttsReady = false;
  bool _isSpeaking = false;
  Completer<void>? _speakDone;
  String _lastRecognized = '';
  bool _deliveredFinal = false;
  int _listenEpoch = 0;
  Timer? _listenWatchdog;
  VoidCallback? _onBargeIn;

  String? lastListenError;

  static const _silencePause = Duration(milliseconds: 2000);

  Future<void> init() async {
    lastListenError = null;
    try {
      _speechReady = (await _speech.initialize(
        onError: (error) {
          lastListenError = error.errorMsg;
          debugPrint('DayX STT error: ${error.errorMsg}');
        },
        onStatus: (status) {
          debugPrint('DayX STT status: $status');
          if (status == 'done' || status == 'notListening') {
            _finalizeIfNeeded();
          }
        },
      )) ==
          true;
      if (_speechReady) {
        final permitted = await _speech.hasPermission;
        if (permitted != true) {
          _speechReady = false;
          lastListenError =
              'Microphone permission needed. Allow mic & speech in Settings.';
        }
      }
    } catch (e) {
      _speechReady = false;
      lastListenError = e.toString();
    }

    try {
      if (await _tts.isLanguageAvailable('en-US') == 1) {
        await _tts.setLanguage('en-US');
      }
      await _tts.setVolume(0.55);
      await _tts.setSpeechRate(0.50);
      await _tts.setPitch(1.02);
      await _tts.awaitSpeakCompletion(true);
      await _configureBestVoice();
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        if (!(_speakDone?.isCompleted ?? true)) {
          _speakDone?.complete();
        }
      });
      _ttsReady = true;
    } catch (_) {
      _ttsReady = false;
    }
  }

  void setBargeInHandler(VoidCallback? handler) {
    _onBargeIn = handler;
  }

  void triggerBargeIn() {
    if (_isSpeaking) {
      stopSpeaking();
      _onBargeIn?.call();
    }
  }

  Future<void> _configureBestVoice() async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List || raw.isEmpty) return;

      Map<String, String>? pick;
      var bestScore = -1;

      for (final entry in raw) {
        if (entry is! Map) continue;
        final name = (entry['name'] ?? '').toString();
        final locale = (entry['locale'] ?? '').toString();
        if (name.isEmpty || locale.isEmpty) continue;
        if (!locale.toLowerCase().startsWith('en')) continue;

        final id = '$name $locale'.toLowerCase();
        var score = 0;
        if (id.contains('enhanced')) score += 60;
        if (id.contains('premium')) score += 55;
        if (id.contains('siri')) score += 40;
        if (locale.toLowerCase().startsWith('en-us')) score += 12;
        if (score > bestScore) {
          bestScore = score;
          pick = {'name': name, 'locale': locale};
        }
      }

      if (pick != null) {
        await _tts.setVoice(pick);
        await _tts.setLanguage(pick['locale']!);
      }
    } catch (_) {
      /* keep default */
    }
  }

  bool get isReady => _speechReady;

  bool get isListening => _speech.isListening;

  bool get isSpeaking => _isSpeaking;

  String get lastRecognized => _lastRecognized;

  void Function(String)? _pendingOnFinal;

  void _finalizeIfNeeded() {
    if (_deliveredFinal) return;
    final text = _lastRecognized.trim();
    if (text.isEmpty) return;
    _deliveredFinal = true;
    _listenWatchdog?.cancel();
    _pendingOnFinal?.call(text);
  }

  /// Continuous listen: ends after silence or when the engine stops.
  Future<bool> startConversationListen({
    required void Function(String partial) onPartial,
    required void Function(String finalText) onFinal,
  }) async {
    if (!_speechReady) {
      lastListenError = 'Speech recognition is not available.';
      return false;
    }

    lastListenError = null;
    await stopListening();
    // Let TTS release the iOS audio session before grabbing the mic.
    await Future<void>.delayed(const Duration(milliseconds: 350));

    _lastRecognized = '';
    _deliveredFinal = false;
    _pendingOnFinal = onFinal;
    final epoch = ++_listenEpoch;

    try {
      // speech_to_text 7.x listen() returns Future<void>, not bool.
      await _speech.listen(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        pauseFor: _silencePause,
        listenFor: const Duration(minutes: 2),
        cancelOnError: false,
        localeId: 'en_US',
        onResult: (result) {
          if (epoch != _listenEpoch) return;
          _lastRecognized = result.recognizedWords;
          onPartial(_lastRecognized);
          final isFinal = result.finalResult == true;
          if (isFinal && !_deliveredFinal) {
            _deliveredFinal = true;
            _listenWatchdog?.cancel();
            final text = _lastRecognized.trim();
            if (text.isNotEmpty) onFinal(text);
          }
        },
      );

      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!_speech.isListening) {
        lastListenError =
            'Could not start the microphone. Allow mic & speech access in Settings.';
        return false;
      }

      _listenWatchdog?.cancel();
      _listenWatchdog = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (epoch != _listenEpoch || _deliveredFinal) return;
        if (!_speech.isListening) {
          _finalizeIfNeeded();
        }
      });

      return true;
    } catch (e) {
      lastListenError = e.toString();
      return false;
    }
  }

  Future<void> speak(String text) async {
    if (!_ttsReady || text.trim().isEmpty) return;
    await stopListening();
    await stopSpeaking();
    _isSpeaking = true;
    _speakDone = Completer<void>();
    await _tts.speak(trimForSpeech(text));
    await _speakDone!.future.timeout(
      const Duration(seconds: 45),
      onTimeout: () {},
    );
    _isSpeaking = false;
  }

  static String trimForSpeech(String text) {
    final trimmed = text.trim();
    if (trimmed.length <= 180) return trimmed;
    final parts = trimmed.split(RegExp(r'(?<=[.!?])\s+'));
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}'.trim();
    }
    return '${trimmed.substring(0, 177).trim()}…';
  }

  Future<void> stopSpeaking() async {
    if (_ttsReady) await _tts.stop();
    _isSpeaking = false;
    if (!(_speakDone?.isCompleted ?? true)) {
      _speakDone?.complete();
    }
  }

  Future<void> stopListening() async {
    _listenEpoch++;
    _listenWatchdog?.cancel();
    if (_speech.isListening) {
      await _speech.stop();
    }
    _pendingOnFinal = null;
  }

  /// Ends the current listen pass and returns the best transcript (hold-to-talk release).
  Future<String?> endListenAndCollect() async {
    _listenWatchdog?.cancel();
    if (_speech.isListening) {
      await _speech.stop();
    }
    final text = _lastRecognized.trim();
    _deliveredFinal = true;
    _pendingOnFinal = null;
    _listenEpoch++;
    return text.isEmpty ? null : text;
  }

  Future<void> stopAll() async {
    await stopListening();
    await stopSpeaking();
  }
}
