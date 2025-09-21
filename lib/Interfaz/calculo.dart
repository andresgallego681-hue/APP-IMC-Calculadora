import 'package:app_bmi/Logica/imc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class calculo extends StatefulWidget {
  const calculo({super.key});

  @override
  State<calculo> createState() => _calculoState();
}

class _calculoState extends State<calculo> {
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();
  bool unidadSeleccionada = true; // true para kg/cm, false para lbs/in
  String resultado = '';

    @override
  void initState() {
    super.initState();
    _cargarUnidadGuardada(); 
  }

  Future<void> realizarCalculos() async {
    final double? peso = double.tryParse(pesoController.text);
    final double? altura = double.tryParse(alturaController.text);

    if (peso != null && altura != null && altura > 0) {
      final imc = calcularIMC(
        peso: peso,
        altura: altura,
        esMetrico: unidadSeleccionada,
      );
      setState(() {
        resultado = 'Tu IMC es: ${imc.toStringAsFixed(2)}';
      });
    } else {
      setState(() {
        resultado = 'Por favor ingresa valores válidos.';
      });
    }
  }

  Future<void> _cargarUnidadGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    final unidad = prefs.getBool('unidadSeleccionada');
    if (unidad != null) {
      setState(() {
        unidadSeleccionada = unidad;
      });
    }
  }

  Future<void> _guardarUnidadSeleccionada(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('unidadSeleccionada', value);
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: pesoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: unidadSeleccionada ? 'Peso (kg)' : 'Peso (lbs)',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: alturaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: unidadSeleccionada ? 'Altura (cm)' : 'Altura (in)',
                  ),
                ),
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
            ],
          ),
        ),
      ),
    );
  }
  Widget buildSwitch() {
    return SwitchListTile(
      title: Text(unidadSeleccionada ? 'kg/cm' : 'lbs/in'),
      value: unidadSeleccionada,
      onChanged: (bool value) {
        setState(() {
          unidadSeleccionada = value;
        });
        _guardarUnidadSeleccionada(value); 
      },
    );
  }
}
