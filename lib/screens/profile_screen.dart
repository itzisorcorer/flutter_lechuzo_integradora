// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/screens/mis_pedidos_screen.dart';
import '../services/auth_services.dart';
import 'login_screens.dart'; // <-- Importamos la pantalla de pedidos

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Función simple para cerrar sesión (Localmente por ahora)
  Future<void> _logout(BuildContext context)async {
    final authService = AuthService();
    await authService.logout();

    //limpiamos los datos del ambiente
    Ambiente.token = '';
    Ambiente.idUsuario = 0;
    Ambiente.nombreUsuario = '';
    Ambiente.rol = '';

    if(context.mounted){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: ListView(
        children: [
          //Cabecera del Usuario
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.blue.withOpacity(0.1),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  Ambiente.nombreUsuario,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rol: ${Ambiente.rol}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          //Menú de Opciones

          // Opción: Mis Pedidos
          ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.blue),
            title: const Text('Mis Pedidos'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // ¡Aquí es donde navegamos a la pantalla que ya hicimos!
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MisPedidosScreen()),
              );
            },
          ),

          const Divider(), // Una línea divisora

          // Opción: Configuración (Ejemplo)
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Configuración'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Pantalla de configuración
            },
          ),

          const Divider(),

          // Opción: Cerrar Sesión
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}