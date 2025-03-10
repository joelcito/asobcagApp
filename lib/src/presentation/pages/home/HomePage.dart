import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String nombreUsuario = "Usuario"; // Valor por defecto

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioString = prefs.getString('usuario');
    if (usuarioString != null) {
      final usuario = jsonDecode(usuarioString);
      setState(() {
        nombreUsuario =
            usuario['email']; // Puedes cambiar esto por nombres si existe
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(child: Text("Bienvenido, $nombreUsuario!")),
    );
  }
}
