// lib/screens/producto_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';
import 'package:flutter_lechuzo_integradora/services/cart_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/chat_service.dart';
import '../utils/custom_transitions.dart';
import 'chat_screen.dart';

class ProductoDetalleScreen extends StatefulWidget {
  final ProductoModel producto;

  const ProductoDetalleScreen({super.key, required this.producto});

  @override
  State<ProductoDetalleScreen> createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  // estado inicial del selector
  int _cantidad = 1;

  // --- PALETA DE COLORES (Comprador) ---
  final Color _colPrimario = const Color(0xFF032C42); // Azul Oscuro
  final Color _colSecundario = const Color(0xFF175554);
  final Color _colAcento = const Color(0xFF24799E); // Azul Botón
  final Color _colFondo = const Color(0xFFFEF8D8); // Crema

  void _incrementar() {
    // Validamos que no supere el stock disponible
    if (_cantidad < widget.producto.cantidadDisponible) {
      setState(() => _cantidad++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡No hay más stock disponible!')),
      );
    }
  }

  void _decrementar() {
    if (_cantidad > 1) {
      setState(() => _cantidad--);
    }
  }

  void _agregarAlCarrito() {
    final cart = context.read<CartService>();
    // Usamos la cantidad seleccionada
    cart.agregarProducto(widget.producto, cantidadAAgregar: _cantidad);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agregaste $_cantidad ${widget.producto.nombre} al carrito'),
        backgroundColor: _colSecundario,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context); // Regresar a la tienda
  }
  Future<void> _contactarVendedor() async {
    // Mostramos loading
    showDialog(context: context, builder: (c) => const Center(child: CircularProgressIndicator()));

    try {
      final chatService = ChatService();
      // Iniciamos el chat con el vendedor de este producto
      final chatId = await chatService.iniciarChat(vendedorId: widget.producto.vendedor.id);

      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        // Navegar al chat
        Navigator.push(
            context,
            Transiciones.crearRutaSlide(
                ChatScreen(chatId: chatId, nombreOtroUsuario: widget.producto.vendedor.nombreTienda)
            )
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al contactar")));
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _colPrimario, // El fondo detrás de todo es el Azul Oscuro
      appBar: AppBar(
        backgroundColor: _colPrimario,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SizedBox(
        height: size.height,
        child: Stack(
          children: [
            // --- 1. PANEL BLANCO/CREMA INFERIOR ---
            Positioned(
              top: size.height * 0.3, // Empieza al 30% de la pantalla
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: _colFondo, // Color Crema
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 90, 24, 60), // Padding top grande para la imagen
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y Precio
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.producto.nombre,
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: _colPrimario,
                                ),
                              ),
                              Text(
                                widget.producto.categoria.nombre, // "Burger" en tu ejemplo
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${widget.producto.precio.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _colAcento, // Precio resaltado
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Vendedor (Info extra)
                    Row(
                      children: [
                        const Icon(Icons.storefront, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Vendido por: ${widget.producto.vendedor.nombreTienda}',
                          style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
                        ),
                        const Spacer(),
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        Text(
                          " 4.8", // (Hardcodeado por ahora, luego lo traemos de la BD)
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Descripción
                    Text(
                      "Descripción",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: _colPrimario),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          widget.producto.descripcion ?? "Sin descripción disponible.",
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // --- ✅ BOTÓN DE CONTACTAR (NUEVO) ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: _contactarVendedor,
                        icon: Icon(Icons.chat_bubble_outline, size: 18, color: _colPrimario),
                        label: Text("Contactar ahora", style: GoogleFonts.poppins(color: _colPrimario, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _colPrimario.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- ZONA DE ACCIÓN INFERIOR ---
                    Row(
                      children: [
                        // Selector de Cantidad (- 1 +)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, color: _colPrimario),
                                onPressed: _decrementar,
                              ),
                              Text(
                                '$_cantidad',
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: _colPrimario),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: _colPrimario),
                                onPressed: _incrementar,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Botón Agregar al Carrito
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _agregarAlCarrito,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _colSecundario, // Verde Oscuro
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 5,
                              ),
                              child: Text(
                                "Agregar al Carrito",
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. LA IMAGEN FLOTANTE (HERO) ---
            // La ponemos después del panel para que quede ENCIMA
            Positioned(
              top: size.height * 0.05, // Ajusta esto para subir/bajar la imagen
              left: 0,
              right: 0,
              height: size.height * 0.35, // 35% de la pantalla
              child: Hero(
                tag: "producto-${widget.producto.id}", // ¡Animación bonita al entrar!
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: ClipOval( // La hacemos circular para que se vea como en la referencia
                    child: widget.producto.urlImagen != null
                        ? CachedNetworkImage(
                      imageUrl: Ambiente.getUrlImagen(widget.producto.urlImagen),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Container(color: Colors.white, child: const Icon(Icons.broken_image, size: 50)),
                    )
                        : Container(color: Colors.white, child: Icon(Icons.fastfood, size: 80, color: _colAcento)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}