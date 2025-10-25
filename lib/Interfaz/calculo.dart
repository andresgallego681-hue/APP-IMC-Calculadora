import 'package:app_bmi/Logica/imc.dart';
import 'package:app_bmi/datos/historial_datos.dart';
import 'package:app_bmi/datos/preferencias_usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_bmi/Interfaz/historialview.dart';
import 'package:app_bmi/Interfaz/grafico_imc_view.dart';
import 'package:app_bmi/Interfaz/registro_usaurios/login_view.dart';
import 'package:app_bmi/datos/shared_preferences/preferencias_sesion.dart';

// >>> Servicio de Firebase (verificá el path)
import 'package:app_bmi/datos/firebase/usuario_registo.dart';

class calculo extends StatefulWidget {
  const calculo({super.key});

  @override
  State<calculo> createState() => _CalculoState();
}

class _CalculoState extends State<calculo> {
  // Controladores
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();

  // Repo Firebase
  final UsuarioRegisto _repo = UsuarioRegisto();

  late double imc;
  bool unidadSeleccionada = true; // true = métrico (kg/cm), false = imperial (lb/in)
  String resultado = '', categoria = '', recomendacion = '';

  /// Valores base normalizados (kg / cm)
  double? pesoBase;
  double? alturaBase;

  @override
  void initState() {
    super.initState();
    _cargarUnidadGuardada();
    _ensureLoggedIn();
  }

  /// Verifica sesión y redirige si no está logueado
  Future<void> _ensureLoggedIn() async {
    final isLogged = await PreferenciasSesion.estaLogueado();
    if (!isLogged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      });
    }
  }

  /// Convierte y actualiza valores base (kg/cm) a partir de los campos visibles
  void _actualizarValoresBase() {
    final valores = actualizarValoresBase(
      pesoTexto: pesoController.text,
      alturaTexto: alturaController.text,
      esMetrico: unidadSeleccionada,
    );
    pesoBase = valores[0];
    alturaBase = valores[1];
  }

  /// Cambiar métrico/imperial
  void _cambiarUnidad(bool value) {
    setState(() {
      unidadSeleccionada = value;

      if (pesoBase != null) {
        // Si pasa a métrico: mostrar kg; si pasa a imperial: mostrar lb
        pesoController.text =
            value ? pesoBase!.toStringAsFixed(2) : (pesoBase! / 0.453592).toStringAsFixed(2);
      }

      if (alturaBase != null) {
        // Si pasa a métrico: mostrar cm; si pasa a imperial: mostrar in
        alturaController.text =
            value ? alturaBase!.toStringAsFixed(2) : (alturaBase! / 2.54).toStringAsFixed(2);
      }
    });

    _guardarUnidadSeleccionada(value);
  }

  /// Calcular, clasificar y guardar (local + Firestore por UID)
  Future<void> realizarCalculos() async {
    _actualizarValoresBase();

    if (pesoBase != null && alturaBase != null && alturaBase! > 0) {
      // IMC siempre en métrico (kg/cm)
      imc = calcularIMC(peso: pesoBase!, altura: alturaBase!, esMetrico: true);
      final clasificacion = clasificarIMC(imc);

      // Valores visibles según unidad seleccionada
      final double pesoParaGuardar =
          unidadSeleccionada ? pesoBase! : (pesoBase! / 0.453592); // lb si imperial
      final double alturaParaGuardar =
          unidadSeleccionada ? alturaBase! : (alturaBase! / 2.54); // in si imperial

      // Guardado local (tu lógica existente)
      await HistorialDatos.agregarRegistro(
        peso: pesoParaGuardar,
        altura: alturaParaGuardar,
        imc: imc,
        categoria: clasificacion,
        esMetrico: unidadSeleccionada,
      );

      // Guardado en Firestore ligado al UID del usuario
      try {
        await _repo.agregarRegistroIMC(
          imc: imc,
          categoria: clasificacion,
          pesoKg: pesoBase!,           // normalizado
          alturaCm: alturaBase!,       // normalizado
          pesoVisible: pesoParaGuardar,
          alturaVisible: alturaParaGuardar,
          esMetricoVisible: unidadSeleccionada,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro guardado en la nube ✅')),
        );
      } on Exception catch (e) {
        // Si no hay auth, se informa y se ofrece ir al login
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo guardar en la nube: $e'),
            action: SnackBarAction(
              label: 'Iniciar sesión',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
              },
            ),
          ),
        );
      }

      setState(() {
        resultado = 'Tu IMC es: ${imc.toStringAsFixed(2)}';
        categoria = 'Tu IMC se considera: $clasificacion';
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

  /// Cargar preferencia de unidad
  Future<void> _cargarUnidadGuardada() async {
    final unidad = await PreferenciasUsuario.cargarUnidadSeleccionada();
    if (!mounted) return;
    setState(() {
      unidadSeleccionada = unidad;
    });
  }

  /// Guardar preferencia de unidad
  Future<void> _guardarUnidadSeleccionada(bool value) async {
    await PreferenciasUsuario.guardarUnidadSeleccionada(value);
  }

  /// Cerrar sesión (local + Firebase)
  Future<void> _logout() async {
    // Cierra sesión local
    await PreferenciasSesion.cerrarSesion();
    // Cierra sesión Firebase (por si acaso)
    try {
      await _repo.cerrarSesion();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Calculadora IMC'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
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
                buildSwitch(),

                _buildCampos(
                  controller: pesoController,
                  label: unidadSeleccionada ? 'Peso (kg)' : 'Peso (lb)',
                ),
                _buildCampos(
                  controller: alturaController,
                  label: unidadSeleccionada ? 'Altura (cm)' : 'Altura (in)',
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: realizarCalculos,
                  child: const Text('Calcular IMC'),
                ),
                const SizedBox(height: 16),

                Text(
                  resultado,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'grafico',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GraficoIMCView()),
              );
            },
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.show_chart),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'historial',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistorialView()),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.history),
          ),
        ],
      ),
    );
  }

  /// Campo de texto numérico
  Widget _buildCampos({required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        onChanged: (_) => _actualizarValoresBase(),
      ),
    );
  }

  /// Switch unidades
  Widget buildSwitch() {
    return SwitchListTile(
      title: Text(unidadSeleccionada ? 'Sistema internacional' : 'Sistema imperial'),
      value: unidadSeleccionada,
      onChanged: _cambiarUnidad,
    );
  }
}
