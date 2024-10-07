import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductoDetallePage extends StatefulWidget {
  final dynamic producto;
  final int cantidadSeleccionada;
  final bool esModoEdicion; // Nuevo parámetro para indicar si es edición o no

  const ProductoDetallePage({
    Key? key,
    required this.producto,
    this.cantidadSeleccionada = 1,
    this.esModoEdicion = false, // Por defecto, no es modo edición
  }) : super(key: key);

  @override
  _ProductoDetallePageState createState() => _ProductoDetallePageState();
}

class _ProductoDetallePageState extends State<ProductoDetallePage> {
  late int cantidadSeleccionada;
  double totalPrecio = 0.0;

  @override
  void initState() {
    super.initState();
    cantidadSeleccionada = widget.cantidadSeleccionada;
    _actualizarTotal();
  }

  void _actualizarTotal() {
    setState(() {
      try {
        totalPrecio = cantidadSeleccionada * double.parse(widget.producto['precio']);
      } catch (e) {
        totalPrecio = 0.0;
      }
    });
  }

  void _agregarAlCarrito() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? carritoJson = prefs.getString('carrito');
    List<dynamic> carrito = carritoJson != null ? jsonDecode(carritoJson) : [];

    Map<String, dynamic> productoCarrito = {
      'id': widget.producto['id'],
      'titulo': widget.producto['titulo'],
      'descripcion': widget.producto['descripcion'],
      'precio': widget.producto['precio'],
      'imagen': widget.producto['imagen'],
      'cantidad': widget.producto['cantidad'],
      'cantidadSe':cantidadSeleccionada
    };

    bool existe = false;
    for (var producto in carrito) {
      if (producto['id'] == widget.producto['id']) {
         producto['cantidadSe'] = cantidadSeleccionada;
        existe = true;
        break;
      }
    }

    if (!existe) {
      carrito.add(productoCarrito);
    }

    await prefs.setString('carrito', jsonEncode(carrito));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.esModoEdicion
            ? 'Producto actualizado en el carrito'
            : 'Producto agregado al carrito'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.producto['titulo'],
                style: const TextStyle(color: Colors.white),
              ),
              background: Image.network(
                'http://192.168.1.100:8000/storage/${widget.producto['imagen']}',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    widget.producto['titulo'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${widget.producto['precio'].toString()}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Muestra la cantidad disponible obtenida desde InicioPage
                  Text(
                    'Cantidad disponible: ${widget.producto['cantidad'].toString()}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.producto['descripcion'],
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Cantidad:',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (cantidadSeleccionada > 1) {
                            setState(() {
                              cantidadSeleccionada--;
                              _actualizarTotal();
                            });
                          }
                        },
                      ),
                      Text(
                        '$cantidadSeleccionada',
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (cantidadSeleccionada < widget.producto['cantidad']) {
                            setState(() {
                              cantidadSeleccionada++;
                              _actualizarTotal();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: \$${totalPrecio.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      ElevatedButton(
                        onPressed: _agregarAlCarrito,
                        child: Text(widget.esModoEdicion
                            ? 'Actualizar producto'
                            : 'Agregar al carrito'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
