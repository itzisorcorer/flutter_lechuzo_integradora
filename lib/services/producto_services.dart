// lib/services/producto_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';


class ProductoService {

  Future<PaginatedProductosResponse> getProductos() async {
    // Obtenemos el token guardado
    final token = Ambiente.token;

    if (token.isEmpty) {
      throw Exception('Token no encontrado. Inicia sesión.');
    }

    final url = Uri.parse('${Ambiente.urlServer}/api/productos');
    print('Consultando: $url');
    print('Con Token: Bearer $token');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        // ¡El paso más importante! Enviar el token para autorización
        'Authorization': 'Bearer $token',
      },
    );

    print('Respuesta de Productos: ${response.statusCode}');

    if (response.statusCode == 200) {
      return PaginatedProductosResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar los productos: ${response.body}');
    }
  }

//Función para obtener los productos del vendedor logueado - autenticado
Future<PaginatedProductosResponse> getMisProductos() async{
    final token = Ambiente.token;

    if(token.isEmpty) {
      throw Exception('Token no encontrado. Inicia sesión.');
    }
    final url = Uri.parse('${Ambiente.urlServer}/api/vendedor/productos');
    print('Consultando MIS productos');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('Respuesta de MIS productos: ${response.statusCode}');

    if(response.statusCode == 200){
      return PaginatedProductosResponse.fromJson(jsonDecode(response.body));
    }else if(response.statusCode == 403) {
      throw Exception('No tienes autorización para esta acción');
    }
    else{
      throw Exception('Error al cargar los productos: ${response.body}');
    }
  }
  Future<List<CategoriaModel>> getCategorias() async{
    final token = Ambiente.token;
    final url = Uri.parse('${Ambiente.urlServer}/api/categorias');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if(response.statusCode == 200){
      List<dynamic> data = jsonDecode(response.body);

      return data.map((json) => CategoriaModel.fromJson(json)).toList();

    }else{
      throw Exception('Error al cargar las categorías: ${response.body}');
    }
  }
  Future<ProductoModel> createProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required int categoriaId,
    required int cantidad,
}) async{
    final token = Ambiente.token;
    final url = Uri.parse('${Ambiente.urlServer}/api/productos');

    final response = await http.post(
      url,
      headers: {
        'Content-type' : 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'categoria_id': categoriaId,
        'cantidad_disponible': cantidad,
        'disponible' : true
      }),

    );
    if(response.statusCode == 201){ //201 = creado
      return ProductoModel.fromJson(jsonDecode(response.body)['producto']);

    }else{
      throw Exception('Error al crear el producto: ${response.body}');
    }


  }
  Future<ProductoModel> updateProducto(
      int productoId,
      Map<String, dynamic> data,
      ) async{
    final token = Ambiente.token;
    final url = Uri.parse('${Ambiente.urlServer}/api/productos/$productoId');
    final response = await http.put(
      url,
      headers: {
        'Content-type' : 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization' : 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if(response.statusCode == 200){
      return ProductoModel.fromJson(jsonDecode(response.body)['producto']);

    }else{
      throw Exception('Error al actualizar el producto: ${response.body}');

    }


  }
  Future<void> deleteProducto(int productoId) async{
    final token = Ambiente.token;

    final url = Uri.parse('${Ambiente.urlServer}/api/productos/$productoId');
    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },

    );
    if(response.statusCode == 200){
      return;

    }else{
      throw Exception('Error al eliminar el producto: ${response.body}');
    }

  }

}
