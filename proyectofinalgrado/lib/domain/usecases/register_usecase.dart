import '../repositories/i_auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repo);
  final IAuthRepository _repo;

  Future<void> call(String email, String password, String username) =>
      _repo.register(email, password, username);
}
