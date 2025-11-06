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

// (Aquí irán 'createProducto', 'updateProducto', etc. en el futuro)
}