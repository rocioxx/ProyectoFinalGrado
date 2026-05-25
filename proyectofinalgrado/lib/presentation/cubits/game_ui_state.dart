import '../../domain/entities/carta.dart';
import '../../domain/entities/game_state.dart';

sealed class GameUiState {}

class GamePlaying extends GameUiState {
  GamePlaying({required this.cartaActual, required this.gameState});
  final Carta cartaActual;
  final GameState gameState;
}

class GameOverState extends GameUiState {}

class GameVictoryState extends GameUiState {}
