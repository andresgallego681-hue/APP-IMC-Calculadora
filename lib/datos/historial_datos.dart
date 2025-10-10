import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';


class HistorialDatos {
  /// Clave para almacenar el historial en SharedPreferences
  static const String _historialKey = 'historialIMC';

  /// Agregar un nuevo registro al historial
  static Future<void> agregarRegistro({
    required double peso,
    required double altura,
    required double imc,
    required String categoria,
    required bool esMetrico, 
  }) async {
    // Obtener instancia de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
// Cargar el historial existente o iniciar uno nuevo
    final historial = prefs.getStringList(_historialKey) ?? [];

    //aplicar formato a la fecha y hora actual
    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

// Crear el nuevo registro como un mapa
    final registro = {
      "peso": peso.toStringAsFixed(2),
      "altura": altura.toStringAsFixed(2),
      "imc": imc.toStringAsFixed(2),
      "categoria": categoria,
      "fecha": fecha,
       "unidadPeso": esMetrico ? "kg" : "lbs",
  "unidadAltura": esMetrico ? "cm" : "in",
    };
// Convertir el registro a JSON y agregarlo al historial
    historial.add(jsonEncode(registro));

    // Guardar el historial actualizado
    await prefs.setStringList(_historialKey, historial);

    print("Registro guardado: $registro");
    print("Historial completo: $historial");
  }

  /// Cargar historial completo como lista de mapas
  static Future<List<Map<String, dynamic>>> cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();

    // Obtener la lista de registros en formato JSON
    final historial = prefs.getStringList(_historialKey) ?? [];

    // Convertir cada registro JSON a un mapa
    return historial.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList();
  }
}
