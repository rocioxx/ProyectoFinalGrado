import 'package:flutter/material.dart';
import 'login_screen.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Imagen de fondo ───────────────────────────────────────────────
          Image.asset('lib/fotos/portada.png', fit: BoxFit.cover),

          // ── Degradado oscuro encima ───────────────────────────────────────
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000),
                  Color(0xAA000000),
                  Color(0xEE000000),
                ],
                stops: [0.3, 0.65, 1.0],
              ),
            ),
          ),

          // ── Contenido ─────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Titulo
                const Text(
                  'DUNGEON',
                  style: TextStyle(
                    fontFamily: 'Inconsolata',
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFD4AF37),
                    letterSpacing: 8,
                    shadows: [
                      Shadow(
                        color: Color(0xFF000000),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Subtitulo
                const Text(
                  'Entrar a la mazmorra',
                  style: TextStyle(
                    fontFamily: 'Inconsolata',
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFB8A070),
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 60),

                // Boton entrar
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Container(
                    width: 200,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1208),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66D4AF37),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'ENTRAR',
                        style: TextStyle(
                          fontFamily: 'Inconsolata',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
