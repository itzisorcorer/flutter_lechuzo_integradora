// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/screens/login_screens.dart';
import 'package:flutter_lechuzo_integradora/screens/mis_pedidos_screen.dart';
import 'package:flutter_lechuzo_integradora/services/auth_services.dart';
import 'package:flutter_lechuzo_integradora/services/estudiante_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final EstudianteService _estudianteService = EstudianteService();
  Map<String, dynamic>? _perfilData;
  bool _isLoading = true;

  // Foto
  File? _nuevaFoto;
  final ImagePicker _picker = ImagePicker();

  // Colores Estudiante
  final Color _colPrimario = const Color(0xFF032C42);
  final Color _colSecundario = const Color(0xFF175554);

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final data = await _estudianteService.getPerfil();
      if (mounted) {
        setState(() {
          _perfilData = data;
          _nuevaFoto = null;
          _isLoading = false;
          Ambiente.nombreUsuario = data['nombre_completo'];
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _seleccionarFoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() { _nuevaFoto = File(pickedFile.path); });
      _mostrarDialogoEditar(); // Confirmar subida
    }
  }

  void _mostrarDialogoEditar() {
    final nombreCtrl = TextEditingController(text: _perfilData?['nombre_completo']);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(dialogContext);
                _seleccionarFoto();
              },
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: _getImagenProvider(),
                child: _getImagenProvider() == null ? const Icon(Icons.add_a_photo) : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() { _isLoading = true; });
              try {
                await _estudianteService.updatePerfil(
                    nombre: nombreCtrl.text,
                    fotoNueva: _nuevaFoto
                );
                await _cargarPerfil();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado!')));
              } catch (e) {
                if (mounted) {
                  setState(() { _isLoading = false; });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getImagenProvider() {
    if (_nuevaFoto != null) return FileImage(_nuevaFoto!);
    if (_perfilData?['url_foto'] != null) return CachedNetworkImageProvider(Ambiente.urlServer + _perfilData!['url_foto']);
    return null;
  }

  Future<void> _logout() async {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Mi Perfil", style: GoogleFonts.poppins(color: _colPrimario, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.edit, color: _colPrimario), onPressed: _mostrarDialogoEditar)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[200]!, width: 4)),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFFEF8D8),
                    backgroundImage: _getImagenProvider(),
                    child: _getImagenProvider() == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: InkWell(
                    onTap: _seleccionarFoto,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: _colSecundario, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _perfilData?['nombre_completo']?.toUpperCase() ?? "ESTUDIANTE",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: _colPrimario),
            ),
            Text(
              "Matrícula: ${_perfilData?['matricula'] ?? '---'}",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Opciones
            _buildOption("MIS PEDIDOS", "Historial de compras", Icons.shopping_bag_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MisPedidosScreen()));
            }),
            const Divider(height: 40),
            _buildOption("CERRAR SESIÓN", "Salir de la cuenta", Icons.logout, _logout, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isDestructive ? Colors.red[50] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF032C42)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : Colors.black87)),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}