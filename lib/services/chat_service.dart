// lib/services/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/chat_models.dart';

class ChatService {

  // 1. Iniciar Chat (devuelve el ID del chat)
  Future<int> iniciarChat({int? vendedorId, int? estudianteId}) async {
    final url = Uri.parse('${Ambiente.urlServer}/api/chats/iniciar');
    final token = Ambiente.token;

    Map<String, dynamic> body = {};
    if (vendedorId != null) body['vendedor_id'] = vendedorId;
    if (estudianteId != null) body['estudiante_id'] = estudianteId;

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id']; // Retornamos el ID del chat
    } else {
      throw Exception('Error al iniciar chat');
    }
  }

  // 2. Obtener Mis Chats (Bandeja de entrada)
  Future<List<ChatModel>> getMisChats() async {
    final url = Uri.parse('${Ambiente.urlServer}/api/chats');
    final token = Ambiente.token;

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      // Pasamos el rol actual para que el modelo sepa formatear el nombre del "otro"
      return data.map((json) => ChatModel.fromJson(json, Ambiente.rol)).toList();
    } else {
      throw Exception('Error al cargar chats');
    }
  }

  // 3. Obtener Mensajes de un Chat
  Future<List<MessageModel>> getMensajes(int chatId) async {
    final url = Uri.parse('${Ambiente.urlServer}/api/chats/$chatId/mensajes');
    final token = Ambiente.token;

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar mensajes');
    }
  }

  // 4. Enviar Mensaje
  Future<void> enviarMensaje(int chatId, String contenido) async {
    final url = Uri.parse('${Ambiente.urlServer}/api/chats/$chatId/mensajes');
    final token = Ambiente.token;

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': contenido}),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al enviar mensaje');
    }
  }
}