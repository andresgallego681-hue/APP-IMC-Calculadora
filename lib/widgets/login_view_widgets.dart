import 'package:flutter/material.dart';

class LoginWidgets {
  // Campo de correo
  static Widget campoCorreo({
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: "Correo electrónico",
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
      // validación del campo
      validator: validator,
    );
  }

  //  Campo de contraseña
  static Widget campoClave({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      // ocultar o mostrar la contraseña
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: "Contraseña",
        prefixIcon: const Icon(Icons.lock_outline),
        border: const OutlineInputBorder(),
        //finaliza el ícono para mostrar u ocultar la contraseña
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator,
    );
  }

  //  Botón principal: Iniciar sesión
  static Widget botonIniciarSesion({
    required bool cargando,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        // deshabilitar el botón si está cargando
        onPressed: cargando ? null : onPressed,
        child: cargando
            ? const CircularProgressIndicator()
            : const Text("Iniciar Sesión"),
      ),
    );
  }

  // Botón secundario: Registrarse
  static Widget botonRegistrarse({
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        child: const Text("Registrarse"),
      ),
    );
  }

  //  Botón inferior: Continuar sin registrar
  static Widget botonContinuarInvitado({
    required VoidCallback onPressed,
    required double bottomInset,
  }) {
    // SafeArea para evitar que sea tapado por el teclado
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          // se añade espacio inferior si el teclado está visible
          bottom: bottomInset > 0 ? bottomInset : 12,
          top: 8,
        ),
        child: TextButton(
          onPressed: onPressed,
          child: const Text(
            "Continuar sin registrar",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
