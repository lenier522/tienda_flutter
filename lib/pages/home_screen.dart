import 'package:cliente/pages_screen/carrito.dart';
import 'package:cliente/pages_screen/favorito.dart';
import 'package:cliente/pages_screen/inicio.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'dart:convert'; // Para manejar JSON
import 'package:shared_preferences/shared_preferences.dart'; // Para usar SharedPreferences

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<dynamic> _favoritos = []; // Lista de favoritos

  // Método para cargar favoritos desde SharedPreferences
  void _cargarFavoritos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favoritosJson = prefs.getString('favoritos');
    
    if (favoritosJson != null) {
      setState(() {
        _favoritos = jsonDecode(favoritosJson);
      });
    }
  }

  // Método para guardar los favoritos en SharedPreferences
  void _guardarFavoritos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String favoritosJson = jsonEncode(_favoritos);
    await prefs.setString('favoritos', favoritosJson);
  }

  @override
  void initState() {
    super.initState();
    _cargarFavoritos(); // Cargar favoritos al iniciar la app
  }

  // Método para actualizar la página seleccionada en el BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Método para actualizar los favoritos y guardar los cambios
  void _actualizarFavoritos(producto) {
    setState(() {
      if (_favoritos.contains(producto)) {
        _favoritos.remove(producto);
      } else {
        _favoritos.add(producto);
      }
      _guardarFavoritos(); // Guardar favoritos cuando se actualicen
    });
  }

  // Lista de opciones de pantalla
  List<Widget> _widgetOptions() {
    return <Widget>[
      InicioPage(
        onFavoritoChanged: _actualizarFavoritos, // Pasar la función para actualizar los favoritos
      ),
      const Center(child: Text('Buscar', style: TextStyle(fontSize: 24))),
      CarritoPage(),
      FavoritosPage(favoritos: _favoritos),
      const Center(child: Text('Perfil', style: TextStyle(fontSize: 24))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecommerce App'),
      ),
      body: _widgetOptions().elementAt(_selectedIndex), // Llamamos el método para obtener la lista de opciones
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent, // Fondo del cuerpo
        color: const Color.fromARGB(255, 17, 113, 223), // Color de la barra de navegación
        buttonBackgroundColor: Colors.orange, // Color del botón flotante
        height: 60, // Altura de la barra de navegación
        animationCurve: Curves.easeInOutCubicEmphasized,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.search, size: 30, color: Colors.white),
          Icon(Icons.shopping_cart, size: 30, color: Colors.white),
          Icon(Icons.favorite, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        onTap: _onItemTapped, // Se utiliza la función _onItemTapped para cambiar de página
      ),
    );
  }
}
