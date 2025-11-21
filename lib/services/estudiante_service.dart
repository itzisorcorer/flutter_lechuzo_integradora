// lib/services/estudiante_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';

class EstudianteService {

  Future<Map<String, dynamic>> getPerfil() async {
    final token = Ambiente.token;
    final url = Uri.parse('${Ambiente.urlServer}/api/estudiante/perfil');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al cargar perfil');
  }

  Future<void> updatePerfil({required String nombre, File? fotoNueva}) async {
    final token = Ambiente.token;
    final url = Uri.parse('${Ambiente.urlServer}/api/estudiante/perfil');

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['_method'] = 'PUT';
    request.fields['nombre_completo'] = nombre;

    if (fotoNueva != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', fotoNueva.path));
    }

    var response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) throw Exception('Error: ${response.body}');
  }
}