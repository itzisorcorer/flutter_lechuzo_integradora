// lib/screens/editar_producto_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';
import 'package:flutter_lechuzo_integradora/services/producto_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditarProductoScreen extends StatefulWidget {
  final ProductoModel producto;
  const EditarProductoScreen({super.key, required this.producto});

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductoService _productoService = ProductoService();

  late TextEditingController _nombreCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _stockCtrl;

  // Dropdown
  late Future<List<CategoriaModel>> _categoriasFuture;
  int? _categoriaId;

  // Imagen
  File? _nuevaImagen;
  String? _imagenUrlExistente;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // --- PALETA VENDEDOR ---
  final Color _colFondoDark = const Color(0xFF557689); // Azul Oscuro Fondo
  final Color _colIconos = const Color(0xFF4C8AB9);    // Azul Medio Iconos
  final Color _colVerdeBtn = const Color(0xFF98E27F);  // Verde Botón

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con datos actuales
    _nombreCtrl = TextEditingController(text: widget.producto.nombre);
    _descripcionCtrl = TextEditingController(text: widget.producto.descripcion);
    _precioCtrl = TextEditingController(text: widget.producto.precio.toStringAsFixed(2));
    _stockCtrl = TextEditingController(text: widget.producto.cantidadDisponible.toString());
    _categoriaId = widget.producto.categoria.id;
    _imagenUrlExistente = widget.producto.urlImagen;

    _categoriasFuture = _productoService.getCategorias();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() { _nuevaImagen = File(pickedFile.path); });
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate() || _categoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Revisa los campos')));
      return;
    }
    setState(() { _isLoading = true; });

    try {
      await _productoService.updateProducto(
        productoId: widget.producto.id,
        nombre: _nombreCtrl.text,
        descripcion: _descripcionCtrl.text,
        precio: double.parse(_precioCtrl.text),
        cantidad: int.parse(_stockCtrl.text),
        categoriaId: _categoriaId!,
        imagenNueva: _nuevaImagen,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _colFondoDark,
      appBar: AppBar(
        title: Text('Editar Producto', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _colFondoDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SizedBox(
        height: size.height,
        child: Stack(
          children: [
            // --- 1. PANEL BLANCO INFERIOR ---
            Positioned(
              top: size.height * 0.15, // Empieza más arriba
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
                    padding: const EdgeInsets.fromLTRB(24, 100, 24, 24), // Padding top grande para la imagen
                    children: [
                      // --- CATEGORÍA ---
                      FutureBuilder<List<CategoriaModel>>(
                        future: _categoriasFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const LinearProgressIndicator();
                          return _buildDropdown(snapshot.data!);
                        },
                      ),
                      const SizedBox(height: 20),

                      // --- NOMBRE ---
                      _buildModernInput(
                        controller: _nombreCtrl,
                        label: 'Nombre del Producto',
                        icon: Icons.edit,
                        validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                      ),
                      const SizedBox(height: 20),

                      // --- PRECIO Y STOCK ---
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernInput(
                              controller: _precioCtrl,
                              label: 'Precio (\$)',
                              icon: Icons.attach_money,
                              isNumber: true,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildModernInput(
                              controller: _stockCtrl,
                              label: 'Stock',
                              icon: Icons.inventory,
                              isNumber: true,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- DESCRIPCIÓN ---
                      _buildModernInput(
                        controller: _descripcionCtrl,
                        label: 'Descripción',
                        icon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),

                      // --- BOTÓN GUARDAR ---
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _guardarCambios,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _colVerdeBtn,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text('GUARDAR CAMBIOS', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- 2. IMAGEN FLOTANTE ---
            Positioned(
              top: size.height * 0.02,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: ClipOval(
                          child: _getImageWidget(),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: _colIconos, shape: BoxShape.circle, border: Border.all(color: Colors.white)),
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

  // --- WIDGETS AYUDANTES ---

  Widget _getImageWidget() {
    if (_nuevaImagen != null) {
      return Image.file(_nuevaImagen!, fit: BoxFit.cover);
    }
    if (_imagenUrlExistente != null) {
      return CachedNetworkImage(
        imageUrl: Ambiente.urlServer + _imagenUrlExistente!,
        fit: BoxFit.cover,
        placeholder: (c, u) => const CircularProgressIndicator(),
        errorWidget: (c, u, e) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
    return Container(color: Colors.grey[200], child: Icon(Icons.add_a_photo, size: 50, color: _colIconos));
  }

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
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

// Helper para Dropdown Categoria
  Widget _buildDropdown(List<CategoriaModel> categorias) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonFormField<int>(
        value: _categoriaId,

        // --- CORRECCIÓN 1: EXPANDIR ---
        // Esto evita que el dropdown trate de ser más ancho que la pantalla
        isExpanded: true,

        decoration: InputDecoration(
          prefixIcon: Icon(Icons.category, color: _colIconos),
          labelText: 'Categoría',
          border: InputBorder.none,
        ),
        items: categorias.map((cat) => DropdownMenuItem(
          value: cat.id,
          // --- CORRECCIÓN 2: CORTE DE TEXTO ---
          // Si el texto es muy largo, pone "..."
          child: Text(
            cat.nombre,
            style: GoogleFonts.poppins(),
            overflow: TextOverflow.ellipsis,
          ),
        )).toList(),
        onChanged: (v) => setState(() => _categoriaId = v),
        validator: (v) => v == null ? 'Selecciona una categoría' : null,
      ),
    );
  }
}