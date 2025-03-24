import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:indrive_clone_flutter/src/config/AppConfig.dart';
import 'package:indrive_clone_flutter/src/data/DataBaseFenotipo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Fenotiposervice {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> getFenotipos() async {
    final url = Uri.parse("$baseUrl/getFenotipos");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("No se encontro el token.");
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
            return {"fenotipo_id": color['id'], "nombre": color['nombre']};
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

  Future<List<Map<String, dynamic>>> listaFenotipos() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    final dataBaseColor = DataBaseFenotipo.instance;

    if (connectivityResult == ConnectivityResult.none) {
      return await dataBaseColor.getFenotipos();
    } else {
      List<Map<String, dynamic>> listadoColores = await getFenotipos();

      // REALIZAMOS EL SINCRONIZADO DE DATOS DE COLORES
      for (var color in listadoColores) {
        Map<String, dynamic>? result = await dataBaseColor.getFenotipoFindById(
          color['fenotipo_id'],
        );

        if (result == null) {
          Map<String, dynamic> newFenotipo = {
            "fenotipo_id": color['fenotipo_id'],
            "nombre": color['nombre'],
          };
          dataBaseColor.insertFenotipo(newFenotipo);
        } else {
          dataBaseColor.editarFenotipo(color['fenotipo_id'], color['nombre']);
        }
      }
      return await dataBaseColor.getFenotipos();
    }
  }
}
