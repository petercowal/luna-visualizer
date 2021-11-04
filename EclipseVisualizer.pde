// EclipseVisualizer renders a "fiery ring" representing pitch classes at a high response rate
// the color of the ring is determined by the frequency bands and the color palette
class EclipseVisualizer extends EDOVisualizer {
  
  color color1 = color(120, 50, 10);
  color color2 = color(60, 100, 180);
  int blendmode = ADD;
  
  float base_radius = 200;
  float effect_amplitude = 100;

  float[] radii = new float[1024];
  float[] prevradii = new float[1024];

  public EclipseVisualizer(PApplet parent, int edo) {
    super(parent, 4096, edo);
  }

  public void render(float[] pitchAverages, int highestPitch) {
    float center_x = width/2;
    float center_y = height/2;
    noStroke();
    
    blendMode(NORMAL);
    fill(18);
    circle(center_x, center_y, 2*base_radius);
    
    blendMode(blendmode);

    for (int i = 0; i < 1024; i++) {
      radii[i] = log(1 + 10*pitchAverages[i])*effect_amplitude;
    }


    for (int i = 0; i < highestPitch; i++ ) {
      color currentColor = lerpColor(color1, color2, float(i)/highestPitch);

      float theta1 = i*2.0*PI/edo - 0.5*PI;

      float theta2 = (i+1)*2.0*PI/edo - 0.5*PI;

      float cc1 = cos(theta1);
      float ss1 = sin(theta1);
      float cc2 = cos(theta2);
      float ss2 = sin(theta2);

      // separate red/cyan channels for cool chromatic aberration
      
      // draw red ring channel at an offset
      fill(color(red(currentColor), 0, 0));
      float r1 = base_radius + (radii[i]*0.5 + prevradii[i]*0.5);
      float r2 = base_radius + (radii[i+1]*0.5 + prevradii[i+1]*0.5);

      float ir1 = base_radius - 0.16*(radii[i]);
      float ir2 = base_radius - 0.16*(radii[i+1]);
      quad(center_x+r1*cc1, center_y+r1*ss1, 
        center_x+r2*cc2, center_y+r2*ss2, 
        center_x+ir2*cc2, center_y+ir2*ss2, 
        center_x+ir1*cc1, center_y+ir1*ss1);

      // draw cyan ring channel at a different offset
      fill(color(0, green(currentColor), blue(currentColor)));
      r1 = base_radius + (radii[i]*1 + prevradii[i]*0)*0.9;
      r2 = base_radius + (radii[i+1]*1 + prevradii[i+1]*0)*0.9;
      ir1 = base_radius - 0.1*(radii[i]);
      ir2 = base_radius - 0.1*(radii[i+1]);
      quad(center_x+r1*cc1, center_y+r1*ss1, 
        center_x+r2*cc2, center_y+r2*ss2, 
        center_x+ir2*cc2, center_y+ir2*ss2, 
        center_x+ir1*cc1, center_y+ir1*ss1);
    }

    for (int i = 0; i < 1024; i++) {
      prevradii[i] = radii[i];
    }
  }
}
