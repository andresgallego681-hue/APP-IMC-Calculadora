import 'package:flutter/material.dart';

class RegistroWidgets {
  
  /// Campo: Nombre
  static Widget campoNombre({
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "Nombre",
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  /// Campo: Apellido
  static Widget campoApellido({
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "Apellido",
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  /// Campo: Correo electrónico
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
      validator: validator,
    );
  }

  /// Campo: Contraseña
  static Widget campoClave({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: "Contraseña",
        prefixIcon: const Icon(Icons.lock_outline),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator,
    );
  }

  /// Botón registrarme
  static Widget botonRegistrarme({
    required bool cargando,
    required VoidCallback onPressed,
    String texto = "Registrarme",
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        child: cargando
            ? const CircularProgressIndicator()
            : Text(texto),
      ),
    );
  }
}
