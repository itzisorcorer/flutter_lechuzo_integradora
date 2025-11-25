// lib/screens/ventas_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Modelos/OrdenModel.dart';
import 'package:flutter_lechuzo_integradora/services/orden_service.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Ambiente/ambiente.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final OrdenService _ordenService = OrdenService();
  late Future<List<OrdenModel>> _ventasFuture;

  // --- PALETA VENDEDOR ---
  final Color _colOscuro = const Color(0xFF557689); // Gris Azulado
  final Color _colMedio = const Color(0xFF4C8AB9);  // Azul Acero
  final Color _colClaro = const Color(0xFFFFFFFF);  // blanco
  final Color _colFondoCard = const Color(0xFFFFFFFF); // Fondo suave de tarjeta
  final Color _colVerde = const Color(0xFF98E27F);  // Verde acción

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  void _cargarVentas() {
    setState(() {
      _ventasFuture = _ordenService.getMisVentas().then((response) => response.ordenes);
    });
  }

  // Lógica para cambiar estatus (Con spinner de carga rápido)
  Future<void> _cambiarEstatus(int ordenId, String nuevoStatus) async {
    // Mostramos un loading rápido
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _ordenService.updateOrdenStatus(ordenId, nuevoStatus);
      Navigator.pop(context); // Cierra el loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estatus actualizado'), backgroundColor: Colors.green),
      );
      _cargarVentas(); // Recarga la lista
    } catch (e) {
      Navigator.pop(context); // Cierra el loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
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
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text('Ventas Recibidas', style: GoogleFonts.poppins(color: _colOscuro, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _colOscuro),
      ),
      body: FutureBuilder<List<OrdenModel>>(
        future: _ventasFuture,
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
                  Icon(Icons.receipt_long_outlined, size: 80, color: _colClaro.withOpacity(0.5)),
                  const SizedBox(height: 10),
                  Text('No hay ventas aún', style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            );
          }

          final ventas = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ventas.length,
            itemBuilder: (context, index) {
              return _buildVentaExpandible(ventas[index]);
            },
          );
        },
      ),
    );
  }

  // --- TARJETA EXPANDIBLE (ACORDEÓN) ---
  Widget _buildVentaExpandible(OrdenModel venta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: _colFondoCard, // Azul muy clarito
      child: Theme(
        // Quitamos los bordes divisorios por defecto del ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),

          // --- CABECERA (Visible siempre) ---
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pedido #${venta.id}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _colOscuro, fontSize: 18),
              ),
              Chip(
                label: Text(venta.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                backgroundColor: _getStatusColor(venta.status),
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
                // Usamos ?. y ?? para evitar errores si el usuario fue borrado
                'Cliente: ${venta.estudiante?.nombreCompleto ?? "Desconocido"}',
                style: GoogleFonts.poppins(color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: \$${venta.cantidadTotal.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _colMedio, fontSize: 16),
              ),
            ],
          ),

          // --- DETALLES (Visible al expandir) ---
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, // Fondo blanco para resaltar los detalles
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Productos:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),

                  // LISTA DE ITEMS
                  ...venta.itemsOrdenes.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0), // Un poco más de espacio
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // Centrados verticalmente
                      children: [

                        // --- 1. LA FOTO ---
                        Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.producto.urlImagen != null
                                ? CachedNetworkImage(
                              imageUrl: Ambiente.getUrlImagen(item.producto.urlImagen),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                            )
                                : const Icon(Icons.fastfood, size: 20, color: Colors.grey),
                          ),
                        ),

                        // --- 2. NOMBRE Y CANTIDAD ---
                        Expanded(
                          child: Text(
                            "${item.cantidad}x ${item.producto.nombre}",
                            style: GoogleFonts.poppins(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // --- 3. SUBTOTAL ---
                        Text(
                          "\$${(item.cantidad * item.precioDeCompra).toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: _colOscuro),
                        ),
                      ],
                    ),
                  )).toList(),

                  const Divider(height: 24),

                  Text("Gestionar Estatus:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 15),

                  // BOTONES DE ACCIÓN
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildActionChip('En Progreso', 'en_progreso', Colors.blue, venta.id),
                      _buildActionChip('Listo', 'listo', Colors.teal, venta.id),
                      _buildActionChip('Entregado', 'completado', Colors.green, venta.id),
                      _buildActionChip('Cancelar', 'cancelado', Colors.red, venta.id),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para los chips de acción
  Widget _buildActionChip(String label, String statusValue, Color color, int ordenId) {
    return ActionChip(
      label: Text(label, style: GoogleFonts.poppins(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      backgroundColor: color.withOpacity(0.05),
      side: BorderSide(color: color.withOpacity(0.5), width: 1),
      onPressed: () => _cambiarEstatus(ordenId, statusValue),
    );
  }
}