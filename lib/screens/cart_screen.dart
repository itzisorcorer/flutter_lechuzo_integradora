// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/services/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // --- COLORES (Paleta Estudiante Premium) ---
  final Color _colFondo = const Color(0xFFFEF8D8); // Crema
  final Color _colPrimario = const Color(0xFF032C42); // Azul Oscuro (Textos)
  final Color _colSecundario = const Color(0xFF175554); // Verde Oscuro (Botones)
  final Color _colAcento = const Color(0xFF24799E); // Azul Medio

  // --- LÓGICA DE CHECKOUT ---
  Future<void> _handleCheckout(BuildContext context) async {
    final cart = context.read<CartService>();
    if (cart.isLoading) return;

    try {
      final String paymentUrl = await cart.checkout();
      if (context.mounted) {
        _launchMPCheckout(context, paymentUrl);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _launchMPCheckout(BuildContext context, String url) async {
    try {
      await launch(
        url,
        customTabsOption: CustomTabsOption(
          toolbarColor: Theme.of(context).primaryColor,
          showPageTitle: true,

          enableUrlBarHiding: true,

          animation: CustomTabsSystemAnimation.slideIn(),

          enableDefaultShare: false,
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

  void _showVaciarCarritoDialog(BuildContext context, CartService cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Vaciar Carrito', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text('¿Estás seguro de que quieres eliminar todos los productos?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () { cart.vaciarCarrito(); Navigator.pop(ctx); },
            child: const Text('Vaciar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();

    return Scaffold(
      backgroundColor: _colFondo, // ¡Fondo Crema!
      appBar: AppBar(
        backgroundColor: _colFondo,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Mi Carrito',
          style: GoogleFonts.poppins(color: _colPrimario, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: () => _showVaciarCarritoDialog(context, cart),
            )
        ],
      ),

      body: Column(
        children: [
          // --- LISTA DE ITEMS ---
          Expanded(
            child: cart.items.isEmpty
                ? _buildEmptyCart()
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                return _buildCartItem(cart, index);
              },
            ),
          ),

          // --- PANEL INFERIOR (TOTAL + BOTÓN) ---
          if (cart.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fila de Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
                      Text(
                        '\$${cart.total.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: _colPrimario),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botón de Checkout
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: cart.isLoading
                        ? Center(child: CircularProgressIndicator(color: _colPrimario))
                        : ElevatedButton(
                      onPressed: () => _handleCheckout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colSecundario, // Verde Oscuro
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        'Pagar Ahora',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGET: TARJETA DE PRODUCTO (DISEÑO PREMIUM) ---
  Widget _buildCartItem(CartService cart, int index) {
    final item = cart.items[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          // 1. Imagen
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: item.producto.urlImagen != null
                  ? CachedNetworkImage(
                imageUrl: Ambiente.urlServer + item.producto.urlImagen!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
              )
                  : const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 15),

          // 2. Info (Nombre y Precio)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.producto.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: _colPrimario),
                ),
                Text(
                  item.producto.vendedor.nombreTienda,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  '\$${item.producto.precio.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: _colAcento),
                ),
              ],
            ),
          ),

          // 3. Controles de Cantidad (+ 1 -)
          Column(
            children: [
              _buildQtyButton(
                icon: Icons.add,
                color: _colSecundario,
                onTap: () => cart.incrementarCantidad(item),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '${item.cantidad}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              _buildQtyButton(
                icon: Icons.remove,
                color: Colors.grey, // Gris para restar
                onTap: () => cart.decrementarCantidad(item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Botoncito redondo pequeño para la cantidad
  Widget _buildQtyButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1), // Fondo suave del color
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: _colAcento.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            'Tu carrito está vacío',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: _colPrimario),
          ),
          const SizedBox(height: 10),
          Text(
            '¡Ve a la tienda y antoja algo!',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}