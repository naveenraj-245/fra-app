import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen to auth changes (Login/Logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ----------------------------------------------------------------
  // 1. SIGN UP (Register)
  // ----------------------------------------------------------------
  // By default, anyone who registers via the app is a 'dweller'.
  // Officers are created manually in the Firebase Console.
  Future<UserCredential> signUp({
    required String email, 
    required String password,
    required String name,      // New
    required String phone,     // New
  }) async {
    try {
      // 1. Create Auth Account
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      // 2. Save User Details to Firestore
      if (cred.user != null) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'email': email,
          'name': name,         // Saved
          'phone': phone,       // Saved
          'role': 'dweller',    // Default role
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Registration failed. Please try again.';
    }
  }

  // ----------------------------------------------------------------
  // 2. SIGN IN (Login) & GET ROLE
  // ----------------------------------------------------------------
  // Returns the 'role' string (e.g., 'officer' or 'dweller') 
  // so the UI knows which Dashboard to open.
  Future<String?> signIn({required String email, required String password}) async {
    try {
      // A. Sign In
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      // B. Fetch Role from Firestore
      // This ensures that even if I select "Officer" on the login screen,
      // the database decides who I really am.
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return data['role'] ?? 'dweller'; // Return the role
      }
      
      return 'dweller'; // Default fallback

    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Login failed. Please check your connection.';
    }
  }

  // ----------------------------------------------------------------
  // 3. SIGN OUT
  // ----------------------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ----------------------------------------------------------------
  // 4. HELPER: Error Handling
  // ----------------------------------------------------------------
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
