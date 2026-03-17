import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("Sign in error: $e");
      rethrow;
    }
  }

  // Sign up with Email and Password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("Sign up error: $e");
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Google sign in error: $e");
      rethrow;
    }
  }

  // Check if email exists
  Future<bool> doesEmailExist(String email) async {
    try {
      final list = await _auth.fetchSignInMethodsForEmail(email);
      return list.isNotEmpty;
    } catch (e) {
      debugPrint("Check email error: $e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Save/Update user data in Firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      debugPrint("Attempting to save user data to Firestore for UID: ${user.uid}");
      debugPrint("Project ID being used: ${_firestore.app.options.projectId}");
      final dataToSave = user.toMap();
      debugPrint("DATA BEING SENT TO FIRESTORE: $dataToSave");
      await _firestore.collection('users').doc(user.uid).set(
            dataToSave,
            SetOptions(merge: true),
          );
      debugPrint("Successfully saved user data to Firestore for UID: ${user.uid}");
    } catch (e) {
      debugPrint("CRITICAL: Save user data error for UID ${user.uid}: $e");
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      debugPrint("AuthService: Fetching doc for UID: $uid");
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        debugPrint("AuthService: RAW DATA FROM FIRESTORE: ${doc.data()}");
        return UserModel.fromMap(doc.data()!);
      }
      debugPrint("AuthService: Document does not exist for UID: $uid");
      return null;
    } catch (e) {
      debugPrint("AuthService: Get user data error: $e");
      rethrow;
    }
  }
}
