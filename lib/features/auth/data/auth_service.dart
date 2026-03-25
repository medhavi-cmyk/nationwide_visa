import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  static const String _isCompletePrefKey = 'is_user_complete_';
  
  // Cache for user completeness status to avoid redundant Firestore calls
  static final Map<String, bool> _isCompleteCache = {};

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
      // Force account picker by signing out first
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        authCredential,
      );
      return userCredential;
    } catch (e) {
      debugPrint("Google sign in error: $e");
      rethrow;
    }
  }

  // Check if user profile is complete
  Future<bool> isUserComplete(String uid) async {
    // 1. Check memory cache first
    if (_isCompleteCache.containsKey(uid) && _isCompleteCache[uid] == true) {
      return true;
    }

    // 2. Check persistent cache
    final prefs = await SharedPreferences.getInstance();
    final persistentIsComplete = prefs.getBool('$_isCompletePrefKey$uid');
    if (persistentIsComplete == true) {
      _isCompleteCache[uid] = true;
      return true;
    }

    try {
      final userData = await getUserData(uid);
      if (userData == null) return false;

      // Mandatory fields for "complete" profile
      final isComplete = userData.phoneNumber != null &&
          userData.country != null &&
          userData.city != null &&
          userData.nationality != null &&
          userData.studyCountry != null;

      // Update both caches
      _isCompleteCache[uid] = isComplete;
      if (isComplete) {
        await prefs.setBool('$_isCompletePrefKey$uid', true);
      }
      
      return isComplete;
    } catch (e) {
      debugPrint("Check user complete error: $e");
      return false;
    }
  }

  // Check if email exists
  Future<bool> doesEmailExist(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      // 1. Try Firebase Auth first
      final list = await _auth.fetchSignInMethodsForEmail(normalizedEmail);
      if (list.isNotEmpty) return true;

      // 2. Fallback: Check Firestore 'users' collection
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Check email error: $e");
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // --- Password Reset ---
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("Password reset error: $e");
      rethrow;
    }
  }

  // --- Phone Authentication (OTP) ---

  // Verify Phone Number and send OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      debugPrint("Phone verification error: $e");
      rethrow;
    }
  }

  // Sign in with Phone Credential
  Future<UserCredential> signInWithPhoneCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Phone sign in error: $e");
      rethrow;
    }
  }

  // Link Email/Password to current user account
  Future<void> linkEmailPassword(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in to link info to");

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.linkWithCredential(credential);
    } catch (e) {
      debugPrint("Linking email error: $e");
      rethrow;
    }
  }

  // --- End Phone Authentication ---

  // Save/Update user data in Firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      debugPrint(
        "Attempting to save user data to Firestore for UID: ${user.uid}",
      );
      debugPrint("Project ID being used: ${_firestore.app.options.projectId}");
      final dataToSave = user.toMap();
      debugPrint("DATA BEING SENT TO FIRESTORE: $dataToSave");
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(dataToSave, SetOptions(merge: true));
      
      // Update both caches
      final isComplete = user.phoneNumber != null &&
          user.country != null &&
          user.city != null &&
          user.nationality != null &&
          user.studyCountry != null;
      _isCompleteCache[user.uid] = isComplete;
      
      if (isComplete) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('$_isCompletePrefKey${user.uid}', true);
      }

      debugPrint(
        "Successfully saved user data to Firestore for UID: ${user.uid}",
      );
    } catch (e) {
      debugPrint("CRITICAL: Save user data error for UID ${user.uid}: $e");
      rethrow;
    }
  }

  // Update only email verification status in Firestore
  Future<void> updateEmailVerificationStatus(String uid, bool isVerified) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set({'isEmailVerified': isVerified}, SetOptions(merge: true));
      debugPrint("Updated Firestore verification status for $uid to $isVerified");
    } catch (e) {
      debugPrint("Error updating verification status: $e");
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
