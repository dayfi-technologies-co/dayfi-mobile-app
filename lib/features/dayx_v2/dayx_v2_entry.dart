import 'package:dayfi/features/dayx/widgets/dayx_navigation.dart';
import 'package:dayfi/features/dayx_v2/services/dayx_v2_prefs.dart';
import 'package:dayfi/features/dayx_v2/views/dayx_v2_overlay.dart';
import 'package:dayfi/features/dayx_v2/views/dayx_v2_voice_picker.dart';
import 'package:flutter/material.dart';

/// Opens DayX v2 — voice picker on first launch, then voice-first overlay.
abstract final class DayxV2Entry {
  DayxV2Entry._();

  static Future<void> open(
    BuildContext context, {
    required DayxChangeTab onChangeTab,
    void Function(String target)? onNavigate,
    bool fromNavHold = false,
  }) async {
    if (!DayxV2Prefs.hasSelectedVoice) {
      await Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (pickerContext) => DayxV2VoicePicker(
            onDone: () => Navigator.of(pickerContext).pop(),
          ),
        ),
      );
      if (!context.mounted) return;
    }

    await DayxV2Overlay.show(
      context,
      onChangeTab: onChangeTab,
      onNavigate: onNavigate,
      fromNavHold: fromNavHold,
    );
  }
}
