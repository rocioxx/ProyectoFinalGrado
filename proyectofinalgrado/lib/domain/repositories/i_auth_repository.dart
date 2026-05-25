abstract interface class IAuthRepository {
  Future<bool> emailExists(String email);
  Future<void> signInWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> register(String email, String password, String username);
  Future<void> signOut();
}
