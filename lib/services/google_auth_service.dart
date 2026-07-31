import 'package:google_sign_in/google_sign_in.dart';

/// Wrapper minimale su Google Sign-In per collegare l'account (identità/profilo).
///
/// NB: i dati reali dei wearable (Garmin, Samsung Health, Honor Health, ecc.)
/// vengono letti da Health Connect / Apple Health tramite [HealthService];
/// il login Google serve per l'identità e per un'esperienza personalizzata.
class GoogleAuthService {
  static final GoogleSignIn _google = GoogleSignIn(
    scopes: const ['email', 'profile'],
  );

  static GoogleSignInAccount? _current;
  static GoogleSignInAccount? get current => _current;
  static bool get isSignedIn => _current != null;

  /// Ripristina una sessione precedente in modo silenzioso.
  static Future<GoogleSignInAccount?> restore() async {
    try {
      _current = await _google.signInSilently();
    } catch (_) {
      _current = null;
    }
    return _current;
  }

  /// Avvia il flusso interattivo di login.
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      _current = await _google.signIn();
    } catch (_) {
      _current = null;
    }
    return _current;
  }

  static Future<void> signOut() async {
    try {
      await _google.signOut();
    } catch (_) {}
    _current = null;
  }

  /// Token OAuth dell'account corrente, necessari per autenticare su
  /// Firebase Auth (GoogleAuthProvider.credential).
  static Future<({String? idToken, String? accessToken})> tokens() async {
    final acc = _current;
    if (acc == null) return (idToken: null, accessToken: null);
    try {
      final auth = await acc.authentication;
      return (idToken: auth.idToken, accessToken: auth.accessToken);
    } catch (_) {
      return (idToken: null, accessToken: null);
    }
  }
}
