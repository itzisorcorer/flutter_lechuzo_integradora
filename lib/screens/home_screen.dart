// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';

import '../services/producto_services.dart';

// Convertimos HomeScreen a un StatefulWidget para manejar el estado de carga
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Creamos la instancia del servicio
  final ProductoService _productoService = ProductoService();

  // Usamos 'late' porque lo inicializaremos en initState()
  late Future<PaginatedProductosResponse> _productosFuture;

  @override
  void initState() {
    super.initState();
    // Llamamos a la API en cuanto la pantalla se construye
    _productosFuture = _productoService.getProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${Ambiente.nombreUsuario}'),
      ),
      body: FutureBuilder<PaginatedProductosResponse>(
        future: _productosFuture,
        builder: (context, snapshot) {

          // --- Caso 1: Cargando ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Caso 2: Error ---
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // --- Caso 3: No hay datos (o la lista está vacía) ---
          if (!snapshot.hasData || snapshot.data!.productos.isEmpty) {
            return const Center(child: Text('No hay productos disponibles.'));
          }

          // --- Caso 4: ¡Éxito! Tenemos datos ---
          final productos = snapshot.data!.productos;

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];

              // Creamos una tarjeta bonita para cada producto
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del Producto
                      Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Vendedor
                      Text(
                        'Vendido por: ${producto.vendedor.nombreTienda}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Precio
                      Text(
                        // \$.${...} -> Muestra el símbolo de pesos
                        // .toStringAsFixed(2) -> Asegura 2 decimales (ej. 25.50)
                        '\$${producto.precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
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