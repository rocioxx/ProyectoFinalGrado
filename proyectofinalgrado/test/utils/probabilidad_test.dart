import 'package:flutter_test/flutter_test.dart';

// Fórmula central del juego: modula probabilidad base según la suerte actual.
// Duplicada aquí para testearla de forma aislada sin depender de card_datasource.
double conSuerte(double suerte, double base) =>
    (base + (suerte - 50) * 0.008).clamp(0.0, 1.0);

void main() {
  group('conSuerte — fórmula de probabilidad', () {
    test('suerte 50 no modifica la probabilidad base', () {
      expect(conSuerte(50, 0.5), closeTo(0.5, 0.001));
    });

    test('suerte 100 suma 0.4 a la base', () {
      expect(conSuerte(100, 0.5), closeTo(0.9, 0.001));
    });

    test('suerte 0 resta 0.4 a la base', () {
      expect(conSuerte(0, 0.5), closeTo(0.1, 0.001));
    });

    test('resultado nunca supera 1.0', () {
      expect(conSuerte(100, 1.0), lessThanOrEqualTo(1.0));
    });

    test('resultado nunca baja de 0.0', () {
      expect(conSuerte(0, 0.0), greaterThanOrEqualTo(0.0));
    });

    test('cofre grupo A con suerte 50: 50% de éxito', () {
      expect(conSuerte(50, 0.50), closeTo(0.50, 0.001));
    });

    test('cofre grupo B con suerte 50: 70% de éxito', () {
      expect(conSuerte(50, 0.70), closeTo(0.70, 0.001));
    });

    test('cofre grupo B con suerte alta: probabilidad mayor que con A', () {
      final grupoA = conSuerte(50, 0.50);
      final grupoB = conSuerte(50, 0.70);
      expect(grupoB, greaterThan(grupoA));
    });
  });
}
