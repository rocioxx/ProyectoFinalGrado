class GameState {
  GameState({
    this.vida = 50,
    this.suerte = 50,
    this.tiempo = 100,
    this.poder = 10,
    this.defeatedEnemies = 0,
    this.cartaPendiente,
    this.victoria = false,
    this.iniciada = false,
    this.enemyVida,
    this.enemyMaxVida,
    this.cantimploraEncontrada = false,
    this.aventureroEncontrado = false,
    this.puertaFinalAlcanzada = false,
    List<int>? enemyQueue,
    this.abGroup = 'A',
  }) : enemyQueue = enemyQueue ?? [];

  double vida;
  double suerte;
  double tiempo;
  double poder;

  int defeatedEnemies;
  Object? cartaPendiente;
  bool victoria;
  bool iniciada;
  double? enemyVida;
  double? enemyMaxVida;
  bool cantimploraEncontrada;
  bool aventureroEncontrado;
  bool puertaFinalAlcanzada;
  List<int> enemyQueue;
  String abGroup;
}
