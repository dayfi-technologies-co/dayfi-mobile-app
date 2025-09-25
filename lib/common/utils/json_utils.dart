import 'dart:convert';

class JsonUtils {
  static bool isValidJson(String data) {
    data = data.trim();
    if (!data.startsWith("{") || !data.endsWith("}")) return false;
    try {
      var parsedData = json.decode(data);
      return parsedData != null;
    } catch (_) {
      return false;
    }
  }

  static formatErrorResponse(String message) {
    return {"error": true, "data": null, "message": message};
  }
}
