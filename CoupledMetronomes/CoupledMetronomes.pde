// damped, driven and coupled pendulums 
// nolan lem 11-7-22

PrintWriter output; 
String thefilename; 
String filename = "";

ControlFrame cf;

int N = 3; // initial number of metronomes in ensemble 
int maxN = 100; 
int maxmetros = 100; // max number of metronomes 
int curr_i = N;

// equation of motion terms 
float coupleAccel = 0.0;
float avgAngle = 0.0;
// coupled platform
float init_L = 25.0;
float gravity = 0.4; 
float damping = 0.01; 
//float period = L/gravity;
float period = 60.0;
float platformfreq;
int xdist = 500; 
float amp = 0.003;
//float amp =0.0; 
float kn = 0.5; 

// grid indications for metronome position on screen 
int maxrow = 10, maxcol = 10; 

// to save states matrices
int[] states = new int[maxN]; // hold matrix of buttons to indicate active states
float[] kn_states = new float[maxN]; 




// define arraylist of pendulum objects 
ArrayList<Pendulum> p = new ArrayList<Pendulum>();

// grid stuff
int x = 60, y = x, h=int(init_L), off = int(init_L*2)+10, grid = 10, many = grid*grid;  // 10 x 10 array of   


float omega_0 = 1.3; // damping variable for damping function, D(angle)
float epsilon = 0.05; // see update() class function in pendulum

int freqspread = 60;
int num_states = 10; // number of loaded states for tab buttons

// phase coherence mag, avg. angle 
float R = 0.0; 
float psi = 0.0; 

// for graphical |R| real-time display 
int graphlen = 100; 
float[] readings = new float[graphlen];  
float[] rmag = new float[graphlen]; 
float[] pang = new float[graphlen]; 

// display window size
int wwidth = 900, wheight = 800;

float[] ls = new float[maxmetros]; // hold matrix state to select metronomes length

void settings(){
 size(wwidth, wheight); 
}
 
void setup() {
  //size(640,640);
  noStroke();
  cf = new ControlFrame(this, 500, 600, "Controls");
  surface.setLocation(520, 10);

   int s = second();
   int m = minute();
   int h = hour();
   String thetime = str(h) + "_" + str(m) + "_" + str(s) + ".txt";
   thefilename = "savedstates/" + thetime;
   output = createWriter(thefilename); // object to write to file with
  

  makeControls();
 
//We make a new Pendulum object with an origin location and arm length.
  for(int i = 0; i < N; i++){
      float randomangleL = random(-PI/2, -PI/4); 
      float randomangleR = random(PI/4, PI/2);
      float[] randomangarr = {randomangleL, randomangleR}; 
      int randint = int(random(0,2));
      p.add(new Pendulum(new PVector(x + (i%grid)*(init_L+off), y + (floor(i/grid))*(init_L+off)), init_L, randomangarr[randint], i));  
      ls[i] = init_L;
  }
}




void draw() {
  background(255);
  
  OscMessage myMessage = new OscMessage("/trig");
  
  platformfreq = amp*cos(TWO_PI * frameCount/period);  
  
  couplePendulums();


  for(int i=0; i < p.size(); i++){
    p.get(i).go();
  }
  
  for(int i=0; i < p.size(); i++){
    //myMessage.add(p[i].state);
    myMessage.add(p.get(i).state);
  }
  oscP5.send(myMessage, myRemoteLocation);
  
   
}

void couplePendulums(){
  float x = 0.0; 
  float y = 0.0; 
  coupleAccel = 0.0;
  avgAngle = 0.0; 

  // calculate phase coherence at each iter
  for(int i=0; i < p.size(); i++){
      coupleAccel += p.get(i).aAcceleration;
      avgAngle += p.get(i).angle/(TWO_PI); 
      
      x += cos(p.get(i).angle);
      y += sin(p.get(i).angle);
    }
  x /= p.size(); 
  y /= p.size(); 
  R = sqrt(x*x + y*y); // calculate R, psi 
  psi = atan2(y,x);
 
  coupleAccel = kn*coupleAccel/p.size();
  
  avgAngle = avgAngle/p.size(); 

}

// function to display graphical phase coherence 
void plotR(float r, float ang){
   rmag[graphlen-1] = r;
   rmag[graphlen-1] = map(rmag[graphlen-1], 0, 1, 0, 100);
   for (int i = 0; i < graphlen-1; i++){
     stroke(0);
     if(rmag[i] != 0){
       fill(0);
       ellipse(i, height - rmag[i], 1, 1);
     }
     rmag[i] = rmag[i+1]; 
   }
   fill(0);
   line(0, height-graphlen, width/4, height-graphlen);
   fill(0);
   line(width/4, height-graphlen, width/4, height);
   stroke(0);    
}

// plot complex order params (R, psi)
void plotCOP(float r, float ang){
  //println(r + ", " + ang);
  translate(1*width/3, 6*height/7);
  stroke(0);
  noFill();
  ellipse(0, 0, 100, 100);
  stroke(255,0,0);
  fill(100);
  line(0, 0, 100*r*cos(ang)/2, 100*r*sin(ang)/2); 

}


