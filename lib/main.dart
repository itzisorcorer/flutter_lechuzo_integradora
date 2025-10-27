// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/screens/login_screens.dart';


void main() {
  runApp(const MyApp());
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
      home: const LoginScreen(), // Empezamos en la pantalla de login
    );
  }
}