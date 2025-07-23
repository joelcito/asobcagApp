import 'dart:convert';

import 'package:FENCAMEL/src/config/AppConfig.dart';
import 'package:FENCAMEL/src/data/DataBaseEquipo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Equiposervice {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> getEquipos() async {
    final url = Uri.parse("$baseUrl/getEquipos");

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
          final equipos = data['data'] as List;
          return equipos.map<Map<String, dynamic>>((equipo) {
            return {"equipo_id": equipo['id'], "nombre": equipo['nombre']};
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

  Future<List<Map<String, dynamic>>> listaEquipos() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    final dataBaseColor = Databaseequipo.instance;

    if (connectivityResult == ConnectivityResult.none) {
      return await dataBaseColor.getEquipos();
    } else {
      List<Map<String, dynamic>> equipos = await getEquipos();

      // REALIZAMOS EL SINCRONIZADO DE DATOS DE COLORES
      for (var equipo in equipos) {
        Map<String, dynamic>? result = await dataBaseColor.getEquipoFindById(
          equipo['equipo_id'],
        );

        if (result == null) {
          Map<String, dynamic> newEquipo = {
            "equipo_id": equipo['equipo_id'],
            "nombre": equipo['nombre'],
          };
          dataBaseColor.insertEquipo(newEquipo);
        } else {
          dataBaseColor.editarEquipo(equipo['equipo_id'], equipo['nombre']);
        }
      }
      return await dataBaseColor.getEquipos();
    }
  }
}
