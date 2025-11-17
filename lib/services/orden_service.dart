// lib/services/orden_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/OrdenModel.dart'; // <-- ¡Importa el nuevo modelo!

class OrdenService {

  Future<PaginatedOrdenesResponse> getMisOrdenes() async {
    final token = Ambiente.token;
    if (token.isEmpty) {
      throw Exception('Token no encontrado. Inicia sesión.');
    }

    final url = Uri.parse('${Ambiente.urlServer}/api/estudiante/ordenes');
    print('Consultando Mis Órdenes: $url');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Enviamos el token
      },
    );

    if (response.statusCode == 200) {
      return PaginatedOrdenesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar tus órdenes: ${response.body}');
    }
  }
  //funcion para obtener las ventas
Future<PaginatedOrdenesResponse> getMisVentas()async {
    final token = Ambiente.token;
    if(token.isEmpty){
      throw Exception('Token no encontrado. Inicia sesión');
    }
    final url = Uri.parse('${Ambiente.urlServer}/api/vendedor/ordenes');
    print('Consultando ventas: $url');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if(response.statusCode == 200){
      return PaginatedOrdenesResponse.fromJson(jsonDecode(response.body));
    }else{
      throw Exception('Error al cargar tus ventas: ${response.body}');

    }

}
}