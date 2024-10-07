import 'package:cliente/service/favorito_service.dart';
import 'package:flutter/material.dart';

class FavoritosPage extends StatefulWidget {

  final List<dynamic> favoritos; // Asegúrate de que este campo esté presente

  FavoritosPage({required this.favoritos}); // Constructor

  @override
  _FavoritosPageState createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<dynamic> favoritos = [];

  @override
  void initState() {
    super.initState();
    _cargarFavoritos(); // Cargar los favoritos al iniciar la pantalla
  }

  // Función para cargar los favoritos desde SharedPreferences
  void _cargarFavoritos() async {
    List<dynamic> favoritosCargados = await FavoritosService.cargarFavoritos();
    setState(() {
      favoritos = favoritosCargados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: favoritos.isEmpty
          ? Center(child: Text('No tienes productos favoritos aún.'))
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: GridView.builder(
                itemCount: favoritos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15.0,
                  mainAxisSpacing: 15.0,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final producto = favoritos[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              'http://192.168.1.100:8000/storage/${producto['imagen']}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            producto['titulo'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '\$${producto['precio'].toString()}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
