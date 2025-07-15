import 'dart:convert';

// import 'package:FENCAMEL/src/config/AppConfig.dart';
import 'package:FENCAMEL/src/config/AppConfig.dart';
import 'package:FENCAMEL/src/data/DataBaseColor.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Colorservice {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> getColores() async {
    final url = Uri.parse("$baseUrl/getColores");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("No se pudo obtener el token.");
    }

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['estado']) {
          final colores = data['data'] as List;
          return colores.map<Map<String, dynamic>>((color) {
            return {"color_id": color['id'], "nombre": color['nombre']};
          }).toList();
        } else {
          throw Exception("Ocurrio un error: " + data['mensaje']);
        }
      } else if (response.statusCode == 401) {
        throw Exception("El token ha expirado o no es válido.");
      } else {
        throw Exception(
          "Error al obtener los ejemplares. Código: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error de al solicitar datos: $e");
    }
  }

  Future<List<Map<String, dynamic>>> listaColores() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    final dataBaseColor = Databasecolor.instance;

    if (connectivityResult == ConnectivityResult.none) {
      return await dataBaseColor.getColores();
    } else {
      List<Map<String, dynamic>> listadoColores = await getColores();

      // REALIZAMOS EL SINCRONIZADO DE DATOS DE COLORES
      for (var color in listadoColores) {
        Map<String, dynamic>? result = await dataBaseColor.getColorFindById(
          color['color_id'],
        );

        if (result == null) {
          Map<String, dynamic> newColor = {
            "color_id": color['color_id'],
            "nombre": color['nombre'],
          };
          dataBaseColor.insertColor(newColor);
        } else {
          dataBaseColor.editarColor(color['color_id'], color['nombre']);
        }
      }
      return await dataBaseColor.getColores();
    }
  }
}
