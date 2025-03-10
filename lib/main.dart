import 'package:flutter/material.dart';
import 'package:indrive_clone_flutter/src/presentation/pages/auth/login/LoginPage.dart';
import 'package:indrive_clone_flutter/src/presentation/pages/home/HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth',
      initialRoute: '/',
      routes: {'/': (context) => LoginPage(), '/home': (context) => HomePage()},
    );
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //   ),
    //   home: LoginPage(),
    // );
  }
}

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Home")),
//       body: Center(child: Text("Bienvenido!")),
//     );
//   }
// }
