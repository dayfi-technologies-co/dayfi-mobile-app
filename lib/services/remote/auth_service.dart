import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/api_response.dart';
import 'package:dayfi/core/network/network_service.dart';
import 'package:dayfi/core/network/url_config.dart';

class AuthService {
  NetworkService _networkService;
  AuthService({required NetworkService networkService})
    : _networkService = networkService;

  void updateNetworkService() =>
      _networkService = NetworkService(baseUrl: F.baseUrl);

  Future<APIResponse> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['email'] = username;
      map['password'] = password;
      final response = await _networkService.call(
        F.baseUrl + UrlConfig.login,
        RequestMethod.post,
        data: map,
      );

      return APIResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