// draw the platforms
void drawPlatform(){
  pushMatrix();
 // stroke(0);
  fill(175);
  noStroke();
  translate(platformfreq*4000, 10 + int(init_L) + height/2);
  rect(width/14, 0, 520, 20);
  //translate(platformfreq*10000, L + height/2);
  //ellipse(platformfreq*10000, 0, 10,10);
  popMatrix();
}

// randomize the metronome phases 
void randomize() {
  println("randomize phases:");
    for(int i = 0; i < p.size(); i ++){
      p.get(i).angle = random(-PI/2, PI/2);
    }
}

// randomize the pendulum length (natural tempo/freq)
void randomizeFreqs(float theValue) {
  println("modify pendula lengths");
  for(int i = 0; i < p.size(); i ++){
    p.get(i).r = random(init_L+0, init_L+theValue);
  }
}

// just for reference 
/*
a list of all methods available for the Matrix Controller
use ControlP5.printPublicMethodsFor(Matrix.class);
to print the following list into the console.

You can find further details about class Matrix in the javadoc.

Format:
ClassName : returnType methodName(parameter type)


controlP5.Controller : CColor getColor() 
controlP5.Controller : ControlBehavior getBehavior() 
controlP5.Controller : ControlWindow getControlWindow() 
controlP5.Controller : ControlWindow getWindow() 
controlP5.Controller : ControllerProperty getProperty(String) 
controlP5.Controller : ControllerProperty getProperty(String, String) 
controlP5.Controller : ControllerView getView() 
controlP5.Controller : Label getCaptionLabel() 
controlP5.Controller : Label getValueLabel() 
controlP5.Controller : List getControllerPlugList() 
controlP5.Controller : Matrix addCallback(CallbackListener) 
controlP5.Controller : Matrix addListener(ControlListener) 
controlP5.Controller : Matrix addListenerFor(int, CallbackListener) 
controlP5.Controller : Matrix align(int, int, int, int) 
controlP5.Controller : Matrix bringToFront() 
controlP5.Controller : Matrix bringToFront(ControllerInterface) 
controlP5.Controller : Matrix hide() 
controlP5.Controller : Matrix linebreak() 
controlP5.Controller : Matrix listen(boolean) 
controlP5.Controller : Matrix lock() 
controlP5.Controller : Matrix onChange(CallbackListener) 
controlP5.Controller : Matrix onClick(CallbackListener) 
controlP5.Controller : Matrix onDoublePress(CallbackListener) 
controlP5.Controller : Matrix onDrag(CallbackListener) 
controlP5.Controller : Matrix onDraw(ControllerView) 
controlP5.Controller : Matrix onEndDrag(CallbackListener) 
controlP5.Controller : Matrix onEnter(CallbackListener) 
controlP5.Controller : Matrix onLeave(CallbackListener) 
controlP5.Controller : Matrix onMove(CallbackListener) 
controlP5.Controller : Matrix onPress(CallbackListener) 
controlP5.Controller : Matrix onRelease(CallbackListener) 
controlP5.Controller : Matrix onReleaseOutside(CallbackListener) 
controlP5.Controller : Matrix onStartDrag(CallbackListener) 
controlP5.Controller : Matrix onWheel(CallbackListener) 
controlP5.Controller : Matrix plugTo(Object) 
controlP5.Controller : Matrix plugTo(Object, String) 
controlP5.Controller : Matrix plugTo(Object[]) 
controlP5.Controller : Matrix plugTo(Object[], String) 
controlP5.Controller : Matrix registerProperty(String) 
controlP5.Controller : Matrix registerProperty(String, String) 
controlP5.Controller : Matrix registerTooltip(String) 
controlP5.Controller : Matrix removeBehavior() 
controlP5.Controller : Matrix removeCallback() 
controlP5.Controller : Matrix removeCallback(CallbackListener) 
controlP5.Controller : Matrix removeListener(ControlListener) 
controlP5.Controller : Matrix removeListenerFor(int, CallbackListener) 
controlP5.Controller : Matrix removeListenersFor(int) 
controlP5.Controller : Matrix removeProperty(String) 
controlP5.Controller : Matrix removeProperty(String, String) 
controlP5.Controller : Matrix setArrayValue(float[]) 
controlP5.Controller : Matrix setArrayValue(int, float) 
controlP5.Controller : Matrix setBehavior(ControlBehavior) 
controlP5.Controller : Matrix setBroadcast(boolean) 
controlP5.Controller : Matrix setCaptionLabel(String) 
controlP5.Controller : Matrix setColor(CColor) 
controlP5.Controller : Matrix setColorActive(int) 
controlP5.Controller : Matrix setColorBackground(int) 
controlP5.Controller : Matrix setColorCaptionLabel(int) 
controlP5.Controller : Matrix setColorForeground(int) 
controlP5.Controller : Matrix setColorLabel(int) 
controlP5.Controller : Matrix setColorValue(int) 
controlP5.Controller : Matrix setColorValueLabel(int) 
controlP5.Controller : Matrix setDecimalPrecision(int) 
controlP5.Controller : Matrix setDefaultValue(float) 
controlP5.Controller : Matrix setHeight(int) 
controlP5.Controller : Matrix setId(int) 
controlP5.Controller : Matrix setImage(PImage) 
controlP5.Controller : Matrix setImage(PImage, int) 
controlP5.Controller : Matrix setImages(PImage, PImage, PImage) 
controlP5.Controller : Matrix setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : Matrix setLabel(String) 
controlP5.Controller : Matrix setLabelVisible(boolean) 
controlP5.Controller : Matrix setLock(boolean) 
controlP5.Controller : Matrix setMax(float) 
controlP5.Controller : Matrix setMin(float) 
controlP5.Controller : Matrix setMouseOver(boolean) 
controlP5.Controller : Matrix setMoveable(boolean) 
controlP5.Controller : Matrix setPosition(float, float) 
controlP5.Controller : Matrix setPosition(float[]) 
controlP5.Controller : Matrix setSize(PImage) 
controlP5.Controller : Matrix setSize(int, int) 
controlP5.Controller : Matrix setStringValue(String) 
controlP5.Controller : Matrix setUpdate(boolean) 
controlP5.Controller : Matrix setValue(float) 
controlP5.Controller : Matrix setValueLabel(String) 
controlP5.Controller : Matrix setValueSelf(float) 
controlP5.Controller : Matrix setView(ControllerView) 
controlP5.Controller : Matrix setVisible(boolean) 
controlP5.Controller : Matrix setWidth(int) 
controlP5.Controller : Matrix show() 
controlP5.Controller : Matrix unlock() 
controlP5.Controller : Matrix unplugFrom(Object) 
controlP5.Controller : Matrix unplugFrom(Object[]) 
controlP5.Controller : Matrix unregisterTooltip() 
controlP5.Controller : Matrix update() 
controlP5.Controller : Matrix updateSize() 
controlP5.Controller : Pointer getPointer() 
controlP5.Controller : String getAddress() 
controlP5.Controller : String getInfo() 
controlP5.Controller : String getName() 
controlP5.Controller : String getStringValue() 
controlP5.Controller : String toString() 
controlP5.Controller : Tab getTab() 
controlP5.Controller : boolean isActive() 
controlP5.Controller : boolean isBroadcast() 
controlP5.Controller : boolean isInside() 
controlP5.Controller : boolean isLabelVisible() 
controlP5.Controller : boolean isListening() 
controlP5.Controller : boolean isLock() 
controlP5.Controller : boolean isMouseOver() 
controlP5.Controller : boolean isMousePressed() 
controlP5.Controller : boolean isMoveable() 
controlP5.Controller : boolean isUpdate() 
controlP5.Controller : boolean isVisible() 
controlP5.Controller : float getArrayValue(int) 
controlP5.Controller : float getDefaultValue() 
controlP5.Controller : float getMax() 
controlP5.Controller : float getMin() 
controlP5.Controller : float getValue() 
controlP5.Controller : float[] getAbsolutePosition() 
controlP5.Controller : float[] getArrayValue() 
controlP5.Controller : float[] getPosition() 
controlP5.Controller : int getDecimalPrecision() 
controlP5.Controller : int getHeight() 
controlP5.Controller : int getId() 
controlP5.Controller : int getWidth() 
controlP5.Controller : int listenerSize() 
controlP5.Controller : void remove() 
controlP5.Controller : void setView(ControllerView, int) 
controlP5.Matrix : Matrix clear() 
controlP5.Matrix : Matrix pause() 
controlP5.Matrix : Matrix play() 
controlP5.Matrix : Matrix plugTo(Object) 
controlP5.Matrix : Matrix plugTo(Object, String) 
controlP5.Matrix : Matrix set(int, int, boolean) 
controlP5.Matrix : Matrix setBackground(int) 
controlP5.Matrix : Matrix setCells(int[][]) 
controlP5.Matrix : Matrix setGap(int, int) 
controlP5.Matrix : Matrix setGrid(int, int) 
controlP5.Matrix : Matrix setInterval(int) 
controlP5.Matrix : Matrix setMode(int) 
controlP5.Matrix : Matrix setValue(float) 
controlP5.Matrix : Matrix stop() 
controlP5.Matrix : Matrix trigger(int) 
controlP5.Matrix : Matrix update() 
controlP5.Matrix : boolean get(int, int) 
controlP5.Matrix : boolean isPlaying() 
controlP5.Matrix : int getInterval() 
controlP5.Matrix : int getMode() 
controlP5.Matrix : int[][] getCells() 
controlP5.Matrix : void remove() 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 

created: 2015/03/24 12:21:14

*/

  
