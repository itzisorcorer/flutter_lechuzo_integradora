// lib/screens/register_screen.dart
import 'package:flutter/material.dart';

import '../Ambiente/ambiente.dart';
import '../services/auth_services.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  // Controladores para los campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nombreTiendaController = TextEditingController();
  final _nombreCompletoController = TextEditingController();

  // Variable para el Dropdown
  String _selectedRole = 'estudiante'; // Valor por defecto

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nombreTiendaController.dispose();
    _nombreCompletoController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_isLoading) return;
    setState(() { _isLoading = true; });

    try {
      final response = await _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
        role: _selectedRole,
        nombreTienda: _nombreTiendaController.text,
        nombreCompleto: _nombreCompletoController.text,
      );

      // --- ¡ÉXITO! ---
      // Si el registro es exitoso, auto-iniciamos sesión
      Ambiente.token = response.accessToken;
      Ambiente.idUsuario = response.userId;
      Ambiente.rol = response.userRole;
      Ambiente.nombreUsuario = response.userName;

      // Navegamos a la pantalla principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

    } catch (e) {
      // --- ERROR ---
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Usamos SingleChildScrollView para evitar overflow si el teclado aparece
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Selector de Rol ---
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: const [
                  // Texto: "Lo que ve el usuario", value: "Lo que se envía a la API"
                  DropdownMenuItem(value: 'vendedor', child: Text('Soy Vendedor (Externo)')),
                  DropdownMenuItem(value: 'modulo', child: Text('Soy Módulo (Kiosco U.)')),
                  DropdownMenuItem(value: 'estudiante', child: Text('Soy Estudiante (Comprador)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Tipo de Cuenta'),
              ),
              const SizedBox(height: 16),

              // --- Campos Comunes ---
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordConfirmController,
                decoration: const InputDecoration(labelText: 'Confirmar Contraseña'),
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // --- CAMPO CONDICIONAL: VENDEDOR O MODULO ---
              if (_selectedRole == 'vendedor' || _selectedRole == 'modulo')
                TextField(
                  controller: _nombreTiendaController,
                  decoration: const InputDecoration(labelText: 'Nombre de la Tienda / Servicio'),
                ),

              // --- CAMPO CONDICIONAL: ESTUDIANTE ---
              if (_selectedRole == 'estudiante')
                TextField(
                  controller: _nombreCompletoController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo'),
                ),

              const SizedBox(height: 32),

              // --- Botón de Registro ---
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _handleRegister,
                child: const Text('Registrarme'),
              ),

              // Botón para ir a Login
              TextButton(
                onPressed: () {
                  // Cierra esta pantalla y regresa a la anterior (Login)
                  Navigator.pop(context);
                },
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              )
            ],
          ),
        ),
      ),
    );
  }
}