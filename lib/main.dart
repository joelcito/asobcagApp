import 'package:FENCAMEL/src/data/AuthService.dart';
import 'package:FENCAMEL/src/data/EjemplarService.dart';
import 'package:FENCAMEL/src/presentation/pages/auth/login/LoginPage.dart';
import 'package:FENCAMEL/src/presentation/pages/home/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Importa la librería

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth',
      supportedLocales: [Locale('es', 'ES')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Connectivity _connectivity;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();

    // Verificar si hay conectividad al iniciar
    _checkInitialConnectivity();
  }

  // Verifica si hay conectividad al iniciar la app
  void _checkInitialConnectivity() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    if (result != ConnectivityResult.none) {
      // Si hay conexión, enviar los ejemplares pendientes
      EjemplarService().enviarEjemplaresPendientes();
    }

    // Después de verificar la conectividad, revisar el estado del login
    _checkLoginStatus();
  }

  // Verifica el estado de login
  Future<void> _checkLoginStatus() async {
    final authService = AuthService();
    final token = await authService.getValidAccessToken();

    if (token != null) {
      // Si hay un token válido, redirigir a la pantalla principal
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Si no hay token válido, redirigir a la pantalla de login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // Pantalla de carga mientras verificamos el estado
      ),
    );
  }
}
