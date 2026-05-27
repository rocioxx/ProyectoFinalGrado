import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'login_screen.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final VideoPlayerController _ctrl;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.asset('lib/fotos/portada_video.mp4')
      ..setLooping(true)
      ..setVolume(0);
    _ctrl
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() => _videoReady = true);
          _ctrl.play();
        })
        .catchError((_) {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.13).clamp(34.0, 56.0);
    final subtitleSize = (size.width * 0.04).clamp(13.0, 18.0);
    final btnWidth = (size.width * 0.55).clamp(160.0, 240.0);
    final topSpacing = size.height * 0.07;
    final bottomSpacing = size.height * 0.06;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fondo ────────────────────────────────────────────────────────
          const ColoredBox(color: Colors.black),
          AnimatedOpacity(
            opacity: _videoReady ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoReady ? _ctrl.value.size.width : 1,
                  height: _videoReady ? _ctrl.value.size.height : 1,
                  child: _videoReady ? VideoPlayer(_ctrl) : const SizedBox(),
                ),
              ),
            ),
          ),

          // ── Contenido ─────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: topSpacing),

                SizedBox(height: size.height * 0.012),
                Image.asset(
                  'lib/fotos/inicio.png', //esta imagen aparece a la mitad de la pantalla y se ve muy grande
                  width: btnWidth,
                  height: 600,
                  alignment: Alignment.topCenter,
                  fit: BoxFit.contain,
                ),

                Text(
                  'Entrar a la mazmorra',
                  style: TextStyle(
                    fontFamily: 'Inconsolata',
                    fontSize: subtitleSize,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFFB8A070),
                    letterSpacing: 1.5,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 12),
                    ],
                  ),
                ),

                const Spacer(),

                // Botón abajo
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Image.asset(
                    'lib/fotos/entrar.png',
                    width: btnWidth,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: bottomSpacing),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
