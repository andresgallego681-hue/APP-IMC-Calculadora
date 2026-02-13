import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Switch reutilizable para cambiar entre sistema internacional e imperial
class UnidadSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String tituloSI;
  final String tituloImperial;
// constructor del switch
  const UnidadSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.tituloSI = 'Sistema internacional (kg / cm)',
    this.tituloImperial = 'Sistema imperial (lb / in)',
  });

//retorna el switch
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(value ? tituloSI : tituloImperial),
      value: value,
      onChanged: onChanged,
    );
  }
}

/// Campo numérico reutilizable (solo números/decimal)
class CampoNumerico extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final String? hint;

// constructor del campo numérico
  const CampoNumerico({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
    this.hint,
  });

//retorna el campo numérico
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        // teclado numérico con punto decimal
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          // solo permitir números y un punto decimal
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
          hintText: hint,
        ),
        //captura cambios en el campo
        onChanged: onChanged,
      ),
    );
  }
}

/// Panel de resultados (IMC, categoría y recomendación) reutilizable
class ResultadosIMC extends StatelessWidget {
  final String resultado;       
  final String categoria;       
  final String recomendacion;   

//constructor
  const ResultadosIMC({
    super.key,
    required this.resultado,
    required this.categoria,
    required this.recomendacion,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    if (resultado.isNotEmpty) {
      children.add(
        Text(
          resultado,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }
    // agregar categoría si está disponible

    if (categoria.isNotEmpty) {
      children.add(
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 1.5),
          ),
          child: Text(
            'Categoría: $categoria',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade900,
            ),
          ),
        ),
      );
    }
// agregar recomendación si está disponible
    if (recomendacion.isNotEmpty) {
      children.add(
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green, width: 1.5),
          ),
          child: Text(
            'Recomendación: $recomendacion',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade900,
            ),
          ),
        ),
      );
    }

    if (children.isEmpty) return const SizedBox.shrink();
// retorna la columna con los resultados
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
