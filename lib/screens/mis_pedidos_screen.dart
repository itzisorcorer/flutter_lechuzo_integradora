// lib/screens/mis_pedidos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Modelos/OrdenModel.dart';
import 'package:flutter_lechuzo_integradora/services/orden_service.dart';
import 'package:flutter_lechuzo_integradora/screens/pedido_detalle_screen.dart';

class MisPedidosScreen extends StatefulWidget {
  const MisPedidosScreen({super.key});

  @override
  State<MisPedidosScreen> createState() => _MisPedidosScreenState();
}

class _MisPedidosScreenState extends State<MisPedidosScreen> {
  final OrdenService _ordenService = OrdenService();
  late Future<List<OrdenModel>> _ordenesFuture;

  @override
  void initState() {
    super.initState();
    // Llamamos a la API al iniciar la pantalla
    // Usamos .then() para extraer solo la lista de órdenes de la paginación
    _ordenesFuture = _ordenService.getMisOrdenes().then((response) => response.ordenes);
  }

  // Función para dar color al estatus
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'en_progreso':
        return Colors.blue;
      case 'listo':
        return Colors.teal;
      case 'pendiente': // ¡El que veremos ahora!
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
      ),
      body: FutureBuilder<List<OrdenModel>>(
        future: _ordenesFuture,
        builder: (context, snapshot) {

          // --- Caso 1: Cargando ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Caso 2: Error ---
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar: ${snapshot.error.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // --- Caso 3: No hay datos ---
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No has realizado ningún pedido todavía.'));
          }

          // --- Caso 4: ¡Éxito! Tenemos datos ---
          final ordenes = snapshot.data!;

          return ListView.builder(
            itemCount: ordenes.length,
            itemBuilder: (context, index) {
              final orden = ordenes[index];

              // (Aquí podrías hacer la tarjeta "tocable" para ir al detalle)
            return InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PedidoDetalleScreen(orden: orden),
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
                    // Encabezado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pedido #${orden.id}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        // ¡El Chip de Estatus!
                        Chip(
                          label: Text(
                            orden.status,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: _getStatusColor(orden.status),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Vendedor
                    Text(
                      'Vendido por: ${orden.vendedor.nombreTienda}',
                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),

                    // Total
                    Text(
                      'Total: \$${orden.cantidadTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
}