// lib/Modelos/CartItemModel.dart
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';

class CartItemModel {
  final ProductoModel producto;
  int cantidad; // La cantidad sí puede cambiar

  CartItemModel({
    required this.producto,
    this.cantidad = 1, // Por defecto, se añade 1
  });
}