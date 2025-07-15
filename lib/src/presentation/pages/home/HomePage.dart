import 'package:FENCAMEL/src/data/AuthService.dart';
import 'package:FENCAMEL/src/data/EjemplarService.dart';
import 'package:FENCAMEL/src/presentation/pages/llama/AlpacaPage.dart';
import 'package:FENCAMEL/src/presentation/pages/llama/LlamaOffLinePage.dart';
import 'package:FENCAMEL/src/presentation/pages/llama/LlamaPage.dart';
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
  String nombreRol = "Invitado"; // Valor por defecto
  final AuthService authService = AuthService();
  int _selectedIndex = 0; // Controla la vista actual

  // Lista de vistas disponibles
  final List<Widget> _pages = [
    Center(child: Text("🏠 Inicio", style: TextStyle(fontSize: 24))),
    // Center(child: Text("👤 Llama", style: TextStyle(fontSize: 24))),
    LlamaPage(),
    // Center(child: Text("⚙ Alpaca", style: TextStyle(fontSize: 24))),
    AlpacaPage(),
    LlamaOffLinePage(),
  ];

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
    EjemplarService().enviarEjemplaresPendientes();
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    final usuarioString = prefs.getString('usuario');
    final rolString = prefs.getString('rol');

    if (usuarioString != null && rolString != null) {
      final usuario = jsonDecode(usuarioString);
      final rol = jsonDecode(rolString);
      setState(() {
        nombreUsuario =
            usuario['email']; // Puedes cambiar esto por nombres si existe
        nombreRol = rol['nombre'];
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cambia solo el contenido
      Navigator.pop(context); // Cierra el Drawer después de seleccionar
    });
  }

  void _logout() async {
    final success = await authService.logout();
    if (success) {
      // if (false) {
      Navigator.pushReplacementNamed(context, "/");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Se cerro sesion con exito!.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hubo un error al cerrar sesión, intenta nuevamente."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FENCAMEL",
          style: TextStyle(
            color: Color(0xFF7A6E2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(nombreUsuario),
              accountEmail: Text("Rol: $nombreRol"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/logo_2.png"),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 122, 110, 42),
              ),
            ),
            ListTile(
              leading: Icon(Icons.house),
              title: Text("Inicio"),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.bedroom_baby),
              title: Text("Llamas en linea"),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.bedroom_baby),
              title: Text("Alpaca en linea"),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: Icon(Icons.bedroom_baby),
              title: Text("Ejemplares fuera de linea"),
              onTap: () => _onItemTapped(3),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }
}
