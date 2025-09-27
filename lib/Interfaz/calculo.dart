import 'package:app_bmi/logica/imc.dart';
import 'package:app_bmi/datos/historial_datos.dart';
import 'package:app_bmi/datos/preferencias_usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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


  @override
  void initState() {
    super.initState();
    _cargarUnidadGuardada();
   // HistorialDatos.borrarHistorial();
  }

  /// Calcula IMC y lo guarda en el historial
  Future<void> realizarCalculos() async {
    final double? peso = double.tryParse(pesoController.text);
    final double? altura = double.tryParse(alturaController.text);

    if (peso != null && altura != null && altura > 0) {
      imc = calcularIMC(
        peso: peso,
        altura: altura,
        esMetrico: unidadSeleccionada,
      );
      final clasificacion = clasificarIMC(imc);

      // Guardar en historial
      await HistorialDatos.agregarRegistro(
        peso: peso,
        altura: altura,
        imc: imc,
        categoria: clasificacion,
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

  /// Cargar preferencia del switch desde archivo
  Future<void> _cargarUnidadGuardada() async {
    final unidad = await PreferenciasUsuario.cargarUnidadSeleccionada();
    setState(() {
      unidadSeleccionada = unidad;
    });
  }

  /// Guardar preferencia del switch en archivo
  Future<void> _guardarUnidadSeleccionada(bool value) async {
    await PreferenciasUsuario.guardarUnidadSeleccionada(value);
  }

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
              if(categoria.isNotEmpty)
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
              if(recomendacion.isNotEmpty)
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
    );
  }

  /// Campo de texto reutilizable
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
      ),
    );
  }

  /// Switch para cambiar entre sistema métrico/imperial
  Widget buildSwitch() {
    return SwitchListTile(
      title: Text(unidadSeleccionada ? 'sistema internacional' : 'sistema imperial'),
      value: unidadSeleccionada,
      onChanged: (bool value) {
        setState(() {
          final peso = double.tryParse(pesoController.text);
          final altura = double.tryParse(alturaController.text);

         
        if (peso != null) {
          pesoController.text = cambiopeso(peso, value).toStringAsFixed(2);
        }

        if (altura != null) {
          alturaController.text = cambioaltura(altura, value).toStringAsFixed(2);
        }

          unidadSeleccionada = value;
        });

        //Guardar preferencia en archivo
        _guardarUnidadSeleccionada(value);
      },
    );
  }
}
