import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/AppConfig.dart';

class AuthService {
  // final String baseUrl = "https://tu-api.com/api"; // Cambia con tu URL
  final String baseUrl = AppConfig.baseUrl; // Cambia con tu URL

  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    print(url);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final usuario = data['usuario'];

      print(data);

      // Guardar token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('usuario', jsonEncode(usuario));

      return true;
    } else {
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
