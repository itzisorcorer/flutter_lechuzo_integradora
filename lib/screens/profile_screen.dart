// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/screens/login_screens.dart';
import 'package:flutter_lechuzo_integradora/screens/mis_pedidos_screen.dart';
import 'package:flutter_lechuzo_integradora/services/auth_services.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    try {
      await authService.logout();
    } catch (e) {
      print("Error logout backend: $e");
    }
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
    // --- COLORES ---
    final Color _colPrimario = const Color(0xFF032C42);
    final Color _colSecundario = const Color(0xFF175554);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Mi Perfil", style: GoogleFonts.poppins(color: _colPrimario, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // --- 1. FOTO DE PERFIL Y EDITAR ---
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[200]!, width: 4), // Borde grisecito
                  ),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFFFEF8D8), // Fondo crema si no hay foto
                    child: Icon(Icons.person, size: 60, color: Colors.grey),
                    // backgroundImage: NetworkImage('...'), // Aquí iría la foto real
                  ),
                ),
                // Botoncito de lápiz
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _colSecundario,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- 2. NOMBRE ---
            Text(
              Ambiente.nombreUsuario.toUpperCase(),
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: _colPrimario),
            ),
            Text(
              "Estudiante",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey, letterSpacing: 1.5),
            ),

            const SizedBox(height: 40),

            // --- 3. LISTA DE OPCIONES ---
            _buildProfileOption(
              context,
              title: "MIS PEDIDOS",
              subtitle: "Historial de compras",
              icon: Icons.shopping_bag_outlined,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MisPedidosScreen()));
              },
            ),

            _buildProfileOption(
              context,
              title: "CONFIGURACIÓN",
              subtitle: "Notificaciones, Privacidad",
              icon: Icons.settings_outlined,
              onTap: () {},
            ),

            const Divider(height: 40), // Separador

            _buildProfileOption(
              context,
              title: "CERRAR SESIÓN",
              subtitle: "Salir de la cuenta",
              icon: Icons.logout,
              isDestructive: true, // Para que salga rojo
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET AYUDANTE ---
  Widget _buildProfileOption(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            // Icono con fondo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : const Color(0xFF032C42),
              ),
            ),
            const SizedBox(width: 16),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Flechita
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}