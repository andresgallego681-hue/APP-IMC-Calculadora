import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Inicia sesión con email y password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    // Intentar iniciar sesión con Firebase Authentication
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Verifica si el documento del usuario existe en Firestore
  Future<bool> userProfileExists(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    return doc.exists;
  }
}
