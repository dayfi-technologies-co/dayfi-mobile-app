import 'package:dayfi/app_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists DayX v2 voice selection and first-session flag.
abstract final class DayxV2Prefs {
  DayxV2Prefs._();

  static const _voiceKey = 'dayx_v2_voice_id';
  static const _onboardedKey = 'dayx_v2_voice_onboarded';
  static const _introShownKey = 'dayx_v2_intro_shown';

  static SharedPreferences get _prefs => locator<SharedPreferences>();

  static String? get selectedVoiceId {
    final v = _prefs.getString(_voiceKey);
    return v != null && v.isNotEmpty ? v : null;
  }

  static Future<void> setSelectedVoice(String voiceId) async {
    await _prefs.setString(_voiceKey, voiceId);
    await _prefs.setBool(_onboardedKey, true);
  }

  static bool get hasSelectedVoice =>
      _prefs.getBool(_onboardedKey) == true &&
      selectedVoiceId != null;

  /// True only for the first assistant turn after voice selection.
  static bool get shouldShowIntro =>
      hasSelectedVoice && _prefs.getBool(_introShownKey) != true;

  static Future<void> markIntroShown() async {
    await _prefs.setBool(_introShownKey, true);
  }
}
