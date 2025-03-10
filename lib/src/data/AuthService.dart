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
      final rol = data['usuario']['role'];

      print(data);

      // Guardar token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('usuario', jsonEncode(usuario));
      await prefs.setString('rol', jsonEncode(rol));

      return true;
    } else {
      return false;
    }
  }

  Future<bool> logout() async {
    final url = Uri.parse("$baseUrl/logout");

    // Obtener el token almacenado en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print(url);
    print(token);

    if (token == null) {
      // Si no hay token, no se puede cerrar sesión
      return false;
    }

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      // body: jsonEncode({"email": email, "password": password}),
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      // final data = jsonDecode(response.body);
      // final token = data['token'];
      // final usuario = data['usuario'];
      // final rol = data['usuario']['role'];

      // print(data);

      // Guardar token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // Elimina el token de autenticación
      await prefs.remove('usuario'); // Elimina cualquier dato del usuario
      await prefs.remove('rol'); // Elimina el rol del usuario
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
