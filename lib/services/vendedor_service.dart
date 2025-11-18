// lib/services/vendedor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';

class VendedorService {

  // Obtener datos
  Future<Map<String, dynamic>> getPerfil() async {
    final token = Ambiente.token;
    final url = Uri.parse('${Ambiente.urlServer}/api/vendedor/perfil');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar perfil');
    }
  }

  // Actualizar datos
  Future<void> updatePerfil(String nombre, String descripcion) async {
    final token = Ambiente.token;
    final url = Uri.parse('${Ambiente.urlServer}/api/vendedor/perfil');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'nombre_tienda': nombre,
        'description': descripcion,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar: ${response.body}');
    }
  }
}