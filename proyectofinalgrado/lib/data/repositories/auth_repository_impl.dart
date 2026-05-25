import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._dataSource);
  final AuthDataSource _dataSource;

  @override
  Future<bool> emailExists(String email) => _dataSource.emailExists(email);

  @override
  Future<void> signInWithEmail(String email, String password) =>
      _dataSource.signInWithEmail(email, password);

  @override
  Future<void> signInWithGoogle() => _dataSource.signInWithGoogle();

  @override
  Future<void> register(String email, String password, String username) =>
      _dataSource.register(email, password, username);

  @override
  Future<void> signOut() => _dataSource.signOut();
}
