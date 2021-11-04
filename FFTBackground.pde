// FFT background animation.  Currently unused.
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
