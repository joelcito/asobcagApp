import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/AppConfig.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  // final String baseUrl = "https://tu-api.com/api"; // Cambia con tu URL
  final String baseUrl = AppConfig.baseUrl; // Cambia con tu URL

  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    // print(url);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final refreshToken = data['refresh_token'];
      final usuario = data['usuario'];
      final rol = data['usuario']['role'];

      // print(data);

      // Guardar token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('refresh_token', refreshToken);
      await prefs.setString('usuario', jsonEncode(usuario));
      await prefs.setString('rol', jsonEncode(rol));

      return true;
    } else {
      return false;
    }
  }

  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return false; // Si no hay token, no se puede cerrar sesión
    }

    final url = Uri.parse("$baseUrl/logout");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      // Eliminar tokens de SharedPreferences
      await prefs.remove('token');
      await prefs.remove('refresh_token');
      await prefs.remove('usuario');
      await prefs.remove('rol');
      return true;
    } else {
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> isTokenExpired(String token) async {
    return JwtDecoder.isExpired(token); // Retorna true si el token ha expirado
  }

  Future<String?> refreshAccessToken(String refreshToken) async {
    final url = Uri.parse("$baseUrl/refreshToken");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh_token": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token']; // Retorna el nuevo access token
    } else {
      return null; // El refresh token no es válido
    }
  }

  Future<String?> getValidAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('token');
    final refreshToken = prefs.getString('refresh_token');

    if (accessToken == null) {
      return null; // No hay access token
    }

    if (await isTokenExpired(accessToken)) {
      // Si el token ha expirado, intenta refrescarlo
      if (refreshToken != null) {
        final newAccessToken = await refreshAccessToken(refreshToken);
        if (newAccessToken != null) {
          await prefs.setString(
            'token',
            newAccessToken,
          ); // Guarda el nuevo token
          return newAccessToken;
        }
      }
      return null; // Si no se pudo refrescar el token
    }

    return accessToken; // El token es válido
  }
}
