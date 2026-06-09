import 'dart:convert';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/services/local/local_cache.dart';

/// Persists merged send recipients for instant picker / list hydration.
class RecipientsListCache {
  RecipientsListCache._();

  static const cacheKey = 'recipients_v5';

  static LocalCache get _cache => locator<LocalCache>();

  static List<BeneficiaryWithSource>? read() {
    final raw = _cache.getFromLocalCache(cacheKey);
    if (raw == null) return null;
    try {
      final List<dynamic> list =
          raw is String ? beneficiariesFromJson(raw) : (raw as List<dynamic>);
      return list.map((e) => BeneficiaryWithSource.fromJson(e)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(List<BeneficiaryWithSource> recipients) async {
    await _cache.saveToLocalCache(
      key: cacheKey,
      value: json.encode(recipients.map((e) => e.toJson()).toList()),
    );
  }
}
