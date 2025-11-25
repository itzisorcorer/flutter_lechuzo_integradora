// lib/screens/mis_pedidos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/OrdenModel.dart';
import 'package:flutter_lechuzo_integradora/services/orden_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MisPedidosScreen extends StatefulWidget {
  const MisPedidosScreen({super.key});

  @override
  State<MisPedidosScreen> createState() => _MisPedidosScreenState();
}

class _MisPedidosScreenState extends State<MisPedidosScreen> {
  final OrdenService _ordenService = OrdenService();
  late Future<List<OrdenModel>> _ordenesFuture;

  // --- PALETA ESTUDIANTE ---
  final Color _colFondo = const Color(0xFFFEF8D8); // Crema (Fondo Pantalla)
  final Color _colCard = Colors.white; // Blanco (Tarjetas)
  final Color _colPrimario = const Color(0xFF032C42); // Azul Oscuro (Textos)
  final Color _colSecundario = const Color(0xFF175554); // Verde Oscuro
  final Color _colAcento = const Color(0xFF24799E); // Azul Medio

  @override
  void initState() {
    super.initState();
    _ordenesFuture = _ordenService.getMisOrdenes().then((response) => response.ordenes);
  }

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
      backgroundColor: _colFondo, // Fondo Crema
      appBar: AppBar(
        title: Text('Mis Pedidos', style: GoogleFonts.poppins(color: _colPrimario, fontWeight: FontWeight.bold)),
        backgroundColor: _colFondo,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _colPrimario),
      ),
      body: FutureBuilder<List<OrdenModel>>(
        future: _ordenesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: _colAcento.withOpacity(0.5)),
                  const SizedBox(height: 10),
                  Text('No has realizado pedidos', style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            );
          }

          final ordenes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordenes.length,
            itemBuilder: (context, index) {
              return _buildOrdenAcordeon(ordenes[index]);
            },
          );
        },
      ),
    );
  }

  // --- TARJETA EXPANDIBLE (ACORDEÓN) ---
  Widget _buildOrdenAcordeon(OrdenModel orden) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white, width: 1), // Borde sutil
      ),
      color: _colCard, // Tarjeta Blanca
      child: Theme(
        // Quitamos las líneas divisorias del ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          // --- CABECERA (Siempre visible) ---
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _colAcento.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt, color: _colAcento),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pedido #${orden.id}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _colPrimario, fontSize: 16),
              ),
              Chip(
                label: Text(orden.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                backgroundColor: _getStatusColor(orden.status),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                // Aquí mostramos el VENDEDOR
                'Vendedor: ${orden.vendedor?.nombreTienda ?? "Desconocido"}',
                style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
              ),
              Text(
                'Total: \$${orden.cantidadTotal.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _colSecundario, fontSize: 15),
              ),
            ],
          ),

          // --- DETALLES (Al expandir) ---
          children: [
            const Divider(color: Colors.black12),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Productos comprados:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 10),

            // Lista de productos de la orden
            ...orden.itemsOrdenes.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  // Foto pequeña
                  Container(
                    width: 45,
                    height: 45,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item.producto.urlImagen != null
                          ? CachedNetworkImage(
                        imageUrl: Ambiente.getUrlImagen(item.producto.urlImagen),
                        fit: BoxFit.cover,
                        placeholder: (c, u) => const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (c, u, e) => const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                      )
                          : const Icon(Icons.fastfood, size: 20, color: Colors.grey),
                    ),
                  ),
                  // Nombre y Cantidad
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.producto.nombre,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: _colPrimario),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Cantidad: ${item.cantidad}",
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Precio
                  Text(
                    "\$${(item.cantidad * item.precioDeCompra).toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _colAcento),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}