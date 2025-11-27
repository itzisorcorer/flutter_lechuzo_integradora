// lib/screens/chat_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/chat_models.dart';
import 'package:flutter_lechuzo_integradora/services/chat_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final String nombreOtroUsuario;

  const ChatScreen({super.key, required this.chatId, required this.nombreOtroUsuario});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> _mensajes = [];
  bool _isLoading = true;
  Timer? _timer;

  // Colores
  final Color _colYo = const Color(0xFF032C42); // Mis mensajes (Azul oscuro)
  final Color _colOtro = const Color(0xFFE0E0E0); // Sus mensajes (Gris)

  @override
  void initState() {
    super.initState();
    _cargarMensajes();
    // Polling: Consultar mensajes nuevos cada 3 segundos
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _cargarMensajes(silencioso: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ¡IMPORTANTE! Cancelar timer al salir
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarMensajes({bool silencioso = false}) async {
    if (!silencioso) setState(() => _isLoading = true);
    try {
      final nuevosMensajes = await _chatService.getMensajes(widget.chatId);
      if (mounted) {
        setState(() {
          _mensajes = nuevosMensajes;
          _isLoading = false;
        });
        // Si es la primera carga, bajar el scroll al final
        if (!silencioso) _scrollToBottom();
      }
    } catch (e) {
      if (mounted && !silencioso) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _enviar() async {
    if (_msgController.text.trim().isEmpty) return;

    final texto = _msgController.text;
    _msgController.clear(); // Limpiar input rápido para UX

    try {
      await _chatService.enviarMensaje(widget.chatId, texto);
      _cargarMensajes(silencioso: true); // Recargar para ver el mío
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al enviar")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreOtroUsuario, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _colYo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // --- LISTA DE MENSAJES ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mensajes.isEmpty
                ? Center(child: Text("Di hola 👋", style: GoogleFonts.poppins(color: Colors.grey)))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final msg = _mensajes[index];
                final esMio = msg.senderId == Ambiente.idUsuario;
                return _buildBurbuja(msg, esMio);
              },
            ),
          ),

          // --- INPUT ---
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.of(context).viewPadding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: _colYo,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _enviar,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBurbuja(MessageModel msg, bool esMio) {
    return Align(
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: esMio ? _colYo : _colOtro,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: esMio ? const Radius.circular(15) : Radius.zero,
            bottomRight: esMio ? Radius.zero : const Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.content,
              style: GoogleFonts.poppins(color: esMio ? Colors.white : Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2,'0')}",
              style: TextStyle(color: esMio ? Colors.white70 : Colors.black54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}