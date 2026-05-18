import 'package:meu_jogo/mundo/escola/desafio_config.dart';

/// Pool de desafios para crianças de 4–6 anos.
///
/// Conteúdo:
/// - Matemática: somas simples até 10
/// - Palavras: completar sílabas e letras
/// - Letras: reconhecer a letra inicial
///
/// O [fase_escola.dart] embaralha e pega 5 por partida,
/// então a criança sempre vê perguntas diferentes.
const List<DesafioConfig> poolDesafiosEscola = [

  // ─────────────────────────────────────────────
  // MATEMÁTICA — somas até 10
  // ─────────────────────────────────────────────

  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é\n1 + 1?',
    opcoes: ['1', '2', '3', '4', '5'],
    indiceCorreto: 1,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é\n2 + 1?',
    opcoes: ['2', '3', '4', '5', '6'],
    indiceCorreto: 1,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é\n2 + 2?',
    opcoes: ['3', '4', '5', '6', '7'],
    indiceCorreto: 1,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é\n3 + 1?',
    opcoes: ['3', '4', '5', '6', '7'],
    indiceCorreto: 1,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é\n3 + 2?',
    opcoes: ['4', '5', '6', '7', '8'],
    indiceCorreto: 1,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é\n4 + 1?',
    opcoes: ['3', '4', '5', '6', '7'],
    indiceCorreto: 2,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é\n4 + 2?',
    opcoes: ['4', '5', '6', '7', '8'],
    indiceCorreto: 2,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é\n5 + 1?',
    opcoes: ['4', '5', '6', '7', '8'],
    indiceCorreto: 2,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é\n5 + 5?',
    opcoes: ['8', '9', '10', '11', '12'],
    indiceCorreto: 2,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é\n3 + 3?',
    opcoes: ['4', '5', '6', '7', '8'],
    indiceCorreto: 2,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é\n4 + 4?',
    opcoes: ['6', '7', '8', '9', '10'],
    indiceCorreto: 2,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.matematica,
    pergunta: 'Quanto é\n2 + 3?',
    opcoes: ['3', '4', '5', '6', '7'],
    indiceCorreto: 2,
  ),

  // ─────────────────────────────────────────────
  // PALAVRAS — completar sílabas simples
  // ─────────────────────────────────────────────

  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.palavra,
    pergunta: 'Qual é a palavra?\nBO _ A',
    opcoes: ['Bola', 'Boca', 'Bota', 'Boba', 'Bora'],
    indiceCorreto: 0,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.palavra,
    pergunta: 'Qual é a palavra?\nCA _ A',
    opcoes: ['Casa', 'Cama', 'Cara', 'Cava', 'Cana'],
    indiceCorreto: 0,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.palavra,
    pergunta: 'Qual é a palavra?\nPA _ O',
    opcoes: ['Pato', 'Pavo', 'Paro', 'Paso', 'Paco'],
    indiceCorreto: 0,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.palavra,
    pergunta: 'Qual é a palavra?\nGA _ O',
    opcoes: ['Gato', 'Gavo', 'Garo', 'Gaco', 'Gano'],
    indiceCorreto: 0,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.palavra,
    pergunta: 'Qual é a palavra?\nME _ A',
    opcoes: ['Mesa', 'Mela', 'Mera', 'Meva', 'Mena'],
    indiceCorreto: 0,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.palavra,
    pergunta: 'Qual é a palavra?\nSA _ O',
    opcoes: ['Sapo', 'Saro', 'Savo', 'Saco', 'Sano'],
    indiceCorreto: 0,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.palavra,
    pergunta: 'Qual é a palavra?\nLI _ O',
    opcoes: ['Livro', 'Liro', 'Livo', 'Lico', 'Lino'],
    indiceCorreto: 0,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.palavra,
    pergunta: 'Qual é a palavra?\nSO _',
    opcoes: ['Sol', 'Som', 'Sor', 'Sof', 'Sov'],
    indiceCorreto: 0,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.palavra,
    pergunta: 'Qual é a palavra?\nA _ UL A',
    opcoes: ['Aula', 'Abula', 'Acула', 'Adula', 'Afula'],
    indiceCorreto: 0,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.palavra,
    pergunta: 'Qual é a palavra?\nES _ O _ A',
    opcoes: ['Escola', 'Estola', 'Espola', 'Escoba', 'Escona'],
    indiceCorreto: 0,
  ),

  // ─────────────────────────────────────────────
  // LETRAS — qual letra começa a palavra
  // ─────────────────────────────────────────────

  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.letra,
    pergunta: 'Qual letra começa\na palavra BOLA?',
    opcoes: ['A', 'B', 'C', 'D', 'E'],
    indiceCorreto: 1,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.letra,
    pergunta: 'Qual letra começa\na palavra CASA?',
    opcoes: ['A', 'B', 'C', 'D', 'E'],
    indiceCorreto: 2,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.letra,
    pergunta: 'Qual letra começa\na palavra DADO?',
    opcoes: ['A', 'B', 'C', 'D', 'E'],
    indiceCorreto: 3,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.letra,
    pergunta: 'Qual letra começa\na palavra ELEFANTE?',
    opcoes: ['A', 'B', 'C', 'D', 'E'],
    indiceCorreto: 4,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.letra,
    pergunta: 'Qual letra começa\na palavra FACA?',
    opcoes: ['D', 'E', 'F', 'G', 'H'],
    indiceCorreto: 2,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.letra,
    pergunta: 'Qual letra começa\na palavra GATO?',
    opcoes: ['D', 'E', 'F', 'G', 'H'],
    indiceCorreto: 3,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.letra,
    pergunta: 'Qual letra começa\na palavra UVAS?',
    opcoes: ['S', 'T', 'U', 'V', 'X'],
    indiceCorreto: 2,
  ),
  DesafioConfig(
    porta: 0,
    tipo: TipoDesafio.letra,
    pergunta: 'Qual letra começa\na palavra PATO?',
    opcoes: ['M', 'N', 'O', 'P', 'Q'],
    indiceCorreto: 3,
  ),
];
