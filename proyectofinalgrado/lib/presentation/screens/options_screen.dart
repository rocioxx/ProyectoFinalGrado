import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/sound_settings.dart';
import 'play_screen.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  bool _sonido = SoundSettings.sonidoActivo.value;

  void _toggleSonido(bool val) {
    setState(() => _sonido = val);
    SoundSettings.sonidoActivo.value = val;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final btnWidth = (size.width * 0.58).clamp(180.0, 260.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A06),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'OPCIONES',
                style: TextStyle(
                  fontFamily: 'Inconsolata',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                  letterSpacing: 4,
                ),
              ),

              SizedBox(height: size.height * 0.06),

              // ── Toggle sonido ──────────────────────────────────────────
              Container(
                width: btnWidth,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1208),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x66D4AF37)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sonido',
                      style: TextStyle(
                        fontFamily: 'Inconsolata',
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Checkbox(
                      value: _sonido,
                      onChanged: (v) => _toggleSonido(v ?? true),
                      activeColor: const Color(0xFFD4AF37),
                      checkColor: const Color(0xFF1A1208),
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.05),

              // ── Menú principal ────────────────────────────────────────
              _OpcionBtn(
                label: 'Menú principal',
                width: btnWidth,
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const PlayScreen()),
                  (_) => false,
                ),
              ),

              const SizedBox(height: 14),

              // ── Salir ──────────────────────────────────────────────────
              _OpcionBtn(
                label: 'Salir',
                width: btnWidth,
                onTap: () => exit(0),
              ),

              SizedBox(height: size.height * 0.05),

              // ── Volver ─────────────────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Volver al juego',
                  style: TextStyle(
                    fontFamily: 'Inconsolata',
                    fontSize: 13,
                    color: Color(0xFFB8A070),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFB8A070),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpcionBtn extends StatelessWidget {
  const _OpcionBtn({
    required this.label,
    required this.width,
    required this.onTap,
  });

  final String label;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD4AF37)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inconsolata',
            fontSize: 16,
            color: Color(0xFFD4AF37),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
