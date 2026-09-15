import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importe Riverpod
import 'features/auth/presentation/screens/register_screen.dart';
// import 'ui/screens/login_screen.dart'; // Décommente si besoin

void main() {
  // 2. Enveloppe runApp avec ProviderScope pour activer la gestion d'état
  runApp(const ProviderScope(child: MyApp()));
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
      // Définis le premier écran au démarrage
      home: const RegisterScreen(),
    );
  }
}
