import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/feature_intro_keys.dart';
import 'package:dayfi/common/services/feature_activity_service.dart';
import 'package:dayfi/common/views/feature_intro_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeatureIntroService {
  FeatureIntroService._();

  /// Shows intro once per feature (or skips if the user already has activity).
  static Future<void> runWithIntro(
    BuildContext context, {
    required DayfiHomeFeature feature,
    required Future<void> Function() onContinue,
    Future<bool> Function()? shouldSkipIntro,
  }) async {
    final skipFromFeature =
        shouldSkipIntro != null && await shouldSkipIntro();
    final hasActivity =
        skipFromFeature ||
        await FeatureActivityService.instance.hasActivity(feature);
    final hasSeenIntro = await _hasSeenIntro(feature);
    if (!context.mounted) return;

    if (hasActivity || hasSeenIntro) {
      await onContinue();
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (ctx) => FeatureIntroView(
          feature: feature,
          onPrimary: () async {
            await _markIntroSeen(feature);
            if (ctx.mounted) Navigator.of(ctx).pop();
            if (context.mounted) await onContinue();
          },
          onLater: () async {
            await _markIntroSeen(feature);
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
        ),
      ),
    );
  }

  static Future<bool> _hasSeenIntro(DayfiHomeFeature feature) async {
    final prefs = locator<SharedPreferences>();
    return prefs.getBool(feature.storageKey) ?? false;
  }

  static Future<void> _markIntroSeen(DayfiHomeFeature feature) async {
    await locator<SharedPreferences>().setBool(feature.storageKey, true);
  }
}
