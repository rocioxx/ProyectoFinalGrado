import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/carta.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/usecases/apply_decision_usecase.dart';
import '../../domain/usecases/draw_card_usecase.dart';
import 'game_ui_state.dart';

class GameCubit extends Cubit<GameUiState> {
  GameCubit._({
    required DrawCardUseCase drawCard,
    required ApplyDecisionUseCase applyDecision,
    required GameState gameState,
    required Carta initialCard,
  })  : _drawCard = drawCard,
        _applyDecision = applyDecision,
        _gameState = gameState,
        super(GamePlaying(cartaActual: initialCard, gameState: gameState));

  factory GameCubit({
    required DrawCardUseCase drawCard,
    required ApplyDecisionUseCase applyDecision,
  }) {
    final state = GameState();
    return GameCubit._(
      drawCard: drawCard,
      applyDecision: applyDecision,
      gameState: state,
      initialCard: drawCard(state),
    );
  }

  final DrawCardUseCase _drawCard;
  final ApplyDecisionUseCase _applyDecision;
  final GameState _gameState;

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
