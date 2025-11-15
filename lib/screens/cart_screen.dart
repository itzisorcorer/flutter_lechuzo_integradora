// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/services/cart_service.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final cart = context.watch<CartService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                // TODO: Poner un diálogo de confirmación aquí
                cart.vaciarCarrito();
              },
            )
        ],
      ),
      body:
      // Si el carrito está vacío, muestra un mensaje
      cart.items.isEmpty
          ? const Center(
        child: Text(
          'Tu carrito está vacío 🛒',
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      )
      //muestra la lista de items
          : ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                // Mostramos el precio total de este item
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text('\$${(item.producto.precio * item.cantidad).toStringAsFixed(0)}'),
                  ),
                ),
              ),
              title: Text(item.producto.nombre),
              subtitle: Text('Precio: \$${item.producto.precio.toStringAsFixed(2)}'),

              // --- Control de Cantidad ---
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.red),
                    onPressed: () {
                      cart.decrementarCantidad(item);
                    },
                  ),
                  Text(item.cantidad.toString(), style: const TextStyle(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () {
                      cart.incrementarCantidad(item);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // --- El Total y Botón de Pagar ---
      bottomNavigationBar: cart.items.isEmpty
          ? null // No mostramos nada si el carrito está vacío
          : Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- El Total ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Botón de Pagar ---
            ElevatedButton(
              onPressed: () {
                // TODO: La "chamba" de mañana: El Checkout
                print('Iniciando proceso de pago...');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Proceder al Pago', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}