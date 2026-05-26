import '../entities/carta.dart';
import '../entities/game_state.dart';

abstract interface class IGameRepository {
  Carta drawCard(GameState state);
  void applyDecision(GameState state, Carta carta, bool eligioIzquierda);
  Carta cartaEnemigoRandom();
}
