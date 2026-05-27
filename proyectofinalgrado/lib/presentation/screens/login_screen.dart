import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/check_email_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/sign_in_email_usecase.dart';
import '../../domain/usecases/sign_in_google_usecase.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_ui_state.dart';
import 'card_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repo = AuthRepositoryImpl(AuthDataSource());
        return AuthCubit(
          checkEmail: CheckEmailUseCase(repo),
          signInEmail: SignInEmailUseCase(repo),
          signInGoogle: SignInGoogleUseCase(repo),
          register: RegisterUseCase(repo),
        );
      },
      child: const _LoginView(),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────────

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  static const _primary   = Color(0xFFD4AF37);
  static const _secondary = Color(0xFFC2B280);
  static const _red       = Color(0xFFB22222);
  static const _bg        = Color(0xFF0D0D0D);
  static const _bgWarm    = Color(0xFF1D140D);

  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _usernameCtrl = TextEditingController();

  // FocusNodes para saltar al campo correcto automáticamente
  final _passFocus     = FocusNode();
  final _usernameFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _usernameCtrl.dispose();
    _passFocus.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  void _onBack() {
    _passCtrl.clear();
    _usernameCtrl.clear();
    context.read<AuthCubit>().back();
  }

  void _onSubmit(int paso) {
    final cubit = context.read<AuthCubit>();
    final email = _emailCtrl.text.trim();
    switch (paso) {
      case 0:
        if (email.isEmpty) return;
        cubit.submitEmail(email);
      case 1:
        cubit.signIn(email, _passCtrl.text);
      case 2:
        cubit.register(email, _passCtrl.text, _usernameCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgWarm, _bg],
                stops: [0.0, 0.65],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                // BlocConsumer = listener + builder en un solo widget
                child: BlocConsumer<AuthCubit, AuthUiState>(
                  // No redibujar cuando ya se ha autenticado (estamos navegando)
                  buildWhen: (_, s) => s is! AuthAuthenticated,
                  listener: (context, state) {
                    if (state is AuthAuthenticated) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CardScreen()),
                      );
                    }
                    // Auto-foco al campo nuevo cuando cambia el paso
                    if (state is AuthStep) {
                      if (state.paso == 1) {
                        _passFocus.requestFocus();
                      } else if (state.paso == 2) {
                        _usernameFocus.requestFocus();
                      }
                    }
                  },
                  builder: (context, state) {
                    final paso    = state is AuthStep ? state.paso : 0;
                    final loading = state is AuthLoading;
                    final error   = state is AuthStep ? state.errorMessage : null;

                    return AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          Center(
                            child: Image.asset(
                              'lib/fotos/acceder.png',
                              height: 90,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Cabecera ──────────────────────────────────────
                          Center(
                            child: Column(
                              children: [
                                const _GoldDivider(),
                                const SizedBox(height: 20),
                                if (paso == 2)
                                  const Text(
                                    'Crear cuenta',
                                    style: TextStyle(
                                      fontFamily: 'Inconsolata',
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: _primary,
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  paso == 0
                                      ? 'Introduce tu correo para continuar'
                                      : paso == 1
                                          ? 'Bienvenido de nuevo'
                                          : 'Primera vez por aquí',
                                  style: const TextStyle(
                                    fontFamily: 'Inconsolata',
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: _secondary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const _GoldDivider(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ── Campos ────────────────────────────────────────
                          _Campo(
                            controller: _emailCtrl,
                            label: 'Correo electrónico',
                            icon: Icons.mail_outline,
                            obscure: false,
                            keyboardType: TextInputType.emailAddress,
                            enabled: paso == 0,
                          ),

                          if (paso == 2) ...[
                            const SizedBox(height: 14),
                            _Campo(
                              controller: _usernameCtrl,
                              label: 'Nombre en el juego',
                              icon: Icons.person_outline,
                              obscure: false,
                              focusNode: _usernameFocus,
                            ),
                          ],

                          if (paso > 0) ...[
                            const SizedBox(height: 14),
                            _Campo(
                              controller: _passCtrl,
                              label: 'Contraseña',
                              icon: Icons.lock_outline,
                              obscure: true,
                              focusNode: _passFocus,
                            ),
                          ],

                          const SizedBox(height: 24),

                          // ── Error ─────────────────────────────────────────
                          if (error != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0x22B22222),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: _red.withValues(alpha: 0.6),
                                    width: 0.8),
                              ),
                              child: Text(
                                error,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFFF8888)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // ── Botón principal ───────────────────────────────
                          if (loading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: CircularProgressIndicator(
                                    color: _primary, strokeWidth: 2),
                              ),
                            )
                          else
                            _Boton(
                              label: paso == 0
                                  ? 'Continuar'
                                  : paso == 1
                                      ? 'Entrar'
                                      : 'Crear cuenta',
                              onTap: () => _onSubmit(paso),
                            ),

                          // ── Google Sign-In ────────────────────────────────
                          if (paso == 0 && !loading) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Expanded(
                                    child: Divider(color: Color(0xFF333333))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text('o',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13)),
                                ),
                                const Expanded(
                                    child: Divider(color: Color(0xFF333333))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _BotonGoogle(
                              onTap: context.read<AuthCubit>().signInWithGoogle,
                            ),
                          ],

                          // ── Volver ────────────────────────────────────────
                          if (paso > 0) ...[
                            const SizedBox(height: 14),
                            Center(
                              child: GestureDetector(
                                onTap: _onBack,
                                child: const Text(
                                  'Cambiar correo',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _secondary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: _secondary,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Divisor dorado ────────────────────────────────────────────────────────────

class _GoldDivider extends StatelessWidget {
  const _GoldDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFD4AF37), thickness: 0.5)),
        _GoldDot(),
        Expanded(child: Divider(color: Color(0xFFD4AF37), thickness: 0.5)),
      ],
    );
  }
}

class _GoldDot extends StatelessWidget {
  const _GoldDot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      child: Center(
        child: SizedBox(
          width: 4,
          height: 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFD4AF37),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Campo de texto ────────────────────────────────────────────────────────────

class _Campo extends StatelessWidget {
  const _Campo({
    required this.controller,
    required this.label,
    required this.icon,
    required this.obscure,
    this.keyboardType,
    this.enabled = true,
    this.focusNode,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? Colors.white : const Color(0xFF777777),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF666666), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF555555), size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF222222)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFF130E07),
      ),
    );
  }
}

// ── Botón Google ──────────────────────────────────────────────────────────────

class _BotonGoogle extends StatelessWidget {
  const _BotonGoogle({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF1A1A1A),
          side: const BorderSide(color: Color(0xFF444444)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'G',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4285F4)),
            ),
            SizedBox(width: 10),
            Text(
              'Continuar con Google',
              style: TextStyle(
                  fontFamily: 'Inconsolata',
                  fontSize: 15,
                  color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Botón principal ───────────────────────────────────────────────────────────

class _Boton extends StatelessWidget {
  const _Boton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB22222),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
          ),
          shadowColor: const Color(0xFFB22222),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inconsolata',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
