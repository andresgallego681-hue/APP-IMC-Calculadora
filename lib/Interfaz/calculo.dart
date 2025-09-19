import 'package:flutter/material.dart';

class calculo extends StatefulWidget {
  const calculo({super.key});

  @override
  State<calculo> createState() => _calculoState();
}

class _calculoState extends State<calculo> {
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();
  String resultado = '';

  void calcularIMC() {
    final double? peso = double.tryParse(pesoController.text);
    final double? alturaCm = double.tryParse(alturaController.text);

    if (peso != null && alturaCm != null && alturaCm > 0) {
      final alturaM = alturaCm / 100;
      final imc = peso / (alturaM * alturaM);
      setState(() {
        resultado = 'Tu IMC es: ${imc.toStringAsFixed(2)}';
      });
    } else {
      setState(() {
        resultado = 'Por favor ingresa valores válidos.';
      });
    }
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: pesoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Peso (kg)',
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
                    labelText: 'Altura (cm)',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: calcularIMC,
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
}