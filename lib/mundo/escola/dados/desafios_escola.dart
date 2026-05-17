import 'package:meu_jogo/mundo/escola/desafio_config.dart';

/// Cinco desafios — um por porta da escola.
const List<DesafioConfig> desafiosPortasEscola = [
  DesafioConfig(
    porta: 1,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é 4 + 6?',
    opcoes: ['8', '9', '10', '11', '12'],
    indiceCorreto: 2,
  ),
  DesafioConfig(
    porta: 2,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é 5 + 5?',
    opcoes: ['8', '9', '10', '11', '12'],
    indiceCorreto: 2,
  ),
  DesafioConfig(
    porta: 3,
    tipo: TipoDesafio.palavra,
    pergunta: 'Complete a palavra:\nA _ u _ a',
    opcoes: ['Aula', 'Casa', 'Sala', 'Mesa', 'Lua'],
    indiceCorreto: 0,
  ),
  DesafioConfig(
    porta: 4,
    tipo: TipoDesafio.palavra,
    pergunta: 'Complete a palavra:\nPr _ fes _ o _',
    opcoes: ['Professor', 'Proferor', 'Prefeito', 'Programa', 'Processo'],
    indiceCorreto: 0,
  ),
  DesafioConfig(
    porta: 5,
    tipo: TipoDesafio.palavra,
    pergunta: 'Complete a palavra:\nEs _ o _ a',
    opcoes: ['Escola', 'Estola', 'Espada', 'Escala', 'Essora'],
    indiceCorreto: 0,
  ),
];
