import 'package:http/http.dart' as http;
import 'package:indrive_clone_flutter/src/data/AuthService.dart';
import '../config/AppConfig.dart';

class ApiHelper {
  // final String baseUrl = "https://tu-api.com/api";
  final String baseUrl = AppConfig.baseUrl;
  final AuthService authService = AuthService();

  Future<http.Response> get(String endpoint) async {
    final token = await authService.getToken();
    final url = Uri.parse("$baseUrl/$endpoint");

    return http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }
}
