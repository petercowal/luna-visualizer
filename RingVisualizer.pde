// RingVisualizer renders a ring of numbers representing detected pitch classes at higher accuracy, slower response rate
class RingVisualizer extends EDOVisualizer {
  color color1 = color(120, 50, 10);
  color color2 = color(60, 100, 180);
  
  public RingVisualizer(PApplet parent, int edo) {
    super(parent, 16384, edo);

  }
  
  public void render(float[] pitchAverages, int highestPitch) {
    
    float center_x = width/2;
    float center_y = height/2;
    
    float[] reds = new float[edo];
    float[] greens = new float[edo];
    float[] blues = new float[edo];
    
    for (int i = 0; i < highestPitch; i++ ) {
       color currentColor = lerpColor(color1, color2, float(i)/highestPitch);
       int pitchClass = i % edo;
       float amplitude = 2*log(1 + 10*max(0, pitchAverages[i] - 0.01)) * min(1, (highestPitch - i)*0.2/edo);
       reds[pitchClass] += red(currentColor) * amplitude;
       greens[pitchClass] += green(currentColor) * amplitude;
       blues[pitchClass] += blue(currentColor) * amplitude;
    }
    
    float base_radius = 170;
    textAlign(CENTER, CENTER);
    for (int i = 0; i < edo; i++) {
      float theta = i*2.0*PI/edo - 0.5*PI;
      fill(reds[i], greens[i], blues[i]);
      
      text(str(i), center_x + cos(theta) * base_radius, center_y + sin(theta) * base_radius);
    }
  }
}
