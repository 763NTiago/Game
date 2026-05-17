import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/jogo/jogo_casa.dart';

/// ESC volta ao menu quando estiver jogando.
class ControleEsc extends Component
    with KeyboardHandler, HasGameReference<JogoCasa> {
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape &&
        !game.noMenu) {
      game.mostrarMenu();
      return true;
    }
    return false;
  }
}
