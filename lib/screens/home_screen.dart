// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';
import 'package:flutter_lechuzo_integradora/services/producto_services.dart';
import 'package:flutter_lechuzo_integradora/screens/producto_detalle_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_lechuzo_integradora/utils/custom_transitions.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductoService _productoService = ProductoService();
  final TextEditingController _searchController = TextEditingController();

  // --- ESTADO ---
  List<ProductoModel> _allProducts = [];
  List<ProductoModel> _filteredProducts = [];
  List<CategoriaModel> _categorias = [];

  bool _isLoading = true;
  String? _errorMessage;

  // Filtro actual
  int? _selectedCategoriaId;

  // --- COLORES ---
  final Color _colFondo = const Color(0xFFFEF8D8);
  final Color _colPrimario = const Color(0xFF032C42);
  final Color _colAcento = const Color(0xFF24799E);
  final Color _colCard = Colors.white;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose(){
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  // ✅ MODIFICADO: Lógica de carga inteligente
  Future<void> _cargarDatosIniciales() async {
    // Si la lista está vacía (primera vez), mostramos el loading grande.
    // Si ya tiene datos (es un refresh), NO mostramos el loading grande para que no parpadee.
    if (_allProducts.isEmpty) {
      setState(() { _isLoading = true; });
    }

    // Limpiamos errores previos al recargar
    if (mounted) setState(() { _errorMessage = null; });

    try {
      final results = await Future.wait([
        _productoService.getProductos(),
        _productoService.getCategorias(),
      ]);

      final productosResp = results[0] as PaginatedProductosResponse;
      final categoriasResp = results[1] as List<CategoriaModel>;

      if (mounted) {
        setState(() {
          _allProducts = productosResp.productos;
          _filteredProducts = productosResp.productos;
          _categorias = categoriasResp;
          _isLoading = false;
        });
        _filterProducts(); // Re-aplicar filtros si había texto escrito
      }
    } catch(e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProducts = _allProducts.where((producto) {
        final nombreMatch = producto.nombre.toLowerCase().contains(query);
        final vendedorMatch = producto.vendedor.nombreTienda.toLowerCase().contains(query);
        final textMatch = nombreMatch || vendedorMatch;
        final catMatch = _selectedCategoriaId == null || producto.categoria.id == _selectedCategoriaId;
        return textMatch && catMatch;
      }).toList();
    });
  }

  void _toggleCategoria(int id) {
    setState(() {
      if (_selectedCategoriaId == id) {
        _selectedCategoriaId = null;
      } else {
        _selectedCategoriaId = id;
      }
      _filterProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colFondo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. CABECERA ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hola,", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                      Text(
                        Ambiente.nombreUsuario,
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: _colPrimario),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: _colAcento.withOpacity(0.2),
                    child: Icon(Icons.person, color: _colAcento),
                  ),
                ],
              ),
            ),

            // --- 2. BUSCADOR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar antojos...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: _colAcento),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            // --- 3. CATEGORÍAS ---
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final cat = _categorias[index];
                  final isSelected = _selectedCategoriaId == cat.id;
                  return GestureDetector(
                    onTap: () => _toggleCategoria(cat.id),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? _colAcento : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                      ),
                      child: Text(
                        cat.nombre,
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // --- 4. GRID DE PRODUCTOS (CON REFRESH) ---
            Expanded(
              child: _isLoading && _allProducts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator( // ✅ AQUI ESTÁ LA MAGIA
                onRefresh: _cargarDatosIniciales, // Llama a la función al deslizar
                color: _colAcento,
                backgroundColor: Colors.white,
                child: _buildGridContent(), // Extraje la lógica para mantenerlo limpio
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para manejar el contenido del RefreshIndicator
  Widget _buildGridContent() {
    if (_errorMessage != null) {
      // ✅ TRUCO: SingleChildScrollView + AlwaysScrollableScrollPhysics
      // Permite hacer pull-to-refresh aunque haya error y la lista no exista
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 10),
                Text('Error de conexión', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                Text('Desliza para reintentar', style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 50, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text('No se encontraron productos', style: GoogleFonts.poppins(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      // Importante: AlwaysScrollableScrollPhysics asegura que el refresh funcione aunque haya pocos items
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final producto = _filteredProducts[index];
        return _buildProductCard(producto);
      },
    );
  }

  Widget _buildProductCard(ProductoModel producto) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          Transiciones.crearRutaFadeUp(ProductoDetalleScreen(producto: producto)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _colCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGEN ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: producto.urlImagen != null
                      ? Hero(
                    tag: 'producto-${producto.id}',
                    child: CachedNetworkImage(
                      imageUrl: Ambiente.getUrlImagen(producto.urlImagen),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )
                      : const Icon(Icons.inventory_2, size: 50, color: Colors.grey),
                ),
              ),
            ),

            // --- TEXTOS ---
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: _colPrimario),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    producto.vendedor.nombreTienda,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${producto.precio.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: _colAcento),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: _colAcento, shape: BoxShape.circle),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
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
}