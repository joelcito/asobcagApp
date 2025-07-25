import 'dart:convert';
import 'dart:io';
import 'package:FENCAMEL/src/data/DataBaseImage.dart';
import 'package:FENCAMEL/src/data/DatabaseHelper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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
          return {
            "title": ejemplar['nombre'],
            "images": ejemplar['imagenes'],
            "sexo": ejemplar['sexo'],
            "fecha_nacimiento": ejemplar['fecha_nacimiento'],
            "numero_registro": ejemplar['numero_registro'],
            "microchip": ejemplar['microchip'],
            "arete": ejemplar['arete'],
            "tipo": ejemplar['tipo'],
            "nombreFenotipo": ejemplar['nombreFenotipo'],
            "nombreColor": ejemplar['nombreColor'],
            "nombrePadre": ejemplar['nombrePadre'],
            "nombreMadre": ejemplar['nombreMadre'],
          };
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

  Future<List<Map<String, dynamic>>> ejemplaresAlpacasUsuario() async {
    final url = Uri.parse("$baseUrl/ejemplaresAlpacasUsuario");

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
          return {
            "title": ejemplar['nombre'],
            "images": ejemplar['imagenes'],
            "sexo": ejemplar['sexo'],
            "fecha_nacimiento": ejemplar['fecha_nacimiento'],
            "numero_registro": ejemplar['numero_registro'],
            "microchip": ejemplar['microchip'],
            "arete": ejemplar['arete'],
            "tipo": ejemplar['tipo'],
            "nombreFenotipo": ejemplar['nombreFenotipo'],
            "nombreColor": ejemplar['nombreColor'],
            "nombrePadre": ejemplar['nombrePadre'],
            "nombreMadre": ejemplar['nombreMadre'],
          };
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

  Future<bool> registroEjemplar(
    Map<String, dynamic> ejemplar,
    List<File> imagenes,
  ) async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // Guardar en la base de datos local si no hay conexión
      // await DatabaseHelper.instance.insertEjemplar(ejemplar);
      int ejemplarId = await DatabaseHelper.instance.insertEjemplar(ejemplar);

      // Guardar las imágenes asociadas al ejemplar
      for (var imagen in imagenes) {
        await DataBaseImage.instance.insertImagen({
          'ejemplar_id': ejemplarId,
          'ruta':
              imagen
                  .path, // O el nombre del archivo o el path donde guardas la imagen
        });
      }

      return true;
    } else {
      final url = Uri.parse("$baseUrl/registroEjemplar");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return false;
      }

      var request = http.MultipartRequest("POST", url);
      request.headers.addAll({"Authorization": "Bearer $token"});

      // Agregar los datos del JSON como un campo de texto en la solicitud
      request.fields['ejemplar'] = jsonEncode(ejemplar);

      // Agregar imágenes a la solicitud
      for (var i = 0; i < imagenes.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagenes[]', // Este nombre debe coincidir con el backend en Laravel
            imagenes[i].path,
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("------------------------------------");
      print(response.statusCode);
      print(responseBody);
      print("------------------------------------");

      if (response.statusCode == 200) {
        print("Ejemplar guardado con éxito: $responseBody");
        return true;
      } else {
        print("Error al registrar el ejemplar: $responseBody");
        return false;
      }
    }
  }

  Future<void> enviarEjemplaresPendientes() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      // Obtener todos los ejemplares pendientes en la base de datos local
      List<Map<String, dynamic>> pendientes =
          await DatabaseHelper.instance.getEjemplaresPendientes();

      print("*******************************************");
      print("SE ESTÁ MANDANDO EL OFFLINE");
      print(pendientes);
      print("*******************************************");

      for (var ejemplar in pendientes) {
        final url = Uri.parse("$baseUrl/registroEjemplar");
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        // Recuperar las imágenes asociadas a este ejemplar
        List<Map<String, dynamic>> imagenes = await DataBaseImage.instance
            .getImagenesFindByIdEjemplar(ejemplar['id']);

        var request = http.MultipartRequest("POST", url);
        request.headers.addAll({"Authorization": "Bearer $token"});

        // Agregar los datos del ejemplar como un campo de texto en la solicitud
        request.fields['ejemplar'] = jsonEncode(ejemplar);

        // Agregar las imágenes a la solicitud
        for (var imagen in imagenes) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'imagenes[]', // Este nombre debe coincidir con el backend en Laravel
              imagen['ruta'], // Ruta de la imagen guardada en la base de datos
            ),
          );
        }

        // Enviar la solicitud
        var response = await request.send();
        var responseBody = await response.stream.bytesToString();

        print("*******************************************");
        print(response.statusCode);
        print(responseBody);
        print("*******************************************");

        if (response.statusCode == 200) {
          // Si el ejemplar se guardó correctamente en el servidor, eliminarlo de la base de datos local
          await DatabaseHelper.instance.deleteEjemplar(ejemplar['id']);

          // Eliminar las imágenes asociadas a ese ejemplar en la base de datos local
          for (var imagen in imagenes) {
            await DataBaseImage.instance.deleteImagen(imagen['id']);
          }
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> ejemplaresLocales() async {
    // Obtener los ejemplares pendientes
    final _ejemplarPendientes =
        await DatabaseHelper.instance.getEjemplaresPendientes();

    // Crear una lista para almacenar los ejemplares con imágenes
    List<Map<String, dynamic>> ejemplaresConImagenes = [];

    // Iterar sobre los ejemplares pendientes
    for (var ejemplar in _ejemplarPendientes) {
      // Asegúrate de trabajar con una copia mutable del ejemplar
      Map<String, dynamic> ejemplarMutable = Map.from(
        ejemplar,
      ); // Esto garantiza que trabajamos con una copia mutable

      // Obtener las imágenes para cada ejemplar usando el ID
      final List<Map<String, dynamic>> imagenes = await DataBaseImage.instance
          .getImagenesFindByIdEjemplar(ejemplar['id']);

      if (imagenes.isNotEmpty) {
        // Asignar las imágenes a la copia mutable
        ejemplarMutable['images'] =
            imagenes.map((img) => img['ruta'].toString()).toList();
      } else {
        ejemplarMutable['images'] = [];
      }

      // Agregar el ejemplar con imágenes a la lista
      ejemplaresConImagenes.add(ejemplarMutable);
    }

    print(
      "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++",
    );
    print(ejemplaresConImagenes);
    print(
      "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++",
    );

    // Devolver la lista de ejemplares con imágenes
    return ejemplaresConImagenes;
  }
}
