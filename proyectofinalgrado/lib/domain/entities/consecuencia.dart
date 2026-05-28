import 'game_state.dart';

class Consecuencia {
  const Consecuencia({
    this.deltaVida = 0,
    this.deltaSuerte = 0,
    this.deltaTiempo = 0,
    this.deltaPoder = 0,
    this.onApply,
  });

  final double deltaVida;
  final double deltaSuerte;
  final double deltaTiempo;
  final double deltaPoder;
  final void Function(GameState estado)? onApply;
}
