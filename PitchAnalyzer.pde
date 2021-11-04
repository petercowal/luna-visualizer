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
