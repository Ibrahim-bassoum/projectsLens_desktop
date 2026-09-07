import 'package:flutter/material.dart';
import 'package:projectlens_desktop/ui/screens/register_screen.dart';
import 'ui/screens/login_screen.dart'; // Importe ton écran de connexion

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProjectLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      // Définis le LoginScreen comme premier écran au démarrage
      home: const RegisterScreen(),
    );
  }
}
