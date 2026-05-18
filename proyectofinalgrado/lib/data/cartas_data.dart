import 'dart:math';
import '../models/carta.dart';
import '../models/consecuencia.dart';
import '../models/game_state.dart';

final _rng = Random();

// Fuerza la siguiente carta sin pasar por el pool aleatorio
void _ir(GameState s, Carta c) => s.cartaPendiente = c;

// Probabilidad de victoria: poder (+30% máx) + suerte (+20% máx)
bool _victoria(GameState s, {double base = 0.45}) =>
    _rng.nextDouble() <
    (base + s.poder * 0.003 + s.suerte * 0.002).clamp(0.0, 0.90);

// Alta suerte → más probable (resultados buenos)
bool _conSuerte(GameState s, double base) =>
    _rng.nextDouble() < (base + (s.suerte - 50) * 0.003).clamp(0.0, 1.0);

// Alta suerte → menos probable (resultados malos)
bool _sinSuerte(GameState s, double base) =>
    _rng.nextDouble() < (base - (s.suerte - 50) * 0.003).clamp(0.0, 1.0);

// ════════════════════════════════════════════════════════════════════════════
// CADENAS DE COMBATE — ESQUELETO
// ════════════════════════════════════════════════════════════════════════════

final Carta _esqueletoPelea = Carta(
  texto: 'Intercambias golpes con el esqueleto.\nSus huesos crujen bajo tu pico.',
  opcionIzquierda: 'Retroceder y huir',
  opcionDerecha: 'Asestar el golpe definitivo',
  efectoIzquierda: (_) => const Consecuencia(deltaVida: -5, deltaTiempo: -5),
  efectoDerecha: (s) {
    if (_victoria(s)) {
      return Consecuencia(
        deltaPoder: 5,
        onApply: (st) => st.defeatedEnemies++,
      );
    }
    return Consecuencia(
      deltaVida: -12,
      onApply: (st) => _ir(st, _esqueletoPelea),
    );
  },
);

final _esqueletoEncuentro = Carta(
  texto: '¡Un esqueleto emerge de las sombras\ny bloquea el pasillo!',
  opcionIzquierda: 'Esquivar y huir',
  opcionDerecha: 'Atacar',
  efectoIzquierda: (_) => const Consecuencia(deltaTiempo: -5),
  efectoDerecha: (s) => Consecuencia(
    deltaVida: -8,
    onApply: (st) => _ir(st, _esqueletoPelea),
  ),
);

// ════════════════════════════════════════════════════════════════════════════
// CADENAS DE COMBATE — GOBLIN
// ════════════════════════════════════════════════════════════════════════════

final Carta _goblinPelea = Carta(
  texto: 'El goblin es torpe pero persistente.\nSe lanza contra ti una y otra vez.',
  opcionIzquierda: 'Darte la vuelta y correr',
  opcionDerecha: 'Seguir golpeando',
  efectoIzquierda: (_) => const Consecuencia(deltaTiempo: -5),
  efectoDerecha: (s) {
    if (_victoria(s)) {
      return Consecuencia(
        deltaPoder: 5,
        onApply: (st) => st.defeatedEnemies++,
      );
    }
    return Consecuencia(
      deltaVida: -10,
      onApply: (st) => _ir(st, _goblinPelea),
    );
  },
);

final _goblinEncuentro = Carta(
  texto: '¡Un goblin agresivo emerge\nde entre las piedras!',
  opcionIzquierda: 'Ignorarle y pasar',
  opcionDerecha: 'Enfrentarle',
  efectoIzquierda: (s) {
    if (_sinSuerte(s, 0.4)) {
      return const Consecuencia(deltaVida: -8); // te golpea por la espalda
    }
    return const Consecuencia(deltaTiempo: -3);
  },
  efectoDerecha: (s) => Consecuencia(
    deltaVida: -5,
    onApply: (st) => _ir(st, _goblinPelea),
  ),
);

// ════════════════════════════════════════════════════════════════════════════
// CADENAS DE COMBATE — MURCIÉLAGO (se cura; el collar de ajo lo impide)
// ════════════════════════════════════════════════════════════════════════════

