// lib/screens/editar_producto_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';
import 'package:flutter_lechuzo_integradora/services/producto_services.dart';

class EditarProductoScreen extends StatefulWidget {
  // --- ¡LA CLAVE! ---
  // Recibimos el producto que vamos a editar
  final ProductoModel producto;

  const EditarProductoScreen({super.key, required this.producto});

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productoService = ProductoService();

  // Controladores para los campos
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();

  // Para manejar el dropdown
  late Future<List<CategoriaModel>> _categoriasFuture;
  int? _selectedCategoriaId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // --- ¡AQUÍ ESTÁ LA MAGIA! ---
    // Pre-llenamos el formulario con los datos del producto
    _nombreController.text = widget.producto.nombre;
    _descripcionController.text = widget.producto.descripcion ?? '';
    _precioController.text = widget.producto.precio.toStringAsFixed(2);
    _cantidadController.text = widget.producto.cantidadDisponible.toString();
    _selectedCategoriaId = widget.producto.categoria.id; // Pre-selecciona la categoría

    // Cargamos las categorías (igual que en "Crear")
    _categoriasFuture = _productoService.getCategorias();
  }

  @override
  void dispose() {
    // Limpiamos los controllers
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  // --- Lógica para guardar ---
  Future<void> _handleActualizar() async {
    if (!_formKey.currentState!.validate() || _selectedCategoriaId == null) {
      return; // Si hay errores, no hace nada
    }

    setState(() { _isLoading = true; });

    // 1. Creamos un 'Map' solo con los datos que queremos enviar
    final Map<String, dynamic> datosActualizados = {
      'nombre': _nombreController.text,
      'descripcion': _descripcionController.text,
      'precio': double.parse(_precioController.text),
      'categoria_id': _selectedCategoriaId!,
      'cantidad_disponible': int.parse(_cantidadController.text),
    };

    try {
      // 2. Llamamos a la nueva función 'updateProducto' del servicio
      await _productoService.updateProducto(
        widget.producto.id, // Pasamos el ID del producto
        datosActualizados,   // Pasamos los datos del formulario
      );

      // 3. ¡Éxito!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Producto actualizado!'), backgroundColor: Colors.green),
      );
      // Regresamos a la pantalla anterior (VendedorHomeScreen)
      Navigator.pop(context, true); // Enviamos 'true' para indicar que refresque

    } catch (e) {
      // 4. Error
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
        child: ListView( // (El formulario es idéntico al de Crear)
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Campo Nombre ---
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del Producto'),
              validator: (value) { /* ... (validador igual) ... */ return null; },
            ),
            const SizedBox(height: 16),

            // --- Dropdown de Categorías ---
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
                  value: _selectedCategoriaId, // ¡Ya viene pre-seleccionado!
                  isExpanded: true,
                  hint: const Text('Selecciona una categoría'),
                  items: snapshot.data!.map((categoria) {
                    return DropdownMenuItem<int>(
                      value: categoria.id,
                      child: Text(categoria.nombre),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() { _selectedCategoriaId = value; });
                  },
                  validator: (value) { /* ... (validador igual) ... */ return null; },
                );
              },
            ),
            const SizedBox(height: 16),

            // --- Campo Precio ---
            TextFormField(
              controller: _precioController,
              decoration: const InputDecoration(labelText: 'Precio (Ej: 150.00)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) { /* ... (validador igual) ... */ return null; },
            ),
            const SizedBox(height: 16),

            // --- Campo Cantidad ---
            TextFormField(
              controller: _cantidadController,
              decoration: const InputDecoration(labelText: 'Cantidad Disponible'),
              keyboardType: TextInputType.number,
              validator: (value) { /* ... (validador igual) ... */ return null; },
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
              onPressed: _handleActualizar, // Llama a la nueva función
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
}