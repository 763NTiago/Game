import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:meu_jogo/jogador/personagem.dart';
import 'package:meu_jogo/mundo/escola/fase_escola.dart';
import 'package:meu_jogo/jogo/controle_esc.dart';
import 'package:meu_jogo/menu/menu.dart';

class JogoCasa extends FlameGame<World> with HasKeyboardHandlerComponents<World> {
  Menu? _menu;
  FaseEscola? _cena;

  bool get noMenu => _cena == null;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(ControleEsc());
    await mostrarMenu();
  }

  Future<void> mostrarMenu() async {
    _cena?.removeFromParent();
    _cena = null;
    _menu?.removeFromParent();

    _menu = Menu(
      onSelecionado: (personagem) {
        _menu?.removeFromParent();
        _menu = null;
        iniciarJogo(personagem);
      },
    );
    await add(_menu!);
  }

  Future<void> iniciarJogo(Personagem personagem) async {
    _cena = FaseEscola(personagem: personagem);
    await add(_cena!);
  }
}
