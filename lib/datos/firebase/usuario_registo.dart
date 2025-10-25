import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuarioRegisto {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // -------------------- AUTH --------------------

  /// Crea el usuario en Firebase Auth
  Future<UserCredential> crearUsuario(String correo, String clave) {
    return _auth.createUserWithEmailAndPassword(email: correo, password: clave);
  }

  /// (Opcional) Inicia sesión
  Future<UserCredential> iniciarSesion(String correo, String clave) {
    return _auth.signInWithEmailAndPassword(email: correo, password: clave);
  }

  Future<void> cerrarSesion() => _auth.signOut();

  // -------------------- PERFIL --------------------

  /// Crea/actualiza el documento del usuario en `usuarios/{uid}`
  Future<void> guardarDatosUsuario({
    required String uid,
    required String nombre,
    required String apellido,
    required String correo,
  }) async {
    await _db.collection('usuarios').doc(uid).set({
      'uid': uid,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'fecha_creacion': FieldValue.serverTimestamp(),
      'fecha_actualizacion': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // <- no pisa campos existentes
  }

  // -------------------- REGISTROS IMC --------------------

  /// Agrega un registro de IMC en `usuarios/{uid}/registros/{autoId}`
  Future<void> agregarRegistroIMC({
    required double imc,
    required String categoria,
    required double pesoKg,         // normalizado (kg)
    required double alturaCm,       // normalizado (cm)
    required double pesoVisible,    // como lo vio el usuario (kg o lb)
    required double alturaVisible,  // como lo vio el usuario (cm o in)
    required bool esMetricoVisible, // true = SI, false = imperial
    Map<String, dynamic>? extra,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseException(
        plugin: 'firebase_auth',
        code: 'no-auth',
        message: 'No hay usuario autenticado.',
      );
    }

    final uid = user.uid;

    // Garantiza que el doc del usuario exista (idempotente)
    await _db.collection('usuarios').doc(uid).set({
      'uid': uid,
      'correo': user.email,
      'fecha_actualizacion': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final doc = _db
        .collection('usuarios')
        .doc(uid)
        .collection('registros')
        .doc();

    final data = {
      // Core
      'imc': imc,
      'categoria': categoria,

      // Normalizados
      'pesoKg': pesoKg,
      'alturaCm': alturaCm,

      // Visibles tal como los ingresó/visualiza
      'pesoVisible': pesoVisible,
      'alturaVisible': alturaVisible,
      'esMetricoVisible': esMetricoVisible,

      // Metadatos
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'origen': 'calculo_view_v1',
      if (extra != null) ...extra,
    };

    await doc.set(data);
  }

  /// Stream del historial del usuario autenticado (ordenado desc por fecha)
  Stream<QuerySnapshot<Map<String, dynamic>>> registrosStream({String? uid}) {
    final effectiveUid = uid ?? _auth.currentUser?.uid;
    if (effectiveUid == null) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return _db
        .collection('usuarios')
        .doc(effectiveUid)
        .collection('registros')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  /// Borra un registro por id dentro de `usuarios/{uid}/registros`
  Future<void> eliminarRegistro(String registroId, {String? uid}) async {
    final effectiveUid = uid ?? _auth.currentUser?.uid;
    if (effectiveUid == null) return;

    await _db
        .collection('usuarios')
        .doc(effectiveUid)
        .collection('registros')
        .doc(registroId)
        .delete();
  }

  // -------------------- HELPERS --------------------

  /// UID actual (null si no hay sesión)
  String? get uidActual => _auth.currentUser?.uid;
}
