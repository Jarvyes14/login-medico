import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Iniciar sesión
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No se encontró ningún usuario con ese correo.';
        case 'wrong-password':
          return 'Contraseña incorrecta.';
        case 'invalid-email':
          return 'El correo electrónico no es válido.';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada.';
        default:
          return 'Error: ${e.message}';
      }
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  // Registrar nuevo usuario
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'La contraseña es muy débil.';
        case 'email-already-in-use':
          return 'Ya existe una cuenta con ese correo.';
        case 'invalid-email':
          return 'El correo electrónico no es válido.';
        default:
          return 'Error: ${e.message}';
      }
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  // Resetear contraseña
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No se encontró ningún usuario con ese correo.';
        case 'invalid-email':
          return 'El correo electrónico no es válido.';
        default:
          return 'Error: ${e.message}';
      }
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}