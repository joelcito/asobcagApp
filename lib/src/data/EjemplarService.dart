import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:indrive_clone_flutter/src/data/DatabaseHelper.dart';
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

  // Future<void> saveEjemplar(String nombre, String descripcion) async {
  //   final db = await DatabaseHelper.instance.database;
  //   final connectivity = await Connectivity().checkConnectivity();

  //   if (connectivity == ConnectivityResult.none) {
  //     // No hay internet, guardar en local
  //     await db.insert('ejemplares', {
  //       'nombre': nombre,
  //       'descripcion': descripcion,
  //       'sync_status': 0, // 0 = No sincronizado
  //     });
  //   } else {
  //     // Hay internet, enviar al servidor
  //     bool success = await sendToServer(nombre, descripcion);
  //     if (!success) {
  //       // Si falla, guardar en local
  //       await db.insert('ejemplares', {
  //         'nombre': nombre,
  //         'descripcion': descripcion,
  //         'sync_status': 0,
  //       });
  //     }
  //   }
  // }

  // Future<bool> sendToServer(String nombre, String descripcion) async {
  //   try {
  //     // Simulación de petición al servidor
  //     await Future.delayed(Duration(seconds: 2));
  //     print("Ejemplar enviado a servidor: $nombre - $descripcion");
  //     return true;
  //   } catch (e) {
  //     print("Error enviando ejemplar: $e");
  //     return false;
  //   }
  // }

  // Future<void> syncOfflineEjemplares() async {
  //   final db = await DatabaseHelper.instance.database;
  //   final connectivity = await Connectivity().checkConnectivity();

  //   if (connectivity != ConnectivityResult.none) {
  //     List<Map<String, dynamic>> ejemplares = await db.query(
  //       'ejemplares',
  //       where: 'sync_status = 0',
  //     );

  //     for (var ejemplar in ejemplares) {
  //       bool success = await sendToServer(ejemplar['nombre'], ejemplar['descripcion']);
  //       if (success) {
  //         await db.delete('ejemplares', where: 'id = ?', whereArgs: [ejemplar['id']]);
  //       }
  //     }
  //   }
  // }

  Future<bool> registroEjemplar(
    String nombre,
    String especie,
    String descripcion,
  ) async {
    var connectivityResult = await Connectivity().checkConnectivity();

    Map<String, dynamic> ejemplar = {
      "nombre": nombre,
      "especie": especie,
      "descripcion": descripcion,
    };

    // print(ejemplar);
    // print(connectivityResult);
    // print(ConnectivityResult.none);
    // print(connectivityResult == ConnectivityResult.none);

    if (connectivityResult == ConnectivityResult.none) {
      // Guardar en la base de datos local si no hay conexión
      await DatabaseHelper.instance.insertEjemplar(ejemplar);
      return true;
    } else {
      final url = Uri.parse("$baseUrl/registroEjemplar");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // print(url);
      // print(token);
      // print(token == null);

      if (token == null) {
        return false;
        // throw Exception("No se pudo obtener el token.");
      }
      // Enviar directamente al servidor si hay conexión
      final response = await http.post(
        url,
        // headers: {"Content-Type": "application/json"},
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(ejemplar),
      );

      print("---------------------------------------");
      print(response);
      print(response.statusCode);
      print("---------------------------------------");

      // if (response.statusCode == 201) {
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }

    //  ****************  ESTE ESTA FUNCIONADO BEIN YA AGREGA ****************
    // final url = Uri.parse("$baseUrl/registroEjemplar");
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString('token');

    // if (token == null) {
    //   return false;
    //   // throw Exception("No se pudo obtener el token.");
    // }

    // print(url);

    // final json = {"nombre": nombre, "especie": especie, "descripcion": descripcion};

    // final response = await http.post(
    //   url,
    //   headers: {"Content-Type": "application/json","Authorization": "Bearer $token"},
    //   body: jsonEncode(json),
    // );

    // if (response.statusCode == 200) {
    //   return true;
    // } else {
    //   return false;
    // }
  }

  Future<void> enviarEjemplaresPendientes() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      List<Map<String, dynamic>> pendientes =
          await DatabaseHelper.instance.getEjemplaresPendientes();

      print("*******************************************");
      print("SE ESTA MANDADO EL OFFLINE");
      print(pendientes);
      print("*******************************************");

      for (var ejemplar in pendientes) {
        final url = Uri.parse("$baseUrl/registroEjemplar");
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(ejemplar),
        );

        // if (response.statusCode == 201) {
        if (response.statusCode == 200) {
          await DatabaseHelper.instance.deleteEjemplar(ejemplar['id']);
        }
      }
    }
  }
}