final Carta _murcielagoPelea = Carta(
  texto: 'El murciélago absorbe tu energía\ncon cada mordisco. ¡Se fortalece!',
  opcionIzquierda: 'Huir del combate',
  opcionDerecha: 'Golpe certero a las alas',
  efectoIzquierda: (_) => const Consecuencia(deltaVida: -8, deltaTiempo: -5),
  efectoDerecha: (s) {
    // Con el collar de ajo no puede curarse y es más fácil de matar
    if (_victoria(s, base: s.garlicCollar ? 0.70 : 0.30)) {
      return Consecuencia(
        deltaPoder: 6,
        onApply: (st) => st.defeatedEnemies++,
      );
    }
    return Consecuencia(
      deltaVida: -10,
      onApply: (st) => _ir(st, _murcielagoPelea),
    );
  },
);

final _murcielagoEncuentro = Carta(
  texto: 'Un murciélago enorme desciende del techo\nchillando frenéticamente.',
  opcionIzquierda: 'Agacharte y esquivarlo',
  opcionDerecha: 'Atacar',
  efectoIzquierda: (_) => const Consecuencia(deltaTiempo: -3),
  efectoDerecha: (s) => Consecuencia(
    deltaVida: -6,
    onApply: (st) => _ir(st, _murcielagoPelea),
  ),
);

// ════════════════════════════════════════════════════════════════════════════
// CADENAS DE COMBATE — RATA ZOMBIE (aplica veneno)
// ════════════════════════════════════════════════════════════════════════════

final Carta _rataZombiePelea = Carta(
  texto: 'La rata chilla y se lanza hacia tu cuello.\n¡Sus dientes están infectados!',
  opcionIzquierda: 'Apartarla con el brazo',
  opcionDerecha: 'Golpe preciso a la cabeza',
  efectoIzquierda: (s) => Consecuencia(
    deltaVida: -8,
    onApply: (st) {
      if (!st.vaccinated && _sinSuerte(st, 0.5)) st.isEnvenenado = true;
      _ir(st, _rataZombiePelea);
    },
  ),
  efectoDerecha: (s) {
    if (_victoria(s, base: 0.55)) {
      return Consecuencia(
        deltaPoder: 4,
        onApply: (st) => st.defeatedEnemies++,
      );
    }
    return Consecuencia(
      deltaVida: -5,
      onApply: (st) {
        if (!st.vaccinated) st.isEnvenenado = true;
        _ir(st, _rataZombiePelea);
      },
    );
  },
);

final _rataZombieEncuentro = Carta(
  texto: 'Una rata zombie de ojos rojos\nse arrastra hacia ti gimiendo.',
  opcionIzquierda: 'Esquivarla rápido',
  opcionDerecha: 'Eliminarla antes de que muerda',
  efectoIzquierda: (s) {
    if (_sinSuerte(s, 0.3)) {
      return Consecuencia(
        deltaVida: -5,
        onApply: (st) {
          if (!st.vaccinated) st.isEnvenenado = true;
        },
      );
    }
    return const Consecuencia(deltaTiempo: -3);
  },
  efectoDerecha: (s) => Consecuencia(
    onApply: (st) => _ir(st, _rataZombiePelea),
  ),
);

// ════════════════════════════════════════════════════════════════════════════
// CADENAS DE COMBATE — ARAÑA (no se puede huir; las botas ayudan en encuentro)
// ════════════════════════════════════════════════════════════════════════════

final Carta _aranaPelea = Carta(
  texto: 'La araña lanza redes bloqueando\ntoda salida. ¡No puedes escapar!',
  opcionIzquierda: 'Protegerte con los brazos',
  opcionDerecha: 'Atacar sus patas',
  efectoIzquierda: (s) => Consecuencia(
    deltaVida: -15,
    onApply: (st) => _ir(st, _aranaPelea),
  ),
  efectoDerecha: (s) {
    if (_victoria(s, base: 0.45)) {
      return Consecuencia(
        deltaPoder: 8,
        onApply: (st) => st.defeatedEnemies++,
      );
    }
    return Consecuencia(
      deltaVida: -12,
      onApply: (st) => _ir(st, _aranaPelea),
    );
  },
);

final _aranaEncuentro = Carta(
  texto: 'Una araña gigante desciende del techo\nbloqueando completamente el pasillo.',
  opcionIzquierda: 'Intentar huir',
  opcionDerecha: 'Combatir',
  efectoIzquierda: (s) {
    if (s.antiAdherentBoots) {
      return const Consecuencia(deltaTiempo: -5);
    }
    // Sin botas, la telaraña te atrapa y el combate empieza igualmente
    return Consecuencia(
      deltaVida: -10,
      onApply: (st) => _ir(st, _aranaPelea),
    );
  },
  efectoDerecha: (s) => Consecuencia(
    onApply: (st) => _ir(st, _aranaPelea),
  ),
);

