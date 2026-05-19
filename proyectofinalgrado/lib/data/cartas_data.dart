import 'dart:math';
import '../models/carta.dart';
import '../models/consecuencia.dart';
import '../models/game_state.dart';

final _rng = Random();

// ── Helpers de navegación ─────────────────────────────────────────────────────

// Fuerza la siguiente carta sin pasar por el pool aleatorio
void _ir(GameState s, Carta c) => s.cartaPendiente = c;

// ── Helpers de probabilidad ───────────────────────────────────────────────────

// Victoria en combate: poder (+30% máx) + suerte (+20% máx)
bool _victoria(GameState s, {double base = 0.45}) =>
    _rng.nextDouble() <
    (base + s.poder * 0.003 + s.suerte * 0.002).clamp(0.0, 0.90);

// Alta suerte → resultado bueno más probable
bool _conSuerte(GameState s, double base) =>
    _rng.nextDouble() < (base + (s.suerte - 50) * 0.003).clamp(0.0, 1.0);

// Alta suerte → resultado malo menos probable
bool _sinSuerte(GameState s, double base) =>
    _rng.nextDouble() < (base - (s.suerte - 50) * 0.003).clamp(0.0, 1.0);

// ── Ejemplos de encadenamiento (carta que llega forzada) ─────────────────────

final _cartaEncadenada = Carta(
  texto: 'Has llegado aquí por encadenamiento.\nEsta carta no está en el pool.',
  opcionIzquierda: 'Entendido',
  opcionDerecha: 'Ok',
  efectoIzquierda: (_) => const Consecuencia(deltaSuerte: 5),
  efectoDerecha: (_) => const Consecuencia(deltaPoder: 5),
);

// ════════════════════════════════════════════════════════════════════════════
// POOL DE CARTAS
// ════════════════════════════════════════════════════════════════════════════

final List<Carta> todasLasCartas = [

  // ── EJEMPLO: Vida (subir y bajar) ────────────────────────────────────────
  Carta(
    texto: 'VIDA\nIzquierda: -10 vida\nDerecha: +20 vida',
    opcionIzquierda: 'Bajar vida',
    opcionDerecha: 'Subir vida',
    efectoIzquierda: (_) => const Consecuencia(deltaVida: -10),
    efectoDerecha: (_) => const Consecuencia(deltaVida: 20),
  ),

  // ── EJEMPLO: Poder (subir y bajar) ───────────────────────────────────────
  Carta(
    texto: 'PODER\nIzquierda: -10 poder\nDerecha: +15 poder',
    opcionIzquierda: 'Bajar poder',
    opcionDerecha: 'Subir poder',
    efectoIzquierda: (_) => const Consecuencia(deltaPoder: -10),
    efectoDerecha: (_) => const Consecuencia(deltaPoder: 15),
  ),

  // ── EJEMPLO: Suerte (subir y bajar) ──────────────────────────────────────
  Carta(
    texto: 'SUERTE\nIzquierda: -10 suerte\nDerecha: +10 suerte',
    opcionIzquierda: 'Bajar suerte',
    opcionDerecha: 'Subir suerte',
    efectoIzquierda: (_) => const Consecuencia(deltaSuerte: -10),
    efectoDerecha: (_) => const Consecuencia(deltaSuerte: 10),
  ),

  // ── EJEMPLO: Tiempo (subir y bajar) ──────────────────────────────────────
  Carta(
    texto: 'TIEMPO\nIzquierda: -15 tiempo\nDerecha: +10 tiempo',
    opcionIzquierda: 'Bajar tiempo',
    opcionDerecha: 'Subir tiempo',
    efectoIzquierda: (_) => const Consecuencia(deltaTiempo: -15),
    efectoDerecha: (_) => const Consecuencia(deltaTiempo: 10),
  ),

  // ── EJEMPLO: Combate con _victoria ───────────────────────────────────────
  Carta(
    texto: 'COMBATE (_victoria)\nDerecha: 45%+poder+suerte de ganar.\nIzquierda: huir.',
    opcionIzquierda: 'Huir (-5 vida)',
    opcionDerecha: 'Luchar',
    efectoIzquierda: (_) => const Consecuencia(deltaVida: -5),
    efectoDerecha: (s) {
      if (_victoria(s)) return const Consecuencia(deltaPoder: 10);
      return const Consecuencia(deltaVida: -15);
    },
  ),

  // ── EJEMPLO: Azar con _sinSuerte y _conSuerte ────────────────────────────
  Carta(
    texto: 'SUERTE ALEATORIA\nIzquierda: _sinSuerte (50% base, mejora con suerte)\nDerecha: _conSuerte',
    opcionIzquierda: '_sinSuerte(0.5)',
    opcionDerecha: '_conSuerte(0.5)',
    efectoIzquierda: (s) => _sinSuerte(s, 0.5)
        ? const Consecuencia(deltaVida: -20)
        : const Consecuencia(deltaVida: 10),
    efectoDerecha: (s) => _conSuerte(s, 0.5)
        ? const Consecuencia(deltaPoder: 15)
        : const Consecuencia(deltaPoder: -10),
  ),

  // ── EJEMPLO: Flag en GameState ────────────────────────────────────────────
  Carta(
    texto: 'FLAG (isEnvenenado)\nDerecha: activa isEnvenenado.\nIzquierda: nada.',
    opcionIzquierda: 'Ignorar',
    opcionDerecha: 'Envenenar',
    efectoIzquierda: (_) => const Consecuencia(),
    efectoDerecha: (_) => Consecuencia(
      deltaVida: -5,
      onApply: (st) => st.isEnvenenado = true,
    ),
  ),

  // ── EJEMPLO: Encadenamiento con cartaPendiente ───────────────────────────
  Carta(
    texto: 'ENCADENAMIENTO\nDerecha: fuerza _cartaEncadenada como siguiente carta.',
    opcionIzquierda: 'Ignorar',
    opcionDerecha: 'Encadenar',
    efectoIzquierda: (_) => const Consecuencia(),
    efectoDerecha: (s) => Consecuencia(
      onApply: (st) => _ir(st, _cartaEncadenada),
    ),
  ),

  // ── EJEMPLO: Condición (solo aparece si vida < 50) ────────────────────────
  Carta(
    texto: 'CONDICIÓN\nSolo aparece si vida < 50.\n+30 vida al cogerlo.',
    opcionIzquierda: 'Rechazar',
    opcionDerecha: 'Coger botiquín',
    condicion: (s) => s.vida < 50,
    efectoIzquierda: (_) => const Consecuencia(),
    efectoDerecha: (_) => const Consecuencia(deltaVida: 30),
  ),

];
