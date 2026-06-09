import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:flutter/material.dart';

/// Full-screen blocking overlay while a transaction completes after PIN entry.
class TransactionProcessingOverlay {
  TransactionProcessingOverlay._();

  static OverlayEntry? _entry;

  static bool get isVisible => _entry != null;

  static void show(BuildContext context) {
    hide();
    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          const Positioned.fill(
            child: DayfiLoadingCenter(size: 32, color: Colors.white),
          ),
        ],
      ),
    );
    overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
