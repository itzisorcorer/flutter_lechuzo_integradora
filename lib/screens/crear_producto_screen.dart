// lib/screens/crear_producto_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart'; // Para CategoriaModel
import 'package:flutter_lechuzo_integradora/services/producto_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class CrearProductoScreen extends StatefulWidget {
  const CrearProductoScreen({super.key});

  @override
  State<CrearProductoScreen> createState() => _CrearProductoScreenState();
}

class _CrearProductoScreenState extends State<CrearProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productoService = ProductoService();

  // Controladores
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();

  // Estado
  late Future<List<CategoriaModel>> _categoriasFuture;
  int? _selectedCategoriaId;
  bool _isLoading = false;
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  // --- PALETA VENDEDOR ---
  final Color _colFondoDark = const Color(0xFF557689); // Azul Oscuro Fondo
  final Color _colIconos = const Color(0xFF4C8AB9);    // Azul Medio Iconos
  final Color _colVerdeBtn = const Color(0xFF98E27F);  // Verde Botón

  @override
  void initState() {
    super.initState();
    _categoriasFuture = _productoService.getCategorias();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleGuardar() async {
    if (!_formKey.currentState!.validate() || _selectedCategoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }
    setState(() { _isLoading = true; });

    try {
      await _productoService.createProducto(
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        precio: double.parse(_precioController.text),
        categoriaId: _selectedCategoriaId!,
        cantidad: int.parse(_cantidadController.text),
        imagen: _imagenSeleccionada,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Producto creado!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _colFondoDark, // Fondo superior oscuro
      appBar: AppBar(
        title: Text('Nuevo Producto', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _colFondoDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SizedBox(
        height: size.height,
        child: Stack(
          children: [
            // --- 1. PANEL BLANCO INFERIOR (Formulario) ---
            Positioned(
              top: size.height * 0.15, // Empieza al 15% de la pantalla
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 100, 24, 24), // Padding top grande para dejar espacio a la imagen flotante
                    children: [

                      // --- CATEGORÍA (Dropdown) ---
                      FutureBuilder<List<CategoriaModel>>(
                        future: _categoriasFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const LinearProgressIndicator();
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Text('Error cargando categorías');
                          }
                          return _buildDropdown(snapshot.data!);
                        },
                      ),
                      const SizedBox(height: 20),

                      // --- NOMBRE ---
                      _buildModernInput(
                        controller: _nombreController,
                        label: 'Nombre del Producto',
                        icon: Icons.edit,
                        validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 20),

                      // --- PRECIO Y CANTIDAD (En fila) ---
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernInput(
                              controller: _precioController,
                              label: 'Precio (\$)',
                              icon: Icons.attach_money,
                              isNumber: true,
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildModernInput(
                              controller: _cantidadController,
                              label: 'Stock',
                              icon: Icons.inventory,
                              isNumber: true,
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- DESCRIPCIÓN ---
                      _buildModernInput(
                        controller: _descripcionController,
                        label: 'Descripción',
                        icon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),

                      // --- BOTÓN GUARDAR ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                          onPressed: _handleGuardar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _colVerdeBtn,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                          child: Text(
                            'PUBLICAR PRODUCTO',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- 2. IMAGEN FLOTANTE (TOCABLE) ---
            // La ponemos después del panel para que quede ENCIMA (stack)
            Positioned(
              top: size.height * 0.02, // Flotando cerca del borde del panel
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _seleccionarImagen, // Al tocar, abre galería
                  child: Stack(
                    children: [
                      // El contenedor de la imagen
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: ClipOval(
                          child: _imagenSeleccionada != null
                              ? Image.file(_imagenSeleccionada!, fit: BoxFit.cover)
                              : Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.add_a_photo, size: 50, color: _colIconos),
                          ),
                        ),
                      ),
                      // Iconito de "+" o cámara
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _colIconos,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AYUDANTES PARA LIMPIEZA ---

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _colIconos),
        filled: true,
        fillColor: Colors.grey[100], // Fondo gris suave para el input
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none, // Sin bordes negros
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Widget _buildDropdown(List<CategoriaModel> categorias) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonFormField<int>(
        value: _selectedCategoriaId,
        isExpanded: true, // Evita overflow de texto largo
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.category, color: _colIconos),
          labelText: 'Categoría',
          border: InputBorder.none,
        ),
        items: categorias.map((cat) {
          return DropdownMenuItem<int>(
            value: cat.id,
            child: Text(cat.nombre, style: GoogleFonts.poppins(), overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedCategoriaId = value),
        validator: (value) => value == null ? 'Selecciona una categoría' : null,
      ),
    );
  }
}