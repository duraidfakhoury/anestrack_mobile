import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '590585428593-vr6klodf48irqag840n2nmfstj9vcfe4.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<GoogleSignInAccount?> signIn() {
    return _googleSignIn.signIn();
  }

  Future<GoogleSignInAuthentication?> getAuth(
    GoogleSignInAccount user,
  ) {
    return user.authentication;
  }

  Future<void> signOut() {
    return _googleSignIn.signOut();
  }
}
