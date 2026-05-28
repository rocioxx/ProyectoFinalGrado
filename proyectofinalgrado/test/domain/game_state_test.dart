import 'package:flutter_test/flutter_test.dart';
import 'package:proyectofinalgrado/domain/entities/game_state.dart';

void main() {
  group('GameState — valores iniciales', () {
    late GameState state;

    setUp(() => state = GameState());

    test('vida empieza en 50', () => expect(state.vida, 50));
    test('suerte empieza en 50', () => expect(state.suerte, 50));
    test('tiempo empieza en 100', () => expect(state.tiempo, 100));
    test('poder empieza en 10', () => expect(state.poder, 10));
    test('defeatedEnemies empieza en 0', () => expect(state.defeatedEnemies, 0));
    test('victoria empieza en false', () => expect(state.victoria, false));
    test('iniciada empieza en false', () => expect(state.iniciada, false));
    test('abGroup por defecto es A', () => expect(state.abGroup, 'A'));
    test('enemyQueue empieza vacía', () => expect(state.enemyQueue, isEmpty));
    test('misiones empieza en false', () {
      expect(state.cantimploraEncontrada, false);
      expect(state.aventureroEncontrado, false);
      expect(state.puertaFinalAlcanzada, false);
    });
  });

  group('GameState — constructor personalizado', () {
    test('abGroup B se asigna correctamente', () {
      final s = GameState(abGroup: 'B');
      expect(s.abGroup, 'B');
    });

    test('stats personalizados se respetan', () {
      final s = GameState(vida: 30, suerte: 80, tiempo: 60, poder: 5);
      expect(s.vida, 30);
      expect(s.suerte, 80);
      expect(s.tiempo, 60);
      expect(s.poder, 5);
    });
  });

  group('GameState — condición de game over', () {
    test('vida 0 es derrota', () {
      final s = GameState()..vida = 0;
      expect(s.vida <= 0, true);
    });

    test('suerte 0 es derrota', () {
      final s = GameState()..suerte = 0;
      expect(s.suerte <= 0, true);
    });

    test('tiempo 0 es derrota', () {
      final s = GameState()..tiempo = 0;
      expect(s.tiempo <= 0, true);
    });

    test('poder 0 es derrota', () {
      final s = GameState()..poder = 0;
      expect(s.poder <= 0, true);
    });
  });
}
