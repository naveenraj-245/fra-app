import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user (or null if not logged in)
  User? get currentUser => _auth.currentUser;

  // 1. Sign Up with Email & Password
  Future<User?> signUp({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      throw e.toString(); // Send error back to UI
    }
  }

  // 2. Sign In with Email & Password
  Future<User?> signIn({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      throw e.toString();
    }
  }

  // 3. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}