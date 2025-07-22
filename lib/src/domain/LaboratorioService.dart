import 'dart:convert';

import 'package:FENCAMEL/src/config/AppConfig.dart';
import 'package:FENCAMEL/src/data/DataBaseLaboratorio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Laboratorioservice {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> getLaboratorios() async {
    final url = Uri.parse("$baseUrl/getLaboratorios");

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
          final laboratorios = data['data'] as List;
          return laboratorios.map<Map<String, dynamic>>((laboratorio) {
            return {
              "laboratorio_id": laboratorio['id'],
              "nombre": laboratorio['nombre'],
            };
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

  Future<List<Map<String, dynamic>>> listaLaboratorios() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    final dataBaseColor = Databaselaboratorio.instance;

    if (connectivityResult == ConnectivityResult.none) {
      return await dataBaseColor.getLaboratorios();
    } else {
      List<Map<String, dynamic>> listadoLaboratorios = await getLaboratorios();

      // REALIZAMOS EL SINCRONIZADO DE DATOS DE COLORES
      for (var laboratorio in listadoLaboratorios) {
        Map<String, dynamic>? result = await dataBaseColor
            .getLaboratorioFindById(laboratorio['laboratorio_id']);

        if (result == null) {
          Map<String, dynamic> newLaboratorio = {
            "laboratorio_id": laboratorio['laboratorio_id'],
            "nombre": laboratorio['nombre'],
          };
          dataBaseColor.insertLaboratorio(newLaboratorio);
        } else {
          dataBaseColor.editarLaboratorio(
            laboratorio['laboratorio_id'],
            laboratorio['nombre'],
          );
        }
      }
      return await dataBaseColor.getLaboratorios();
    }
  }
}
