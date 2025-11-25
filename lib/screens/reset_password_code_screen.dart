import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/services/auth_services.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordCodeScreen extends StatefulWidget {
  final String email; // Recibimos el email de la pantalla anterior
  const ResetPasswordCodeScreen({super.key, required this.email});

  @override
  State<ResetPasswordCodeScreen> createState() => _ResetPasswordCodeScreenState();
}

class _ResetPasswordCodeScreenState extends State<ResetPasswordCodeScreen> {
  final _codigoController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // --- COLORES UTTEC ---
  final Color _colorPrimario = const Color(0xFF032C42);
  final Color _colorSecundario = const Color(0xFF175554);

  Future<void> _handleReset() async {
    if (_codigoController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todos los campos son obligatorios'), backgroundColor: Colors.red));
      return;
    }
    if (_passController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await _authService.resetPassword(
        email: widget.email,
        codigo: _codigoController.text.trim(),
        password: _passController.text,
        passwordConfirmation: _confirmController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Contraseña actualizada!'), backgroundColor: Colors.green));
        // Regresar hasta el Login (quitando todo el historial)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restablecer Contraseña"), backgroundColor: _colorPrimario, iconTheme: const IconThemeData(color: Colors.white), titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Código enviado a:", style: GoogleFonts.poppins(color: Colors.grey)),
            Text(widget.email, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: _colorPrimario)),
            const SizedBox(height: 20),

            // Input Código
            TextField(
              controller: _codigoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Código de 6 dígitos', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_clock)),
            ),
            const SizedBox(height: 20),

            // Input Nueva Contraseña
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nueva Contraseña', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 20),

            // Input Confirmar
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar Contraseña', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _colorSecundario, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: _isLoading ? null : _handleReset,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("CAMBIAR CONTRASEÑA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}