// lib/Modelos/chat_models.dart

class ChatModel {
  final int id;
  final int estudianteId;
  final int vendedorId;
  final String? nombreOtroUsuario; // Para mostrar en la lista
  final String? fotoOtroUsuario;   // Opcional

  ChatModel({
    required this.id,
    required this.estudianteId,
    required this.vendedorId,
    this.nombreOtroUsuario,
    this.fotoOtroUsuario,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json, String miRol) {
    String nombre = 'Usuario';
    String? foto;

    // Lógica para saber quién es "el otro"
    if (miRol == 'estudiante') {
      // Soy estudiante, el otro es el vendedor
      if (json['vendedor'] != null && json['vendedor']['nombre_tienda'] != null) {
        nombre = json['vendedor']['nombre_tienda'];
        foto = json['vendedor']['url_foto'];
      }
    } else {
      // Soy vendedor, el otro es el estudiante
      if (json['estudiante'] != null && json['estudiante']['nombre_completo'] != null) {
        nombre = json['estudiante']['nombre_completo'];
        foto = json['estudiante']['url_foto'];
      }
    }

    return ChatModel(
      id: json['id'],
      estudianteId: json['estudiante_id'],
      vendedorId: json['vendedor_id'],
      nombreOtroUsuario: nombre,
      fotoOtroUsuario: foto,
    );
  }
}

class MessageModel {
  final int id;
  final int chatId;
  final int senderId;
  final String content;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}