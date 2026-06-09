import 'dart:convert';

import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/remote/network/api_error.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

class SmileKycApiService {
  final NetworkService _networkService;

  SmileKycApiService(this._networkService);

  Future<Map<String, dynamic>> fetchKycStatus() async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.smileKycStatus}',
        RequestMethod.get,
      );
      return _parseData(response.data);
    } on ApiError catch (e) {
      throw Exception(e.errorDescription);
    }
  }

  Future<Map<String, dynamic>> verifyBvnWithSmile({required String bvn}) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.smileVerifyBvn}',
        RequestMethod.post,
        data: {'bvn': bvn},
      );
      return _parseData(response.data);
    } on ApiError catch (e) {
      throw Exception(e.errorDescription);
    }
  }

  Future<Map<String, dynamic>> prepareBvnVerification() async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.smilePrepareBvn}',
        RequestMethod.post,
        data: const {},
      );
      return _parseData(response.data);
    } on ApiError catch (e) {
      throw Exception(e.errorDescription);
    }
  }

  Future<Map<String, dynamic>> completeSmileKyc({
    required String smileResultJson,
    required String idType,
    required String jobId,
  }) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.smileComplete}',
        RequestMethod.post,
        data: {
          'smileResult': smileResultJson,
          'idType': idType,
          'jobId': jobId,
        },
      );
      return _parseData(response.data);
    } on ApiError catch (e) {
      throw Exception(e.errorDescription);
    }
  }

  Future<Map<String, dynamic>> verifyNinWithSmile({required String nin}) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.smileVerifyNin}',
        RequestMethod.post,
        data: {'nin': nin},
      );
      return _parseData(response.data);
    } on ApiError catch (e) {
      throw Exception(e.errorDescription);
    }
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
