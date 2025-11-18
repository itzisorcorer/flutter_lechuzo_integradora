// lib/screens/vendedor_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/screens/login_screens.dart';
import 'package:flutter_lechuzo_integradora/services/auth_services.dart';
import 'package:flutter_lechuzo_integradora/services/vendedor_service.dart';

class VendedorProfileScreen extends StatefulWidget {
  const VendedorProfileScreen({super.key});

  @override
  State<VendedorProfileScreen> createState() => _VendedorProfileScreenState();
}

class _VendedorProfileScreenState extends State<VendedorProfileScreen> {
  final VendedorService _vendedorService = VendedorService();
  Map<String, dynamic>? _perfilData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final data = await _vendedorService.getPerfil();
      // Verificamos 'mounted' antes de usar setState
      if (mounted) {
        setState(() {
          _perfilData = data;
          _isLoading = false;
          Ambiente.nombreUsuario = data['nombre_tienda'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // --- CORRECCIÓN 1: EL DIÁLOGO DE EDITAR ---
  void _mostrarDialogoEditar() {
    final nombreCtrl = TextEditingController(text: _perfilData?['nombre_tienda']);
    final descCtrl = TextEditingController(text: _perfilData?['description']);

    showDialog(
      context: context, // Este es el contexto de la PANTALLA
      builder: (dialogContext) => AlertDialog( // <-- Renombramos a dialogContext
        title: const Text('Editar Tienda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre de la Tienda'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Cerramos usando el contexto del diálogo
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Cerramos el diálogo INMEDIATAMENTE
              Navigator.pop(dialogContext);

              // 2. Ponemos a cargar la PANTALLA (usando 'this.setState')
              setState(() { _isLoading = true; });

              try {
                await _vendedorService.updatePerfil(nombreCtrl.text, descCtrl.text);
                await _cargarPerfil();

                // 3. ¡MAGIA! Usamos 'mounted' y el 'context' de la PANTALLA (no el del diálogo)
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
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // --- CORRECCIÓN 2: EL LOGOUT ---
  // Quitamos el argumento (BuildContext context) porque ya tenemos acceso global a 'context'
  Future<void> _logout() async {
    final authService = AuthService();

    // Intentamos avisar al backend (no importa si falla)
    try {
      await authService.logout();
    } catch (e) {
      print("Error logout backend: $e");
    }

    // Limpiamos localmente SIEMPRE
    Ambiente.token = '';
    Ambiente.idUsuario = 0;
    Ambiente.nombreUsuario = '';
    Ambiente.rol = '';

    // Usamos 'mounted' por seguridad
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Tienda')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.store, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _perfilData?['nombre_tienda'] ?? 'Tienda',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(
                        ' ${_perfilData?['rating_promedio'] ?? "0.0"}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Align(alignment: Alignment.centerLeft, child: Text("Descripción:", style: TextStyle(fontWeight: FontWeight.bold))),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _perfilData?['description'] ?? 'Sin descripción...',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Información'),
                      onPressed: _mostrarDialogoEditar,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontSize: 18)),
            // Como _logout ya no pide argumentos, esto funciona directo:
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}