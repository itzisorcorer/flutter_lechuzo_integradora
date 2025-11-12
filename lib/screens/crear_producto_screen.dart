// lib/screens/crear_producto_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';
import 'package:flutter_lechuzo_integradora/services/producto_services.dart';
import 'package:image_picker/image_picker.dart'; // <-- Importa ImagePicker

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

  // Dropdown de Categorías
  late Future<List<CategoriaModel>> _categoriasFuture;
  int? _selectedCategoriaId;
  bool _isLoading = false;

  // --- Estado para la imagen ---
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Cargamos las categorías al iniciar
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

  // --- Función para seleccionar imagen ---
  Future<void> _seleccionarImagen() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  // --- Lógica para guardar (con imagen) ---
  Future<void> _handleGuardar() async {
    // 1. Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return; // Si hay errores, no hace nada
    }
    // (La validación del dropdown ya está en el validator del TextFormField)

    setState(() { _isLoading = true; });

    try {
      // 3. Llamar al servicio (con la imagen)
      await _productoService.createProducto(
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        precio: double.parse(_precioController.text),
        categoriaId: _selectedCategoriaId!,
        cantidad: int.parse(_cantidadController.text),
        imagen: _imagenSeleccionada, // <-- Pasamos la imagen
      );

      // 4. ¡Éxito!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Producto creado exitosamente!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Regresamos (y refrescamos)

    } catch (e) {
      // 5. Error
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
        title: const Text('Crear Nuevo Producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [

            // --- Widget para el Preview de Imagen ---
            InkWell(
              onTap: _seleccionarImagen, // Llama a la función al tocar
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _imagenSeleccionada != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_imagenSeleccionada!, fit: BoxFit.cover),
                )
                    : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                    Text('Seleccionar Imagen', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Campo Nombre ---
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del Producto'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Dropdown de Categorías (Completo) ---
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
                  validator: (value) { // Validador para el dropdown
                    if (value == null) {
                      return 'Debes seleccionar una categoría';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // --- Campo Precio (Completo) ---
            TextFormField(
              controller: _precioController,
              decoration: const InputDecoration(labelText: 'Precio (Ej: 150.00)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El precio es obligatorio';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingresa un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Campo Cantidad (Completo) ---
            TextFormField(
              controller: _cantidadController,
              decoration: const InputDecoration(labelText: 'Cantidad Disponible'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La cantidad es obligatoria';
                }
                if (int.tryParse(value) == null) {
                  return 'Ingresa un número entero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Campo Descripción ---
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // --- Botón de Guardar ---
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _handleGuardar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar Producto'),
            ),
          ],
        ),
      ),
    );
  }
}