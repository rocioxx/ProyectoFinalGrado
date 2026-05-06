class Scenario {
  const Scenario({
    required this.texto,
    required this.opcionIzquierda,
    required this.opcionDerecha,
  });

  final String texto;
  final String opcionIzquierda;
  final String opcionDerecha;
}

const List<Scenario> escenarios = [
  Scenario(
    texto: 'Un chamoy bloquea el camino',
    opcionIzquierda: 'Lo ignoras',
    opcionDerecha: 'Lo confrontas con una chancla',
  ),
  Scenario(
    texto: 'Un personaje te ofrece dinero si le vendes un chamoy',
    opcionIzquierda: 'Se lo vendes',
    opcionDerecha: 'No se lo vendes',
  ),
  Scenario(
    texto: 'Encuentras un cofre misterioso',
    opcionIzquierda: 'Lo ignoras',
    opcionDerecha: 'Lo abres',
  ),
  Scenario(
    texto: 'El oráculo te pide un favor',
    opcionIzquierda: 'Te niegas',
    opcionDerecha: 'Aceptas',
  ),
];
