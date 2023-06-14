class ControlFrame extends PApplet {

  PApplet parent;
  ControlP5 cp5;
  int w, h;
  int xg = 100, yg = 300, wg = 10, hg = wg, offg =2, grid = 10, many = grid*grid;  // GRID DESIGN
  Button[] btns = new Button[many];
  Button[] btns_kn = new Button[many]; 

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
    
    // cp5.addMatrix("knMatrix")
    // .setPosition(150, 150)
    // .setSize(200, 200)
    // .setGrid(maxrow, maxcol)
    // .setGap(1, 1)
    // .setInterval(100)
    // .setMode(ControlP5.MULTIPLES)
    // .setColorBackground(color(120))
    // .setBackground(color(40))
    // .setColorForeground(color(144));
    
    //cp5.getController("knMatrix").getCaptionLabel().alignX(CENTER);

      //cp5.addSlider("kn").plugTo(parent, "kn")
      //.setRange(0,0.2)
      //.setValue(0)
      //.setSize(10,100)
      //.setColorValue(color(0,0,0))
      //.setPosition(width-7*40, height-130)
      //.setColorCaptionLabel(color(0,0,0));
      
      cp5.addSlider("intfreq").plugTo(parent, "intfreq")
      .setRange(1,120)
      .setValue(0)
      .setSize(10,100)
      .setColorValue(color(0,0,0))
      .setPosition(width-6*40, height-130)
      .setColorCaptionLabel(color(0,0,0));
    
    cp5.addSlider("amp").plugTo(parent, "amp")
      .setRange(0,0.01)
      .setValue(0.000)
      .setSize(10,100)
      .setColorValue(color(0,0,0))
      .setPosition(width-5*40,height-130)
      .setColorCaptionLabel(color(0,0,0))
      .setCaptionLabel("amp_d");


     cp5.addSlider("damping").plugTo(parent, "damping")
      .setRange(0.0,0.03)
      .setValue(0.00)
      .setSize(10,100)
      .setColorValue(color(0,0,0))
      .setPosition(width-4*40, height-130)
      .setColorCaptionLabel(color(0,0,0));

     cp5.addSlider("period").plugTo(parent, "period")
      .setRange(10,120)
      .setValue(0)
      .setSize(10,100)
      .setColorValue(color(0,0,0))
      .setPosition(width-3*40, height-130)
      .setColorCaptionLabel(color(0,0,0));
      

     cp5.addSlider("freqspread").plugTo(parent, "Hz spread")
      .setRange(0,60)
      .setValue(0)
      .setSize(10,100)
      .setColorValue(color(0,0,0))
      .setPosition(width-2*40, height-130)
      .setColorCaptionLabel(color(0,0,0));

     cp5.addSlider("kn").plugTo(parent, "kn")
      .setRange(0.0, 0.4)
      .setValue(0.0)
      .setSize(10,100)
      .setColorValue(color(0,0,0))
      .setPosition(width-1*40, height-130)
      .setColorCaptionLabel(color(0,0,0));

     cp5.addButton("random").plugTo(parent, "random")
     .setValue(0)
     .setPosition(width-40,height-160)
     .setSize(20,20)
     .setColorCaptionLabel(color(0,0,0));
     
     cp5.addButton("writer").plugTo(parent, "writer")
     .setPosition(width-150,height-160)
     .setSize(60,20);
     
     ButtonBar b = cp5.addButtonBar("states").plugTo(parent, "states")
     .setPosition(0, 0)
     .setSize(400, 20)
     .addItems(split("1 2 3 4 5 6 7 8 9 10"," "))
     ;     
     
    for ( int i = 0; i < many; i++ ) {
    int bx = xg+(i%grid)*( wg+offg);
    int by = yg+(floor(i/grid))*(hg+offg);
     btns[i] = cp5.addButton( "st_"+str(i) )
      .setSwitch(true)
      //.setOff()
      .setColorBackground(color(200,200,200))
      .setColorForeground(color(200, 0, 200)) // mouse over
      .setColorActive(color(0, 200, 0))       // clicked ON
      .setId(i) 
      .setPosition(bx, by)
      .setLabelVisible(false)
      .setSize(wg, hg) ;  
      
       btns_kn[i] = cp5.addButton( "bkn_"+str(i) )
      .setSwitch(true)
      //.setOff()
      .setColorBackground(color(235,235,235))
      .setColorForeground(color(240, 171, 166)) // mouse over
      .setColorActive(color(0, 200, 0))       // clicked ON
      .setId(i) 
      .setPosition(bx+130, by)
      .setLabelVisible(false)
      .setSize(wg, hg) ;
      
       states[i] = 0; // initialize states to 0.     
  }

}