// ════════════════════════════════════════════════════════════════════════════
// CADENAS DE COMBATE — VAMPIRO (3 rondas; fightForHonor bloquea la huida)
// ════════════════════════════════════════════════════════════════════════════

final Carta _vampiroPelea2 = Carta(
  texto: 'El vampiro empieza a sangrar.\n¡Está debilitado!',
  opcionIzquierda: 'Rematar de una vez',
  opcionDerecha: 'Golpe final a fondo',
  efectoIzquierda: (s) {
    if (_victoria(s, base: s.garlicCollar ? 0.70 : 0.45)) {
      return Consecuencia(
        deltaPoder: 12,
        onApply: (st) {
          st.defeatedEnemies++;
          st.fightForHonor = false;
        },
      );
    }
    return Consecuencia(
      deltaVida: -15,
      onApply: (st) => _ir(st, _vampiroPelea2),
    );
  },
  efectoDerecha: (s) {
    if (_victoria(s, base: s.garlicCollar ? 0.75 : 0.50)) {
      return Consecuencia(
        deltaPoder: 14,
        onApply: (st) {
          st.defeatedEnemies++;
          st.fightForHonor = false;
        },
      );
    }
    return Consecuencia(
      deltaVida: -12,
      onApply: (st) => _ir(st, _vampiroPelea2),
    );
  },
);

final Carta _vampiroPelea1 = Carta(
  texto: 'El vampiro esquiva tus ataques\ncon una velocidad sobrenatural.',
  opcionIzquierda: 'Intentar huir',
  opcionDerecha: 'Seguir atacando',
  efectoIzquierda: (s) {
    // fightForHonor: prometiste luchar, el vampiro no te deja salir
    if (s.fightForHonor) {
      return Consecuencia(
        deltaVida: -10,
        onApply: (st) => _ir(st, _vampiroPelea1),
      );
    }
    return const Consecuencia(deltaVida: -15, deltaTiempo: -5);
  },
  efectoDerecha: (s) => Consecuencia(
    deltaVida: -12,
    onApply: (st) => _ir(st, _vampiroPelea2),
  ),
);

final _vampiroEncuentro = Carta(
  texto: 'En la oscuridad relucen dos ojos rojos...\n¡Un vampiro ha encontrado su presa!',
  opcionIzquierda: 'Retroceder lentamente',
  opcionDerecha: 'Plantar cara',
  efectoIzquierda: (_) => const Consecuencia(deltaVida: -5, deltaTiempo: -8),
  efectoDerecha: (s) => Consecuencia(
    onApply: (st) => _ir(st, _vampiroPelea1),
  ),
);

// ════════════════════════════════════════════════════════════════════════════
// CADENAS DE COMBATE — SLIME CUBO (drena poder; si no hay poder, drena vida)
// ════════════════════════════════════════════════════════════════════════════

final Carta _slimePelea = Carta(
  texto: 'El slime se lanza sobre ti\nabsorbiendo tu fuerza en cada golpe.',
  opcionIzquierda: 'Protegerte con los brazos',
  opcionDerecha: 'Golpear su núcleo',
  efectoIzquierda: (s) {
    final bool drenaPoder = s.poder > 0;
    return Consecuencia(
      deltaVida: drenaPoder ? 0 : -10,
      deltaPoder: drenaPoder ? -10 : 0,
      onApply: (st) => _ir(st, _slimePelea),
    );
  },
  efectoDerecha: (s) {
    if (_victoria(s, base: 0.40)) {
      return Consecuencia(
        deltaPoder: 15,
        onApply: (st) => st.defeatedEnemies++,
      );
    }
    final bool drenaPoder = s.poder > 0;
    return Consecuencia(
      deltaVida: drenaPoder ? 0 : -10,
      deltaPoder: drenaPoder ? -10 : 0,
      onApply: (st) => _ir(st, _slimePelea),
    );
  },
);

final _slimeCuboEncuentro = Carta(
  texto: 'Un slime cubo enorme llena el pasillo.\n¡Se mueve lento pero lo absorbe todo!',
  opcionIzquierda: 'Intentar rodearlo',
  opcionDerecha: 'Atacarle de frente',
  efectoIzquierda: (_) => const Consecuencia(deltaTiempo: -8),
  efectoDerecha: (s) => Consecuencia(
    onApply: (st) => _ir(st, _slimePelea),
  ),
);

// ════════════════════════════════════════════════════════════════════════════
// COMBATE ESPECIAL — MÍMICO (activado desde la carta del cofre)
// ════════════════════════════════════════════════════════════════════════════

