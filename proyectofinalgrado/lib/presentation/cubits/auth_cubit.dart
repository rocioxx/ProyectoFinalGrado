import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/usecases/check_email_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/sign_in_email_usecase.dart';
import '../../domain/usecases/sign_in_google_usecase.dart';
import 'auth_ui_state.dart';

class AuthCubit extends Cubit<AuthUiState> {
  AuthCubit({
    required CheckEmailUseCase checkEmail,
    required SignInEmailUseCase signInEmail,
    required SignInGoogleUseCase signInGoogle,
    required RegisterUseCase register,
  })  : _checkEmail = checkEmail,
        _signInEmail = signInEmail,
        _signInGoogle = signInGoogle,
        _register = register,
        super(AuthStep(0)) {
    // On web, session is restored immediately after OAuth redirect
    if (kIsWeb) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        emit(AuthAuthenticated());
        return;
      }
    }
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && !isClosed) {
        emit(AuthAuthenticated());
      }
    });
  }

  final CheckEmailUseCase _checkEmail;
  final SignInEmailUseCase _signInEmail;
  final SignInGoogleUseCase _signInGoogle;
  final RegisterUseCase _register;
  StreamSubscription<AuthState>? _authSub;

  Future<void> submitEmail(String email) async {
    emit(AuthLoading());
    try {
      final exists = await _checkEmail(email);
      emit(AuthStep(exists ? 1 : 2));
    } catch (e) {
      emit(AuthStep(0, errorMessage: _traducir(e.toString())));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _signInEmail(email, password);
      // AuthAuthenticated emitted via stream listener
    } on AuthException catch (e) {
      emit(AuthStep(1, errorMessage: _traducir(e.message)));
    } catch (e) {
      emit(AuthStep(1, errorMessage: 'Error inesperado.'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      await _signInGoogle();
      // Android success: stream listener emits AuthAuthenticated
      // Web/Windows: browser opened; listener fires when OAuth completes
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('cancelled')) {
        emit(AuthStep(0));
      } else {
        emit(AuthStep(0, errorMessage: 'Error con Google Sign-In.'));
      }
    }
  }

  Future<void> register(String email, String password, String username) async {
    emit(AuthLoading());
    try {
      await _register(email, password, username);
      emit(AuthAuthenticated());
    } on AuthException catch (e) {
      emit(AuthStep(2, errorMessage: _traducir(e.message)));
    } catch (e) {
      emit(AuthStep(2, errorMessage: _traducir(e.toString())));
    }
  }

  void back() => emit(AuthStep(0));

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }

  String _traducir(String raw) {
    if (raw.contains('Invalid login')) return 'Contraseña incorrecta.';
    if (raw.contains('already registered')) return 'Este correo ya tiene cuenta.';
    if (raw.contains('Password should')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (raw.contains('Email not confirmed')) {
      return 'Confirma tu correo antes de entrar.';
    }
    return 'Ha ocurrido un error. Inténtalo de nuevo.';
  }
}
