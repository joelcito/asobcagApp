import 'dart:convert';

import 'package:FENCAMEL/src/config/AppConfig.dart';
import 'package:FENCAMEL/src/data/DataBaseProductoVeterrinario.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Productoveterrinarioservice {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<Map<String, dynamic>>> getProductoVeterrinarios() async {
    final url = Uri.parse("$baseUrl/getProductoVeterrinarios");

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
          final producto_veterrinarios = data['data'] as List;
          return producto_veterrinarios.map<Map<String, dynamic>>((
            producto_veterrinario,
          ) {
            return {
              "producto_veterrinario_id": producto_veterrinario['id'],
              "nombre": producto_veterrinario['nombre'],
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

  Future<List<Map<String, dynamic>>> listaProductoVeterrinarios() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    final dataBaseColor = Databaseproductoveterrinario.instance;

    if (connectivityResult == ConnectivityResult.none) {
      return await dataBaseColor.getProductoVeterrinarios();
    } else {
      List<Map<String, dynamic>> listadoProductoVeterrinarios =
          await getProductoVeterrinarios();

      // REALIZAMOS EL SINCRONIZADO DE DATOS DE COLORES
      for (var producto_veterrinario in listadoProductoVeterrinarios) {
        Map<String, dynamic>? result = await dataBaseColor
            .getProductoVeterrinarioFindById(
              producto_veterrinario['producto_veterrinario_id'],
            );

        if (result == null) {
          Map<String, dynamic> newProductoVeterrinario = {
            "producto_veterrinario_id":
                producto_veterrinario['producto_veterrinario_id'],
            "nombre": producto_veterrinario['nombre'],
          };
          dataBaseColor.insertProductoVeterrinario(newProductoVeterrinario);
        } else {
          dataBaseColor.editarProductoVeterrinario(
            producto_veterrinario['producto_veterrinario_id'],
            producto_veterrinario['nombre'],
          );
        }
      }
      return await dataBaseColor.getProductoVeterrinarios();
    }
  }
}
