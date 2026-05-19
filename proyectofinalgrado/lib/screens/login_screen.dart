import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'card_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _primary = Color(0xFFD4AF37);
  static const _secondary = Color(0xFFC2B280);
  static const _bg = Color(0xFF0D0D0D);
  static const _bgWarm = Color(0xFF1D140D);

  final _db = Supabase.instance.client;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();

  // 0 = solo email  |  1 = login (email + pass)  |  2 = registro (email + nombre + pass)
  int _paso = 0;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  // ── Paso 1: comprobar si el correo existe en profiles ────────────────────
  Future<void> _continuar() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Introduce tu correo electrónico.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await _db
        .from('profiles')
        .select('id')
        .eq('email', email)
        .maybeSingle();

    if (!mounted) return;
    setState(() {
      _loading = false;
      _paso = res != null ? 1 : 2; // 1=login, 2=registro
    });
  }

  // ── Paso 2a: iniciar sesión ───────────────────────────────────────────────
  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (pass.isEmpty) {
      setState(() => _error = 'Introduce tu contraseña.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _db.auth.signInWithPassword(email: email, password: pass);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CardScreen()),
        );
      }
    } on AuthException catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = _traducir(e.message);
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = 'Error inesperado.';
        });
    }
  }

  // ── Paso 2b: crear cuenta ────────────────────────────────────────────────
  Future<void> _registrar() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final username = _usernameCtrl.text.trim();

    if (username.isEmpty) {
      setState(() => _error = 'Pon un nombre para el juego.');
      return;
    }
    if (pass.length < 6) {
      setState(
        () => _error = 'La contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _db.auth.signUp(email: email, password: pass);
      final uid = res.user?.id;
      if (uid == null) throw Exception('No se pudo crear el usuario.');

      await _db.from('profiles').insert({
        'id': uid,
        'email': email,
        'username': username,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CardScreen()),
        );
      }
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        // Existe en auth pero no en profiles — intentar login y crear perfil
        try {
          await _db.auth.signInWithPassword(email: email, password: pass);
          final uid = _db.auth.currentUser?.id;
          if (uid != null) {
            await _db.from('profiles').insert({
              'id': uid,
              'email': email,
              'username': username,
            });
          }
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CardScreen()),
            );
          }
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
    if (msg.contains('Invalid login')) return 'Contraseña incorrecta.';
    if (msg.contains('already registered'))
      return 'Este correo ya tiene cuenta.';
    if (msg.contains('Password should'))
      return 'La contraseña debe tener al menos 6 caracteres.';
    return msg;
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgWarm, _bg],
                stops: [0.0, 0.7],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⛏', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 10),
                      Text(
                        _paso == 2 ? 'CREAR CUENTA' : 'ACCEDER',
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                          letterSpacing: 4,
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
                          fontFamily: 'Lora',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: _secondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Email (siempre visible) ──────────────────────────
                      _Campo(
                        controller: _emailCtrl,
                        label: 'Correo electrónico',
                        obscure: false,
                        keyboardType: TextInputType.emailAddress,
                        enabled: _paso == 0,
                      ),

                      // ── Nombre (solo en registro) ────────────────────────
                      if (_paso == 2) ...[
                        const SizedBox(height: 14),
                        _Campo(
                          controller: _usernameCtrl,
                          label: 'Nombre en el juego',
                          obscure: false,
                        ),
                      ],

                      // ── Contraseña (login y registro) ────────────────────
                      if (_paso > 0) ...[
                        const SizedBox(height: 14),
                        _Campo(
                          controller: _passCtrl,
                          label: 'Contraseña',
                          obscure: true,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Error ────────────────────────────────────────────
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x33B22222),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFB22222),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 12,
                              color: Color(0xFFFF8080),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // ── Botón principal ──────────────────────────────────
                      if (_loading)
                        const SizedBox(
                          height: 50,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _primary,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      else
                        _Boton(
                          label: _paso == 0
                              ? 'C O N T I N U A R'
                              : _paso == 1
                              ? 'E N T R A R'
                              : 'C R E A R  C U E N T A',
                          onTap: _paso == 0
                              ? _continuar
                              : _paso == 1
                              ? _login
                              : _registrar,
                        ),

                      // ── Volver (si ya pasamos del paso 0) ───────────────
                      if (_paso > 0) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => setState(() {
                            _paso = 0;
                            _error = null;
                            _passCtrl.clear();
                            _usernameCtrl.clear();
                          }),
                          child: const Text(
                            '← Cambiar correo',
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 12,
                              color: _secondary,
                              decoration: TextDecoration.underline,
                              decorationColor: _secondary,
                            ),
                          ),
                        ),
                      ],
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
    required this.obscure,
    this.keyboardType,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
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
        color: enabled ? Colors.white : const Color(0xFF888888),
        fontFamily: 'Lora',
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF777777),
          fontFamily: 'Lora',
          fontSize: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        filled: true,
        fillColor: enabled ? const Color(0xFF150F08) : const Color(0xFF0D0D0D),
      ),
    );
  }
}

// ── Botón de acción ────────────────────────────────────────────────────────────

class _Boton extends StatelessWidget {
  const _Boton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFB22222),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB22222).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lora',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
