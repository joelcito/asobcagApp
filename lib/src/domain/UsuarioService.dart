import 'dart:convert';

import 'package:FENCAMEL/src/config/AppConfig.dart';
import 'package:FENCAMEL/src/data/DataBaseUsuario.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Usuarioservice {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> getUsuarios() async {
    final url = Uri.parse("$baseUrl/getUsuarios");

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
          final usuarios = data['data'] as List;
          return usuarios.map<Map<String, dynamic>>((usuario) {
            return {"usuario_id": usuario['id'], "nombre": usuario['name']};
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

  Future<List<Map<String, dynamic>>> listaUsuarios() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    final dataBaseColor = Databaseusuario.instance;

    if (connectivityResult == ConnectivityResult.none) {
      return await dataBaseColor.getUsuarios();
    } else {
      List<Map<String, dynamic>> listadoUsuarios = await getUsuarios();

      // REALIZAMOS EL SINCRONIZADO DE DATOS DE COLORES
      for (var usuario in listadoUsuarios) {
        Map<String, dynamic>? result = await dataBaseColor.getUsuarioFindById(
          usuario['usuario_id'],
        );

        if (result == null) {
          Map<String, dynamic> newUsuario = {
            "usuario_id": usuario['usuario_id'],
            "nombre": usuario['nombre'],
          };
          dataBaseColor.insertUsuario(newUsuario);
        } else {
          dataBaseColor.editarUsuario(usuario['usuario_id'], usuario['nombre']);
        }
      }
      return await dataBaseColor.getUsuarios();
    }
  }
}