final Carta _mimicoPelea = Carta(
  texto: 'El mímico abre su enorme boca de madera.\n¡Sus dientes de cerradura son letales!',
  opcionIzquierda: 'Intentar huir',
  opcionDerecha: 'Atacar su tapa',
  efectoIzquierda: (_) => const Consecuencia(deltaVida: -15, deltaTiempo: -5),
  efectoDerecha: (s) {
    if (_victoria(s, base: 0.50)) {
      return Consecuencia(
        deltaPoder: 8,
        onApply: (st) => st.defeatedEnemies++,
      );
    }
    return Consecuencia(
      deltaVida: -15,
      onApply: (st) => _ir(st, _mimicoPelea),
    );
  },
);

// ════════════════════════════════════════════════════════════════════════════
// COMBATE ESPECIAL — GOBLIN BLINDADO (activado desde la carta del escudo)
// ════════════════════════════════════════════════════════════════════════════

final Carta _goblinBlinadoPelea = Carta(
  texto: 'El goblin blindado bloquea cada golpe\ncon el escudo de acero que dejaste.',
  opcionIzquierda: 'Intentar quitarle el escudo',
  opcionDerecha: 'Buscar un hueco en la defensa',
  efectoIzquierda: (s) {
    if (_victoria(s, base: 0.35)) {
      return Consecuencia(
        deltaPoder: 20,
        onApply: (st) => st.defeatedEnemies++,
      );
    }
    return Consecuencia(
      deltaVida: -12,
      onApply: (st) => _ir(st, _goblinBlinadoPelea),
    );
  },
  efectoDerecha: (s) {
    if (_victoria(s, base: 0.40)) {
      return Consecuencia(
        deltaPoder: 20,
        onApply: (st) => st.defeatedEnemies++,
      );
    }
    return Consecuencia(
      deltaVida: -10,
      onApply: (st) => _ir(st, _goblinBlinadoPelea),
    );
  },
);

// ════════════════════════════════════════════════════════════════════════════
// CARTAS NARRATIVAS
// ════════════════════════════════════════════════════════════════════════════

