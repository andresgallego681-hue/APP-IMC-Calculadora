import 'package:flutter/material.dart';
import 'package:app_bmi/Interfaz/calculo.dart';
import 'package:app_bmi/Logica/logica_registro.dart';
import 'package:app_bmi/widgets/Registro_widgets.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  // clave del formulario para validaciones
  final _formKey = GlobalKey<FormState>();
  // controladores de los campos de texto
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();

// instancia de la lógica de registro
  final _logic = RegistroLogica();

  bool _ocultarClave = true; // oculta o muestra la contraseña
  bool _cargando = false; // indica si se está procesando el registro

//Valida que el correo no esté vacío y tenga formato tipo usuario@dominio.com.
  String? _validarCorreo(String? value) {
    if (value == null || value.isEmpty) return 'Por favor ingresa tu correo';
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

  String? _noVacio(String? value, String msg) {
    if (value == null || value.trim().isEmpty) return msg;
    return null;
  }
  Future<void> _registrar() async {

//verificar que el formulario sea válido
    if (!_formKey.currentState!.validate()) return;

// iniciar el proceso de registro llamando a la lógica de registro
    setState(() => _cargando = true);
    final error = await _logic.registrarUsuario(
      nombre: _nombreCtrl.text.trim(),
      apellido: _apellidoCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      clave: _claveCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _cargando = false);

// manejar el resultado del registro
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado con éxito')),
      );

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const calculo()),
        (route) => false,
      );
    } else {
      // mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  // liberar los controladores al destruir el widget
  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _correoCtrl.dispose();
    _claveCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF6EEF9),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF6EEF9),
          foregroundColor: Colors.black,
          title: const Text('Crear cuenta'),
          centerTitle: true,
        ),
        // ---------- BODY ----------
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: bottomInset > 0 ? 16 : 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight -
                      (bottomInset > 0 ? bottomInset : 0),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.disabled,
                        child: Column(
                          children: [
                            // Nombre
                            RegistroWidgets.campoNombre(
                              controller: _nombreCtrl,
                              validator: (v) => _noVacio(v, 'Ingresa tu nombre'),
                            ),
                            const SizedBox(height: 12),

                            // Apellido
                            RegistroWidgets.campoApellido(
                              controller: _apellidoCtrl,
                              validator: (v) => _noVacio(v, 'Ingresa tu apellido'),
                            ),
                            const SizedBox(height: 12),

                            // Correo
                            RegistroWidgets.campoCorreo(
                              controller: _correoCtrl,
                              validator: _validarCorreo,
                            ),
                            const SizedBox(height: 12),

                            // Contraseña
                            RegistroWidgets.campoClave(
                              controller: _claveCtrl,
                              obscureText: _ocultarClave,
                              onToggleVisibility: () =>
                                  setState(() => _ocultarClave = !_ocultarClave),
                              validator: _validarClave,
                            ),
                            const SizedBox(height: 24),

                            // Botón principal
                            RegistroWidgets.botonRegistrarme(
                              texto: 'Registrarme',
                              cargando: _cargando,
                              onPressed: _registrar,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
