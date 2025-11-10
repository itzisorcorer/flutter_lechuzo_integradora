// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
      ),
      body: const Center(
        child: Text(
          'Aquí irán los productos de tu carrito 🛒',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}