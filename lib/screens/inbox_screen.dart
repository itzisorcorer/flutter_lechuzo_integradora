// lib/screens/inbox_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/chat_models.dart';
import 'package:flutter_lechuzo_integradora/screens/chat_screen.dart';
import 'package:flutter_lechuzo_integradora/services/chat_service.dart';
import 'package:flutter_lechuzo_integradora/utils/custom_transitions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ChatService _chatService = ChatService();

  // Variable para almacenar el futuro y poder refrescarlo
  late Future<List<ChatModel>> _chatsFuture;

  @override
  void initState() {
    super.initState();
    _cargarChats();
  }

  // Función para cargar/recargar los chats
  Future<void> _cargarChats() async {
    setState(() {
      _chatsFuture = _chatService.getMisChats();
    });
    // Esperamos a que termine para que el RefreshIndicator sepa cuándo ocultarse
    try {
      await _chatsFuture;
    } catch (e) {
      // El error se manejará en el builder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Mis Mensajes", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF032C42))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF032C42)),
      ),
      body: FutureBuilder<List<ChatModel>>(
        future: _chatsFuture,
        builder: (context, snapshot) {
          // Si está cargando por primera vez (snapshot no tiene datos previos)
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Envolvemos todo el contenido en RefreshIndicator
          return RefreshIndicator(
            onRefresh: _cargarChats,
            color: const Color(0xFF24799E), // Azul Acento
            backgroundColor: Colors.white,
            child: _buildListContent(snapshot),
          );
        },
      ),
    );
  }

  Widget _buildListContent(AsyncSnapshot<List<ChatModel>> snapshot) {
    // 1. Manejo de Errores
    if (snapshot.hasError) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Permite el "pull" aunque haya error
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 50, color: Colors.grey),
                const SizedBox(height: 10),
                Text("Error de conexión", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                Text("Desliza para reintentar", style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Lista Vacía
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Permite el "pull" en lista vacía
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 50, color: Colors.grey),
                const SizedBox(height: 10),
                Text("No tienes chats activos", style: GoogleFonts.poppins(color: Colors.grey)),
                Text("Desliza para actualizar", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    // 3. Lista con Datos
    final chats = snapshot.data!;
    return ListView.separated(
      itemCount: chats.length,
      separatorBuilder: (c, i) => const Divider(height: 1),
      physics: const AlwaysScrollableScrollPhysics(), // Vital para RefreshIndicator
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: chat.fotoOtroUsuario != null
                ? CachedNetworkImageProvider(Ambiente.getUrlImagen(chat.fotoOtroUsuario))
                : null,
            child: chat.fotoOtroUsuario == null ? const Icon(Icons.person) : null,
          ),
          title: Text(
            chat.nombreOtroUsuario ?? 'Usuario',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
              "Toca para ver la conversación",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          onTap: () {
            // Navegar al chat específico
            Navigator.push(
              context,
              Transiciones.crearRutaSlide(
                  ChatScreen(chatId: chat.id, nombreOtroUsuario: chat.nombreOtroUsuario ?? 'Chat')
              ),
            ).then((_) => _cargarChats()); // Recargar al volver por si hubo mensajes nuevos
          },
        );
      },
    );
  }
}