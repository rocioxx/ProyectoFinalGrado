import 'package:flutter/material.dart';

class StatsPanel extends StatelessWidget {
  const StatsPanel({
    super.key,
    required this.vida,
    required this.experiencia,
    required this.nivel,
    required this.fuerza,
  });

  final double vida;
  final double experiencia;
  final double nivel;
  final double fuerza;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
      decoration: const BoxDecoration(
        color: Color.fromARGB(200, 235, 235, 235),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatBar(label: 'Vida', color: const Color(0xFFE8706A), value: vida),
          _StatBar(
            label: 'Exp',
            color: const Color(0xFF5B9BD5),
            value: experiencia,
          ),
          _StatBar(
            label: 'Nivel',
            color: const Color(0xFFAAAAAA),
            value: nivel,
          ),
          _StatBar(
            label: 'Fuerza',
            color: const Color(0xFFD4AF37),
            value: fuerza,
          ),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.label,
    required this.color,
    required this.value,
  });

  final String label;
  final Color color;
  final double value; // 0.0 – 1.0

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color.fromARGB(179, 0, 0, 0),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: 10,
            height: 80,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(color: const Color(0xFF333333)),
                FractionallySizedBox(
                  heightFactor: value.clamp(0.0, 1.0),
                  child: Container(color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
