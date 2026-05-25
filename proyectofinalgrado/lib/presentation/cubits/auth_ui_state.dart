sealed class AuthUiState {}

class AuthLoading extends AuthUiState {}

class AuthStep extends AuthUiState {
  AuthStep(this.paso, {this.errorMessage});
  final int paso;
  final String? errorMessage;
}

class AuthAuthenticated extends AuthUiState {}
