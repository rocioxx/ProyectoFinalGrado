import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'card_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _primary   = Color(0xFFD4AF37);
  static const _secondary = Color(0xFFC2B280);
  static const _red       = Color(0xFFB22222);
  static const _bg        = Color(0xFF0D0D0D);
  static const _bgWarm    = Color(0xFF1D140D);

  final _db = Supabase.instance.client;

  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _usernameCtrl = TextEditingController();

  int     _paso    = 0;
  bool    _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Introduce tu correo electrónico.');
      return;
    }
    setState(() { _loading = true; _error = null; });

    final res = await _db
        .from('profiles')
        .select('id')
        .eq('email', email)
        .maybeSingle();

    if (!mounted) return;
    setState(() { _loading = false; _paso = res != null ? 1 : 2; });
  }

  Future<void> _login() async {
    if (_passCtrl.text.isEmpty) {
      setState(() => _error = 'Introduce tu contraseña.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _db.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const CardScreen()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() { _loading = false; _error = _traducir(e.message); });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Error inesperado.'; });
    }
  }

  Future<void> _registrar() async {
    final email    = _emailCtrl.text.trim();
    final pass     = _passCtrl.text;
    final username = _usernameCtrl.text.trim();

    if (username.isEmpty) { setState(() => _error = 'Pon un nombre para el juego.'); return; }
    if (pass.length < 6)  { setState(() => _error = 'La contraseña debe tener al menos 6 caracteres.'); return; }

    setState(() { _loading = true; _error = null; });
    try {
      final res = await _db.auth.signUp(email: email, password: pass);
      final uid = res.user?.id ?? (throw Exception());

      await _db.from('profiles').insert({'id': uid, 'email': email, 'username': username});

      if (mounted) {
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const CardScreen()),
        );
      }
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        try {
          await _db.auth.signInWithPassword(email: email, password: pass);
          final uid = _db.auth.currentUser?.id;
          if (uid != null) { await _db.from('profiles').insert({'id': uid, 'email': email, 'username': username}); }
          if (mounted) Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const CardScreen()),
          );
        } catch (_) {
          if (mounted) setState(() { _loading = false; _error = 'Correo ya registrado. Vuelve atrás e inicia sesión.'; });
        }
      } else {
        if (mounted) setState(() { _loading = false; _error = _traducir(e.message); });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  String _traducir(String msg) {
    if (msg.contains('Invalid login'))   return 'Contraseña incorrecta.';
    if (msg.contains('already registered')) return 'Este correo ya tiene cuenta.';
    if (msg.contains('Password should')) return 'La contraseña debe tener al menos 6 caracteres.';
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo
          Container(
            decoration: const BoxDecoration(
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
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // ── Cabecera ───────────────────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            // Línea decorativa dorada
                            Row(
                              children: [
                                const Expanded(child: Divider(color: _primary, thickness: 0.5)),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  width: 4, height: 4,
                                  decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
                                ),
                                const Expanded(child: Divider(color: _primary, thickness: 0.5)),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Text(
                              _paso == 2 ? 'Crear cuenta' : 'Acceder',
                              style: const TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _paso == 0
                                  ? 'Introduce tu correo para continuar'
                                  : _paso == 1
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
                            Row(
                              children: [
                                const Expanded(child: Divider(color: _primary, thickness: 0.5)),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  width: 4, height: 4,
                                  decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
                                ),
                                const Expanded(child: Divider(color: _primary, thickness: 0.5)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Campos ─────────────────────────────────────────────
                      _Campo(
                        controller: _emailCtrl,
                        label: 'Correo electrónico',
                        icon: Icons.mail_outline,
                        obscure: false,
                        keyboardType: TextInputType.emailAddress,
                        enabled: _paso == 0,
                      ),

                      if (_paso == 2) ...[
                        const SizedBox(height: 14),
                        _Campo(
                          controller: _usernameCtrl,
                          label: 'Nombre en el juego',
                          icon: Icons.person_outline,
                          obscure: false,
                        ),
                      ],

                      if (_paso > 0) ...[
                        const SizedBox(height: 14),
                        _Campo(
                          controller: _passCtrl,
                          label: 'Contraseña',
                          icon: Icons.lock_outline,
                          obscure: true,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Error ──────────────────────────────────────────────
                      if (_error != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0x22B22222),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _red.withValues(alpha: 0.6), width: 0.8),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFF8888),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Botón principal ────────────────────────────────────
                      if (_loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: CircularProgressIndicator(color: _primary, strokeWidth: 2),
                          ),
                        )
                      else
                        _Boton(
                          label: _paso == 0 ? 'Continuar' : _paso == 1 ? 'Entrar' : 'Crear cuenta',
                          onTap: _paso == 0 ? _continuar : _paso == 1 ? _login : _registrar,
                        ),

                      // ── Volver ─────────────────────────────────────────────
                      if (_paso > 0) ...[
                        const SizedBox(height: 14),
                        Center(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _paso = 0; _error = null;
                              _passCtrl.clear(); _usernameCtrl.clear();
                            }),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Campo de texto ─────────────────────────────────────────────────────────────

class _Campo extends StatelessWidget {
  const _Campo({
    required this.controller,
    required this.label,
    required this.icon,
    required this.obscure,
    this.keyboardType,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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

// ── Botón ──────────────────────────────────────────────────────────────────────

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
