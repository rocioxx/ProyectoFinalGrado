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
    this.victoria = false,
  });

  double vida;
  double suerte;
  double tiempo;
  double poder;

  bool isEnvenenado;
  bool vaccinated;
  bool antiAdherentBoots;
  bool garlicCollar;
  bool fightForHonor;
  bool steelShieldFound;
  bool steelShieldLeft;
  bool watchSlime;

  int defeatedEnemies;
  Object? cartaPendiente;
  String textoResolucion;
  bool victoria;
}
