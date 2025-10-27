// lib/screens/home_screen.dart
import 'package:flutter/material.dart';


import '../Ambiente/ambiente.dart'; // Ajusta la ruta

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido, ${Ambiente.nombreUsuario}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('¡Login exitoso!'),
            Text('Tu rol es: ${Ambiente.rol}'),
            Text('Tu token es: ${Ambiente.token.substring(0, 10)}...'), // Mostramos solo una parte
          ],
        ),
      ),
    );
  }
}