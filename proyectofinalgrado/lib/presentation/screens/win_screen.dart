import 'dart:io';
import 'package:flutter/material.dart';
import 'play_screen.dart';

class WinScreen extends StatelessWidget {
  const WinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final btnWidth = (size.width * 0.62).clamp(180.0, 260.0);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 20, 13),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/fotos/victoria.png',
              width: size.width * 0.85,
              fit: BoxFit.contain,
            ),
            SizedBox(height: size.height * 0.05),
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
    );
  }
}
