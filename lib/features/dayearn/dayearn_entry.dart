import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/feature_intro_keys.dart';
import 'package:dayfi/common/services/feature_activity_service.dart';
import 'package:dayfi/features/dayearn/services/dayearn_summary_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Resolves whether DayEarn marketing intro should be skipped.
abstract final class DayEarnEntry {
  DayEarnEntry._();

  static const _hasPotsKey = 'dayearn_has_pots_v1';

  static Future<void> markHasPots() async {
    await locator<SharedPreferences>().setBool(_hasPotsKey, true);
  }

  static Future<bool> shouldSkipIntro() async {
    if (locator<SharedPreferences>().getBool(_hasPotsKey) == true) {
      return true;
    }

    final cached = DayEarnSummaryCache.instance.peek();
    if (cached != null && cached.pots.isNotEmpty) {
      await markHasPots();
      return true;
    }

    try {
      final summary = await dayEarnService.fetchSummary();
      if (summary.pots.isNotEmpty) {
        await markHasPots();
        return true;
      }
    } catch (_) {}

    return FeatureActivityService.instance.hasActivity(DayfiHomeFeature.invest);
  }
}
