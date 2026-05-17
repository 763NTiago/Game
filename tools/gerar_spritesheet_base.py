"""Gera spritesheet base 192x32 (6 frames de 32x32) para o jogador."""

from pathlib import Path

from PIL import Image, ImageDraw

FRAME = 32
COLS = 6
W, H = FRAME * COLS, FRAME
OUT = Path(__file__).resolve().parents[1] / "assets" / "images" / "skin" / "jogador.png"

# Cores (estilo pixel simples)
SKY = (40, 44, 52, 0)
SKIN = (255, 198, 140)
SHIRT = (66, 135, 245)
PANTS = (52, 88, 168)
SHOES = (45, 45, 55)
HAIR = (90, 55, 35)
OUTLINE = (25, 25, 35)


def rect(draw, x, y, w, h, fill):
    draw.rectangle([x, y, x + w - 1, y + h - 1], fill=fill, outline=OUTLINE)


def draw_idle(draw, ox, oy):
    """Parado."""
    rect(draw, ox + 12, oy + 4, 8, 8, HAIR)      # cabeca
    rect(draw, ox + 11, oy + 12, 10, 10, SHIRT)  # corpo
    rect(draw, ox + 8, oy + 14, 4, 8, SHIRT)     # braco esq
    rect(draw, ox + 20, oy + 14, 4, 8, SHIRT)    # braco dir
    rect(draw, ox + 11, oy + 22, 4, 8, PANTS)    # perna esq
    rect(draw, ox + 17, oy + 22, 4, 8, PANTS)    # perna dir
    rect(draw, ox + 10, oy + 28, 6, 4, SHOES)
    rect(draw, ox + 16, oy + 28, 6, 4, SHOES)


def draw_walk(draw, ox, oy, step: int):
    """Andando - 3 passos."""
    sway = [-1, 0, 1][step % 3]
    rect(draw, ox + 12, oy + 4, 8, 8, HAIR)
    rect(draw, ox + 11 + sway, oy + 12, 10, 10, SHIRT)
    rect(draw, ox + 7, oy + 15 + step, 4, 7, SHIRT)
    rect(draw, ox + 21, oy + 14 - step, 4, 7, SHIRT)
    # pernas alternadas
    if step == 0:
        rect(draw, ox + 9, oy + 22, 5, 7, PANTS)
        rect(draw, ox + 18, oy + 24, 5, 6, PANTS)
    elif step == 1:
        rect(draw, ox + 11, oy + 22, 4, 8, PANTS)
        rect(draw, ox + 17, oy + 22, 4, 8, PANTS)
    else:
        rect(draw, ox + 18, oy + 22, 5, 7, PANTS)
        rect(draw, ox + 9, oy + 24, 5, 6, PANTS)
    rect(draw, ox + 9, oy + 28, 6, 4, SHOES)
    rect(draw, ox + 17, oy + 28, 6, 4, SHOES)


def draw_jump(draw, ox, oy):
    """Pulando - bracos pra cima."""
    rect(draw, ox + 12, oy + 2, 8, 8, HAIR)
    rect(draw, ox + 11, oy + 10, 10, 10, SHIRT)
    rect(draw, ox + 8, oy + 6, 4, 8, SHIRT)
    rect(draw, ox + 20, oy + 6, 4, 8, SHIRT)
    rect(draw, ox + 10, oy + 20, 5, 6, PANTS)
    rect(draw, ox + 17, oy + 20, 5, 6, PANTS)
    rect(draw, ox + 9, oy + 26, 6, 4, SHOES)
    rect(draw, ox + 17, oy + 26, 6, 4, SHOES)


def draw_fall(draw, ox, oy):
    """Caindo - bracos abertos."""
    rect(draw, ox + 12, oy + 6, 8, 8, HAIR)
    rect(draw, ox + 11, oy + 14, 10, 10, SHIRT)
    rect(draw, ox + 5, oy + 16, 6, 4, SHIRT)
    rect(draw, ox + 21, oy + 16, 6, 4, SHIRT)
    rect(draw, ox + 10, oy + 24, 5, 6, PANTS)
    rect(draw, ox + 17, oy + 24, 5, 6, PANTS)
    rect(draw, ox + 9, oy + 28, 6, 4, SHOES)
    rect(draw, ox + 17, oy + 28, 6, 4, SHOES)


def main():
    img = Image.new("RGBA", (W, H), SKY)
    draw = ImageDraw.Draw(img)

    # fundo leve por frame (ajuda a ver separacao no editor)
    labels = ["#2d3436", "#3d4f5f", "#3d5f4f", "#3d5f4f", "#5f4f3d", "#5f3d4f"]
    for i, hex_c in enumerate(labels):
        r = int(hex_c[1:3], 16)
        g = int(hex_c[3:5], 16)
        b = int(hex_c[5:7], 16)
        draw.rectangle([i * FRAME, 0, (i + 1) * FRAME - 1, H - 1], fill=(r, g, b, 40))

    draw_idle(draw, 0, 0)
    draw_walk(draw, FRAME * 1, 0, 0)
    draw_walk(draw, FRAME * 2, 0, 1)
    draw_walk(draw, FRAME * 3, 0, 2)
    draw_jump(draw, FRAME * 4, 0)
    draw_fall(draw, FRAME * 5, 0)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT, "PNG")
    print(f"Salvo: {OUT} ({W}x{H})")


if __name__ == "__main__":
    main()
