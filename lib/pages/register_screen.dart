import 'package:cliente/maps/maps.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _apellido = '';
  String _email = '';
  String _telefono = '';
  String _password = '';
  String _direccion = 'Selecciona tu dirección';
  LatLng? _selectedLocation; // Aquí guardaremos las coordenadas seleccionadas

  Future<void> _openMapScreen() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => MapScreen(),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
        _direccion =
            'Lat: ${_selectedLocation!.latitude}, Lng: ${_selectedLocation!.longitude}';
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final response = await http.post(
      Uri.parse('http://192.168.1.100:8000/api/usuario'),
      body: {
        'nombre': _nombre,
        'apellido': _apellido,
        'email': _email,
        'direccion': _direccion, // Enviar las coordenadas como dirección
        'telefono': _telefono,
        'password': _password,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Registro exitoso
      print('Usuario registrado');
    } else {
      // Manejo de error
      print('Error al registrar usuario: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value!.isEmpty) return 'Ingresa tu nombre';
                  return null;
                },
                onSaved: (value) => _nombre = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Apellido'),
                validator: (value) {
                  if (value!.isEmpty) return 'Ingresa tu apellido';
                  return null;
                },
                onSaved: (value) => _apellido = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@'))
                    return 'Ingresa un email válido';
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) return 'Ingresa tu teléfono';
                  return null;
                },
                onSaved: (value) => _telefono = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Ingresa tu contraseña';
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _openMapScreen, // Abre la pantalla del mapa
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: [
                      Icon(Icons.location_on),
                      SizedBox(width: 10),
                      Expanded(child: Text(_direccion)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
