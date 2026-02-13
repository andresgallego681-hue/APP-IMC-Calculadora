import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasSesion {
  // Clave para almacenar el estado de sesión en SharedPreferences
  static const _kIsLoggedIn = 'isLoggedIn';

/// Verifica si el usuario está logueado devuelve true si está logueado, false si no
  static Future<bool> estaLogueado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsLoggedIn) ?? false;
  }
  /// Establece el estado de sesión del usuario
  static Future<void> setLogueado(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsLoggedIn, value);
  }
/// Cierra la sesión del usuario cambiando el estado en SharedPreferences a false
  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsLoggedIn, false);
  }
}
