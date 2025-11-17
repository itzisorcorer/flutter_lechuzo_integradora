// lib/screens/vendedor_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/screens/login_screens.dart';
import 'package:flutter_lechuzo_integradora/services/auth_services.dart';

class VendedorProfileScreen extends StatelessWidget {
  const VendedorProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();

    Ambiente.token = '';
    Ambiente.idUsuario = 0;
    Ambiente.nombreUsuario = '';
    Ambiente.rol = '';

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Tienda')),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.teal.withOpacity(0.1), // Color diferente para vendedor
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.store, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  Ambiente.nombreUsuario, // Nombre de la Tienda
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text('Rol: ${Ambiente.rol}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Aquí podrías poner opciones como "Editar Tienda", "Horarios", etc.

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}