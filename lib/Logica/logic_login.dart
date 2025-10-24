// lib/logica/login_logic.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_bmi/datos/firebase/autentificacio.dart';


class LoginLogic {
  // Dependencia para manejar la autenticación
  final AuthDataSource _data;
  LoginLogic({AuthDataSource? data}) : _data = data ?? AuthDataSource();

  /// Retorna `null` si todo salió bien; en caso contrario, un mensaje de error.
  Future<String?> iniciarSesion({
    required String correo,
    required String clave,
    bool verificarPerfil = false, 
  }) async {
    try {
      // Intentar iniciar sesión con Firebase Authentication 
      final cred = await _data.signIn(email: correo, password: clave);

      // Verificar si el perfil del usuario está completo si es necesario
      if (verificarPerfil) {
        final existe = await _data.userProfileExists(cred.user!.uid);
        if (!existe) {
          return 'Tu perfil no está completo. Por favor, regístrate nuevamente.';
        }
      }

      return null; // ✅ éxito
      // Manejo de errores específicos  para autenticación no exitosa
   } on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No existe un usuario con ese correo.';
    case 'wrong-password':
      return 'Contraseña incorrecta.';
    case 'invalid-email':
      return 'Correo inválido.';
    case 'user-disabled':
      return 'Usuario deshabilitado.';
    case 'invalid-credential': 
      return 'Credenciales inválidas. Verifica correo y contraseña.';
    case 'operation-not-allowed': 
      return 'El método de inicio de sesión no está habilitado.';
    case 'too-many-requests':
      return 'Demasiados intentos. Intenta más tarde.';
    default:
      return 'Error de autenticación: ${e.message ?? e.code}';
  }
}
 catch (e) {
      return 'Ocurrió un error inesperado: $e';
    }
  }
}
