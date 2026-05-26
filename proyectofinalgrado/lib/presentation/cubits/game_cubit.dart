import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/carta.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/usecases/apply_decision_usecase.dart';
import '../../domain/usecases/draw_card_usecase.dart';
import '../../domain/usecases/skip_card_usecase.dart';
import 'game_ui_state.dart';

class GameCubit extends Cubit<GameUiState> {
  GameCubit._({
    required DrawCardUseCase drawCard,
    required ApplyDecisionUseCase applyDecision,
    required SkipCardUseCase skipCard,
    required GameState gameState,
    required Carta initialCard,
  })  : _drawCard = drawCard,
        _applyDecision = applyDecision,
        _skipCard = skipCard,
        _gameState = gameState,
        super(GamePlaying(cartaActual: initialCard, gameState: gameState));

  factory GameCubit({
    required DrawCardUseCase drawCard,
    required ApplyDecisionUseCase applyDecision,
    required SkipCardUseCase skipCard,
  }) {
    final state = GameState();
    return GameCubit._(
      drawCard: drawCard,
      applyDecision: applyDecision,
      skipCard: skipCard,
      gameState: state,
      initialCard: drawCard(state),
    );
  }

  final DrawCardUseCase _drawCard;
  final ApplyDecisionUseCase _applyDecision;
  final SkipCardUseCase _skipCard;
  final GameState _gameState;

  // Descarta la carta actual y muestra un enemigo aleatorio del pool
  void skipCard() {
    _gameState.cartaPendiente = null;
    _gameState.enemyVida = null;
    _gameState.enemyMaxVida = null;
    emit(GamePlaying(
      cartaActual: _skipCard(),
      gameState: _gameState,
    ));
  }

  void applyDecision(Carta carta, bool eligioIzquierda) {
    _applyDecision(_gameState, carta, eligioIzquierda);

    if (_gameState.victoria) {
      emit(GameVictoryState());
      return;
    }
    if (_gameState.vida <= 0 ||
        _gameState.suerte <= 0 ||
        _gameState.tiempo <= 0 ||
        _gameState.poder <= 0) {
      emit(GameOverState());
      return;
    }
    emit(GamePlaying(
      cartaActual: _drawCard(_gameState),
      gameState: _gameState,
    ));
  }
}
