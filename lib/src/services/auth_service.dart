import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../firebase_options.dart';
import 'firestore_service.dart';

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
  static Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) await FirestoreService.ensureUserDocument(user);
    return credential;
  }

  static Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) await FirestoreService.ensureUserDocument(user);
    return credential;
  }

  static Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> updateDisplayName(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    await currentUser?.updateDisplayName(cleanName);
    await currentUser?.reload();

    final user = currentUser;
    if (user != null) {
      await FirestoreService.updateProfile(user: user, name: cleanName);
    }
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
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) await FirestoreService.ensureUserDocument(user);
    return userCredential;
  }

  // ── Sign Out ──────────────────────────────────────────────
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
