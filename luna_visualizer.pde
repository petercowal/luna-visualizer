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
  
  //blue magenta
  color color1 = color(20, 80, 180);
  color color2 = color(120, 20, 70);
  
  //orange blue
  //color color1 = color(120, 50, 10);
  //color color2 = color(40, 80, 180);
  
  //orange gray
  //color color1 = color(120, 50, 10);
  //color color2 = color(30, 100, 140);
  
  //blue green
  //color color1 = color(50, 150, 30);
  //color color2 = color(20, 80, 140);
  
  //red orange
  //color color1 = color(180, 50, 10);
  //color color2 = color(100, 100, 50);
  
  //deep blue
  //color color1 = color(40, 5, 90);
  //color color2 = color(10, 120, 140);

  size(1280, 720, P2D);
  background(0);
  
  // determines the tuning system used by the pitch class analyzer
  int edo = 19;
  nowPlaying = new SoundFile(this, "petet_19.wav");
  
  title = "";
  
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

// converts frequency to a pitch ID relative to C1 = 16.352 Hz
float freqToEDOPitch(float freq, float edo) {
  return edo * log(freq/16.352)/log(2);
}

// PitchAnalyzer uses an FFT to quickly determine the approximate amplitude of each scale pitch present in the input signal
class PitchAnalyzer {
  FFT fft;
  int bands = 16384; //more bands for more precise analysis
  int edo;
  float[] pitchAverages = new float[1024];
  int highestPitch;
  float[] spectrum;
  float[] rawSpectrum;
  
  public PitchAnalyzer(PApplet parent, int bands, int edo) {
     this.bands = bands;
     spectrum = new float[bands];
     rawSpectrum = new float[bands];
     this.edo = edo;
     fft = new FFT(parent, bands);
  }
  
  public void setEDO(int edo) {
     this.edo = edo; 
  }

  public float bandFreq(int band) {
    return band*(44100.0/bands);
  }

  public void input(SoundObject source) {
    fft.input(source);
  }
  
  public float[] analyze() {
    fft.analyze(rawSpectrum);

    for (int i = 1; i < bands; i++) {
      spectrum[i] = rawSpectrum[i] * sqrt(bandFreq(i)/800);
    }

    highestPitch = 0;
    int lowestBand = bands/1024;
    int lowestPitch = round(freqToEDOPitch(bandFreq(lowestBand), edo));

    int pitch = lowestPitch;
    int prevPitch = pitch;
    float prevAmplitude = 0;
    
    float[] pitchAverages = new float[1024];
    
    for (int i = lowestBand; i < bands/2; i++) {
      float rawPitch = freqToEDOPitch(bandFreq(i), edo);

      pitch = round(rawPitch);

      //CURRENT ALGORITHM: max of adjusted spectrum
      float amplitude = max(pitchAverages[pitch], spectrum[i]);

      //LERP to account for wide differences between pitch in bass
      float pitchDiff = pitch - prevPitch;
      while (prevPitch < pitch - 1) {
        float interp = (pitch - (++prevPitch))/pitchDiff;
        pitchAverages[prevPitch] = prevAmplitude * interp + amplitude*(1 - interp);
      }

      pitchAverages[pitch] = amplitude;
      highestPitch = max(pitch, highestPitch);
      prevPitch = pitch;
      prevAmplitude = amplitude;
    }
    pitchAverages[highestPitch]=0;
    return pitchAverages;
  }
}

class FFTBackground {
   FFT fft;
   float[] spectrum = new float[16384];
   float effect_amplitude = 800;
   public FFTBackground(PApplet parent) {
       fft = new FFT(parent, 16384);
   }
   public void input(SoundObject source) {
      fft.input(source);
   }
   public void Render() {

     fft.analyze(spectrum);
     int numBuckets = round(width/8);
      float[] buckets = new float[numBuckets];
      
      for(int i = 0; i < numBuckets; i++) {
        float maxAmp = 0;
          for(int j=20+i*8; j<28+i*8; j++) {
              maxAmp = max(maxAmp, spectrum[j]);
          }
          buckets[i] = maxAmp;
      }
      float center_x = width/2;
      float center_y = height/2;
      for(int i = 1; i < numBuckets - 1; i++) {
        if (buckets[i] > buckets[i-1] && buckets[i] > buckets[i+1]) {
          stroke(60);
        } else {
          stroke(30); 
        }
        float line_height = sqrt(buckets[i])*effect_amplitude;
        line(center_x + i*4, center_y - line_height, center_x + i*4, center_y + line_height);
        line(center_x - i*4, center_y - line_height, center_x - i*4, center_y + line_height);
      }
   }
}

// Visualizer component base class
abstract class EDOVisualizer {
    PitchAnalyzer analyzer;
    int edo;
    public EDOVisualizer(PApplet parent, int bands, int edo) {
      analyzer = new PitchAnalyzer(parent, bands, edo);
      this.edo = edo;
    }
    
    public void setEDO(int edo) {
      this.edo = edo; 
      analyzer.setEDO(edo);
    }
  
    public void input(SoundObject source) {
      analyzer.input(source);
    }
    
    public void Render() {
       render(analyzer.analyze(), analyzer.highestPitch); 
    }
    
    public abstract void render(float[] pitchAverages, int highestPitch);
}

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
