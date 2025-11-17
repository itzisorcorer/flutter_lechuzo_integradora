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
  //función checkout para pagar
  Future<String> checkout() async{
    final token = Ambiente.token;
    if(token.isEmpty){
      throw Exception('No estas autenticado. Error.');
    }
    if(_items.isEmpty){
      throw Exception('El carrito esta vacío.');
    }

    _isLoading = true;
    notifyListeners();

    try{
      //Convertimos el carrito al JSON que espera Laravel
      final List<Map<String, dynamic>> itemsJson = _items.map((item){
        return {
          'producto_id': item.producto.id,
          'cantidad': item.cantidad,
        };
      }).toList();

      final bodyCheckout = {
        'items': itemsJson,
      };

      //Llamamos a /api/checkout
      final urlCheckout = Uri.parse('${Ambiente.urlServer}/api/checkout');
      final responseCheckout = await http.post(
        urlCheckout,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept' : 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyCheckout),
      );

      print('Respuesta de Checkout: ${responseCheckout.statusCode}');
      print('Cuerpo: ${responseCheckout.body}');

      // 2. Verificamos si la creación de la orden fue exitosa
      if(responseCheckout.statusCode != 201) {
        // Si falló, lanzamos el error y paramos
        final errorBody = jsonDecode(responseCheckout.body);
        throw Exception(errorBody['message'] ?? 'Error al crear el pedido');
      }
      //si es 201...
      final dataCheckout = jsonDecode(responseCheckout.body);
      final List<int> ordenIds = List<int>.from(dataCheckout['orden_ids']);

      if(ordenIds.isEmpty){
        throw Exception('El backend no devolvió IDs de orden');
      }

      // 4. Creamos la preferencia MP (solo para la primera orden)
      final primerOrdenId = ordenIds.first;
      final initPoint = await _crearPreferenciaMP(primerOrdenId, token);


      vaciarCarrito(); // Esto llama a notifyListeners()
      return initPoint;

    }catch(e){

      _isLoading = false;
      notifyListeners();
      throw e;
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

