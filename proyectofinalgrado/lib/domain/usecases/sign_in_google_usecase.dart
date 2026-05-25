import '../repositories/i_auth_repository.dart';

class SignInGoogleUseCase {
  const SignInGoogleUseCase(this._repo);
  final IAuthRepository _repo;

  Future<void> call() => _repo.signInWithGoogle();
}
