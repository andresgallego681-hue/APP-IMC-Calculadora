import 'package:app_bmi/Logica/imc.dart';
import 'package:app_bmi/datos/historial_datos.dart';
import 'package:app_bmi/datos/preferencias_usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_bmi/Interfaz/historialview.dart';


/// Pantalla de cálculo del IMC es stateful paor que los datos cambian de manera dinamica
class calculo extends StatefulWidget {
  const calculo({super.key});

  @override
  State<calculo> createState() => _CalculoState();
}
/// Estado del widget de cálculo
class _CalculoState extends State<calculo> {

  // Controladores para los campos de texto
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();

  late double imc;
  bool unidadSeleccionada = true; // true = métrico (kg/cm), false = imperial (lbs/in)
 String resultado = '', categoria = '', recomendacion = '';

/// Valores base en sistema guradado (kg/cm) para conversiones
  double? pesoBase;   
  double? alturaBase; 

//estado inicial
  @override
  void initState() {
    super.initState();
    _cargarUnidadGuardada();

  }

  /// Convierte los valores ingresados (dependiendo de la unidad seleccionada)
  /// y actualiza las variables base en sistema métrico (kg / cm).
  void _actualizarValoresBase() {
  final valores = actualizarValoresBase(
    pesoTexto: pesoController.text,
    alturaTexto: alturaController.text,
    esMetrico: unidadSeleccionada,
  );

  pesoBase = valores[0];
  alturaBase = valores[1];
}

  
  
  /// cambiar entre sistema métrico e imperial (Switch).
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

    /// Calcula el IMC, clasifica el resultado y guarda el registro en el historial.
  Future<void> realizarCalculos() async {
  _actualizarValoresBase();

  if (pesoBase != null && alturaBase != null && alturaBase! > 0) {
    // Calcular IMC siempre en sistema métrico
    imc = calcularIMC(
      peso: pesoBase!,   // en kg
      altura: alturaBase!, // en cm
      esMetrico: true,
    );

    final clasificacion = clasificarIMC(imc);

    // Guardar en historial según sistema seleccionado
    double pesoParaGuardar = unidadSeleccionada
        ? pesoBase!                         // métrico (kg)
        : pesoBase! / 0.453592;              // imperial (lb)

    double alturaParaGuardar = unidadSeleccionada
        ? alturaBase!                        // métrico (cm)
        : alturaBase! / 2.54;                // imperial (in)

    // Guardar el registro en el historial
    await HistorialDatos.agregarRegistro(
      peso: pesoParaGuardar,
      altura: alturaParaGuardar,
      imc: imc,
      categoria: clasificacion,
      esMetrico: unidadSeleccionada,
    );
// Actualizar la interfaz con el resultado
    setState(() {
      resultado = 'Tu IMC es: ${imc.toStringAsFixed(2)}';
      categoria = 'Tu IMC se considera: $clasificacion';
      recomendacion = recomendacionesSalud(clasificacion);
    });
  } else {
    // Manejar caso de entrada inválida
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

// Construcción de la interfaz
 @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true, // evita que el teclado cause overflow
    appBar: AppBar(title: const Text('Calculadora IMC')),
    body: GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(), // Cierra el teclado al tocar fuera
  child: SafeArea(
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24, 
        // deja espacio suficiente para el teclado
      ),
      //columna principal
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildSwitch(),// Switch para cambiar unidades

          // Campos de entrada
          _buildCampos(
            controller: pesoController,
            label: unidadSeleccionada ? 'Peso (kg)' : 'Peso (lbs)',
          ),
          _buildCampos(
            controller: alturaController,
            label: unidadSeleccionada ? 'Altura (cm)' : 'Altura (in)',
          ),
          const SizedBox(height: 8),

          // Botón para calcular IMC
          ElevatedButton(
            onPressed: realizarCalculos,
            child: const Text('Calcular IMC'),
          ),
           const SizedBox(height: 16),
           // Resultados
          Text(
            resultado,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // Mostrar categoría y recomendación si están disponibles
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

// Botón flotante para historial
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
        onChanged: (_) => _actualizarValoresBase(), //Se actualizan los valores base
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
