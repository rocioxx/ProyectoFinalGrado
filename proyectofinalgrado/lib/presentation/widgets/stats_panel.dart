import 'package:flutter/material.dart';

class StatsPanel extends StatelessWidget {
  const StatsPanel({
    super.key,
    required this.vida,
    required this.poder,
    required this.tiempo,
    required this.suerte,
  });

  final double vida;
  final double poder;
  final double tiempo;
  final double suerte;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final vPad = (size.height * 0.055).clamp(24.0, 55.0);
    final barHeight = (size.height * 0.14).clamp(80.0, 130.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: vPad),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 29, 20, 13),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatBar(label: 'Vida', color: const Color(0xFFE8706A), value: vida, barHeight: barHeight),
          _StatBar(label: 'Poder', color: const Color(0xFFE85D04), value: poder, barHeight: barHeight),
          _StatBar(label: 'Tiempo', color: const Color(0xFF5B9BD5), value: tiempo, barHeight: barHeight),
          _StatBar(label: 'Suerte', color: const Color(0xFF95D44A), value: suerte, barHeight: barHeight),
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
    required this.barHeight,
  });

  final String label;
  final Color color;
  final double value;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color.fromARGB(179, 255, 255, 255),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 16,
            height: barHeight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(color: const Color.fromARGB(179, 255, 255, 255)),
                FractionallySizedBox(
                  heightFactor: (value / 100).clamp(0.0, 1.0),
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
