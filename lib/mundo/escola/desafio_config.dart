/// Tipo de desafio atrás de cada porta.
enum TipoDesafio {
  matematica,
  palavra,
}

/// Dados de um desafio (pergunta + 5 alternativas).
class DesafioConfig {
  const DesafioConfig({
    required this.porta,
    required this.tipo,
    required this.pergunta,
    required this.opcoes,
    required this.indiceCorreto,
  });

  final int porta;
  final TipoDesafio tipo;
  final String pergunta;
  final List<String> opcoes;
  final int indiceCorreto;
}
