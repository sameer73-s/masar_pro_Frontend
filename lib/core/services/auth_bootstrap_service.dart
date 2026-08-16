import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthBootstrapService {
  final FirebaseAuth _firebaseAuth;

  AuthBootstrapService(this._firebaseAuth);

  /// Ensures that the user is signed in (anonymously).
  /// Returns the [User] on success, or null on failure.
  Future<User?> ensureSignedIn() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        debugPrint('AuthBootstrapService: User already signed in. UID: ${currentUser.uid}');
        return currentUser;
      }
      
      debugPrint('AuthBootstrapService: User not signed in. Signing in anonymously...');
      final userCredential = await _firebaseAuth.signInAnonymously();
      debugPrint('AuthBootstrapService: Anonymous sign-in success. UID: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      debugPrint('AuthBootstrapService Error: Failed to sign in anonymously. Error: $e');
      // Do not crash the app, but log and return null.
      return null;
    }
  }
}
