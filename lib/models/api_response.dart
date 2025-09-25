import 'dart:convert';
import 'dart:developer';

class APIResponse<T> {
  dynamic data;
  bool error;
  String message;

  APIResponse({this.data, this.error = false, this.message = ""});

  factory APIResponse.fromJson(Map<String, dynamic> data) {
    log("Response============> ${json.encode(data)}");
    return APIResponse(
        error: data['status'] != null
            ? (data['status'] == 200 ? false : true)
            : true,
        message: data['message'] ?? "",
        data: data['data']);
  }
}
