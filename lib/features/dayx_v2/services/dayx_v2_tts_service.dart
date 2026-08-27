import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayx/services/dayx_voice_service.dart';
import 'package:dayfi/features/dayx_v2/services/dayx_v2_prefs.dart';
import 'package:dayfi/flavors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

/// YarnGPT TTS via backend proxy, with on-device fallback.
///
/// YarnGPT inference is slow (commonly 30–60s) and far slower than real-time,
/// so two things keep DayX v2 usable:
///  * Every clip is cached on disk (persistent) by `voice + text`. Fixed
///    phrases (greeting, confirmations, errors) can be [prewarm]ed once and
///    then play instantly in the real Nigerian voice.
///  * [speak] reports when audio actually starts via `onAudioStart`, so the UI
///    can show a "setting up the voice…" state during the long synthesis.
class DayxV2TtsService {
  DayxV2TtsService({
    Dio? ttsDio,
    AudioPlayer? player,
    FlutterTts? fallbackTts,
  })  : _dio = ttsDio ?? _buildDio(),
        _player = player ?? AudioPlayer(),
        _fallbackTts = fallbackTts ?? FlutterTts();

  final Dio _dio;
  final AudioPlayer _player;
  final FlutterTts _fallbackTts;
  bool _fallbackReady = false;
  bool _speaking = false;
  Directory? _cacheDir;

  bool get isSpeaking => _speaking;

