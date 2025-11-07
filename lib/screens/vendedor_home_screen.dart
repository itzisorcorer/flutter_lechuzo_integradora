// lib/screens/vendedor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';

class VendedorHomeScreen extends StatelessWidget {
  const VendedorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard de ${Ambiente.nombreUsuario}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('¡Bienvenido Vendedor!'),
            Text('Tu rol es: ${Ambiente.rol}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la lógica para ver "Mis Productos"
              },
              child: const Text('Mis Productos'),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la lógica para "Ver Ventas"
              },
              child: const Text('Ver Ventas'),
            ),
          ],
        ),
      ),
    );
  }
}