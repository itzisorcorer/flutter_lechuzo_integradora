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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _ordenService.updateOrdenStatus(ordenId, nuevoStatus);
      if (mounted) Navigator.pop(context); // Cierra el loading

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estatus actualizado'), backgroundColor: Colors.green),
        );
      }
      _cargarVentas(); // Recarga la lista
    } catch (e) {
      if (mounted) Navigator.pop(context); // Cierra el loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completado': return Colors.green;
      case 'confirmado': return Colors.teal; // Ya pagado
      case 'listo': return Colors.indigo;
      case 'en_progreso': return Colors.blue;
      case 'cancelado': return Colors.red;
      default: return Colors.orange; // pendiente
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Fondo suave
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
                  Icon(Icons.receipt_long_outlined, size: 80, color: _colOscuro.withOpacity(0.3)),
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
    // Solo se puede modificar si no está terminada ni cancelada
    bool esModificable = !['completado', 'cancelado'].contains(venta.status);

    // Solo se puede trabajar si ya NO está en pendiente (es decir, si ya pagaron o confirmaron)
    bool estaPagada = venta.status != 'pendiente';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: _colFondoCard,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),

          // --- CABECERA ---
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

          // --- DETALLES ---
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Productos:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),

                  // LISTA DE ITEMS
                  ...venta.itemsOrdenes.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        // FOTO
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
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                            )
                                : const Icon(Icons.fastfood, size: 20, color: Colors.grey),
                          ),
                        ),
                        // DETALLE
                        Expanded(
                          child: Text(
                            "${item.cantidad}x ${item.producto.nombre}",
                            style: GoogleFonts.poppins(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // PRECIO
                        Text(
                          "\$${(item.cantidad * item.precioDeCompra).toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: _colOscuro),
                        ),
                      ],
                    ),
                  )),

                  const Divider(height: 24),

                  // GESTIÓN DE ESTATUS (LÓGICA SEGURA)
                  if (esModificable) ...[
                    Text("Acciones:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 15),

                    if (!estaPagada)
                    // CASO: Pendiente de Pago (Bloqueado)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Esperando confirmación de pago para iniciar preparación.",
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange[800]),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                    // CASO: Pagado (Flujo Secuencial)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // 1. Confirmado -> En Progreso
                          if (venta.status == 'confirmado')
                            _buildActionChip('Empezar a Preparar', 'en_progreso', Colors.blue, venta.id),

                          // 2. En Progreso -> Listo
                          if (venta.status == 'en_progreso')
                            _buildActionChip('¡Está Listo!', 'listo', Colors.teal, venta.id),

                          // 3. Listo -> Entregado
                          if (venta.status == 'listo')
                            _buildActionChip('Entregar al Cliente', 'completado', Colors.green, venta.id),

                          // Cancelar (Siempre disponible mientras esté viva)
                          _buildActionChip('Cancelar Pedido', 'cancelado', Colors.red, venta.id, isDestructive: true),
                        ],
                      ),
                  ] else ...[
                    // CASO: Finalizado (Banner Informativo)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: venta.status == 'completado' ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: venta.status == 'completado' ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            venta.status == 'completado' ? Icons.check_circle : Icons.cancel,
                            color: venta.status == 'completado' ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            venta.status == 'completado' ? "Pedido Entregado" : "Pedido Cancelado",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: venta.status == 'completado' ? Colors.green[800] : Colors.red[800]
                            ),
                          ),
                        ],
                      ),
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper para los chips de acción con opción destructiva
  Widget _buildActionChip(String label, String statusValue, Color color, int ordenId, {bool isDestructive = false}) {
    return ActionChip(
      avatar: isDestructive ? null : Icon(Icons.arrow_forward_rounded, size: 14, color: color),
      label: Text(label, style: GoogleFonts.poppins(color: isDestructive ? Colors.red : color, fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: isDestructive ? Colors.red[50] : color.withOpacity(0.08),
      side: BorderSide(color: isDestructive ? Colors.red.withOpacity(0.5) : color.withOpacity(0.5), width: 1),
      padding: const EdgeInsets.all(8),
      onPressed: () {
        if (isDestructive) {
          // Confirmación para cancelar
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('¿Cancelar Pedido?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: const Text('Esta acción no se puede deshacer y se notificará al cliente.'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Volver', style: TextStyle(color: Colors.grey))),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _cambiarEstatus(ordenId, statusValue);
                  },
                  child: const Text('Sí, Cancelar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        } else {
          // Acción normal
          _cambiarEstatus(ordenId, statusValue);
        }
      },
    );
  }
}