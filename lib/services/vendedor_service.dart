// lib/services/vendedor_service.dart
import 'dart:convert';
import 'dart:io';
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
  Future<void> updatePerfil({
    required String nombre,
    required String descripcion,
    File? fotoNueva
  }) async {
    final token = Ambiente.token;
    final url = Uri.parse('${Ambiente.urlServer}/api/vendedor/perfil');

    // 1. Usamos MultipartRequest (como en Productos)
    // OJO: Usamos POST con _method: PUT para que Laravel procese la imagen
    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // 2. Campos de texto
    request.fields['_method'] = 'PUT'; // El truco de Laravel
    request.fields['nombre_tienda'] = nombre;
    request.fields['description'] = descripcion;

    // 3. La Foto (si hay nueva)
    if (fotoNueva != null) {
      request.files.add(
          await http.MultipartFile.fromPath(
            'foto', // El nombre que pusimos en el Controller de Laravel
            fotoNueva.path,
          )
      );
    }

    // 4. Enviar
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar perfil: ${response.body}');
    }
  }
}