// lib/screens/estudiante_main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_lechuzo_integradora/screens/cart_screen.dart';
import 'package:flutter_lechuzo_integradora/screens/home_screen.dart';
import 'package:flutter_lechuzo_integradora/screens/profile_screen.dart';

class EstudianteMainScreen extends StatefulWidget {
  const EstudianteMainScreen({super.key});

  @override
  State<EstudianteMainScreen> createState() => _EstudianteMainScreenState();
}

class _EstudianteMainScreenState extends State<EstudianteMainScreen> {
  // Índice para saber qué pestaña está seleccionada
  int _selectedIndex = 0;


  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), // <-- Tu pantalla con buscador (Índice 0)
    CartScreen(), // <-- La nueva pantalla de carrito (Índice 1)
    ProfileScreen(), // <-- La nueva pantalla de perfil (Índice 2)
  ];

  // Función que se llama cuando tocas un ícono
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El cuerpo de la app es la pantalla que esté seleccionada
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),

      // La barra de navegación
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Tienda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}