// FFTBackground2 renders a simple fast fourier transform visualizer.  used when the tuning isn't specified
class FFTBackground2 extends EDOVisualizer {
  float effect_amplitude = 800;
  public FFTBackground2(PApplet parent) {
     super(parent, 8192, 24); 
  }
  public void render(float[] pitchAverages, int highestPitch) {
    float center_x = width/2;
      float center_y = height/2;
      
      int display_bands = round(width/8);
      
      for(int i = 1; i < display_bands; i++) {
        int basePitch = i + 60;
        stroke(20+50*log(1+40*pitchAverages[basePitch]));
        float line_height = sqrt(pitchAverages[basePitch])*effect_amplitude *pow((width - i*8)*2./width,1.5);
        
        line(center_x + i*4, center_y - line_height, center_x + i*4, center_y + line_height);
        line(center_x - (i*4), center_y - line_height, center_x - i*4, center_y + line_height);

      }
  }
}
