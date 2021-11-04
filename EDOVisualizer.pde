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
