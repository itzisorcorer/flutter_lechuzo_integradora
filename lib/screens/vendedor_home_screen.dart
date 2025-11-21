// lib/screens/vendedor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';
import 'package:flutter_lechuzo_integradora/services/producto_services.dart';
import 'package:flutter_lechuzo_integradora/screens/crear_producto_screen.dart';
import 'package:flutter_lechuzo_integradora/screens/editar_producto_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VendedorHomeScreen extends StatefulWidget {
  const VendedorHomeScreen({super.key});

  @override
  State<VendedorHomeScreen> createState() => _VendedorHomeScreenState();
}

class _VendedorHomeScreenState extends State<VendedorHomeScreen> {
  final ProductoService _productoService = ProductoService();
  List<ProductoModel> _misProductos = [];
  bool _isLoading = true;
  String? _errorMessage;

  // --- PALETA DE COLORES VENDEDOR ---
  final Color _colOscuro = const Color(0xFF557689); // Gris Azulado Oscuro
  final Color _colMedio = const Color(0xFF4C8AB9);  // Azul Acero
  final Color _colClaro = const Color(0xFF84C1F8);  // Azul Cielo
  final Color _colFondoCard = const Color(0xFFCFEAFF); // Azul Muy Claro (Fondo items)
  final Color _colVerde = const Color(0xFF98E27F);  // Verde (Acción/Precio)

  @override
  void initState() {
    super.initState();
    _fetchMisProductos();
  }

  Future<void> _fetchMisProductos() async {
    try {
      final response = await _productoService.getMisProductos();
      if (mounted) {
        setState(() {
          _misProductos = response.productos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  // Lógica de Borrado (Tu misma lógica, solo integrada en el nuevo diseño)
  Future<void> _mostrarDialogoConfirmacion(ProductoModel producto) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Producto', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _colOscuro)),
          content: Text('¿Seguro que quieres borrar "${producto.nombre}"?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _ejecutarEliminacion(producto);
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _ejecutarEliminacion(ProductoModel producto) async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await _productoService.deleteProducto(producto.id);
      await _fetchMisProductos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo limpio
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. CABECERA ESTILO DASHBOARD ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hola, bienvenido",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _colOscuro,
                        ),
                      ),
                      Text(
                        Ambiente.nombreUsuario,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Botón flotante pequeño de "Añadir" en la cabecera (Opcional, o abajo)
                  InkWell(
                    onTap: () async {
                      final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearProductoScreen()));
                      if (res == true) {
                        setState(() { _isLoading = true; });
                        _fetchMisProductos();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _colVerde,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: _colVerde.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- 2. LISTA DE TARJETAS ---
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text('Error: $_errorMessage'));
    if (_misProductos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: _colClaro.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No tienes productos aún', style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _misProductos.length,
      itemBuilder: (context, index) {
        final producto = _misProductos[index];
        // Alternamos colores para que se vea dinámico como en la referencia
        final Color cardColor = index % 2 == 0 ? _colOscuro : _colMedio;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // --- IMAGEN (Cuadrada con bordes suaves) ---
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: producto.urlImagen != null
                      ? CachedNetworkImage(
                    imageUrl: Ambiente.urlServer + producto.urlImagen!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.white54),
                  )
                      : const Icon(Icons.inventory_2, color: Colors.white),
                ),
              ),

              const SizedBox(width: 16),

              // --- INFO ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Categoría y Stock
                    Row(
                      children: [
                        Text(
                          producto.categoria.nombre,
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Stock: ${producto.cantidadDisponible}',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${producto.precio.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        color: _colVerde, // Precio en verde brillante
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // --- ACCIONES (Editar/Borrar) ---
              Column(
                children: [
                  // Editar
                  InkWell(
                    onTap: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditarProductoScreen(producto: producto)),
                      );
                      if (res == true) {
                        setState(() { _isLoading = true; });
                        _fetchMisProductos();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Borrar
                  InkWell(
                    onTap: () => _mostrarDialogoConfirmacion(producto),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete, color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}