// lib/screens/crear_producto_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';
import 'package:flutter_lechuzo_integradora/services/producto_services.dart';

class CrearProductoScreen extends StatefulWidget {
  const CrearProductoScreen({super.key});

  @override
  State<CrearProductoScreen> createState() => _CrearProductoScreenState();
}

class _CrearProductoScreenState extends State<CrearProductoScreen> {
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
    // Cargamos las categorías al iniciar
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
  Future<void> _handleGuardar() async {
    // 1. Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return; // Si hay errores, no hace nada
    }

    // 2. Validar que se seleccionó una categoría
    if (_selectedCategoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una categoría'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 3. Llamar al servicio
      await _productoService.createProducto(
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        precio: double.parse(_precioController.text),
        categoriaId: _selectedCategoriaId!,
        cantidad: int.parse(_cantidadController.text),
      );

      // 4. ¡Éxito!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Producto creado exitosamente!'), backgroundColor: Colors.green),
      );
      // Regresamos a la pantalla anterior (VendedorHomeScreen)
      Navigator.pop(context, true); // Enviamos 'true' para indicar que refresque

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
        child: ListView( // Usamos ListView en lugar de Column para evitar overflow
          padding: const EdgeInsets.all(16.0),
          children: [
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
                  value: _selectedCategoriaId,
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

            // --- Campo Precio ---
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

            // --- Campo Cantidad ---
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