import 'dart:convert'; // Para convertir el JSON
import 'package:shared_preferences/shared_preferences.dart';

class FavoritosService {
  // Cargar los favoritos desde SharedPreferences
  static Future<List<dynamic>> cargarFavoritos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favoritosJson = prefs.getString('favoritos');
    
    if (favoritosJson != null) {
      return jsonDecode(favoritosJson);
    } else {
      return [];
    }
  }

  // Guardar los favoritos en SharedPreferences
  static Future<void> guardarFavoritos(List<dynamic> favoritos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String favoritosJson = jsonEncode(favoritos);
    await prefs.setString('favoritos', favoritosJson);
  }
}
