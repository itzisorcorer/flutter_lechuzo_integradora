// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/screens/estudiante_main_screen.dart';
import 'package:flutter_lechuzo_integradora/screens/register_screen.dart';
import 'package:flutter_lechuzo_integradora/screens/vendedor_main_screen.dart';
import 'package:flutter_lechuzo_integradora/services/auth_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lechuzo_integradora/screens/forgot_password_screen.dart';
import 'package:flutter_lechuzo_integradora/utils/custom_transitions.dart';

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

  final Color _colorPrimario = const Color(0xFF032C42);
  final Color _colorSecundario = const Color(0xFF175554);
  final Color _colorAcento = const Color(0xFF24799E);

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

      setState(() {
        Ambiente.token = response.accessToken;
        Ambiente.idUsuario = response.userId;
        Ambiente.rol = response.userRole;
        Ambiente.nombreUsuario = response.userName;
        _isLoading = false;
      });

      if (mounted) {
        // ✅ ANIMACIÓN DE ENTRADA (FadeUp)
        // Usamos FadeUp para que se sienta que "entras" a la aplicación
        if (Ambiente.rol == 'vendedor' || Ambiente.rol == 'modulo') {
          Navigator.pushReplacement(
              context,
              Transiciones.crearRutaFadeUp(const VendedorMainScreen())
          );
        } else {
          Navigator.pushReplacement(
              context,
              Transiciones.crearRutaFadeUp(const EstudianteMainScreen())
          );
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
                height: size.height * 0.45,
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
                    padding: const EdgeInsets.only(bottom: 1.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Asegúrate de tener esta imagen o un Icono de fallback
                        Image.asset(
                          'assets/logoIntegradora.png',
                          height: 250,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.storefront, size: 100, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- 2. TARJETA INFERIOR (LOGIN) ---
              Positioned(
                top: size.height * 0.40,
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
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(top: 40, left: 0, right: 0, bottom: 20 + MediaQuery.of(context).viewPadding.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bienvenido",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _colorPrimario,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Inicia sesión para continuar",
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 30),

                        _buildModernInput(
                          controller: _emailController,
                          label: "Correo Institucional",
                          icon: Icons.email_outlined,
                          isEmail: true,
                        ),
                        const SizedBox(height: 20),

                        _buildModernInput(
                          controller: _passwordController,
                          label: "Contraseña",
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),

                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // ✅ ANIMACIÓN LATERAL (Slide)
                              // Para navegar a pantallas secundarias usamos Slide
                              Navigator.push(
                                context,
                                Transiciones.crearRutaSlide(const ForgotPasswordScreen()),
                              );
                            },
                            child: Text(
                              "¿Olvidaste tu contraseña?",
                              style: TextStyle(color: _colorAcento),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: _isLoading
                              ? Center(child: CircularProgressIndicator(color: _colorPrimario))
                              : ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _colorPrimario,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "ENTRAR",
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("¿No tienes cuenta?", style: GoogleFonts.poppins(color: Colors.grey[600])),
                            TextButton(
                              onPressed: () {
                                // ✅ ANIMACIÓN LATERAL (Slide)
                                Navigator.push(
                                    context,
                                    Transiciones.crearRutaSlide(const RegisterScreen())
                                );
                              },
                              child: Text("Regístrate aquí", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _colorSecundario)),
                            ),
                          ],
                        ),
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

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isEmail = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
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
}