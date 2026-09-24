import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

/// The single source of truth for "is anyone logged in". The app shell
/// watches this to decide between the login screen and the dashboard.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Drives the login form: holds the in-flight sign-in call so the screen
/// can show a spinner and surface a friendly error message.
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(email: email.trim(), password: password);
    });
  }

  Future<void> signOut() => ref.read(firebaseAuthProvider).signOut();
}

final authControllerProvider = NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

/// Maps FirebaseAuth's error codes to messages worth showing someone
/// signing in, instead of a raw exception string.
String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error — check your connection and try again.';
      default:
        return error.message ?? 'Could not sign in. Please try again.';
    }
  }
  return 'Could not sign in. Please try again.';
}
