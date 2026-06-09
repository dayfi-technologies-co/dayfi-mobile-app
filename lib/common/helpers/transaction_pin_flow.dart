import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/helpers/transaction_completion_flow.dart';
import 'package:dayfi/common/widgets/transaction_processing_overlay.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/send/views/send_review_view.dart';
import 'package:dayfi/features/send/vm/transaction_pin_viewmodel.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared flow: ensure the user has a transaction PIN (create if missing),
/// then collect it via the standard bottom sheet (same as Send review).
class TransactionPinFlow {
  TransactionPinFlow._();

  static Future<bool> hasTransactionPin(WidgetRef ref) async {
    await ref.read(profileViewModelProvider.notifier).loadUserProfile();
    final user = ref.read(profileViewModelProvider).user;
    return user?.transactionPin != null && user!.transactionPin!.isNotEmpty;
  }

  /// Returns a 4-digit PIN, or `null` if the user cancelled or did not create a PIN.
  static Future<String?> requestPin({
    required BuildContext context,
    required WidgetRef ref,
    String? returnRoute,
    Map<String, dynamic>? returnArguments,
    ValueNotifier<bool>? isProcessing,
  }) async {
    if (!await hasTransactionPin(ref)) {
      await appRouter.pushNamed(
        AppRoute.transactionPinCreateView,
        arguments: {
          if (returnRoute != null) 'returnRoute': returnRoute,
          if (returnArguments != null) 'returnArguments': returnArguments,
        },
      );
      if (!context.mounted) return null;
      if (!await hasTransactionPin(ref)) return null;
    }

    if (!context.mounted) return null;

    final processing = isProcessing ?? ValueNotifier<bool>(false);
    ref.read(transactionPinProvider.notifier).resetForm();
    processing.value = false;

    return showModalBottomSheet<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (bottomSheetContext) => ValueListenableBuilder<bool>(
        valueListenable: processing,
        builder: (_, processingPin, __) => TransactionPinBottomSheet(
          onPinEntered: (pin) => Navigator.pop(bottomSheetContext, pin),
          isProcessing: processingPin,
        ),
      ),
    );
  }

  /// Collect PIN, close the sheet, show a blocking overlay, then run [task].
  static Future<T?> requestPinAndRun<T>({
    required BuildContext context,
    required WidgetRef ref,
    required Future<T> Function(String pin) task,
    String? returnRoute,
    Map<String, dynamic>? returnArguments,
    ValueNotifier<bool>? isProcessing,
  }) async {
    final pin = await requestPin(
      context: context,
      ref: ref,
      returnRoute: returnRoute,
      returnArguments: returnArguments,
      isProcessing: isProcessing,
    );
    if (pin == null || !context.mounted) return null;

  if (isProcessing != null) {
      isProcessing.value = false;
    }

    return TransactionCompletionFlow.runWithOverlay(
      context: context,
      task: () => task(pin),
    );
  }

  /// For flows that use a custom PIN bottom sheet: dismiss sheet, then overlay + task.
  static Future<T?> afterPinFromSheet<T>({
    required BuildContext context,
    required BuildContext sheetContext,
    required Future<T> Function() task,
    ValueNotifier<bool>? isProcessing,
  }) async {
    if (isProcessing != null) {
      isProcessing.value = false;
    }
    if (sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }
    if (!context.mounted) return null;
    return TransactionCompletionFlow.runWithOverlay(
      context: context,
      task: task,
    );
  }

  static void hideProcessingOverlay() {
    TransactionProcessingOverlay.hide();
  }
}
