import 'package:flutter/material.dart';
import 'package:app_bmi/Logica/imc.dart';
import 'package:app_bmi/Interfaz/registro_usaurios/login_view.dart';
import 'package:app_bmi/widgets/widgets_calculo.dart';  

class CalculoInvitado extends StatefulWidget {
  const CalculoInvitado({super.key});

  @override
  State<CalculoInvitado> createState() => _CalculoInvitadoState();
}

class _CalculoInvitadoState extends State<CalculoInvitado> {
  // UI
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();

  bool unidadSeleccionada = true; // true = SI, false = imperial

  // Base SI (kg/cm)
  double? pesoBaseKg;
  double? alturaBaseCm;

  // Resultados
  double? _imc;
  String _resultado = '';
  String _categoria = '';
  String _recomendacion = '';

  void _actualizarValoresBaseDesdeCampos() {
    final vals = actualizarValoresBase(
      pesoTexto: pesoController.text,
      alturaTexto: alturaController.text,
      esMetrico: unidadSeleccionada,
    );
    pesoBaseKg = vals[0];
    alturaBaseCm = vals[1];
  }

  void _onChangeCampos(String _) {
    setState(() {
      _actualizarValoresBaseDesdeCampos();
      if (!inputsSonValidos(
        pesoTexto: pesoController.text,
        alturaTexto: alturaController.text,
        esMetrico: unidadSeleccionada,
      )) {
        _resultado = '';
        _categoria = '';
        _recomendacion = '';
        _imc = null;
      }
    });
  }

  void _cambiarUnidad(bool value) {
    setState(() {
      _actualizarValoresBaseDesdeCampos();
      unidadSeleccionada = value;

      final vis = valoresVisiblesDesdeBase(
        pesoBaseKg: pesoBaseKg,
        alturaBaseCm: alturaBaseCm,
        esMetrico: unidadSeleccionada,
      );
      if (vis.pesoVisible != null) {
        pesoController.text = vis.pesoVisible!.toStringAsFixed(2);
      }
      if (vis.alturaVisible != null) {
        alturaController.text = vis.alturaVisible!.toStringAsFixed(2);
      }
    });
  }

  bool get _inputsOk => inputsSonValidos(
        pesoTexto: pesoController.text,
        alturaTexto: alturaController.text,
        esMetrico: unidadSeleccionada,
      );

  void _realizarCalculos() {
    _actualizarValoresBaseDesdeCampos();
    if (pesoBaseKg == null || alturaBaseCm == null || alturaBaseCm! <= 0) {
      setState(() {
        _imc = null;
        _resultado = 'Por favor ingresa tus datos correctamente.';
        _categoria = '';
        _recomendacion = '';
      });
      return;
    }

    final valorIMC = calcularIMCDesdeBase(
      pesoBaseKg: pesoBaseKg,
      alturaBaseCm: alturaBaseCm,
    );
    final clas = clasificarIMC(valorIMC);
    final rec = recomendacionesSalud(clas);

    setState(() {
      _imc = valorIMC;
      _resultado = 'Tu IMC es: ${valorIMC.toStringAsFixed(2)}';
      _categoria = 'Tu IMC se considera: $clas';
      _recomendacion = rec;
    });
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
                UnidadSwitch(
                  value: unidadSeleccionada,
                  onChanged: _cambiarUnidad,
                ),
                CampoNumerico(
                  controller: pesoController,
                  label: unidadSeleccionada ? 'Peso (kg)' : 'Peso (lb)',
                  onChanged: _onChangeCampos,
                ),
                CampoNumerico(
                  controller: alturaController,
                  label: unidadSeleccionada ? 'Altura (cm)' : 'Altura (in)',
                  onChanged: _onChangeCampos,
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: _inputsOk ? _realizarCalculos : null,
                  child: const Text('Calcular IMC'),
                ),
                const SizedBox(height: 16),

                ResultadosIMC(
                  resultado: _resultado,
                  categoria: _categoria,
                  recomendacion: _recomendacion,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
