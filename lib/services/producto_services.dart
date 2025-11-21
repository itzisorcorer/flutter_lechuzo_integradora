// lib/services/producto_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';
import 'dart:io';



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
    File? imagen,
  }) async {

    final token = Ambiente.token;
    final url = Uri.parse('${Ambiente.urlServer}/api/productos');

    // 1. Creamos un request de tipo 'multipart'
    var request = http.MultipartRequest('POST', url);


    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });


    request.fields['nombre'] = nombre;
    request.fields['descripcion'] = descripcion;
    request.fields['precio'] = precio.toString();
    request.fields['categoria_id'] = categoriaId.toString();
    request.fields['cantidad_disponible'] = cantidad.toString();
    request.fields['disponible'] = 'true';


    if (imagen != null) {
      request.files.add(
          await http.MultipartFile.fromPath(
            'imagen', // Este es el 'name' que tu backend de Laravel espera
            imagen.path,
          )
      );
    }

    // 5. Enviamos la petición
    var streamedResponse = await request.send();

    // 6. Obtenemos la respuesta
    var response = await http.Response.fromStream(streamedResponse);

    print('Respuesta de Crear Producto: ${response.statusCode}');
    print('Cuerpo: ${response.body}');

    if (response.statusCode == 201) { // 201 = Creado
      // La API nos devuelve el producto recién creado
      return ProductoModel.fromJson(jsonDecode(response.body)['producto']);
    } else {
      throw Exception('Error al crear el producto: ${response.body}');
    }
  }

// --- FUNCIÓN CORREGIDA (Para enviar Imagen + Texto) ---
  Future<ProductoModel> updateProducto({
    required int productoId,
    required String nombre,
    required String descripcion,
    required double precio,
    required int categoriaId,
    required int cantidad,
    File? imagenNueva, // <-- Aceptamos la imagen (opcional)
  }) async {
    final token = Ambiente.token;

    // 1. Usamos la URL del producto
    final url = Uri.parse('${Ambiente.urlServer}/api/productos/$productoId');

    // 2. ¡IMPORTANTE! Creamos un MultipartRequest 'POST' (NO 'PUT')
    var request = http.MultipartRequest('POST', url);

    // 3. Headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // 4. --- ¡EL TRUCO! ---
    // Le decimos a Laravel: "Aunque esto es un POST, trátalo como un PUT"
    request.fields['_method'] = 'PUT';

    // 5. Datos de texto
    request.fields['nombre'] = nombre;
    request.fields['descripcion'] = descripcion;
    request.fields['precio'] = precio.toString();
    request.fields['categoria_id'] = categoriaId.toString();
    request.fields['cantidad_disponible'] = cantidad.toString();
    // (Nota: No enviamos 'disponible' a menos que tengas un switch para eso)

    // 6. Imagen (si hay una nueva)
    if (imagenNueva != null) {
      request.files.add(
          await http.MultipartFile.fromPath(
            'imagen', // El nombre del campo que espera Laravel
            imagenNueva.path,
          )
      );
    }

    // 7. Enviar
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print('Respuesta Update: ${response.statusCode}');

    if (response.statusCode == 200) {
      return ProductoModel.fromJson(jsonDecode(response.body)['producto']);
    } else {
      throw Exception('Error al actualizar: ${response.body}');
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
    if(response.statusCode == 200 || response.statusCode == 204){
      return;

    }else{
      throw Exception('Error al eliminar el producto: ${response.body}');
    }

  }

}