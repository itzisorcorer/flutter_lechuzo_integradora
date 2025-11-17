// lib/Modelos/OrdenModel.dart
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';

class PaginatedOrdenesResponse {
  final List<OrdenModel> ordenes;
  final int currentPage;
  final int lastPage;

  PaginatedOrdenesResponse({
    required this.ordenes,
    required this.currentPage,
    required this.lastPage,
  });

  factory PaginatedOrdenesResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<OrdenModel> ordenesList = list.map((i) => OrdenModel.fromJson(i)).toList();

    return PaginatedOrdenesResponse(
      ordenes: ordenesList,
      currentPage: json['current_page'],
      lastPage: json['last_page'],
    );
  }
}

class OrdenModel {
  final int id;
  final String status;
  final double cantidadTotal;
  final VendedorModel? vendedor; // <-- Ahora es opcional (para el flujo de vendedor)
  final EstudianteModel? estudiante; // <-- Nuevo (para saber quién compró)
  final List<ItemsOrdenModel> itemsOrdenes;

  OrdenModel({
    required this.id,
    required this.status,
    required this.cantidadTotal,
    this.vendedor,
    this.estudiante,
    required this.itemsOrdenes,
  });

  factory OrdenModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items_ordenes'] as List;
    List<ItemsOrdenModel> items = itemsList.map((i) => ItemsOrdenModel.fromJson(i)).toList();

    return OrdenModel(
      id: json['id'],
      status: json['status'],
      cantidadTotal: double.parse(json['cantidad_total'].toString()),
      // Revisamos si vienen en el JSON antes de parsear
      vendedor: json['vendedor'] != null ? VendedorModel.fromJson(json['vendedor']) : null,
      estudiante: json['estudiante'] != null ? EstudianteModel.fromJson(json['estudiante']) : null,
      itemsOrdenes: items,
    );
  }
}

class ItemsOrdenModel {
  final int cantidad;
  final double precioDeCompra;
  final ProductoModel producto;

  ItemsOrdenModel({
    required this.cantidad,
    required this.precioDeCompra,
    required this.producto,
  });

  factory ItemsOrdenModel.fromJson(Map<String, dynamic> json) {
    return ItemsOrdenModel(
      cantidad: json['cantidad'],
      precioDeCompra: double.parse(json['precio_de_compra'].toString()),
      producto: ProductoModel.fromJson(json['producto']),
    );
  }
}

//MODELO DE ESTUDIANTE
class EstudianteModel {
  final int id;
  final String nombreCompleto;
  // final String matricula; // Puedes agregarla si la necesitas

  EstudianteModel({required this.id, required this.nombreCompleto});

  factory EstudianteModel.fromJson(Map<String, dynamic> json) {
    return EstudianteModel(
      id: json['id'],
      nombreCompleto: json['nombre_completo'],
    );
  }
}