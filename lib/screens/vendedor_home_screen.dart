// lib/screens/vendedor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/services/producto_services.dart';
import 'package:flutter_lechuzo_integradora/screens/crear_producto_screen.dart';
import 'package:flutter_lechuzo_integradora/screens/editar_producto_screen.dart';

import '../Modelos/ProductoModel.dart';

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

  //llamada de la api
  @override
  void initState() {
    super.initState();
    _fetchMisProductos();
  }

  Future<void> _fetchMisProductos() async {
    try {
      final response = await _productoService.getMisProductos();
      setState(() {
        _misProductos = response.productos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard de ${Ambiente.nombreUsuario}'),
        // TODO:
      ),
      body: _buildProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CrearProductoScreen()
          ),
          );
          if (resultado == true){
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
            _fetchMisProductos();
            
          }
        },
        tooltip: 'Añadir producto',
        child: const Icon(Icons.add),


      ),
    );
  }
  //widget de apoyo para mostrar la lista
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
    if (_misProductos.isEmpty) {
      return const Center(child: Text('No has publicado ningún producto todavía'));
    }

    // Mostramos la lista de productos
    return ListView.builder(
        itemCount: _misProductos.length,
        itemBuilder: (context, index) {
          final producto = _misProductos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(producto.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(producto.categoria.nombre),

              leading: CircleAvatar(
                // FittedBox encoge el texto para que quepa
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0), // Un poco de espacio
                    child: Text('\$${producto.precio.toStringAsFixed(0)}'),
                  ),
                ),
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- BOTÓN EDITAR ---
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      print('DEBUG: URL de la imagen: ${producto.urlImagen}' );

                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditarProductoScreen(producto: producto),
                        ),
                      );
                      if (resultado == true) {
                        setState(() { _isLoading = true; _errorMessage = null; });
                        _fetchMisProductos();
                      }
                    },
                  ),
                  // --- BOTÓN BORRAR ---
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Llama al diálogo de confirmación
                      _mostrarDialogoConfirmacion(producto);
                    },
                  ),
                ],
              ),
              onTap: null,
            ),
          );
        });
  }

  // --- NUEVA FUNCIÓN: DIÁLOGO DE CONFIRMACIÓN ---
  Future<void> _mostrarDialogoConfirmacion(ProductoModel producto) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres eliminar "${producto.nombre}"?'),
                const Text('Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            // Botón "Cancelar"
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            // Botón "Eliminar" (en rojo)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _ejecutarEliminacion(producto); // Llama a la lógica de borrado
              },
            ),
          ],
        );
      },
    );
  }



// --- 4. FUNCIÓN: LÓGICA DE BORRADO ---
  Future<void> _ejecutarEliminacion(ProductoModel producto) async {

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _productoService.deleteProducto(producto.id);

      await _fetchMisProductos();

      if(mounted) {
        // Mostramos un SnackBar de ÉXITO
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('"${producto.nombre}" eliminado correctamente.'),
              backgroundColor: Colors.green),
        );
      }

    } catch (e) {
      // 4. Error
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
      // Mostramos el SnackBar DE ERROR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

}