import '../../domain/entities/carta.dart';
import '../../domain/entities/game_state.dart';

sealed class GameUiState {}

class GamePlaying extends GameUiState {
  GamePlaying({required this.cartaActual, required this.gameState});
  final Carta cartaActual;
  final GameState gameState;
}

class GameOverState extends GameUiState {
  GameOverState({required this.gameState});
  final GameState gameState;
}

class GameVictoryState extends GameUiState {
  GameVictoryState({required this.gameState});
  final GameState gameState;
}
