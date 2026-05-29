import 'package:audioplayers/audioplayers.dart';
import '../sound_settings.dart';

class MusicService {
  MusicService._() {
    SoundSettings.sonidoActivo.addListener(() {
      if (SoundSettings.sonidoActivo.value) {
        _play();
      } else {
        _player.stop();
      }
    });
  }

  static final MusicService instance = MusicService._();

  final _player = AudioPlayer();

  void _play() {
    _player.setReleaseMode(ReleaseMode.loop);
    _player.play(AssetSource('sonidos/backgroundmusic.ogg'), volume: 0.7);
  }

  void start() {
    if (!SoundSettings.sonidoActivo.value) return;
    _play();
  }
}
