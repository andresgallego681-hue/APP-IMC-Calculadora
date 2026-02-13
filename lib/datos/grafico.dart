import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class GraficoIMC {
  static const String _historialKey = 'historialIMC';
  static const String _apiUrl = 'https://quickchart.io/chart/create'; 

  /// Carga el historial y envía los datos a la API para generar el gráfico
  static Future<String> generarGraficoIMC() async {
    final prefs = await SharedPreferences.getInstance();
    final historial = prefs.getStringList(_historialKey) ?? [];

    if (historial.isEmpty) {
      throw Exception("No hay datos en el historial de IMC");
    }

    // Decodificar y ordenar por fecha
    final datos = historial.map((e) => jsonDecode(e)).toList();
    datos.sort((a, b) =>
        DateFormat('dd/MM/yyyy HH:mm').parse(a['fecha']).compareTo(
              DateFormat('dd/MM/yyyy HH:mm').parse(b['fecha']),
            ));

    // Extraer etiquetas (fechas) y valores (IMC)
    final labels = datos.map((e) => e['fecha'].toString().split(' ')[0]).toList();
    final valores = datos.map((e) => double.parse(e['imc'])).toList();

    // Configuración del gráfico (Chart.js)
    final chartConfig = {
      "type": "line",
      "data": {
        "labels": labels,
        "datasets": [
          {
            "label": "Evolución del IMC",
            "data": valores,
            "borderColor": "orange",
            "fill": false,
            "tension": 0.3
          }
        ]
      },
      "options": {
        "title": {"display": true, "text": "Historial de IMC"},
        "scales": {"y": {"beginAtZero": true}}
      }
    };

    // Enviar solicitud a la API de QuickChart
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "chart": chartConfig,
        "backgroundColor": "white",
        "width": 800,
        "height": 400,
        "format": "png",
      }),
    );

    if (response.statusCode == 200) {
      // La API responde con un JSON que contiene la URL del gráfico
      final data = jsonDecode(response.body);
      final chartUrl = data['url'] as String;
      print("✅ Gráfico generado en: $chartUrl");
      return chartUrl;
    } else {
      throw Exception("Error al generar gráfico (${response.statusCode}): ${response.body}");
    }
  }

  /// Recibe el nuevo registro y actualiza el gráfico con la API
  static Future<void> actualizarGraficoConRegistro(
      Map<String, dynamic> nuevoRegistro) async {
    print("📈 Enviando nuevo registro a la API para actualizar gráfico...");
    final url = await generarGraficoIMC();
    print("URL actualizada del gráfico: $url");
    // Aquí podrías guardar la URL en SharedPreferences si quieres usarla luego
  }
}
