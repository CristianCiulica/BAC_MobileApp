import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../firebase_options.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn(
    clientId: DefaultFirebaseOptions.currentPlatform.iosClientId,
  );

  // Stream activ — ascultă schimbările de sesiune și profil
  static Stream<User?> get userStream => _auth.userChanges();
  static User? get currentUser => _auth.currentUser;

  static String get displayName {
    final user = currentUser;
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;

    return 'Utilizator BacPro';
  }

  // ── Email & Parolă ────────────────────────────────────────
  static Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> updateDisplayName(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    await currentUser?.updateDisplayName(cleanName);
    await currentUser?.reload();
  }

  // ── Google ────────────────────────────────────────────────
  static Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  // ── Sign Out ──────────────────────────────────────────────
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
