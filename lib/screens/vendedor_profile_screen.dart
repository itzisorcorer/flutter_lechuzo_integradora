// lib/screens/vendedor_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/screens/login_screens.dart';
import 'package:flutter_lechuzo_integradora/services/auth_services.dart';
import 'package:flutter_lechuzo_integradora/services/vendedor_service.dart';
import 'package:google_fonts/google_fonts.dart';

class VendedorProfileScreen extends StatefulWidget {
  const VendedorProfileScreen({super.key});

  @override
  State<VendedorProfileScreen> createState() => _VendedorProfileScreenState();
}

class _VendedorProfileScreenState extends State<VendedorProfileScreen> {
  final VendedorService _vendedorService = VendedorService();
  Map<String, dynamic>? _perfilData;
  bool _isLoading = true;

  // --- PALETA VENDEDOR ---
  final Color _colFondo = const Color(0xFF557689); // Tu Azul Grisáceo (Fondo)
  final Color _colCard = Colors.white; // Tarjetas
  final Color _colTexto = const Color(0xFF557689);
  final Color _colVerde = const Color(0xFF98E27F); // Acento

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final data = await _vendedorService.getPerfil();
      if (mounted) {
        setState(() {
          _perfilData = data;
          _isLoading = false;
          // Actualizamos el nombre global para que se vea en otras pantallas
          Ambiente.nombreUsuario = data['nombre_tienda'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // --- DIÁLOGO PARA EDITAR TIENDA ---
  void _mostrarDialogoEditar() {
    final nombreCtrl = TextEditingController(text: _perfilData?['nombre_tienda']);
    final descCtrl = TextEditingController(text: _perfilData?['description']);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Editar Tienda', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _colTexto)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre de la Tienda', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Nombre y descripción', border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _colVerde),
            onPressed: () async {
              Navigator.pop(dialogContext); // Cerrar diálogo
              setState(() { _isLoading = true; }); // Spinner en pantalla

              try {
                await _vendedorService.updatePerfil(nombreCtrl.text, descCtrl.text);
                await _cargarPerfil(); // Recargar datos nuevos
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tienda actualizada correctamente'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() { _isLoading = false; });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- LOGOUT ---
  Future<void> _logout() async {
    final authService = AuthService();
    try {
      await authService.logout();
    } catch (e) {
      print("Error logout: $e");
    }
    Ambiente.token = '';
    Ambiente.idUsuario = 0;
    Ambiente.nombreUsuario = '';
    Ambiente.rol = '';

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: _colFondo, // Fondo Azul Vendedor
      appBar: AppBar(
        title: Text('Mi Perfil', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _colFondo,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // --- 1. CABECERA (Icono y Nombre) ---
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.store_rounded, size: 50, color: Color(0xFF557689)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _perfilData?['nombre_tienda'] ?? 'Mi Tienda',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${_perfilData?['rating_promedio'] ?? "0.0"} Rating',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- 2. TARJETA BLANCA INFERIOR ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _colCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text("INFORMACIÓN", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 10),

                  // Descripción
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.description_outlined, color: _colTexto),
                    ),
                    title: Text("Descripción", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      _perfilData?['description'] ?? 'Sin descripción...',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: _mostrarDialogoEditar, // Abre el diálogo
                    ),
                  ),

                  const Divider(height: 40),

                  const Text("CUENTA", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 10),

                  // Logout
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _logout(), // Cierra sesión
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.logout, color: Colors.red),
                    ),
                    title: Text("Cerrar Sesión", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.red)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}