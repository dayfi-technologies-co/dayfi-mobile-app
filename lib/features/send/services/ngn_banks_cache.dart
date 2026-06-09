import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/services/remote/payment_service.dart';

/// In-memory cache for Nigerian bank list (Flutterwave). Shared across send flows.
class NgnBanksCache {
  NgnBanksCache._();

  static List<Network>? _banks;
  static DateTime? _loadedAt;
  static Future<List<Network>>? _inFlight;
  static const Duration _ttl = Duration(hours: 24);

  static bool get hasFreshCache =>
      _banks != null &&
      _banks!.isNotEmpty &&
      _loadedAt != null &&
      DateTime.now().difference(_loadedAt!) < _ttl;

  static List<Network>? get cached => hasFreshCache ? List<Network>.from(_banks!) : null;

  static void seed(List<Network> banks) {
    if (banks.isEmpty) return;
    _banks = List<Network>.from(banks);
    _loadedAt = DateTime.now();
  }

  /// Loads NG banks once; concurrent callers share the same in-flight request.
  static Future<List<Network>> load(PaymentService paymentService) async {
    if (hasFreshCache) return List<Network>.from(_banks!);
    if (_inFlight != null) return _inFlight!;

    _inFlight = _loadInternal(paymentService);
    try {
      return await _inFlight!;
    } finally {
      _inFlight = null;
    }
  }

  static Future<List<Network>> _loadInternal(
    PaymentService paymentService,
  ) async {
    final response = await paymentService.fetchNigerianBanks();
    if (response.statusCode == 200 &&
        response.data?.networks != null &&
        response.data!.networks!.isNotEmpty) {
      _banks = response.data!.networks!;
      _loadedAt = DateTime.now();
      return List<Network>.from(_banks!);
    }
    return _banks != null ? List<Network>.from(_banks!) : [];
  }
}
