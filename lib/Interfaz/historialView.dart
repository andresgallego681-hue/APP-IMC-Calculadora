import 'package:flutter/material.dart';
import 'package:app_bmi/datos/historial_datos.dart';

class HistorialView extends StatefulWidget {
  const HistorialView({super.key});

  @override
  State<HistorialView> createState() => _HistorialViewState();
}
/// Estado del widget de cálculo
class _HistorialViewState extends State<HistorialView> {
  // Lista para almacenar los registros del historial en formato json
  List<Map<String, dynamic>> historial = [];

// estado inicial
  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  /// Cargar el historial desde SharedPreferences
  Future<void> _cargarHistorial() async {
    final datos = await HistorialDatos.cargarHistorial();
    setState(() {
      historial = List.from(datos.reversed);// Mostrar el más reciente primero
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de IMC')),
      body: historial.isEmpty

      // Mostrar mensaje si no hay registros
          ? const Center(
              child: Text(
                'No hay registros en el historial.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )

          // Mostrar la lista de registros
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: historial.length,
              itemBuilder: (context, index) {

                // Obtener el registro  por su índice
                final registro = historial[index];

                final fecha = registro['fecha'] ?? ''; //  ?? para evitar null
                final peso = registro['peso'] ?? '';
                final altura = registro['altura'] ?? '';
                final imc = registro['imc'] ?? '';
                final categoria = registro['categoria'] ?? '';
                final unidadPeso = registro['unidadPeso'] ?? '';
                final unidadAltura = registro['unidadAltura'] ?? '';

                // Construir la tarjeta del registro
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(

                    // Icono con el valor del IMC
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        imc, 
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    
                    // Título y subtítulo con detalles del registro
                    title: Text('IMC: $imc  •  $categoria'),
                    subtitle: Text(
                      'Peso: $peso $unidadPeso | '
                      'Altura: $altura $unidadAltura\n'
                      '$fecha',
                    ),
                  ),
                );
              },
            ),
    );
  }
}