  static Dio _buildDio() => Dio(
        BaseOptions(
          // YarnGPT inference can take ~60s; keep the connection alive for it.
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 180),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

  Future<void> init() async {
    // iOS: speech_to_text holds the audio session in record mode. Without an
    // explicit playback-capable category, audioplayers fails to play the clip
    // and we silently fall back to the device voice. playAndRecord +
    // defaultToSpeaker lets the YarnGPT mp3 play out loud while STT is active.
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playAndRecord,
            options: const {
              AVAudioSessionOptions.defaultToSpeaker,
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.allowBluetooth,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            contentType: AndroidContentType.speech,
            usageType: AndroidUsageType.assistant,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
    } catch (e) {
      debugPrint('DayX v2 TTS: audio context setup failed: $e');
    }

    try {
      await _player.setReleaseMode(ReleaseMode.stop);
    } catch (_) {}

    try {
      if (await _fallbackTts.isLanguageAvailable('en-US') == 1) {
        await _fallbackTts.setLanguage('en-US');
      }
      await _fallbackTts.setVolume(0.55);
      await _fallbackTts.setSpeechRate(0.48);
      await _fallbackTts.awaitSpeakCompletion(true);
      _fallbackReady = true;
    } catch (_) {
      _fallbackReady = false;
    }
  }

  /// Speaks [text]. Plays the YarnGPT clip (cached or freshly synthesized) and
  /// falls back to the device voice on any failure. [onAudioStart] fires the
  /// moment sound actually begins — use it to drop a "preparing voice" state.
  Future<void> speak(String text, {void Function()? onAudioStart}) async {
    final trimmed = DayxVoiceService.trimForSpeech(text);
    if (trimmed.isEmpty) return;

    await stop();
    _speaking = true;
    final voice = DayxV2Prefs.selectedVoiceId ?? 'Idera';

    try {
      if (kIsWeb) {
        final bytes = await _ensureBytes(trimmed, voice);
        if (bytes != null && bytes.isNotEmpty) {
          onAudioStart?.call();
          _speaking = true;
          await _player.play(BytesSource(bytes));
          await _awaitPlaybackComplete();
          return;
        }
      } else {
        final file = await _ensureCachedFile(trimmed, voice);
        if (file != null) {
          onAudioStart?.call();
          _speaking = true;
          await _player.play(DeviceFileSource(file.path));
          await _awaitPlaybackComplete();
          return;
        }
      }
    } catch (e, st) {
      debugPrint('DayX v2 TTS: YarnGPT path failed ($e) — using device voice.');
      debugPrint('$st');
    } finally {
      _speaking = false;
    }

    onAudioStart?.call();
    await _speakFallback(trimmed);
  }

  /// Synthesizes and caches [phrases] in the background (skips ones already
  /// cached). Used to pre-bake the fixed phrase set so it plays instantly.
  Future<void> prewarm(Iterable<String> phrases) async {
    if (kIsWeb) return;
    final voice = DayxV2Prefs.selectedVoiceId ?? 'Idera';
    for (final phrase in phrases) {
      final trimmed = DayxVoiceService.trimForSpeech(phrase);
      if (trimmed.isEmpty) continue;
      try {
        final file = await _fileFor(trimmed, voice);
        if (await file.exists()) continue;
        // Don't fight a live reply for the (single-lane) synth engine.
        var guard = 0;
        while (_speaking && guard++ < 60) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
        final bytes = await _fetchYarnGptAudio(trimmed, voice);
        if (bytes != null && bytes.isNotEmpty) {
          await file.writeAsBytes(bytes, flush: true);
          debugPrint('DayX v2 TTS: pre-warmed "${_preview(trimmed)}" ($voice)');
        }
      } catch (e) {
        debugPrint('DayX v2 TTS: pre-warm failed for "${_preview(phrase)}": $e');
      }
    }
  }

  Future<void> _awaitPlaybackComplete() async {
    await _player.onPlayerComplete.first.timeout(
      const Duration(seconds: 120),
      onTimeout: () {},
    );
  }

  /// Returns a playable cache file (cached or freshly fetched), or null if the
  /// fetch produced no audio.
  Future<File?> _ensureCachedFile(String text, String voice) async {
    final file = await _fileFor(text, voice);
    if (await file.exists()) {
      debugPrint('DayX v2 TTS: cache hit for "${_preview(text)}" ($voice)');
      return file;
    }
    final bytes = await _fetchYarnGptAudio(text, voice);
    if (bytes == null || bytes.isEmpty) return null;
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<Uint8List?> _ensureBytes(String text, String voice) =>
      _fetchYarnGptAudio(text, voice);

  Future<Directory> _ensureCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    // Application support survives across sessions, so we don't re-spend the
    // slow/limited YarnGPT quota for the same phrase (temp dirs get purged).
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/dayx_v2_tts');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  Future<File> _fileFor(String text, String voice) async {
    final dir = await _ensureCacheDir();
    final key = md5.convert(utf8.encode('$voice|mp3|$text')).toString();
    return File('${dir.path}/$key.mp3');
  }

  Future<Uint8List?> _fetchYarnGptAudio(String text, String voice) async {
    final token = await localCache.getToken();
    debugPrint(
      'DayX v2 TTS: synthesizing "${_preview(text)}" ($voice) — may take ~30-60s…',
    );
    final response = await _dio.post(
      '${F.baseUrl}/dayx/tts',
      data: {'text': text, 'voice': voice, 'format': 'mp3'},
      options: Options(
        responseType: ResponseType.json,
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    final root = response.data;
    if (root is! Map<String, dynamic>) {
      debugPrint('DayX v2 TTS: unexpected response shape: ${root.runtimeType}');
      return null;
    }
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root;
    final b64 = data['audioBase64']?.toString();
    if (b64 == null || b64.isEmpty) {
      debugPrint('DayX v2 TTS: response missing audioBase64');
      return null;
    }
    final bytes = base64Decode(b64);
    debugPrint('DayX v2 TTS: received ${bytes.length} bytes ($voice)');
    return bytes;
  }

  Future<void> _speakFallback(String text) async {
    if (!_fallbackReady) return;
    _speaking = true;
    try {
      await _fallbackTts.speak(text);
    } finally {
      _speaking = false;
    }
  }

  String _preview(String text) =>
      text.length <= 40 ? text : '${text.substring(0, 40)}…';

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    if (_fallbackReady) {
      try {
        await _fallbackTts.stop();
      } catch (_) {}
    }
    _speaking = false;
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
