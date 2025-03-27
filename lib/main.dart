import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:indrive_clone_flutter/src/data/AuthService.dart';
import 'package:indrive_clone_flutter/src/presentation/pages/auth/login/LoginPage.dart';
import 'package:indrive_clone_flutter/src/presentation/pages/home/HomePage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth',
      supportedLocales: [
        Locale('es', 'ES'), // Español
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // Para iOS
      ],
      initialRoute: '/',
      // routes: {'/': (context) => LoginPage(), '/home': (context) => HomePage()},
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
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

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
