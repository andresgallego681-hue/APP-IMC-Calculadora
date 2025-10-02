import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';


class HistorialDatos {
  static const String _historialKey = 'historialIMC';

  /// Agregar un nuevo registro al historial
  static Future<void> agregarRegistro({
    required double peso,
    required double altura,
    required double imc,
    required String categoria,
    required bool esMetrico, 
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final historial = prefs.getStringList(_historialKey) ?? [];
    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final registro = {
      "peso": peso.toStringAsFixed(2),
      "altura": altura.toStringAsFixed(2),
      "imc": imc.toStringAsFixed(2),
      "categoria": categoria,
      "fecha": fecha,
       "unidadPeso": esMetrico ? "kg" : "lbs",
  "unidadAltura": esMetrico ? "cm" : "in",
    };

    historial.add(jsonEncode(registro));
    await prefs.setStringList(_historialKey, historial);

    print("Registro guardado: $registro");
    print("Historial completo: $historial");
  }

  /// Cargar historial completo como lista de mapas
  static Future<List<Map<String, dynamic>>> cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final historial = prefs.getStringList(_historialKey) ?? [];

    return historial.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList();
  }
}
