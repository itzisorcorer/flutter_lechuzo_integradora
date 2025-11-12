// lib/screens/editar_producto_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';
import 'package:flutter_lechuzo_integradora/services/producto_services.dart';
import 'package:image_picker/image_picker.dart';

class EditarProductoScreen extends StatefulWidget {
  // Recibimos el producto que vamos a editar
  final ProductoModel producto;

  const EditarProductoScreen({super.key, required this.producto});

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productoService = ProductoService();

  // Controladores
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();

  // Dropdown
  late Future<List<CategoriaModel>> _categoriasFuture;
  int? _selectedCategoriaId;
  bool _isLoading = false;

  // Estado de la Imagen
  File? _imagenNueva; // La foto que el usuario acaba de tomar/elegir
  String? _imagenUrlExistente; // La foto que ya estaba en el servidor
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    //Pre-llenamos el formulario con los datos del producto
    _nombreController.text = widget.producto.nombre;
    _descripcionController.text = widget.producto.descripcion ?? '';
    _precioController.text = widget.producto.precio.toStringAsFixed(2);
    _cantidadController.text = widget.producto.cantidadDisponible.toString();
    _selectedCategoriaId = widget.producto.categoria.id;
    _imagenUrlExistente = widget.producto.urlImagen; // Guardamos la URL de la foto vieja

    // Cargamos las categorías
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
        _imagenNueva = File(pickedFile.path);
      });
    }
  }

  //Lógica para ACTUALIZAR
  Future<void> _handleActualizar() async {
    if (!_formKey.currentState!.validate() || _selectedCategoriaId == null) {
      return;
    }
    setState(() { _isLoading = true; });

    try {
      //Llamamos a la función 'updateProducto'
      await _productoService.updateProducto(
        productoId: widget.producto.id,
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        precio: double.parse(_precioController.text),
        categoriaId: _selectedCategoriaId!,
        cantidad: int.parse(_cantidadController.text),
        imagenNueva: _imagenNueva,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Producto actualizado!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);

    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [

            // --- 7. Widget de Imagen
            InkWell(
              onTap: _seleccionarImagen,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 16),


            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del Producto'),
              validator: (value) {
                if (value == null || value.isEmpty) return 'El nombre es obligatorio';
                return null;
              },
            ),
            const SizedBox(height: 16),

            FutureBuilder<List<CategoriaModel>>(
              future: _categoriasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Error al cargar categorías', style: TextStyle(color: Colors.red));
                }
                return DropdownButtonFormField<int>(
                  value: _selectedCategoriaId,
                  isExpanded: true,
                  hint: const Text('Selecciona una categoría'),
                  items: snapshot.data!.map((categoria) {
                    return DropdownMenuItem<int>(
                      value: categoria.id,
                      child: Text(categoria.nombre, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() { _selectedCategoriaId = value; });
                  },
                  validator: (value) {
                    if (value == null) return 'Debes seleccionar una categoría';
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _precioController,
              decoration: const InputDecoration(labelText: 'Precio (Ej: 150.00)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'El precio es obligatorio';
                if (double.tryParse(value) == null) return 'Ingresa un número válido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _cantidadController,
              decoration: const InputDecoration(labelText: 'Cantidad Disponible'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'La cantidad es obligatoria';
                if (int.tryParse(value) == null) return 'Ingresa un número entero';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _handleActualizar, // Llama a la función de 'update'
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  //Widget Ayudante para la Imagen
  Widget _buildImagePreview() {
    if (_imagenNueva != null) {
      //Si el usuario seleccionó una FOTO NUEVA, la mostramos
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_imagenNueva!, fit: BoxFit.cover),
      );
    } else if (_imagenUrlExistente != null) {
      //Si NO hay foto nueva, pero SÍ había una foto VIEJA, la cargamos
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network( // <-- ¡Usamos Image.network!
          Ambiente.urlServer + _imagenUrlExistente!,
          fit: BoxFit.cover,
          // Placeholder mientras carga
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          // Error si no puede cargar la URL
          errorBuilder: (context, error, stack) {
            return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
          },
        ),
      );
    } else {
      //Si no hay ni nueva ni vieja, mostramos el placeholder
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
          Text('Toca para cambiar la imagen', style: TextStyle(color: Colors.grey)),
        ],
      );
    }
  }
}