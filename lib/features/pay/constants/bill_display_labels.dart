/// User-facing bill labels: 9mobile → T2mobile, always drop “Nigeria”.
String formatBillBillerLabel(String raw) {
  var label = raw.trim();
  if (label.isEmpty) return label;

  label = label.replaceAll(
    RegExp(r'9[\s\-]*mobile', caseSensitive: false),
    'T2mobile',
  );
  label = label.replaceAll(
    RegExp(r'\betisalat\b', caseSensitive: false),
    'T2mobile',
  );
  label = label.replaceAll(RegExp(r'\bNigeria\b', caseSensitive: false), '');

  final seen = <String>{};
  final out = <String>[];
  for (final part in label.split(RegExp(r'\s+'))) {
    if (part.isEmpty) continue;
    final key = part.toLowerCase();
    if (key == 'nigeria' || key == 'ng') continue;
    if (!seen.add(key)) continue;
    out.add(part);
  }
  return out.join(' ');
}

String billBillerTitleFrom({String? shortName, required String name}) {
  final pieces = <String>[
    if ((shortName ?? '').trim().isNotEmpty) shortName!.trim(),
    if (name.trim().isNotEmpty) name.trim(),
  ];
  return formatBillBillerLabel(pieces.join(' '));
}
