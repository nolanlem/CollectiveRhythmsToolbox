class ControlFrame extends PApplet {

  int w, h;
  PApplet parent;
  ControlP5 cp5;

  public ControlFrame(PApplet _parent, int _w, int _h, String _name) {
    super();   
    parent = _parent;
    w=_w;
    h=_h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w,h);
  }

  public void setup() {
    surface.setLocation(10,10);
    cp5 = new ControlP5(this);
    
     cp5.addMatrix("knMatrix")
     .setPosition(150, 150)
     .setSize(200, 200)
     .setGrid(maxrow, maxcol)
     .setGap(1, 1)
     .setInterval(100)
     .setMode(ControlP5.MULTIPLES)
     .setColorBackground(color(120))
     .setBackground(color(40))
     .setColorForeground(color(144));
    
    cp5.getController("knMatrix").getCaptionLabel().alignX(CENTER);

    
    cp5.addSlider("amp").plugTo(parent, "amp")
      .setRange(0,0.01)
      .setValue(0.000)
      .setSize(10,100)
      .setColorValue(0xffff88ff)
      .setPosition(width-5*40,height-130)
      .setColorCaptionLabel(0xffff88ff)
      .setCaptionLabel("amp_d");

     cp5.addSlider("damping").plugTo(parent, "damping")
      .setRange(0.0,0.03)
      .setValue(0.00)
      .setSize(10,100)
      .setColorValue(0xffff88ff)
      .setPosition(width-4*40, height-130)
      .setColorCaptionLabel(0xffff88ff);

     cp5.addSlider("period").plugTo(parent, "period")
      .setRange(10,120)
      .setValue(0)
      .setSize(10,100)
      .setColorValue(0xffff88ff)
      .setPosition(width-3*40, height-130)
      .setColorCaptionLabel(0xffff88ff);

     cp5.addSlider("freqspread").plugTo(parent, "freqspread")
      .setRange(0,60)
      .setValue(0)
      .setSize(10,100)
      .setColorValue(0xffff88ff)
      .setPosition(width-2*40, height-130)
      .setColorCaptionLabel(0xffff88ff);

     cp5.addSlider("kn").plugTo(parent, "kn")
      .setRange(0.0, 0.4)
      .setValue(0.0)
      .setSize(10,100)
      .setColorValue(0xffff88ff)
      .setPosition(width-1*40, height-130)
      .setColorCaptionLabel(0xffff88ff);

     cp5.addButton("random").plugTo(parent, "random")
     .setValue(0)
     .setPosition(width-40,height-160)
     .setSize(20,20)
     .setColorCaptionLabel(0xffff88ff);
     
     cp5.addButton("writer").plugTo(parent, "writer")
     .setPosition(width-150,height-160)
     .setSize(60,20);
     
     ButtonBar b = cp5.addButtonBar("states").plugTo(parent, "states")
     .setPosition(0, 0)
     .setSize(400, 20)
     .addItems(split("1 2 3 4 5 6 7 8 9 10"," "))
     ;      

}

void knMatrix(int theX, int theY){

  float l_ = cp5.getController("period").getValue(); // get natural frequency as determined from length of pendulum (L)
  
  int theidx = theX + (theY*9)+theY; 
  
  ls[theidx] = l_;
     
  p.get(theidx).r = l_;



}



  void draw() {
    background(244);
  }
  
  void controlEvent(ControlEvent theEvent){
   if(theEvent.getController().getName() == "Choose file"){
     println("choose the file");
   }
  }

// keypress stuff
 void keyPressed(){
 // clear the selector matrix 
 if (key == '0'){
   cp5.get(Matrix.class, "knMatrix").clear();
 }
  if (key == '='){ 
     println("add oscillator");
     N += 1;
     p.add(new Pendulum(new PVector(x + (curr_i%grid)*(init_L+off), y + (floor(curr_i/grid))*(init_L+off)), init_L, N)); 
     curr_i += 1 ; 
  }
   // remove oscillator to arraylist by pressing '='
 if (key == '-'){  
      println("remove oscillator");
   
     curr_i -= 1 ; 
     p.remove(curr_i); 
     N -= 1; 
  }
  // set params using trigger button 
   if (key == '1'){  
      println("update params");     

  }
}
  
}
