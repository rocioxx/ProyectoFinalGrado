class StatsController {
  StatsController({
    this.vida = 0.9,
    this.experiencia = 0.9,
    this.nivel = 0.9,
    this.fuerza = 0.9,
  });

  double vida;
  double experiencia;
  double nivel;
  double fuerza;

  void restarVida(double cantidad) => vida = (vida - cantidad).clamp(0.0, 1.0);

  void sumarVida(double cantidad) => vida = (vida + cantidad).clamp(0.0, 1.0);

  void aumentarExperiencia(double cantidad) =>
      experiencia = (experiencia + cantidad).clamp(0.0, 1.0);

  void reducirExperiencia(double cantidad) =>
      experiencia = (experiencia - cantidad).clamp(0.0, 1.0);

  void aumentarFuerza(double cantidad) =>
      fuerza = (fuerza + cantidad).clamp(0.0, 1.0);

  void reducirFuerza(double cantidad) =>
      fuerza = (fuerza - cantidad).clamp(0.0, 1.0);

  void subirNivel(double cantidad) =>
      nivel = (nivel + cantidad).clamp(0.0, 1.0);

  void bajarNivel(double cantidad) =>
      nivel = (nivel - cantidad).clamp(0.0, 1.0);
}
