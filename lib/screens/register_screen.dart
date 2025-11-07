// lib/screens/register_screen.dart
import 'package:flutter/material.dart';

import '../Ambiente/ambiente.dart';
import '../services/auth_services.dart';
import 'home_screen.dart';

import 'package:flutter_lechuzo_integradora/Modelos/ProgramaEducativoModel.dart';
import 'package:flutter_lechuzo_integradora/screens/vendedor_home_screen.dart';


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
  final _matriculaController = TextEditingController();

  // Variable para el Dropdown
  String _selectedRole = 'estudiante'; // Valor por defecto
  late Future<List<ProgramaEducativoModel>> _programasFuture;
  int? _selectedProgramaId; // aki se guarda el id del programa

  @override
  void initState() {
    super.initState();
    _programasFuture = _authService.getProgramas();
  }


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

    //validar un programa seleccionado
    if(_selectedProgramaId == null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor seleccione un programa educativo'), backgroundColor: Colors.red),
      );
      return;

    }
    setState(() { _isLoading = true; });

    try {
      final response = await _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
        role: _selectedRole,
        nombreTienda: _nombreTiendaController.text,
        nombreCompleto: _nombreCompletoController.text,
        matricula: _matriculaController.text,
        programaEducativoId: _selectedProgramaId!,
      );

      // --- ¡ÉXITO! ---
      // Si el registro es exitoso, auto-iniciamos sesión
      Ambiente.token = response.accessToken;
      Ambiente.idUsuario = response.userId;
      Ambiente.rol = response.userRole;
      Ambiente.nombreUsuario = response.userName;

      // Navegamos a la pantalla principal
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

              //dropdown de los programas educativos
              FutureBuilder<List<ProgramaEducativoModel>>(
                  future: _programasFuture,
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator());
                    }
                    if(snapshot.hasError || !snapshot.hasData){
                      return const Text('Error al cargar los programas', style: TextStyle(color: Colors.red));
                    }
                    return DropdownButtonFormField<int>(
                        value: _selectedProgramaId,
                        hint: const Text('Selecciona tu programa educativo'),
                        isExpanded: true,
                        items: snapshot.data!.map((programa){
                          return DropdownMenuItem<int>(
                              value: programa.id,
                              child: Text(programa.nombre),
                          );
                        }).toList(),
                        onChanged: (value){
                          setState((){_selectedProgramaId = value; });
                        },
                    );
                  },
              ),
              const SizedBox(height: 16),


              //TextField de la matricula
              TextField(
                controller: _matriculaController,
                decoration: const InputDecoration(labelText: 'Matrícula (10 dígitos)'),
                keyboardType: TextInputType.number,
                maxLength: 10,
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