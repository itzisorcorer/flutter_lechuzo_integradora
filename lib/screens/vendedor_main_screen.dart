// lib/screens/vendedor_main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/screens/inbox_screen.dart';
// Importamos las 3 pantallas que usará
import 'package:flutter_lechuzo_integradora/screens/vendedor_home_screen.dart'; // ¡Tu pantalla actual!
import 'package:flutter_lechuzo_integradora/screens/ventas_screen.dart';
import 'package:flutter_lechuzo_integradora/screens/vendedor_profile_screen.dart';

class VendedorMainScreen extends StatefulWidget {
  const VendedorMainScreen({super.key});

  @override
  State<VendedorMainScreen> createState() => _VendedorMainScreenState();
}

class _VendedorMainScreenState extends State<VendedorMainScreen> {
  int _selectedIndex = 0;


  static const List<Widget> _widgetOptions = <Widget>[
    VendedorHomeScreen(), // <-- Tu pantalla de "Mis Productos" (Índice 0)
    VentasScreen(), // <-- La nueva pantalla de Ventas (Índice 1)
    InboxScreen(), // indice 3
    VendedorProfileScreen(), // <-- La nueva pantalla de Perfil (Índice 3)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),


      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Mis Productos',
              backgroundColor: Colors.black
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Ventas',
              backgroundColor: Colors.black
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Mensajes',
              backgroundColor: Colors.black
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront
            ),
            label: 'Perfil',
            backgroundColor: Colors.black,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}