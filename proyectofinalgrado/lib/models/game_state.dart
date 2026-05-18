class GameState {
  GameState({
    this.vida = 100,
    this.suerte = 50,
    this.tiempo = 100,
    this.poder = 20,
    this.isEnvenenado = false,
    this.vaccinated = false,
    this.antiAdherentBoots = false,
    this.garlicCollar = false,
    this.fightForHonor = false,
    this.steelShieldFound = false,
    this.steelShieldLeft = false,
    this.watchSlime = false,
    this.defeatedEnemies = 0,
    this.textoResolucion = '',
    this.cartaPendiente,
  });

  // ── Estadísticas principales (rango 0–100) ──────────────────────────────
  double vida;
  double suerte;
  double tiempo;
  double poder;

  // ── Estados alterados ────────────────────────────────────────────────────
  bool isEnvenenado;
  bool vaccinated;

  // ── Objetos (flags de inventario) ────────────────────────────────────────
  bool antiAdherentBoots;
  bool garlicCollar;

  // ── Flags de narrativa / misión ──────────────────────────────────────────
  bool fightForHonor;
  bool steelShieldFound;
  bool steelShieldLeft;
  bool watchSlime;

  // ── Contadores de misiones ───────────────────────────────────────────────
  int defeatedEnemies;

  // ── Carta forzada para el próximo turno ──────────────────────────────────
  // Se usa para encadenar decisiones narrativas (combate, consecuencias).
  // Typed as Object? para evitar dependencia circular con carta.dart.
  Object? cartaPendiente;

  String textoResolucion;
}
