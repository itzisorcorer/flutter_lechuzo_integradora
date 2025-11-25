// lib/screens/pedido_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Modelos/OrdenModel.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Para las fotos

class PedidoDetalleScreen extends StatelessWidget {
  final OrdenModel orden;

  const PedidoDetalleScreen({super.key, required this.orden});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completado': return Colors.green;
      case 'cancelado': return Colors.red;
      case 'en_progreso': return Colors.blue;
      case 'listo': return Colors.teal;
      default: return Colors.orange; // pendiente
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${orden.id}'),
      ),
      body: Column(
        children: [
          // --- Cabecera del Pedido ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estatus:', style: TextStyle(fontSize: 16)),
                    Chip(
                      label: Text(
                        orden.status.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: _getStatusColor(orden.status),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Vendedor:', style: TextStyle(fontSize: 16)),
                    Text(
                      orden.vendedor?.nombreTienda ?? "Desconocido",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pagado:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '\$${orden.cantidadTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // --- Lista de Productos (Items) ---
          Expanded(
            child: ListView.builder(
              itemCount: orden.itemsOrdenes.length,
              itemBuilder: (context, index) {
                final item = orden.itemsOrdenes[index];
                return ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: item.producto.urlImagen != null
                        ? CachedNetworkImage(
                      imageUrl: Ambiente.getUrlImagen(item.producto.urlImagen),
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                    )
                        : const Icon(Icons.inventory_2, color: Colors.grey),
                  ),
                  title: Text(item.producto.nombre),
                  subtitle: Text('${item.cantidad} x \$${item.precioDeCompra.toStringAsFixed(2)}'),
                  trailing: Text(
                    '\$${(item.cantidad * item.precioDeCompra).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}