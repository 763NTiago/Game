/// Tipo de desafio atrás de cada porta.
enum TipoDesafio {
  matematica,
  palavra,
  letra, // ← novo: reconhecer letra inicial
}

/// Dados de um desafio (pergunta + até 5 alternativas).
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

  /// Cria uma cópia trocando só o número da porta.
  /// Usado pelo fase_escola.dart ao sortear desafios do pool.
  DesafioConfig copyWith({
    int? porta,
    TipoDesafio? tipo,
    String? pergunta,
    List<String>? opcoes,
    int? indiceCorreto,
  }) {
    return DesafioConfig(
      porta:         porta         ?? this.porta,
      tipo:          tipo          ?? this.tipo,
      pergunta:      pergunta      ?? this.pergunta,
      opcoes:        opcoes        ?? this.opcoes,
      indiceCorreto: indiceCorreto ?? this.indiceCorreto,
    );
  }

  /// Label amigável para mostrar no painel de desafio.
  String get labelTipo {
    switch (tipo) {
      case TipoDesafio.matematica:
        return 'Desafio de matemática 🔢';
      case TipoDesafio.palavra:
        return 'Complete a palavra 📝';
      case TipoDesafio.letra:
        return 'Qual é a letra? 🔤';
    }
  }
}
