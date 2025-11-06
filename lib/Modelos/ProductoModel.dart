
import 'dart:convert';

// Modelo para la respuesta de paginación completa
class PaginatedProductosResponse {
  final List<ProductoModel> productos;
  final int currentPage;
  final int lastPage;

  PaginatedProductosResponse({
    required this.productos,
    required this.currentPage,
    required this.lastPage,
  });

  factory PaginatedProductosResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<ProductoModel> productosList = list.map((i) => ProductoModel.fromJson(i)).toList();

    return PaginatedProductosResponse(
      productos: productosList,
      currentPage: json['current_page'],
      lastPage: json['last_page'],
    );
  }
}

// Modelo para un solo Producto
class ProductoModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int cantidadDisponible;
  final String? urlImagen;
  final VendedorModel vendedor; // Objeto anidado
  final CategoriaModel categoria; // Objeto anidado

  ProductoModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.cantidadDisponible,
    this.urlImagen,
    required this.vendedor,
    required this.categoria,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      // El precio viene como String desde Laravel, lo convertimos a double
      precio: double.parse(json['precio']),
      cantidadDisponible: json['cantidad_disponible'],
      urlImagen: json['url_imagen'],
      vendedor: VendedorModel.fromJson(json['vendedor']),
      categoria: CategoriaModel.fromJson(json['categoria']),
    );
  }
}

// Modelo simple para el Vendedor anidado
class VendedorModel {
  final int id;
  final String nombreTienda;

  VendedorModel({required this.id, required this.nombreTienda});

  factory VendedorModel.fromJson(Map<String, dynamic> json) {
    return VendedorModel(
      id: json['id'],
      nombreTienda: json['nombre_tienda'],
    );
  }
}

// Modelo simple para la Categoria anidada
class CategoriaModel {
  final int id;
  final String nombre;

  CategoriaModel({required this.id, required this.nombre});

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}