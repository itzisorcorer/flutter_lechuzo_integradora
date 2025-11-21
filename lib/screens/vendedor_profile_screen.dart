// lib/screens/vendedor_profile_screen.dart
import 'dart:io'; // <-- Nuevo
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/screens/login_screens.dart';
import 'package:flutter_lechuzo_integradora/services/auth_services.dart';
import 'package:flutter_lechuzo_integradora/services/vendedor_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // <-- Nuevo
import 'package:cached_network_image/cached_network_image.dart'; // <-- Nuevo

class VendedorProfileScreen extends StatefulWidget {
  const VendedorProfileScreen({super.key});

  @override
  State<VendedorProfileScreen> createState() => _VendedorProfileScreenState();
}

class _VendedorProfileScreenState extends State<VendedorProfileScreen> {
  final VendedorService _vendedorService = VendedorService();
  Map<String, dynamic>? _perfilData;
  bool _isLoading = true;

  // --- ESTADO PARA LA FOTO ---
  File? _nuevaFoto;
  final ImagePicker _picker = ImagePicker();

  // --- PALETA VENDEDOR ---
  final Color _colFondo = const Color(0xFF557689);
  final Color _colCard = Colors.white;
  final Color _colTexto = const Color(0xFF557689);
  final Color _colVerde = const Color(0xFF98E27F);

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
          // Importante: Limpiamos la foto nueva seleccionada al recargar
          _nuevaFoto = null;
          _isLoading = false;
          Ambiente.nombreUsuario = data['nombre_tienda'];
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  // --- SELECCIONAR FOTO ---
  Future<void> _seleccionarFoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _nuevaFoto = File(pickedFile.path);
      });
      // Opcional: Podrías subirla inmediatamente aquí,
      // pero mejor esperemos a que le den "Guardar" en el diálogo.
      _mostrarDialogoEditar(); // Abrimos el diálogo para que confirmen
    }
  }

  // --- DIÁLOGO PARA EDITAR ---
  void _mostrarDialogoEditar() {
    final nombreCtrl = TextEditingController(text: _perfilData?['nombre_tienda']);
    final descCtrl = TextEditingController(text: _perfilData?['description']);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Editar Perfil', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _colTexto)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview de la foto en el diálogo
              GestureDetector(
                onTap: () {
                  Navigator.pop(dialogContext); // Cerramos para abrir galería
                  _seleccionarFoto();
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _getImagenProvider(), // Helper para mostrar la foto correcta
                  child: _nuevaFoto == null && _perfilData?['url_foto'] == null
                      ? Icon(Icons.add_a_photo, color: _colTexto)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              Text("Toca para cambiar foto", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),

              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre de la Tienda', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nuevaFoto = null; // Cancelamos la foto si la hubo
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _colVerde),
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() { _isLoading = true; });

              try {
                // ¡ENVIAMOS LA FOTO!
                await _vendedorService.updatePerfil(
                    nombre: nombreCtrl.text,
                    descripcion: descCtrl.text,
                    fotoNueva: _nuevaFoto // <-- Aquí va
                );

                await _cargarPerfil();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perfil actualizado'), backgroundColor: Colors.green),
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

  // Helper para decidir qué imagen mostrar (Nueva, URL o nada)
  ImageProvider? _getImagenProvider() {
    if (_nuevaFoto != null) {
      return FileImage(_nuevaFoto!);
    }
    if (_perfilData?['url_foto'] != null) {
      // Concatenamos la URL del servidor
      return CachedNetworkImageProvider(Ambiente.urlServer + _perfilData!['url_foto']);
    }
    return null;
  }

  Future<void> _logout() async {
    // ... (Tu lógica de logout sigue igual) ...
    final authService = AuthService();
    try { await authService.logout(); } catch (e) {}
    Ambiente.token = '';
    Ambiente.idUsuario = 0;
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: _colFondo,
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

          // --- 1. CABECERA CON FOTO ---
          Center(
            child: Column(
              children: [
                // CÍRCULO DE FOTO (Con botón de editar)
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        // Usamos el mismo helper para mostrar la foto
                        backgroundImage: _getImagenProvider(),
                        child: _getImagenProvider() == null
                            ? Icon(Icons.store_rounded, size: 50, color: Color(0xFF557689))
                            : null,
                      ),
                    ),
                    // Botón de cámara pequeño
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _seleccionarFoto, // Abre galería directo
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Text(
                  _perfilData?['nombre_tienda'] ?? 'Mi Tienda',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                // ... (Rating y resto del UI sigue igual) ...
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${_perfilData?['rating_promedio'] ?? "0.0"} Rating', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- 2. TARJETA INFERIOR ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: _colCard, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // ... (Igual que antes) ...
                  const Text("INFORMACIÓN", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)), child: Icon(Icons.description_outlined, color: _colTexto)),
                    title: Text("Descripción", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text(_perfilData?['description'] ?? 'Sin descripción...', style: GoogleFonts.poppins(color: Colors.grey[600])),
                    trailing: IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: _mostrarDialogoEditar),
                  ),
                  const Divider(height: 40),
                  const Text("CUENTA", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _logout(),
                    leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.logout, color: Colors.red)),
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