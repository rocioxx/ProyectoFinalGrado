import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/audio/music_service.dart';
import '../../core/sound_settings.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) MusicService.instance.start();
    });
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
    final logoWidth = (size.width * 0.82).clamp(260.0, 420.0);
    final topSpacing = size.height * 0.12;
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

          // ── Botón música ─────────────────────────────────────────────────
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: ValueListenableBuilder<bool>(
                valueListenable: SoundSettings.sonidoActivo,
                builder: (_, activo, _) => IconButton(
                  icon: Icon(
                    activo ? Icons.volume_up : Icons.volume_off,
                    color: const Color(0xFFD4AF37),
                    size: 28,
                  ),
                  onPressed: () {
                    SoundSettings.sonidoActivo.value = !activo;
                  },
                ),
              ),
            ),
          ),

          // ── Contenido ─────────────────────────────────────────────────────
          SafeArea(
            child: size.width > size.height
                ? Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            'lib/fotos/inicio.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            ),
                            child: Image.asset(
                              'lib/fotos/entrar.png',
                              width: size.width * 0.38,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: topSpacing),
                      SizedBox(height: size.height * 0.016),
                      Image.asset(
                        'lib/fotos/inicio.png',
                        width: logoWidth,
                        height: size.height * 0.50,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.contain,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        ),
                        child: SizedBox(
                          width: (size.width * 0.90).clamp(280.0, 460.0),
                          height: (size.height * 0.20).clamp(120.0, 200.0),
                          child: Image.asset(
                            'lib/fotos/entrar.png',
                            fit: BoxFit.contain,
                          ),
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
