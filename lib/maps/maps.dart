import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona tu ubicación'),
        actions: [
          if (_pickedLocation != null)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                // Regresar a la pantalla anterior con la ubicación seleccionada
                Navigator.of(context).pop(_pickedLocation);
              },
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(23.10261145078899, -82.33272368671817), // Coordenadas iniciales
          zoom: 16,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          _getUserLocation(); // Mueve el mapa a la ubicación actual del usuario
        },
        onTap: _selectLocation, // Selecciona la ubicación con un toque en el mapa
        markers: (_pickedLocation == null)
            ? {}
            : {
                Marker(
                  markerId: MarkerId('selected-location'),
                  position: _pickedLocation!,
                ),
              },
      ),
    );
  }
}
