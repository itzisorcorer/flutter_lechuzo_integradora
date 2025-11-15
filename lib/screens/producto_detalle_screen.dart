// lib/screens/producto_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_lechuzo_integradora/services/cart_service.dart';
import 'package:provider/provider.dart';

class ProductoDetalleScreen extends StatelessWidget {
  // 1. Recibimos el producto que el usuario tocó
  final ProductoModel producto;

  const ProductoDetalleScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Container(
              height: 300, // Una altura fija para la foto
              width: double.infinity,
              color: Colors.grey[200],
              child: producto.urlImagen != null
                  ? CachedNetworkImage(
                imageUrl: Ambiente.urlServer + producto.urlImagen!,
                fit: BoxFit.cover,
                // Un placeholder bonito mientras carga
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                // El widget de error si falla (como ahora)
                errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, size: 150, color: Colors.grey)),
              )
                  : const Center(child: Icon(Icons.inventory_2, size: 150, color: Colors.grey)),

            ),

            //Información del Producto ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    producto.nombre,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Precio
                  Text(
                    '\$${producto.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vendedor
                  Text(
                    'Vendido por: ${producto.vendedor.nombreTienda}',
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),

                  // Categoría
                  Text(
                    'Categoría: ${producto.categoria.nombre}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    producto.descripcion ?? 'Este producto no tiene descripción.',
                    style: const TextStyle(fontSize: 16, height: 1.5), // height: 1.5 = interlineado
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      //Botón Flotante de "Agregar al Carrito" ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.shopping_cart_checkout),
          label: const Text('Agregar al Carrito'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            final cart = context.read<CartService>();

            cart.agregarProducto(producto);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${producto.nombre} agregado al carrito!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );

          },
        ),
      ),
    );
  }
}