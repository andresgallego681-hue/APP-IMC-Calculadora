import 'package:flutter/material.dart';
import 'package:app_bmi/Logica/imc.dart';
import 'package:app_bmi/datos/historial_datos.dart';
import 'package:app_bmi/datos/preferencias_usuario.dart';
import 'package:app_bmi/datos/shared_preferences/preferencias_sesion.dart';
import 'package:app_bmi/Interfaz/historialview.dart';
import 'package:app_bmi/Interfaz/grafico_imc_view.dart';
import 'package:app_bmi/Interfaz/registro_usaurios/login_view.dart';
import 'package:app_bmi/widgets/widgets_calculo.dart';

// Servicio Firebase (asegurá el path)
import 'package:app_bmi/datos/firebase/usuario_registo.dart';

class calculo extends StatefulWidget {
  const calculo({super.key});

  @override
  State<calculo> createState() => _CalculoState();
}

class _CalculoState extends State<calculo> {

 //controladores de texto para los campos de entrada
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();

  // Estado de unidad (true = SI kg/cm, false = imperial lb/in)
  bool unidadSeleccionada = true;

  // Base SI (kg / cm) – fuente de verdad para cálculos
  double? pesoBaseKg;
  double? alturaBaseCm;

  // Resultados
  double? _imc;
  String _resultado = '';
  String _categoria = '';
  String _recomendacion = '';

  // Repo Firebase
  final UsuarioRegisto _repo = UsuarioRegisto();

  @override
  void initState() {
    super.initState();
    _cargarUnidadGuardada();
    _ensureLoggedIn();
  }

// verifica si el usuario está logueado
  Future<void> _ensureLoggedIn() async {
    final isLogged = await PreferenciasSesion.estaLogueado();
    //un usuario no está logueado, redirigir a la pantalla de login
    if (!isLogged) {
      // Navegación después del primer frame para evitar problemas de contexto
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // limpia la pila de navegación y va a LoginView
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      });
    }
  }

// carga la unidad guardada en preferencias de usuario
  Future<void> _cargarUnidadGuardada() async {
    final unidad = await PreferenciasUsuario.cargarUnidadSeleccionada();
    if (!mounted) return;
    setState(() => unidadSeleccionada = unidad);
  }

// guarda la unidad seleccionada en preferencias de usuario
  Future<void> _guardarUnidadSeleccionada(bool value) async {
    await PreferenciasUsuario.guardarUnidadSeleccionada(value);
  }

  // actualiza los valores base kg/cm desde los campos de texto
  void _actualizarValoresBaseDesdeCampos() {
    final vals = actualizarValoresBase(
      pesoTexto: pesoController.text,
      alturaTexto: alturaController.text,
      esMetrico: unidadSeleccionada,
    );
    pesoBaseKg = vals[0];
    alturaBaseCm = vals[1];
  }

// maneja cambios en los campos de texto
  void _onChangeCampos(String _) {
    setState(() {
      _actualizarValoresBaseDesdeCampos();
      // Limpiamos resultados si el input se invalida
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

// maneja el cambio de unidad (kg/cm <-> lb/in)
  void _cambiarUnidad(bool value) {
    setState(() {
      // Antes, actualizamos base para no perder info
      _actualizarValoresBaseDesdeCampos();
      unidadSeleccionada = value;

      // Reflejamos conversión en los campos visibles
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

    _guardarUnidadSeleccionada(value);
  }

// habilita el botón "Calcular" solo si los inputs son válidos
  bool get _inputsOk => inputsSonValidos(
        pesoTexto: pesoController.text,
        alturaTexto: alturaController.text,
        esMetrico: unidadSeleccionada,
      );

  // realiza los cálculos de IMC y guarda el registro
  Future<void> realizarCalculos() async {
    _actualizarValoresBaseDesdeCampos();
    if (pesoBaseKg == null || alturaBaseCm == null || alturaBaseCm! <= 0) {
      setState(() {
        _imc = null;
        _resultado = 'Por favor ingrese sus datos.';
        _categoria = '';
        _recomendacion = '';
      });
      return;
    }

// logica del imc y clasificación
    final valorIMC = calcularIMCDesdeBase(
      pesoBaseKg: pesoBaseKg,
      alturaBaseCm: alturaBaseCm,
    );
    final clasificacion = clasificarIMC(valorIMC);

    // Valores visibles segun unidad para guardar en tu historial local
    final vis = valoresVisiblesDesdeBase(
      pesoBaseKg: pesoBaseKg,
      alturaBaseCm: alturaBaseCm,
      esMetrico: unidadSeleccionada,
    );

    // Guardado local
    await HistorialDatos.agregarRegistro(
      peso: vis.pesoVisible ?? 0,
      altura: vis.alturaVisible ?? 0,
      imc: valorIMC,
      categoria: clasificacion,
      esMetrico: unidadSeleccionada,
    );

    // Guardado en Firestore (base normalizada SI)
    try {
      await _repo.agregarRegistroIMC(
        imc: valorIMC,
        categoria: clasificacion,
        pesoKg: pesoBaseKg!,
        alturaCm: alturaBaseCm!,
        pesoVisible: vis.pesoVisible ?? 0,
        alturaVisible: vis.alturaVisible ?? 0,
        esMetricoVisible: unidadSeleccionada,
      );
    } on Exception catch (e) {
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

// Actualización de UI
    setState(() {
      _imc = valorIMC;
      _resultado = 'Tu IMC es: ${valorIMC.toStringAsFixed(2)}';
      _categoria = 'Tu IMC se considera: $clasificacion';
      _recomendacion = recomendacionesSalud(clasificacion);
    });
  }

// maneja el cierre de sesión
  Future<void> _logout() async {
    await PreferenciasSesion.cerrarSesion();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Calculadora IMC'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Colors.black,
        elevation: 1,
        // botón de cerrar sesión
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
                // switch de unidad
                UnidadSwitch(
                  value: unidadSeleccionada,
                  onChanged: _cambiarUnidad,
                ),
                // Campo de peso
                CampoNumerico(
                  controller: pesoController,
                  label: unidadSeleccionada ? 'Peso (kg)' : 'Peso (lb)',
                  onChanged: _onChangeCampos,
                ),
                // Campo de altura
                CampoNumerico(
                  controller: alturaController,
                  label: unidadSeleccionada ? 'Altura (cm)' : 'Altura (in)',
                  onChanged: _onChangeCampos,
                ),
                const SizedBox(height: 8),
                  // botón calcular que se habilita solo si los inputs son válidos
                ElevatedButton(
                  onPressed: _inputsOk ? realizarCalculos : null,
                  child: const Text('Calcular IMC'),
                ),
                const SizedBox(height: 16),
// mostrar resultados
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
      // botones  flotantes para historial y gráfico
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
}

