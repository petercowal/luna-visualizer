import processing.sound.*;

SoundFile nowPlaying;
String title;
PFont font24;
PFont font36;
PFont font28;
TonnetzVisualizer tonnetzVisualizer;
EclipseVisualizer eclipseVisualizer;
RingVisualizer ringVisualizer;
FFTBackground2 fftBackground;

void setup() {
  
  
  // determines the tuning system used by the pitch class analyzer
  int edo = 19;
  nowPlaying = new SoundFile(this, "petet_19.wav");
  
  // displays song title
  title = "";
  
  color[] colors = ColorPalette(Palette.BLUE_MAGENTA);
  color color1 = colors[0]; 
  color color2 = colors[1];

  size(1280, 720, P2D);
  background(0);
  
  fftBackground = new FFTBackground2(this);
  eclipseVisualizer = new EclipseVisualizer(this, edo*2);
  ringVisualizer = new RingVisualizer(this, edo);
  tonnetzVisualizer = new TonnetzVisualizer(this, edo);
  
  // controls the scale of the visual effects.  boost if necessary!
  eclipseVisualizer.effect_amplitude = 150;
  
  eclipseVisualizer.color1 = color1;
  eclipseVisualizer.color2 = color2;
  
  ringVisualizer.color1 = color1;
  ringVisualizer.color2 = color2;

  eclipseVisualizer.input(nowPlaying);
  ringVisualizer.input(nowPlaying);
  tonnetzVisualizer.input(nowPlaying);
  fftBackground.input(nowPlaying);

  font24 = loadFont("SourceSansPro-Light-24.vlw");
  font28 = loadFont("SourceCodePro-Light-28.vlw");
  font36 = loadFont("SourceCodePro-Light-36.vlw");
}

int startTime = 0;

void draw() {
  // play song on key press
  if(keyPressed && !nowPlaying.isPlaying()) {
    nowPlaying.play();
    startTime = millis();
  }
  
  int playTimeMillis = (millis() - startTime);
  if (startTime == 0) playTimeMillis = 0;
  
  blendMode(NORMAL);
  background(20);
  
  textAlign(CENTER, CENTER);
  textFont(font24, 24);
  int t1 = millis();
  tonnetzVisualizer.Render();
  //fftBackground.Render();
  
  boolean flashing = false;
  
  if (!flashing || (playTimeMillis % 250 > 125)) {
    eclipseVisualizer.Render();
    ringVisualizer.Render();
  } else {
    //replace the circle in the center
    float center_x = width/2;
    float center_y = height/2;
    noStroke();
    
    blendMode(NORMAL);
    fill(18);
    circle(center_x, center_y, 2*eclipseVisualizer.base_radius); 
  }
  println(millis() - t1);
  
  if(nowPlaying.isPlaying()) {
    textFont(font28, 28);
    blendMode(NORMAL);
    fill(255);
    text(title, width/2, height/2 + 280);
  }
}
