// lib/Interfaz/login_view.dart
import 'package:app_bmi/Interfaz/calculo.dart';
import 'package:flutter/material.dart';
import 'package:app_bmi/Interfaz/calculo_inivitado.dart';
import 'package:app_bmi/Interfaz/registro_usaurios/registro_view.dart';
import 'package:app_bmi/logica/logic_login.dart';
import  'package:app_bmi/widgets/login_view_widgets.dart';
import 'package:app_bmi/datos/shared_preferences/preferencias_sesion.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
  // validar los campos del formulario
  final _formKey = GlobalKey<FormState>();
  // instantiar la lógica de login
  final _logic = LoginLogic();

  bool _obscurePassword = true;  // oculta o muestra la contraseña
  bool _cargando = false;         // indica si se está procesando el login

//Valida que el correo no esté vacío y tenga formato tipo usuario@dominio.com.
  String? _validarCorreo(String? value) {
    if (value == null || value.isEmpty) return 'Por favor ingresa tu correo';
// expresión regular para validar formato de correo
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!regex.hasMatch(value)) return 'Formato de correo no válido';
    return null;
  }
//valida que la contraseña tenga mínimo 6 caracteres.
  String? _validarClave(String? value) {
    if (value == null || value.isEmpty) return 'Por favor ingresa tu contraseña';
    if (value.length < 6) return 'Debe tener al menos 6 caracteres';
    return null;
  }

  Future<void> _iniciarSesion() async {
    //verificar que el formulario sea válido
    if (!_formKey.currentState!.validate()) return;

// iniciar el proceso de login llamar a la lógica de login
    setState(() => _cargando = true);
    final error = await _logic.iniciarSesion(
      correo: _correoController.text.trim(),
      clave: _claveController.text.trim(),
      verificarPerfil: false,
    );
    // finalizar el proceso de carga
    if (!mounted) return;
    setState(() => _cargando = false);

// si no hay error, guardar estado de sesión en SharedPreferences
    if (error == null) {
      await PreferenciasSesion.setLogueado(true);
// mostrar mensaje de bienvenida
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Bienvenido!')),
      );

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

// navegar a la pantalla principal
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const calculo()),
        (route) => false,
      );
      // si hay error, mostrar mensaje
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

// navegar a la pantalla de registro
  void _irARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PantallaRegistro()),
    );
  }
// navegar como invitado
  void _continuarComoInvitado() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalculoInvitado()),
    );
  }

// limpiar los controladores al cerrar la pantalla es decir libera memoria
  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; // alto del teclado

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // cerrar teclado al tocar fuera
      child: Scaffold(
        resizeToAvoidBottomInset: true, // empuja el body cuando aparece el teclado
        backgroundColor: const Color(0xFFF6EEF9),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF6EEF9),
          foregroundColor: Colors.black,
          title: const Text("Bienvenido a la Calculadora de IMC"),
          centerTitle: true,
        ),

        // ---------- BODY SCROLLABLE ----------
      
        body: LayoutBuilder(
          builder: (context, constraints) {
            // el SingleChildScrollView permite desplazar el contenido cuando el teclado está abierto
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                // dar espacio extra cuando el teclado aparece
                bottom: bottomInset > 0 ? 16 : 32,
              ),
            
              // Asegura que el contenido ocupe al menos la altura visible
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - (bottomInset > 0 ? bottomInset : 0)),

                // mide el contenido para centrarlo verticalmente
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // -------- FORM --------
                      // formulario de login
                       Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Campo de correo
                                LoginWidgets.campoCorreo(
                                  controller: _correoController,
                                  validator: _validarCorreo,
                                ),
                                const SizedBox(height: 16),

                                // Campo de contraseña
                                LoginWidgets.campoClave(
                                  controller: _claveController,
                                  obscureText: _obscurePassword,
                                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                                  validator: _validarClave,
                                ),
                                const SizedBox(height: 24),

                                // Botones de acción iniciar sesión
                                LoginWidgets.botonIniciarSesion(
                                  cargando: _cargando,
                                  onPressed: _iniciarSesion,
                                ),
                                const SizedBox(height: 12),
                                // Botón registrarse
                                LoginWidgets.botonRegistrarse(
                                  onPressed: _irARegistro,
                                ),
                              ],
                            ),
                          ),

                      const Spacer(), // empuja el contenido hacia arriba si hay espacio
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // botón continuar como invitado
        bottomNavigationBar: LoginWidgets.botonContinuarInvitado(
            onPressed: _continuarComoInvitado,
            bottomInset: bottomInset,
          ),
      ),
    );
  }
 
}
