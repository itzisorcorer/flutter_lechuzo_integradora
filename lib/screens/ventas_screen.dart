// lib/screens/ventas_screen.dart
import 'package:flutter/material.dart';

class VentasScreen extends StatelessWidget {
  const VentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ventas'),
      ),
      body: const Center(
        child: Text(
          'Aquí irá la lista de órdenes recibidas 📈',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}