import 'package:app_bmi/Logica/imc.dart';
import 'package:app_bmi/datos/historial_datos.dart';
import 'package:app_bmi/datos/preferencias_usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_bmi/Interfaz/historialview.dart';

class calculo extends StatefulWidget {
  const calculo({super.key});

  @override
  State<calculo> createState() => _CalculoState();
}

class _CalculoState extends State<calculo> {
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();

  late double imc;
  bool unidadSeleccionada = true; // true = métrico (kg/cm), false = imperial (lbs/in)

  String resultado = '', categoria = '', recomendacion = '';


  double? pesoBase;   // en kg
  double? alturaBase; // en cm

  @override
  void initState() {
    super.initState();
    _cargarUnidadGuardada();

  }

  /// Actualiza los valores base en sistema métrico
  void _actualizarValoresBase() {
  final valores = actualizarValoresBase(
    pesoTexto: pesoController.text,
    alturaTexto: alturaController.text,
    esMetrico: unidadSeleccionada,
  );

  pesoBase = valores[0];
  alturaBase = valores[1];
}

  
  /// Cambiar de unidad
  void _cambiarUnidad(bool value) {
    setState(() {
      unidadSeleccionada = value;

      if (pesoBase != null) {
        pesoController.text = value
            ? pesoBase!.toStringAsFixed(2) // kg
            : (pesoBase! / 0.453592).toStringAsFixed(2); // lb
      }

      if (alturaBase != null) {
        alturaController.text = value
            ? alturaBase!.toStringAsFixed(2) // cm
            : (alturaBase! / 2.54).toStringAsFixed(2); // in
      }
    });

    _guardarUnidadSeleccionada(value);
  }

  /// Calcular IMC
  Future<void> realizarCalculos() async {
    _actualizarValoresBase(); 

    if (pesoBase != null && alturaBase != null && alturaBase! > 0) {
      imc = calcularIMC(
        peso: pesoBase!,   // usamos siempre en kg
        altura: alturaBase!, // usamos siempre en cm
        esMetrico: true,
      );

      final clasificacion = clasificarIMC(imc);

      // Guardar en historial
      await HistorialDatos.agregarRegistro(
        peso: pesoBase!,
        altura: alturaBase!,
        imc: imc,
        categoria: clasificacion,
        esMetrico: unidadSeleccionada,
      );

      setState(() {
        resultado = 'Tu IMC es: ${imc.toStringAsFixed(2)}';
        categoria = 'Tu imc se considera: $clasificacion';
        recomendacion = recomendacionesSalud(clasificacion);
      });
    } else {
      setState(() {
        resultado = 'Por favor ingrese sus datos.';
        categoria = '';
        recomendacion = '';
      });
    }
  }

  /// Cargar preferencia
  Future<void> _cargarUnidadGuardada() async {
    final unidad = await PreferenciasUsuario.cargarUnidadSeleccionada();
    setState(() {
      unidadSeleccionada = unidad;
    });
  }

  /// Guardar preferencia
  Future<void> _guardarUnidadSeleccionada(bool value) async {
    await PreferenciasUsuario.guardarUnidadSeleccionada(value);
  }

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Calculadora IMC')),
    body: Center(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildSwitch(),
            _buildCampos(
              controller: pesoController,
              label: unidadSeleccionada ? 'Peso (kg)' : 'Peso (lbs)',
            ),
            _buildCampos(
              controller: alturaController,
              label: unidadSeleccionada ? 'Altura (cm)' : 'Altura (in)',
            ),
            ElevatedButton(
              onPressed: realizarCalculos,
              child: Text('Calcular IMC'),
            ),
            SizedBox(height: 16),
            Text(
              resultado,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (categoria.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue, width: 1.5),
                ),
                child: Text(
                  'Categoría: $categoria',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            if (recomendacion.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 1.5),
                ),
                child: Text(
                  'Recomendación: $recomendacion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistorialView()),
        );
      },
      backgroundColor: Colors.blue,
      child: const Icon(Icons.history),
    ),
  );
}

  /// Campo de texto
  Widget _buildCampos({required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
        onChanged: (_) => _actualizarValoresBase(), // 🔹 Se actualizan los valores base
      ),
    );
  }

  /// Switch dentro de la clase
  Widget buildSwitch() {
    return SwitchListTile(
      title: Text(unidadSeleccionada ? 'Sistema internacional' : 'Sistema imperial'),
      value: unidadSeleccionada,
      onChanged: _cambiarUnidad,
    );
  }
}
