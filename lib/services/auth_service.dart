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
    required String name,      
    required String phone,     
    String role = 'dweller', // Added default role so NGOs can be added later
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
          'name': name,         
          'phone': phone,       
          'role': role,         
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
  // Returns the 'role' string (e.g., 'officer', 'ngo', or 'dweller') 
  // so the UI knows which Dashboard to open.
  Future<String?> signIn({required String email, required String password}) async {
    try {
      // A. Sign In
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      // B. Fetch Role from Firestore
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
  // 3. GET USER ROLE (Standalone fetch if needed elsewhere)
  // ----------------------------------------------------------------
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ----------------------------------------------------------------
  // 4. RESET PASSWORD (Needed for Officer Profile)
  // ----------------------------------------------------------------
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Failed to send password reset email.';
    }
  }

  // ----------------------------------------------------------------
  // 5. SIGN OUT
  // ----------------------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ----------------------------------------------------------------
  // 6. HELPER: Error Handling
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