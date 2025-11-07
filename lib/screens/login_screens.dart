// lib/screens/login_screen.dart

import 'package:flutter/material.dart';


import '../Ambiente/ambiente.dart';
import '../services/auth_services.dart';
import 'home_screen.dart';

import 'package:flutter_lechuzo_integradora/screens/register_screen.dart';
import 'package:flutter_lechuzo_integradora/screens/vendedor_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_isLoading) return;

    setState(() { _isLoading = true; });

    try {
      final response = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      // --- ¡ÉXITO! ---
      // Guardamos los datos globalmente en tu clase Ambiente
      Ambiente.token = response.accessToken;
      Ambiente.idUsuario = response.userId;
      Ambiente.rol = response.userRole;
      Ambiente.nombreUsuario = response.userName;

      // Revisamos el rol que guardamos en Ambiente
      if (Ambiente.rol == 'vendedor' || Ambiente.rol == 'modulo') {
        // Es un vendedor, vamos a su dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VendedorHomeScreen()),
        );
      } else {
        // Es un estudiante (o admin), vamos al catálogo de productos
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }

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
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Entrar'),
            ),
            TextButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('¿No tienes cuenta? Registrate'),
            )
          ],
        ),
      ),
    );
  }
}