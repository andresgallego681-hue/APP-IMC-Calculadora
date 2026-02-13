import 'package:app_bmi/datos/shared_preferences/preferencias_sesion.dart';
import 'package:app_bmi/datos/firebase/usuario_registo.dart';

class RegistroLogica {
/// Instancia de la clase que maneja los datos del usuario en Firebase
  final UsuarioRegisto _usuarioDatos = UsuarioRegisto();

  // recibe los datos del usuario y registra en Firebase Authentication y Firestore
  Future<String?> registrarUsuario({
    required String nombre,
    required String apellido,
    required String correo,
    required String clave,
  }) async {
    try {
      // Crear usuario en Firebase
      final cred = await _usuarioDatos.crearUsuario(correo, clave);

      //  Guardar datos adicionales del usuario en Firestore
      await _usuarioDatos.guardarDatosUsuario(
        uid: cred.user!.uid,
        nombre: nombre,
        apellido: apellido,
        correo: correo,
      );

      //  Guardar sesión local
      await PreferenciasSesion.setLogueado(true);

      // Si todo va bien, devolvemos null (sin error)
      return null;
    } catch (e) {
      // Manejo de errores comunes de Firebase
      final mensaje = _traducirErrorFirebase(e.toString());
      return mensaje ?? "Error inesperado: $e";
    }
  }

  /// Traduce errores técnicos de FirebaseAuth a mensajes entendibles
  String? _traducirErrorFirebase(String error) {
    if (error.contains('email-already-in-use')) {
      return "El correo ya está registrado.";
    } else if (error.contains('weak-password')) {
      return "La contraseña es demasiado débil.";
    } else if (error.contains('invalid-email')) {
      return "Correo inválido.";
    } else if (error.contains('network-request-failed')) {
      return "Sin conexión a internet.";
    } else if (error.contains('too-many-requests')) {
      return "Demasiados intentos. Intenta más tarde.";
    }
    return null;
  }
}
