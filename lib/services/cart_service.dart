// lib/services/cart_service.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_lechuzo_integradora/Modelos/CartItemModel.dart';
import 'package:flutter_lechuzo_integradora/Modelos/ProductoModel.dart';
import 'package:flutter_lechuzo_integradora/Ambiente/ambiente.dart';
import 'package:http/http.dart' as http;


class CartService extends ChangeNotifier {


  final List<CartItemModel> _items = [];
  List<CartItemModel> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;




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
//Devuelve una Lista de Enteros (IDs de las órdenes creadas)
  Future<List<int>> checkout() async {
    final token = Ambiente.token;
    if (token.isEmpty) throw Exception('No estas autenticado. Error.');
    if (_items.isEmpty) throw Exception('El carrito esta vacío.');

    _isLoading = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> itemsJson = _items.map((item) {
        return {
          'producto_id': item.producto.id,
          'cantidad': item.cantidad,
        };
      }).toList();

      final bodyCheckout = {'items': itemsJson};

      final urlCheckout = Uri.parse('${Ambiente.urlServer}/api/checkout');
      final responseCheckout = await http.post(
        urlCheckout,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyCheckout),
      );

      if (responseCheckout.statusCode != 201) {
        final errorBody = jsonDecode(responseCheckout.body);
        throw Exception(errorBody['message'] ?? 'Error al crear el pedido');
      }

      final dataCheckout = jsonDecode(responseCheckout.body);
      // Obtenemos TODOS los IDs, no solo el primero
      final List<int> ordenIds = List<int>.from(dataCheckout['orden_ids']);

      if (ordenIds.isEmpty) {
        throw Exception('El backend no devolvió IDs de orden');
      }

      // Vaciamos el carrito local porque las órdenes ya existen en BD
      vaciarCarrito();

      _isLoading = false;
      notifyListeners();

      return ordenIds; // Retornamos la lista para que la Pantalla decida qué hacer

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<String> obtenerLinkDePago(int ordenId) async {
    final token = Ambiente.token;
    final urlPago = Uri.parse('${Ambiente.urlServer}/api/pagos/crear-preferencia/$ordenId');

    final responsePago = await http.post(
      urlPago,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (responsePago.statusCode == 201) {
      final dataPago = jsonDecode(responsePago.body);
      return dataPago['init_point'];
    } else {
      throw Exception('Error al generar el pago para la orden #$ordenId');
    }
  }


  Future<String> _crearPreferenciaMP(int ordenId, String token) async{
    final urlPago = Uri.parse('${Ambiente.urlServer}/api/pagos/crear-preferencia/$ordenId');
    final responsePago = await http.post(
      urlPago,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('Respuesta de MP: ${responsePago.body}');
    if(responsePago.statusCode == 201){
      final dataPago = jsonDecode(responsePago.body);
      return dataPago['init_point'];
    }else{
      throw Exception('Error al crear el link de mercado Pago');
    }
  }



}

