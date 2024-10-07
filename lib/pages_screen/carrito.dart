import 'package:cliente/producto_detalle/producto_detalle.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CarritoPage extends StatefulWidget {
  const CarritoPage({Key? key}) : super(key: key);

  @override
  _CarritoPageState createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  List<dynamic> _carrito = [];

  List<int?> _ids = [];
  List<String> _titulos = [];
  List<String> _descripcion = [];
  List<double> _precios = [];
  List<int> _cantidades = [];
  List<String> _imagenes = [];

  void _cargarCarrito() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? carritoJson = prefs.getString('carrito');

    if (carritoJson != null) {
      setState(() {
        _carrito = jsonDecode(carritoJson);

        _ids.clear();
        _titulos.clear();
        _descripcion.clear();
        _precios.clear();
        _cantidades.clear();
        _imagenes.clear();

        for (var producto in _carrito) {
          _ids.add(producto['id']);
          _titulos.add(producto['titulo']);
          _descripcion.add(producto['descripcion']);
          _precios.add(double.tryParse(producto['precio'].toString()) ?? 0.0);
          _cantidades.add(producto['cantidadSe'] ?? 0);
          _imagenes.add(producto['imagen']);
        }
      });
    }
  }

  void _guardarCarrito() async {
    List<Map<String, dynamic>> carrito = [];
    for (int i = 0; i < _ids.length; i++) {
      carrito.add({
        'id': _ids[i],
        'titulo': _titulos[i],
        'descripcion': _descripcion[i],
        'precio': _precios[i],
        'cantidadSe': _cantidades[i],
        'imagen': _imagenes[i],
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('carrito', jsonEncode(carrito));
  }

  void _removerDelCarrito(int index) {
    setState(() {
      _ids.removeAt(index);
      _titulos.removeAt(index);
      _descripcion.removeAt(index);
      _precios.removeAt(index);
      _cantidades.removeAt(index);
      _imagenes.removeAt(index);
    });
    _guardarCarrito();
  }

  void _navegarADetalleProducto(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoDetallePage(
          producto: _carrito[index],
          esModoEdicion: true,
          cantidadSeleccionada: _cantidades[index],
        ),
      ),
    ).then((_) {
      _cargarCarrito(); // Recargar el carrito cuando volvemos de la pantalla de detalle
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ids.isEmpty
          ? const Center(
              child: Text('El carrito está vacío'),
            )
          : ListView.builder(
              itemCount: _ids.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(
                    'http://192.168.1.100:8000/storage/${_imagenes[index]}',
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(_titulos[index]),
                  subtitle: Text(
                      'Cantidad: ${_cantidades[index]} | Total: \$${(_precios[index] * _cantidades[index]).toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navegarADetalleProducto(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removerDelCarrito(index),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
