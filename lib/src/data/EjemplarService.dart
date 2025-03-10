import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/AppConfig.dart';

class EjemplarService {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> ejemplaresUsuario() async {
    final url = Uri.parse("$baseUrl/ejemplaresUsuario");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("No se pudo obtener el token.");
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ejemplares = data['ejemplares'] as List;

        return ejemplares.map<Map<String, dynamic>>((ejemplar) {
          return {"title": ejemplar['nombre'], "images": ejemplar['imagenes']};
        }).toList();
      } else if (response.statusCode == 401) {
        throw Exception("El token ha expirado o no es válido.");
      } else {
        throw Exception(
          "Error al obtener los ejemplares. Código: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }
}
