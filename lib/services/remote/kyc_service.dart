import 'dart:convert';

import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/remote/network/api_error.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

class KycApiService {
  final NetworkService _networkService;

  KycApiService(this._networkService);

  Future<Map<String, dynamic>> verifyIdentity({
    required String bvn,
    required String nin,
  }) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.kycVerifyIdentity}',
        RequestMethod.post,
        data: {'bvn': bvn, 'nin': nin},
      );
      return _parseData(response.data);
    } on ApiError catch (e) {
      throw Exception(_messageFromApiError(e));
    }
  }

  Future<Map<String, dynamic>> fetchKycStatus() async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.smileKycStatus}',
        RequestMethod.get,
      );
      return _parseData(response.data);
    } on ApiError catch (e) {
      throw Exception(_messageFromApiError(e));
    }
  }

  static String _messageFromApiError(ApiError e) {
    final fromModel = (e.apiErrorModel?.message ?? '').trim();
    if (fromModel.isNotEmpty) return fromModel;
    final desc = (e.errorDescription ?? '').trim();
    if (desc.isNotEmpty && !desc.contains('status code')) return desc;
    return 'Verification failed. Please check your BVN and NIN and try again.';
  }

  Map<String, dynamic> _parseData(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    if (raw is String) {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) return data;
        return decoded;
      }
    }
    return {};
  }
}
