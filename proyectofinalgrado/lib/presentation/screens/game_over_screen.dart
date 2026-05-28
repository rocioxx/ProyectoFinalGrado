import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import 'play_screen.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key, required this.gameState});

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final btnWidth = (size.width * 0.62).clamp(180.0, 260.0);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 20, 13),
      body: size.width > size.height
          ? Row(
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'lib/fotos/derrota.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MisionesResumen(gameState: gameState),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const PlayScreen()),
                              (_) => false,
                            ),
                            child: Image.asset(
                              'lib/fotos/menu.png',
                              width: btnWidth * 0.7,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => exit(0),
                            child: Image.asset(
                              'lib/fotos/salir.png',
                              width: btnWidth * 0.7,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'lib/fotos/derrota.png',
                      width: size.width * 0.75,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: size.height * 0.03),
                    _MisionesResumen(gameState: gameState),
                    SizedBox(height: size.height * 0.035),
                    GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const PlayScreen()),
                        (_) => false,
                      ),
                      child: Image.asset(
                        'lib/fotos/menu.png',
                        width: btnWidth * 0.7,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: size.height * 0.012),
                    GestureDetector(
                      onTap: () => exit(0),
                      child: Image.asset(
                        'lib/fotos/salir.png',
                        width: btnWidth * 0.7,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _MisionesResumen extends StatelessWidget {
  const _MisionesResumen({required this.gameState});
  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    final misiones = [
      (titulo: 'Derrotar al Nigromante', completada: gameState.victoria),
      (
        titulo: 'Llegar a la puerta final',
        completada: gameState.puertaFinalAlcanzada
      ),
      (
        titulo: 'Vencer todos los combates',
        completada: gameState.defeatedEnemies >= 3
      ),
      (
        titulo: 'Encontrar la cantimplora',
        completada: gameState.cantimploraEncontrada
      ),
      (
        titulo: 'Hablar con el aventurero',
        completada: gameState.aventureroEncontrado
      ),
    ];

    final completadas = misiones.where((m) => m.completada).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1208),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MISIONES',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.2,
                  fontFamily: 'Inconsolata',
                ),
              ),
              Text(
                '$completadas / ${misiones.length}',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 12,
                  fontFamily: 'Inconsolata',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFF333333), height: 1),
          const SizedBox(height: 6),
          ...misiones.map(
            (m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(
                    m.completada
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: m.completada
                        ? const Color(0xFF5B9BD5)
                        : Colors.white38,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      m.titulo,
                      style: TextStyle(
                        color:
                            m.completada ? Colors.white38 : Colors.white70,
                        fontSize: 13,
                        fontFamily: 'Inconsolata',
                        decoration: m.completada
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
