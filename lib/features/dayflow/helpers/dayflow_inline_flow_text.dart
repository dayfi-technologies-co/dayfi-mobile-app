import 'package:dayfi/features/dayx/models/dayx_flow.dart';

String dayFlowInlineFlowBubbleText({
  required String text,
  DayxFlowUi? flowUi,
}) {
  var cleaned = text.trim();
  if (flowUi == null) return cleaned;

  final lower = cleaned.toLowerCase();
  final buf = StringBuffer(cleaned);

  if (flowUi.rateLine != null && flowUi.rateLine!.isNotEmpty) {
    buf.writeln('\n${flowUi.rateLine}');
  }

  if (flowUi.review.isNotEmpty) {
    buf.writeln('');
    for (final line in flowUi.review) {
      buf.writeln('${line.label}: ${line.value}');
    }
    if (!lower.contains('confirm')) {
      buf.writeln('\nReply confirm to continue, or cancel to stop.');
    }
  } else if (flowUi.options.isNotEmpty && flowUi.input == null) {
    buf.writeln('');
    final selectable =
        flowUi.options
            .where((o) => o.id != 'confirm' && o.id != 'cancel')
            .toList();
    for (var i = 0; i < selectable.length; i++) {
      final opt = selectable[i];
      final subtitle =
          opt.subtitle != null && opt.subtitle!.isNotEmpty
              ? ' — ${opt.subtitle}'
              : '';
      buf.writeln('${i + 1}. ${opt.label}$subtitle');
    }
    if (flowUi.options.any((o) => o.id == 'confirm')) {
      if (!lower.contains('confirm')) {
        buf.writeln('\nReply confirm when ready, or cancel.');
      }
    } else {
      buf.writeln('\nReply with a number or name.');
    }
  }

  final input = flowUi.input;
  if (input != null) {
    final body = buf.toString().toLowerCase();
    if (input.isPin && !body.contains('pin')) {
      buf.writeln('\nEnter your 4-digit PIN.');
    } else if (input.isAmount && !body.contains('amount')) {
      buf.writeln('\nEnter the amount.');
    }
  }

  return buf.toString().trim();
}

String dayFlowUserBubbleForOption(DayxFlowOption option, {String? typed}) {
  final raw = typed?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  switch (option.id) {
    case 'confirm':
      return 'Confirm';
    case 'cancel':
      return 'Cancel';
    default:
      return option.label;
  }
}

DayxFlowOption? dayFlowMatchFlowOption(DayxFlowUi ui, String text) {
  final q = text.toLowerCase().trim();
  if (q.isEmpty) return null;

  final numbered = RegExp(r'^(\d+)$').firstMatch(q);
  if (numbered != null) {
    final idx = int.tryParse(numbered.group(1)!);
    final selectable =
        ui.options.where((o) => o.id != 'confirm' && o.id != 'cancel').toList();
    if (idx != null && idx >= 1 && idx <= selectable.length) {
      return selectable[idx - 1];
    }
  }

  if (q == 'confirm' ||
      q == 'yes' ||
      q == 'ok' ||
      q.startsWith('confirm')) {
    for (final opt in ui.options) {
      if (opt.id == 'confirm') return opt;
    }
  }
  if (q == 'cancel' || q == 'stop' || q == 'no') {
    for (final opt in ui.options) {
      if (opt.id == 'cancel') return opt;
    }
  }

  for (final opt in ui.options) {
    final label = opt.label.toLowerCase();
    final id = opt.id.toLowerCase();
    if (label == q || id == q || label.contains(q) || q.contains(label)) {
      return opt;
    }
  }
  return null;
}
