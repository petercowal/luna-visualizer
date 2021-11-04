// TonnetzVisualizer renders a lattice of harmonic relationships.  thirds are diagonals, fifths are horizontal.
// intervals are determined by the closest approximation in the current tuning system
class TonnetzVisualizer extends EDOVisualizer {
  
  float nullRadius = 100;
  float effectAmplitude = 100;
  public TonnetzVisualizer(PApplet parent, int edo) {
     super(parent, 8192, edo); 
  }
  
  public void render(float[] pitchAverages, int highestPitch) {
    
    float[] amplitudes = new float[edo];
    
    for (int i = 0; i < highestPitch; i++ ) {
       int pitchClass = i % edo;
       amplitudes[pitchClass] += log(1 + 10*max(0, pitchAverages[i] - 0.02));
    }
    
    
    float center_x = width/2;
    float center_y = height/2;
    
    int majorThird = round(edo*log(5./4)/log(2));
    int perfectFifth = round(edo*log(3./2)/log(2));
    
    //println("M3 = " + majorThird + ", P5 = " + perfectFifth);
    float root3over2 = sqrt(3)/2;
    float spacing = 100;
    
    int yBounds = round(height/(spacing*sqrt(3)));
    
    int xBounds = round(width*0.5/spacing);
    blendMode(LIGHTEST);
    for (int j = -yBounds; j <= yBounds; j++) {
      for (int i = -xBounds-j/2; i <= xBounds-j/2; i++) {
           float x = center_x + i*spacing + j*spacing/2;
           float y = center_y - j*spacing*root3over2;
           if (dist(x, y, center_x, center_y) > nullRadius) {
             
             float amp = amplitudes[Math.floorMod(perfectFifth*i + majorThird * j, edo)];
             float amp32 = amplitudes[Math.floorMod(perfectFifth*(i+1) + majorThird * j, edo)];
             float amp54 = amplitudes[Math.floorMod(perfectFifth*i + majorThird * (j+1), edo)];
             float amp65 = amplitudes[Math.floorMod(perfectFifth*(i-1) + majorThird * (j+1), edo)];
             noStroke();
             fill(effectAmplitude * amp);
             circle(x, y, 10);
             
             stroke(effectAmplitude * min(amp, amp32));
             line(x, y, x+spacing, y);
             
             stroke(effectAmplitude * min(amp, amp54));
             line(x, y, x+spacing/2, y-spacing*root3over2);
             
             stroke(effectAmplitude * min(amp, amp65));
             line(x, y, x-spacing/2, y-spacing*root3over2);
           }
       }
    }
  }
}
