// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/screens/reset_password_code_screen.dart';
import 'package:flutter_lechuzo_integradora/services/auth_services.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService(); // (Añadiremos la función aquí después)
  bool _isLoading = false;

  // --- COLORES UTTEC (Misma paleta) ---
  final Color _colorPrimario = const Color(0xFF032C42);
  final Color _colorSecundario = const Color(0xFF175554);
  final Color _colorAcento = const Color(0xFF24799E);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu correo'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // TODO: Implementar esta función en AuthService y Laravel
      await _authService.sendPasswordResetLink(_emailController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Enlace enviado! Revisa tu correo.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordCodeScreen(email: _emailController.text),
        ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      // Usamos Stack para el fondo degradado
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
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_reset, size: 80, color: Colors.white),
                        const SizedBox(height: 10),
                        Text(
                          "Recuperar Cuenta",
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

              // --- 2. TARJETA FLOTANTE ---
              Positioned(
                top: size.height * 0.35,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "¿Olvidaste tu contraseña?",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _colorPrimario,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Ingresa tu correo institucional y te enviaremos un enlace para restablecerla.",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 30),

                      // --- INPUT EMAIL ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.poppins(color: Colors.black87),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                            labelText: "Correo Institucional",
                            labelStyle: GoogleFonts.poppins(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- BOTÓN ENVIAR ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: _isLoading
                            ? Center(child: CircularProgressIndicator(color: _colorPrimario))
                            : ElevatedButton(
                          onPressed: _handleSendResetLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _colorPrimario,
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text(
                            "ENVIAR ENLACE",
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 3. BOTÓN VOLVER (Parte Inferior) ---
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: _colorSecundario),
                    label: Text(
                      "Volver al inicio de sesión",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _colorSecundario),
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
}