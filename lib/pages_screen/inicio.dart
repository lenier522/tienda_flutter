import 'package:cliente/producto_detalle/producto_detalle.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InicioPage extends StatefulWidget {
  final Function(dynamic) onFavoritoChanged; // Añadir el parámetro

  const InicioPage({super.key, required this.onFavoritoChanged}); // Constructor

  @override
  // ignore: library_private_types_in_public_api
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  List<dynamic> _productos = [];
  List<dynamic> _categorias = [];
  String _selectedCategoria =
      'Todos'; // Por defecto, la categoría seleccionada es "Todos"
  bool isLoadingProductos = true;
  bool isLoadingCategorias = true;

  // Lista para almacenar los productos favoritos
  List<dynamic> _favoritos = [];

  @override
  void initState() {
    super.initState();
    fetchProductos();
    fetchCategorias();
    loadFavoritos(); // Cargar favoritos al iniciar la app
  }

  Future<void> fetchProductos() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.100:8000/api/producto'));

    if (response.statusCode == 200) {
      final List<dynamic> productos = json.decode(response.body);
      if (mounted) {
        // Verificar si el widget sigue montado
        setState(() {
          _productos = productos;
          isLoadingProductos = false;
        });
      }
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  Future<void> fetchCategorias() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.100:8000/api/categoria'));

    if (response.statusCode == 200) {
      final List<dynamic> categorias = json.decode(response.body);
      if (mounted) {
        // Verificar si el widget sigue montado
        setState(() {
          _categorias = categorias.map((categoria) {
            return {
              'nombre': categoria['nombre'].toString(),
              'descripcion': categoria['descripcion'].toString(),
            };
          }).toList();

          // Añadir la categoría 'Todos' al principio
          _categorias.insert(0, {'nombre': 'Todos', 'descripcion': ''});

          isLoadingCategorias = false;
        });
      }
    } else {
      throw Exception('Error al cargar categorías');
    }
  }

  // Función para filtrar productos por categoría seleccionada
  List<dynamic> get _productosFiltrados {
    if (_selectedCategoria == 'Todos') {
      return _productos; // Si "Todos" está seleccionada, mostrar todos los productos
    } else {
      return _productos.where((producto) {
        return producto['categoria'] != null &&
            producto['categoria']['nombre'] == _selectedCategoria;
      }).toList();
    }
  }

  // Función para agregar o quitar productos de favoritos
  void toggleFavorito(dynamic producto) {
    setState(() {
      if (esFavorito(producto)) {
        _favoritos.removeWhere(
            (p) => p['id'] == producto['id']); // Quitar de favoritos
      } else {
        _favoritos.add(producto); // Agregar a favoritos
      }
      saveFavoritos(); // Guardar favoritos en SharedPreferences
    });
  }

  // Comprobar si un producto es favorito
  bool esFavorito(dynamic producto) {
    return _favoritos.any((p) => p['id'] == producto['id']);
  }

  // Guardar favoritos en SharedPreferences
  Future<void> saveFavoritos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String favoritosJson = jsonEncode(_favoritos);
    await prefs.setString('favoritos', favoritosJson);
  }

  // Cargar favoritos desde SharedPreferences
  Future<void> loadFavoritos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? favoritosJson = prefs.getString('favoritos');
    if (favoritosJson != null && mounted) {
      // Verificar si el widget sigue montado
      setState(() {
        _favoritos = jsonDecode(favoritosJson);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slider Carousel - Siempre mostrará todos los productos, independientemente de la categoría seleccionada
            isLoadingProductos
                ? const Center(child: CircularProgressIndicator())
                : _productos.isEmpty
                    ? const Center(child: Text('No hay productos disponibles.'))
                    : Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 175,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            aspectRatio: 16 / 9,
                            enableInfiniteScroll: true,
                            autoPlayInterval: const Duration(seconds: 3),
                          ),
                          // Aquí usamos la lista completa de productos (_productos)
                          items: _productos.map((producto) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Stack(
                                      children: <Widget>[
                                        Image.network(
                                          'http://192.168.1.100:8000/storage/${producto['imagen']}',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 185,
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          left: 10,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                producto['titulo'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  shadows: [
                                                    Shadow(
                                                      blurRadius: 10.0,
                                                      color: Colors.black,
                                                      offset: Offset(2, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '\$${producto['precio'].toString()}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  shadows: [
                                                    Shadow(
                                                      blurRadius: 10.0,
                                                      color: Colors.black,
                                                      offset: Offset(2, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),

            // Título de la sección de categorías
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Mostrar categorías con scroll horizontal
            isLoadingCategorias
                ? const Center(child: CircularProgressIndicator())
                : _categorias.isEmpty
                    ? const Center(
                        child: Text('No hay categorías disponibles.'))
                    : Container(
                        height: 50, // Altura definida para las categorías
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // Scroll horizontal
                          child: Row(
                            children: _categorias.map((categoria) {
                              final bool isSelected =
                                  categoria['nombre'] == _selectedCategoria;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategoria = categoria['nombre'];
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Chip(
                                    label: Text(categoria['nombre']),
                                    backgroundColor: isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.transparent,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

            // Productos filtrados por categoría seleccionada
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Productos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            isLoadingProductos
                ? const Center(child: CircularProgressIndicator())
                : _productosFiltrados.isEmpty
                    ? const Center(
                        child: Text('No hay productos para esta categoría.'))
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0), // Añadir margen
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 600, // Establecer un límite de altura
                          ),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _productosFiltrados.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 0.8, // Ajustar el aspect ratio
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              final producto = _productosFiltrados[index];
                              final bool favorito = esFavorito(producto);

                              return GestureDetector(
                                onTap: () {
                                  // Mostrar detalles del producto al hacer clic
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductoDetallePage(
                                          producto: producto),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 4.0,
                                  child: Stack(
                                    children: <Widget>[
                                      // Imagen del producto
                                      Column(
                                        children: <Widget>[
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                      top: Radius.circular(15)),
                                              child: Image.network(
                                                'http://192.168.1.100:8000/storage/${producto['imagen']}',
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  producto['titulo'],
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '\$${producto['precio'].toString()}',
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Botón de favorito
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: GestureDetector(
                                          onTap: () {
                                            toggleFavorito(producto);
                                          },
                                          child: Icon(
                                            favorito
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: favorito
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
