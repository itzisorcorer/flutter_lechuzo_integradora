// lib/services/cart_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/Modelos/CartItemModel.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';


class CartService extends ChangeNotifier {


  final List<CartItemModel> _items = [];
  List<CartItemModel> get items => _items;


  double get total {
    return _items.fold(0.0, (sum, item) {
      return sum + (item.producto.precio * item.cantidad);
    });
  }


  void agregarProducto(ProductoModel producto, {int cantidadAAgregar = 1}) {

    final itemExistente = _items.cast<CartItemModel?>().firstWhere(
          (item) => item?.producto.id == producto.id,
      orElse: () => null,
    );

    if (itemExistente != null) {
      itemExistente.cantidad += cantidadAAgregar;
    } else {
      _items.add(CartItemModel(
        producto: producto,
        cantidad: cantidadAAgregar,
      ));
    }

    notifyListeners();

    print('🛒 CARRITO ACTUALIZADO: Total a pagar: \$${total.toStringAsFixed(2)}');
  }


  void removerProducto(CartItemModel item) {
    _items.remove(item);
    notifyListeners();
  }

  void incrementarCantidad(CartItemModel item) {
    item.cantidad++;
    notifyListeners();
  }

  void decrementarCantidad(CartItemModel item) {
    if (item.cantidad > 1) {
      item.cantidad--;
      notifyListeners();
    } else {
      removerProducto(item);
    }
  }

  void vaciarCarrito() {
    _items.clear();
    notifyListeners();
  }
}