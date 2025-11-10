// lib/screens/vendedor_profile_screen.dart
import 'package:flutter/material.dart';

class VendedorProfileScreen extends StatelessWidget {
  const VendedorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Tienda'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Aquí podrás editar tu tienda y ver calificaciones 🏪',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Lógica de Logout
              },
              child: const Text('Cerrar Sesión'),
            )
          ],
        ),
      ),
    );
  }
}