import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {
  /// Clave para almacenar la unidad seleccionada en SharedPreferences
  static const String _unidadKey = 'unidadSeleccionada';

  /// Guarda si se usa sistema métrico (true) o imperial (false)
  static Future<void> guardarUnidadSeleccionada(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_unidadKey, value);
  }

  /// Carga la unidad seleccionada, por defecto true (métrico)
  static Future<bool> cargarUnidadSeleccionada() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_unidadKey) ?? true;
  }
}