final List<Carta> todasLasCartas = [

  // ── CADÁVER CON EQUIPAMIENTO ─────────────────────────────────────────────
  Carta(
    texto: 'Un aventurero caído yace en el camino.\nSu armadura parece intacta...',
    opcionIzquierda: 'Ignorarlo',
    opcionDerecha: 'Robarle el equipo',
    efectoIzquierda: (_) => const Consecuencia(deltaSuerte: 3, deltaTiempo: -5),
    efectoDerecha: (s) {
      if (_sinSuerte(s, 0.5)) {
        // Se levanta como no-muerto — entra directamente en combate
        return Consecuencia(
          deltaVida: -10,
          onApply: (st) => _ir(st, _esqueletoPelea),
        );
      }
      return const Consecuencia(deltaPoder: 15, deltaSuerte: -5);
    },
  ),

  // ── COFRE (mímico o recompensa) ──────────────────────────────────────────
  Carta(
    texto: 'Un cofre ornamentado reposa en una hornacina.\nParece demasiado perfecto...',
    opcionIzquierda: 'Ignorarlo',
    opcionDerecha: 'Abrirlo',
    efectoIzquierda: (_) => const Consecuencia(deltaTiempo: -3),
    efectoDerecha: (s) {
      if (_sinSuerte(s, 0.5)) {
        return Consecuencia(
          onApply: (st) => _ir(st, _mimicoPelea),
        );
      }
      if (s.isEnvenenado) {
        return Consecuencia(
          deltaSuerte: 5,
          onApply: (st) => st.isEnvenenado = false,
        );
      }
      return const Consecuencia(deltaPoder: 10, deltaVida: 10);
    },
  ),

  // ── ESCUDO DE ACERO ──────────────────────────────────────────────────────
  Carta(
    texto: 'Un reluciente escudo de acero está clavado\nen la roca del pasillo.',
    opcionIzquierda: 'Dejarlo ahí',
    opcionDerecha: 'Cogerlo',
    condicion: (s) => !s.steelShieldFound,
    efectoIzquierda: (_) => Consecuencia(
      deltaTiempo: -3,
      onApply: (s) {
        s.steelShieldFound = true;
        s.steelShieldLeft = true;
      },
    ),
    efectoDerecha: (_) => Consecuencia(
      deltaPoder: 15,
      onApply: (s) {
        s.steelShieldFound = true;
        s.steelShieldLeft = false;
      },
    ),
  ),

  // ── GOBLIN BLINDADO (follow-up si dejaste el escudo) ────────────────────
  Carta(
    texto: 'Un goblin te corta el paso empuñando\nel escudo de acero que dejaste atrás.',
    opcionIzquierda: 'Huir antes de que reaccione',
    opcionDerecha: 'Combatir',
    condicion: (s) => s.steelShieldLeft,
    efectoIzquierda: (_) => Consecuencia(
      deltaTiempo: -10,
      onApply: (s) => s.steelShieldLeft = false,
    ),
    efectoDerecha: (_) => Consecuencia(
      onApply: (s) {
        _ir(s, _goblinBlinadoPelea);
        s.steelShieldLeft = false;
      },
    ),
  ),

  // ── SLIME AGRADECIDO (follow-up si dejaste el escudo) ───────────────────
  Carta(
    texto: 'Un slime rueda hacia ti con el escudo\nde acero. "¡Glup! ¡Gracias!"',
    opcionIzquierda: 'Aceptar su ofrenda',
    opcionDerecha: 'Rechazarla',
    condicion: (s) => s.steelShieldLeft,
    efectoIzquierda: (_) => Consecuencia(
      deltaPoder: 20,
      deltaSuerte: 10,
      onApply: (s) {
        s.steelShieldLeft = false;
        s.watchSlime = true;
      },
    ),
    efectoDerecha: (_) => Consecuencia(
      deltaSuerte: -3,
      onApply: (s) => s.steelShieldLeft = false,
    ),
  ),

  // ── SLIME PIDE LAS BOTAS ─────────────────────────────────────────────────
  Carta(
    texto: 'Un slime te bloquea el camino.\n"¡Glup! Dame tus botas\nanti-adherentes... o pelearemos."',
    opcionIzquierda: 'Darle las botas',
    opcionDerecha: 'Atacar',
    condicion: (s) => s.antiAdherentBoots,
    efectoIzquierda: (_) => Consecuencia(
      deltaSuerte: 10,
      onApply: (s) => s.antiAdherentBoots = false,
    ),
    efectoDerecha: (s) => Consecuencia(
      onApply: (st) => _ir(st, _slimePelea),
    ),
  ),

  // ── AVENTURERO PIDE AYUDA ────────────────────────────────────────────────
  Carta(
    texto: 'Un aventurero herido te detiene:\n"¡Hay un vampiro más adelante!\n¡Ayúdame a derrotarlo!"',
    opcionIzquierda: 'Negarte',
    opcionDerecha: 'Ayudarle',
    efectoIzquierda: (_) => const Consecuencia(deltaSuerte: -5),
    efectoDerecha: (_) => Consecuencia(
      onApply: (s) {
        s.fightForHonor = true;
        _ir(s, _vampiroPelea1);
      },
    ),
  ),

  // ── PASILLO SOSPECHOSO ───────────────────────────────────────────────────
  Carta(
    texto: 'El pasillo se estrecha. En la oscuridad\nse escuchan extraños crujidos.',
    opcionIzquierda: 'Dar media vuelta',
    opcionDerecha: 'Atravesarlo',
    efectoIzquierda: (_) => const Consecuencia(deltaTiempo: -10),
    efectoDerecha: (s) {
      if (_conSuerte(s, 0.5)) {
        return const Consecuencia(deltaPoder: 5, deltaSuerte: 3);
      }
      return const Consecuencia(deltaVida: -15);
    },
  ),

  // ── CANTIMPLORA ──────────────────────────────────────────────────────────
  Carta(
    texto: 'Una cantimplora abollada yace en el suelo.\nPodría tener algo dentro...',
    opcionIzquierda: 'Dejarla ahí',
    opcionDerecha: 'Beber de ella',
    efectoIzquierda: (_) => const Consecuencia(),
    efectoDerecha: (s) {
      if (!s.vaccinated && _sinSuerte(s, 0.15)) {
        return Consecuencia(
          deltaVida: -5,
          onApply: (st) => st.isEnvenenado = true,
        );
      }
      return const Consecuencia(deltaVida: 20);
    },
  ),

  // ── ENCUENTROS CON ENEMIGOS ──────────────────────────────────────────────

  _esqueletoEncuentro,
  _goblinEncuentro,
  _murcielagoEncuentro,
  _rataZombieEncuentro,
  _aranaEncuentro,
  _vampiroEncuentro,
  _slimeCuboEncuentro,
];
