// lib/screens/ventas_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Modelos/OrdenModel.dart';
import 'package:flutter_lechuzo_integradora/services/orden_service.dart';
import 'package:flutter_lechuzo_integradora/screens/pedido_detalle_screen.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final OrdenService _ordenService = OrdenService();
  late Future<List<OrdenModel>> _ventasFuture;

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  void _cargarVentas() {
    // ¡El setState es lo que hace que la pantalla parpadee y se actualice!
    setState(() {
      _ventasFuture = _ordenService.getMisVentas().then((response) => response.ordenes);
    });
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
      appBar: AppBar(
        title: const Text('Mis Ventas Recibidas'),
      ),
      body: FutureBuilder<List<OrdenModel>>(
        future: _ventasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes ventas todavía.'));
          }

          final ventas = snapshot.data!;

          return ListView.builder(
            itemCount: ventas.length,
            itemBuilder: (context, index) {
              final venta = ventas[index];

              return InkWell(
                onTap: () {
                  // Reutilizamos la pantalla de detalle para ver qué compraron
                  // (Opcional: Podrías crear una específica para editar el estatus)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PedidoDetalleScreen(orden: venta),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pedido #${venta.id}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    venta.status.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  backgroundColor: _getStatusColor(venta.status),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (String nuevoStatus){
                                    _cambiarStatus(venta.id, nuevoStatus);
                                  },
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                    const PopupMenuItem(value: 'en_progreso', child: Text('Marcar: En Progreso')),
                                    const PopupMenuItem(value: 'listo', child: Text('Marcar: Listo para Recoger')),
                                    const PopupMenuItem(value: 'completado', child: Text('Marcar: Entregado/Completado')),
                                    const PopupMenuItem(value: 'cancelado', child: Text('Cancelar Pedido ')),

                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Aquí mostramos QUIÉN compró
                        Text(
                          // Usamos ?. porque estudiante podría ser nulo si se borró
                          'Cliente: ${venta.estudiante?.nombreCompleto ?? "Desconocido"}',
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Items: ${venta.itemsOrdenes.length}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Total: \$${venta.cantidadTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  //Funciones Future
Future<void> _cambiarStatus (int ordenId, String nuevoStatus)async{
  try{
    await _ordenService.updateOrdenStatus(ordenId, nuevoStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Orden #$ordenId actualizado a: "$nuevoStatus"'),
        backgroundColor: Colors.green,
      ),
    );
    _cargarVentas();
    }catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }
}