import 'dart:convert';
import 'dart:developer';

class APIResponse<T> {
  dynamic data;
  bool error;
  String message;

  APIResponse({this.data, this.error = false, this.message = ""});

  factory APIResponse.fromJson(Map<String, dynamic> data) {
    // log("Response============> ${json.encode(data)}");
    
    // Handle status code - prioritize 'code' field, then 'status'
    int? statusCode;
    if (data['code'] != null) {
      statusCode = data['code'] is int ? data['code'] : int.tryParse(data['code'].toString());
    } else if (data['status'] != null && data['status'] is int) {
      statusCode = data['status'] as int;
    }
    
    // Handle error determination - check both status string and status code
    bool isError = true;
    if (data['status'] != null) {
      // If status is a string like "success" or "error"
      if (data['status'] is String) {
        isError = data['status'].toString().toLowerCase() != 'success';
      } else if (data['status'] is int) {
        isError = data['status'] != 200;
      }
    } else if (statusCode != null) {
      // Fallback to status code
      isError = statusCode != 200;
    }
    
    return APIResponse(
        error: isError,
        message: data['message'] ?? "",
        data: data['data']);
  }
}
