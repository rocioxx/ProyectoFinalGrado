import '../repositories/i_auth_repository.dart';

class CheckEmailUseCase {
  const CheckEmailUseCase(this._repo);
  final IAuthRepository _repo;

  Future<bool> call(String email) => _repo.emailExists(email);
}
