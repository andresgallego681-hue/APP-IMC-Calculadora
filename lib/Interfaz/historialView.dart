import 'package:flutter/material.dart';
import 'package:app_bmi/datos/historial_datos.dart';

class HistorialView extends StatefulWidget {
  const HistorialView({super.key});

  @override
  State<HistorialView> createState() => _HistorialViewState();
}

class _HistorialViewState extends State<HistorialView> {
  List<Map<String, dynamic>> historial = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    final datos = await HistorialDatos.cargarHistorial();
    setState(() {
      historial = datos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de IMC')),
      body: historial.isEmpty
          ? const Center(
              child: Text(
                'No hay registros en el historial.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: historial.length,
              itemBuilder: (context, index) {
                final registro = historial[index];

                final fecha = registro['fecha'] ?? '';
                final peso = registro['peso'] ?? '';
                final altura = registro['altura'] ?? '';
                final imc = registro['imc'] ?? '';
                final categoria = registro['categoria'] ?? '';
                final unidadPeso = registro['unidadPeso'] ?? '';
                final unidadAltura = registro['unidadAltura'] ?? '';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        imc, // ya es String
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
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

