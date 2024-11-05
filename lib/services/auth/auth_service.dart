import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Authentications
class AuthService {
  // Instance of Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? getCurrentUser() => _auth.currentUser;

  // Sign In
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      // Sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Retrieve user info from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection("Users")
          .doc(userCredential.user!.uid)
          .get();

      String role = 'user'; // Default role

      // Check if user document exists and if the role is admin
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (data['role'] == 'admin') {
          role = 'admin'; // Update role if user is admin
        }
      }

      // Save user info in a separate document if it doesn't already exist
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
          'role': role,
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign Up
  Future<UserCredential> signUpWithEmailPassword(
      String email, String password) async {
    try {
      // Create user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user info in a separate document
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
          'role': 'user',
        },
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
