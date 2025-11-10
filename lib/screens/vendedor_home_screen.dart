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
Widget _buildProductList(){
    if(_isLoading){
      return const Center(child: CircularProgressIndicator());
    }
    if(_errorMessage != null){
      return Center(
        child: Text(
          'Error al cargar: $_errorMessage',
          style: const TextStyle(color: Colors.red),
        ),

      );
    }
    if (_misProductos.isEmpty){
      return const Center(child: Text('No has publicado ningún producto todavía'));
    }
    //mostramos la lista de productos
  return ListView.builder(
    itemCount: _misProductos.length,
    itemBuilder: (context, index){
      final producto = _misProductos[index];
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          title: Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(producto.categoria.nombre),
          leading: CircleAvatar(
            child: Text('\$${producto.precio.toStringAsFixed(0)}'),
          ),
          trailing: const Icon(Icons.edit, color: Colors.blue),
          onTap: () async {
            final resultado = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditarProductoScreen(producto: producto),
              ),
            );
            if(resultado == true){
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _fetchMisProductos();

            }

          },
        ),
      );
    }
  );
}
}