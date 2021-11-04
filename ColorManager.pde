enum Palette {
  BLUE_MAGENTA,
  ORANGE_BLUE,
  ORANGE_GRAY,
  BLUE_GREEN,
  RED_ORANGE,
  DEEP_BLUE
}

color[] ColorPalette(Palette palette) {
  color[] colors = new color[2];
  switch(palette) {
     case BLUE_MAGENTA:
       colors[0] = color(20, 80, 180);
       colors[1] = color(120, 20, 70);
       break;
     case ORANGE_BLUE:
       colors[0] = color(120, 50, 10);
       colors[1] = color(40, 80, 180);
       break;
     case ORANGE_GRAY:
       colors[0] = color(120, 50, 10);
       colors[1] = color(30, 100, 140);
       break;
     case BLUE_GREEN:
       colors[0] = color(50, 150, 30);
       colors[1] = color(20, 80, 140);
       break;
     case RED_ORANGE:
       colors[0] = color(180, 50, 10);
       colors[1] = color(100, 100, 50);
       break;
     case DEEP_BLUE:
       colors[0] = color(40, 5, 90);
       colors[1] = color(10, 120, 140);
       break;
     default:
       colors[0] = color(20, 80, 180);
       colors[1] = color(120, 20, 70);
       break;
  }
  return colors;
}
