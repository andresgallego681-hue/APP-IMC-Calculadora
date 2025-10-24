import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuarioRegisto {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<UserCredential> crearUsuario(String correo, String clave) {
    // Crear usuario en Firebase Authentication
    return _auth.createUserWithEmailAndPassword(
      email: correo,
      password: clave,
    );
  }

/// Guardar datos adicionales del usuario en Firestore
  Future<void> guardarDatosUsuario({
    required String uid,
    required String nombre,
    required String apellido,
    required String correo,
  }) async {
    // Guardar datos en la colección 'usuarios' con el UID como ID del documento
    await _db.collection('usuarios').doc(uid).set({
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'fecha_creacion': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cerrarSesion() => _auth.signOut();
}
