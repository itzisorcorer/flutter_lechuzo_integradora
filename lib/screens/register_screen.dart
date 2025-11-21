// lib/screens/register_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProgramaEducativoModel.dart';
import 'package:flutter_lechuzo_integradora/screens/home_screen.dart';
import 'package:flutter_lechuzo_integradora/screens/vendedor_main_screen.dart';
import 'package:flutter_lechuzo_integradora/screens/estudiante_main_screen.dart';
import 'package:flutter_lechuzo_integradora/services/auth_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- Fuente bonita

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  // Controladores
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nombreTiendaController = TextEditingController();
  final _nombreCompletoController = TextEditingController();
  final _matriculaController = TextEditingController();

  // Variables de Estado
  String _selectedRole = 'estudiante';
  late Future<List<ProgramaEducativoModel>> _programasFuture;
  int? _selectedProgramaId;

  // Imagen (Opcional para vendedor, pero bueno tenerlo listo si decides usarlo)
  File? _imagenSeleccionada;
  // final ImagePicker _picker = ImagePicker(); // (Descomentar si vas a pedir foto de perfil)

  // --- COLORES UTTEC ---
  final Color _colorPrimario = const Color(0xFF032C42);
  final Color _colorSecundario = const Color(0xFF175554);
  final Color _colorAcento = const Color(0xFF24799E);

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
    _matriculaController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_isLoading) return;

    // Validación básica de programa educativo
    if (_selectedProgramaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un programa educativo'), backgroundColor: Colors.red),
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

      // Guardar sesión
      setState(() {
        Ambiente.token = response.accessToken;
        Ambiente.idUsuario = response.userId;
        Ambiente.rol = response.userRole;
        Ambiente.nombreUsuario = response.userName;
        _isLoading = false;
      });

      // Navegar
      if (mounted) {
        if (Ambiente.rol == 'vendedor' || Ambiente.rol == 'modulo') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VendedorMainScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EstudianteMainScreen()));
        }
      }

    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // --- 1. FONDO SUPERIOR ---
              Container(
                height: size.height * 0.35, // Un poco más corto que el login para dar espacio
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_colorPrimario, _colorSecundario],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logoIntegradora.png',
                          height: 150,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 10),
                        Text(
                          "Únete a Lechuzos",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- 2. TARJETA DE REGISTRO ---
              Positioned(
                top: size.height * 0.28,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5))],
                  ),
                  child: SingleChildScrollView( // Scroll interno para el formulario largo
                    padding: const EdgeInsets.only(top: 40, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Crea tu cuenta", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: _colorPrimario)),
                        const SizedBox(height: 20),

                        // --- SELECCIÓN DE ROL ---
                        _buildModernDropdown<String>(
                          value: _selectedRole,
                          items: const [
                            DropdownMenuItem(value: 'estudiante', child: Text('Soy Estudiante (Comprador)')),
                            DropdownMenuItem(value: 'vendedor', child: Text('Soy Vendedor (Externo)')),
                            DropdownMenuItem(value: 'modulo', child: Text('Soy Módulo (Kiosko U.)')),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() { _selectedRole = value; });
                          },
                          icon: Icons.person_outline,
                          label: "Tipo de Cuenta",
                        ),
                        const SizedBox(height: 15),

                        // --- CAMPOS COMUNES ---
                        _buildModernInput(controller: _emailController, label: "Email", icon: Icons.email_outlined, isEmail: true),
                        const SizedBox(height: 15),
                        _buildModernInput(controller: _passwordController, label: "Contraseña", icon: Icons.lock_outline, isPassword: true),
                        const SizedBox(height: 15),
                        _buildModernInput(controller: _passwordConfirmController, label: "Confirmar Contraseña", icon: Icons.lock_clock_outlined, isPassword: true),
                        const SizedBox(height: 15),

                        // --- PROGRAMA EDUCATIVO (FutureBuilder) ---
                        FutureBuilder<List<ProgramaEducativoModel>>(
                          future: _programasFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return LinearProgressIndicator(color: _colorAcento);
                            }
                            return _buildModernDropdown<int>(
                              value: _selectedProgramaId,
                              hint: "Selecciona tu Programa",
                              isExpanded: true,
                              items: snapshot.data!.map((programa) {
                                return DropdownMenuItem<int>(
                                  value: programa.id,
                                  child: Text(programa.nombre, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() { _selectedProgramaId = value; }),
                              icon: Icons.school_outlined,
                              label: "Carrera / Programa",
                            );
                          },
                        ),
                        const SizedBox(height: 15),

                        // --- MATRÍCULA ---
                        _buildModernInput(
                            controller: _matriculaController,
                            label: "Matrícula (10 dígitos)",
                            icon: Icons.badge_outlined,
                            isNumber: true
                        ),
                        const SizedBox(height: 15),

                        // --- CAMPOS CONDICIONALES ---
                        if (_selectedRole == 'vendedor' || _selectedRole == 'modulo')
                          _buildModernInput(controller: _nombreTiendaController, label: "Nombre de la Tienda", icon: Icons.store_outlined),

                        if (_selectedRole == 'estudiante')
                          _buildModernInput(controller: _nombreCompletoController, label: "Nombre Completo", icon: Icons.person),

                        const SizedBox(height: 30),

                        // --- BOTÓN REGISTRAR ---
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: _isLoading
                              ? Center(child: CircularProgressIndicator(color: _colorPrimario))
                              : ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _colorPrimario,
                              elevation: 5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text("REGISTRARME", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- VOLVER AL LOGIN ---
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("¿Ya tienes cuenta? Inicia sesión", style: GoogleFonts.poppins(color: _colorSecundario)),
                          ),
                        ),
                        const SizedBox(height: 20), // Espacio extra para el scroll
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET AYUDANTE: INPUT TEXTO ---
  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isEmail = false,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : (isNumber ? TextInputType.number : TextInputType.text),
        style: GoogleFonts.poppins(color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  // --- WIDGET AYUDANTE: DROPDOWN ---
  Widget _buildModernDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    required IconData icon,
    String? label,
    String? hint,
    bool isExpanded = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: isExpanded,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.poppins(color: Colors.grey),
          border: InputBorder.none,
        ),
        style: GoogleFonts.poppins(color: Colors.black87),
      ),
    );
  }
}