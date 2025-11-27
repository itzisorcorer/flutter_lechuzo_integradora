import 'package:flutter/material.dart';

class Transiciones {

  // Transición: Deslizar desde la derecha (Estilo iOS pero más suave)
  static Route crearRutaSlide(Widget pagina) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => pagina,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Empieza a la derecha
        const end = Offset.zero;        // Termina en el centro
        const curve = Curves.easeOutQuart; // Curva suave y elegante

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  // Transición: Aparecer desde abajo con opacidad (Ideal para Detalles de Producto)
  static Route crearRutaFadeUp(Widget pagina) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => pagina,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1); // Empieza un poquito abajo
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween = Tween(begin: 0.0, end: 1.0); // Transparente a Opaco

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}