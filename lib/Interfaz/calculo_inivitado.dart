import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_bmi/Logica/imc.dart'; // Reutiliza tus funciones calcularIMC, clasificarIMC, recomendacionesSalud
import 'package:app_bmi/Interfaz/registro_usaurios/login_view.dart';

class CalculoInvitado extends StatefulWidget {
  const CalculoInvitado({super.key});

  @override
  State<CalculoInvitado> createState() => _CalculoInvitadoState();
}

class _CalculoInvitadoState extends State<CalculoInvitado> {
  // Controladores de texto
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();

  // true = métrico (kg/cm), false = imperial (lb/in)
  bool unidadSeleccionada = true;

  // Valores base siempre en sistema métrico (kg / cm) para el cálculo
  double? pesoBaseKg;
  double? alturaBaseCm;

  // Resultados
  double? imc;
  String resultado = '';
  String categoria = '';
  String recomendacion = '';

  // ---- Helpers locales ----
  /// Lee los campos y actualiza los valores base en sistema métrico (kg/cm)
  void _actualizarValoresBase() {
    final pesoTxt = pesoController.text.replaceAll(',', '.').trim();
    final alturaTxt = alturaController.text.replaceAll(',', '.').trim();

    final pesoNum = double.tryParse(pesoTxt);
    final alturaNum = double.tryParse(alturaTxt);

    if (pesoNum == null || alturaNum == null) {
      pesoBaseKg = null;
      alturaBaseCm = null;
      return;
    }

    if (unidadSeleccionada) {
      // Métrico: ya vienen en kg y cm
      pesoBaseKg = pesoNum;
      alturaBaseCm = alturaNum;
    } else {
      // Imperial: lb -> kg, in -> cm
      pesoBaseKg = pesoNum * 0.453592;
      alturaBaseCm = alturaNum * 2.54;
    }
  }

  /// Cambiar entre sistema métrico e imperial convirtiendo los valores mostrados
  void _cambiarUnidad(bool value) {
    setState(() {
      // Primero asegúrate de tener valores base actualizados
      _actualizarValoresBase();
      unidadSeleccionada = value;

      // Si tenemos base, reflejar conversión en los campos
      if (pesoBaseKg != null) {
        pesoController.text = value
            ? pesoBaseKg!.toStringAsFixed(2) // kg
            : (pesoBaseKg! / 0.453592).toStringAsFixed(2); // lb
      }
      if (alturaBaseCm != null) {
        alturaController.text = value
            ? alturaBaseCm!.toStringAsFixed(2) // cm
            : (alturaBaseCm! / 2.54).toStringAsFixed(2); // in
      }
    });
  }

  /// Realiza el cálculo del IMC y muestra resultados (NO guarda nada)
  void _realizarCalculos() {
    _actualizarValoresBase();

    if (pesoBaseKg != null && alturaBaseCm != null && alturaBaseCm! > 0) {
      final valorIMC = calcularIMC(
        peso: pesoBaseKg!,     // kg
        altura: alturaBaseCm!, // cm
        esMetrico: true,
      );

      final clas = clasificarIMC(valorIMC);
      final rec = recomendacionesSalud(clas);

      setState(() {
        imc = valorIMC;
        resultado = 'Tu IMC es: ${valorIMC.toStringAsFixed(2)}';
        categoria = 'Tu IMC se considera: $clas';
        recomendacion = rec;
      });
    } else {
      setState(() {
        imc = null;
        resultado = 'Por favor ingresa tus datos correctamente.';
        categoria = '';
        recomendacion = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
  title: const Text('Calculadora IMC (Invitado)'),
  backgroundColor: Theme.of(context).colorScheme.surface,
  foregroundColor: Colors.black,
  elevation: 1,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    tooltip: 'Volver',
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    },
  ),
),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Switch unidades
                SwitchListTile(
                  title: Text(
                    unidadSeleccionada
                        ? 'Sistema internacional (kg / cm)'
                        : 'Sistema imperial (lb / in)',
                  ),
                  value: unidadSeleccionada,
                  onChanged: _cambiarUnidad,
                ),

                // Campos de entrada
                _buildCampo(
                  controller: pesoController,
                  label: unidadSeleccionada ? 'Peso (kg)' : 'Peso (lb)',
                ),
                _buildCampo(
                  controller: alturaController,
                  label: unidadSeleccionada ? 'Altura (cm)' : 'Altura (in)',
                ),
                const SizedBox(height: 8),

                // Botón calcular
                ElevatedButton(
                  onPressed: _realizarCalculos,
                  child: const Text('Calcular IMC'),
                ),
                const SizedBox(height: 16),

                // Resultados
                if (resultado.isNotEmpty)
                  Text(
                    resultado,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                if (categoria.isNotEmpty)
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

                if (recomendacion.isNotEmpty)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCampo({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        onChanged: (_) => _actualizarValoresBase(),
      ),
    );
  }
}
