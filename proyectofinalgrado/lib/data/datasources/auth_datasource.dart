import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDataSource {
  static const _webClientId =
      '989019583265-d22kh3qphppn7ni122t5cbflt8l9afg7.apps.googleusercontent.com';

  final _db = Supabase.instance.client;

  Future<bool> emailExists(String email) async {
    final res = await _db
        .from('profiles')
        .select('id')
        .eq('email', email)
        .maybeSingle();
    return res != null;
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _db.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signInWithGoogle() async {
    if (!kIsWeb && Platform.isAndroid) {
      await _signInNative();
    } else {
      await _db.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'http://localhost',
      );
    }
  }

  Future<void> _signInNative() async {
    final googleSignIn = GoogleSignIn(serverClientId: _webClientId);
    await googleSignIn.signOut();
    final account = await googleSignIn.signIn();
    if (account == null) throw Exception('cancelled');

    final googleAuth = await account.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) throw Exception('No se obtuvo el ID token de Google.');

    final response = await _db.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );

    await _ensureProfile(response.user, displayName: account.displayName);
  }

  Future<void> register(
      String email, String password, String username) async {
    final res = await _db.auth.signUp(email: email, password: password);
    final uid = res.user?.id ?? (throw Exception('No se pudo crear la cuenta.'));
    await _db.from('profiles').insert({
      'id': uid,
      'email': email,
      'username': username,
    });
  }

  Future<void> signOut() async {
    if (!kIsWeb && Platform.isAndroid) await GoogleSignIn().signOut();
    await _db.auth.signOut();
  }

  Future<void> _ensureProfile(User? user, {String? displayName}) async {
    if (user == null) return;
    final existing = await _db
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();
    if (existing != null) return;
    final email = user.email ?? '';
    await _db.from('profiles').insert({
      'id': user.id,
      'email': email,
      'username': displayName ?? email.split('@').first,
    });
  }
}
