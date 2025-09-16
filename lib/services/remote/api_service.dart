import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<String> fetchData() async {
    final response = await _dio.get('https://jsonplaceholder.typicode.com/todos/1');
    return response.data.toString();
  }
}
