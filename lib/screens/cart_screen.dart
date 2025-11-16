// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/services/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart'; // <-- ¡Este es el que importa!

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  // --- FUNCIÓN DE CHECKOUT (Esta estaba bien) ---
  Future<void> _handleCheckout(BuildContext context) async {
    final cart = context.read<CartService>();
    if (cart.isLoading) return; // Evitar doble-tap

    try {
      // 1. Llamamos a checkout(), que devuelve el link (init_point)
      final String paymentUrl = await cart.checkout();

      // 2. Si todo sale bien, ¡lanzamos la Custom Tab!
      if (context.mounted) {
        _launchMPCheckout(context, paymentUrl);
      }

    } catch (e) {
      // 3. Error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Future<void> _launchMPCheckout(BuildContext context, String url) async {
    try {
      // 1. La función se llama 'launch' (no 'launchUrl')
      await launch(
        url, // 2. Se pasa el String directamente (no Uri.parse(url))
        customTabsOption: CustomTabsOption(
          toolbarColor: Theme.of(context).primaryColor,
          showPageTitle: true,

        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: No se pudo abrir el navegador de pago. $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- (Función para el diálogo de vaciar carrito, está perfecta) ---
  void _showVaciarCarritoDialog(BuildContext context, CartService cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de que quieres vaciar tu carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              cart.vaciarCarrito();
              Navigator.of(ctx).pop();
            },
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }


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
                _showVaciarCarritoDialog(context, cart);
              },
            )
        ],
      ),
      // --- (El resto de tu UI (body y bottomNavigationBar) está perfecta) ---
      body:
      cart.items.isEmpty
          ? const Center(
        child: Text(
          'Tu carrito está vacío 🛒',
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text('\$${(item.producto.precio * item.cantidad).toStringAsFixed(0)}'),
                  ),
                ),
              ),
              title: Text(item.producto.nombre),
              subtitle: Text('Precio: \$${item.producto.precio.toStringAsFixed(2)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.red),
                    onPressed: () => cart.decrementarCantidad(item),
                  ),
                  Text(item.cantidad.toString(), style: const TextStyle(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () => cart.incrementarCantidad(item),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                  '\$${cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),

            cart.isLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: CircularProgressIndicator(),
              ),
            )
                : ElevatedButton(
              onPressed: () {
                _handleCheckout(context);
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