// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/screens/login_screens.dart';
import 'package:flutter_lechuzo_integradora/services/cart_service.dart'; // <-- 1. Importa
import 'package:provider/provider.dart'; // <-- 2. Importa

void main() {
  runApp(
    // 3. "Envolvemos" la app con el proveedor
    ChangeNotifierProvider(
      create: (context) => CartService(), // Crea una instancia de nuestro servicio
      child: const MyApp(), // Tu app
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lechuzo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}