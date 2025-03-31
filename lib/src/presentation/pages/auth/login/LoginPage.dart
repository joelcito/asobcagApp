import 'package:flutter/material.dart';
import 'package:indrive_clone_flutter/src/data/AuthService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  final _caragado = false;

  void _login() async {
    final email = emailController.text;
    final password = passwordController.text;

    print(email);
    print(password);

    final success = await authService.login(email, password);
    if (success) {
      // if (false) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login fallido. Verifica tus credenciales no seas tonto",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 134, 101, 10),
              Color(0xFFeef2f3),
            ], // Fondo degradado
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar del usuario
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                "assets/logo_2.png",
              ), // Asegúrate de tener esta imagen
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 30),

            // Campo de usuario
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.grey),
                  hintText: "Usuario",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Campo de contraseña
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.grey),
                  hintText: "Contrasenia",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Botón de inicio de sesión
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(
                  255,
                  122,
                  110,
                  42,
                ), // Color del botón
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Ingresar",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(title: Text("Login che")),
    //   body: Padding(
    //     padding: EdgeInsets.all(16.0),
    //     child: Column(
    //       children: [
    //         TextField(
    //           controller: emailController,
    //           decoration: InputDecoration(labelText: "Correo"),
    //         ),
    //         TextField(
    //           controller: passwordController,
    //           obscureText: true,
    //           decoration: InputDecoration(labelText: "Contraseña"),
    //         ),
    //         SizedBox(height: 20),
    //         ElevatedButton(onPressed: _login, child: Text("Iniciar Sesión")),
    //       ],
    //     ),
    //   ),
    // );
  }
}
