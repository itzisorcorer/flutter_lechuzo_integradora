// lib/Modelos/OrdenModel.dart
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart'; // ¡Reutilizamos los modelos que ya tenemos!

// Modelo para la respuesta de paginación completa
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

// Modelo para una sola Orden
class OrdenModel {
  final int id;
  final String status;
  final double cantidadTotal;
  final VendedorModel vendedor; // ¡Reutilizamos VendedorModel!
  final List<ItemsOrdenModel> itemsOrdenes;

  OrdenModel({
    required this.id,
    required this.status,
    required this.cantidadTotal,
    required this.vendedor,
    required this.itemsOrdenes,
  });

  factory OrdenModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items_ordenes'] as List;
    List<ItemsOrdenModel> items = itemsList.map((i) => ItemsOrdenModel.fromJson(i)).toList();

    return OrdenModel(
      id: json['id'],
      status: json['status'],
      cantidadTotal: double.parse(json['cantidad_total'].toString()),
      vendedor: VendedorModel.fromJson(json['vendedor']),
      itemsOrdenes: items,
    );
  }
}

// Modelo para los items dentro de una orden
class ItemsOrdenModel {
  final int cantidad;
  final double precioDeCompra;
  final ProductoModel producto; // ¡El producto que se compró!

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