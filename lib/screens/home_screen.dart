// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';

import 'package:flutter_lechuzo_integradora/services/producto_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductoService _productoService = ProductoService();

  // --- CORRECCIÓN 2: Faltaba declarar el controlador del buscador ---
  final TextEditingController _searchController = TextEditingController();

  List<ProductoModel> _allProducts = [];
  List<ProductoModel> _filteredProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  // --- CORRECCIÓN 3: La variable '_productosFuture' ya no se necesita ---
  // (La borramos, porque ahora usamos _isLoading)

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }


  @override
  void dispose(){
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await _productoService.getProductos();
      setState(() {
        _allProducts = response.productos;
        _filteredProducts = response.productos;
        _isLoading = false;
      });
    } catch(e) {
      setState(() {

        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((producto) {
        final nombreLower = producto.nombre.toLowerCase();
        final vendedorLower = producto.vendedor.nombreTienda.toLowerCase();
        return nombreLower.contains(query) || vendedorLower.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${Ambiente.nombreUsuario}'),
      ),
      body: Column(
        children: [
          Padding(

            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(

                labelText: 'Buscar producto o vendedor...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
    );
  }


  Widget _buildProductList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(
          'Error al cargar: $_errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (_filteredProducts.isEmpty) {
      return const Center(child: Text('No se encontraron productos'));
    }

    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final producto = _filteredProducts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vendido por: ${producto.vendedor.nombreTienda}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
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
  }
}