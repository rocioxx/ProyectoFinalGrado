import '../repositories/i_auth_repository.dart';

class SignInEmailUseCase {
  const SignInEmailUseCase(this._repo);
  final IAuthRepository _repo;

  Future<void> call(String email, String password) =>
      _repo.signInWithEmail(email, password);
}