//void knMatrix(int theX, int theY){

//  float l_ = cp5.getController("period").getValue(); // get natural frequency as determined from length of pendulum (L)
  
//  int theidx = theX + (theY*9)+theY; 
  
//  ls[theidx] = l_;
     
//  p.get(theidx).r = l_;

//}



void draw() {
    background(244);
    // draw text to control frame screen 
    textSize(14);
    fill(0);    
    textSize(10);
    text("keystroke guide", 10, 30); 
    textSize(9); 
    text("'1' select all metronomes", 5, 40); 
    text("'0' deselect all metronomes", 5, 50); 
    text("'=' add metro", 5, 60);
    text("'-' remove metro", 5, 70);
    text("'a' burn in parameters to selected", 100, 30); 
    
    fill(0);
    text("select oscillators in group", 100, 290); 
    text("tempo", 230, 290); 
  }
  
void controlEvent(ControlEvent theEvent){
   if(theEvent.getController().getName() == "Choose file"){
     println("choose the file");
   }
   
    // update states[] array to hold currently active buttons
    for(int i = 0; i < N; i++){
      if(theEvent.isFrom(cp5.getController("st_" + str(i)))){
        String name = theEvent.getController().getName();  
        int btn = theEvent.getController().getId();
        states[i] = int(btns[btn].isOn()); 
      }
  }
}

// keypress stuff
 void keyPressed(){
 // clear the selector matrix 
 //if (key == '0'){
 //  cp5.get(Matrix.class, "knMatrix").clear();
 //}
  if (key == '='){ 
     println("add oscillator");
     N += 1;
     //p.add(new Pendulum(new PVector(x + (curr_i%grid)*(init_L+off), y + (floor(curr_i/grid))*(init_L+off)), init_L, random(0, PI/2), N)); 
      float randomangleL = random(-PI/2, -PI/4); 
      float randomangleR = random(PI/4, PI/2);
      float[] randomangarr = {randomangleL, randomangleR}; 
      int randint = int(random(0,2));
      p.add(new Pendulum(new PVector(x + (curr_i%grid)*(init_L+off), y + (floor(curr_i/grid))*(init_L+off)), init_L, randomangarr[randint], N)); 
     curr_i += 1 ; 
  }
   // remove oscillator to arraylist by pressing '='
 if ((key == '-') & (N >=1)){  
      println("remove oscillator");
   
     curr_i -= 1 ; 
     p.remove(curr_i); 
     N -= 1; 
     // update active states 
     states[N] = 0; 
     cp5.get(Button.class, "st_" + str(N)).setOff(); 
  }
  
  // select all metronomes 
   if (key == '1'){  
     println("select all metronomes " + "N=" + N); 
    for(int i = 0; i < N ; i++){
     cp5.get(Button.class, "st_" + str(i)).setOn();
   }
   }
   
  // deselect all metronomes 
   if (key == '0'){  
     println("deselect all metronomes"); 
    for(int i = 0; i < maxN ; i++){
     cp5.get(Button.class, "st_" + str(i)).setOff();
   }

  }
  
   // set the slider period (int. freq) of the selected ===oscillators and 'burn in' with 'a' key press
   if ( key == 'a' ){
    for (int i = 0; i < states.length; i++){
      if (states[i] == 1){
        print(kn_states[states[i]] + " ");  
        //float knval = cp5.getController("coupling").getValue(); // slider values from controller
        float freqval = cp5.getController("intfreq").getValue();
        //float knval = cp5.getController("kn").getValue();
        //kn_states[states[i]] =  knval; // set
        
        
        //p.get(i).kn = kn_states[states[i]]; // set coupling 
        p.get(i).r = freqval; // set intrinsic freq; 
        //p.get(i).kn = knval; 
        
        //println("\n kn_" + i + " = " + cp5.getController("coupling").getValue());
        float cmap = map(freqval, 1, 120, 235, 15); 
        btns_kn[i].setColorBackground(color(240, int(cmap),int(cmap)));
        
        }
      }
    }
}
  
}
