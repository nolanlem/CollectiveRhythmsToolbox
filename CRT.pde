// Collective Rhythms Toolbox 
// extended kuramoto coupled oscillator model 
// This script allows a user to interact with networks of coupled oscillators (<=100) using
// either pulse-coupling or generalized continuous coupling (Kuramoto Model). 
// The darker grey matrix on the left is the 'selector matrix'. Each toggle corresponds to an 
// oscillators in the ensemble. By clicking on a toggle or a group of toggles you select the oscillators 
// that you intend for parameter modification. Using the sliders, the user can adjust the 
// selected oscillators coupling ('KN'), natural frequency (FREQ_I), external forcing frequency (FREQ_E), 
//, and external forcing strength (CFF). The slider labeled 'F_SPREAD', allows you to create a 
// normal natural frequency distribution applied to all active oscillators (this is often the case 
// in the literature). The matrix to the right of the selector matrix shows the strength of each oscillators 
// coupling coefficient. Darker red means that it contains strong coupling. 
// The phase coherence is shown graphically over time in the window labeled |R| and is also shown 
// as a rotating phasor in the grey circle on the bottom right. The target phase coherence is 
// shown as a slider which is active from the corresponding keystroke '2'. 

// keystrokes key:
// 'f' = toggle display mode
// '=' = add oscillator 
// '-' = remove oscillator 
// 'k' = kuramoto Model Coupling 
// 'p' = pulse coupling 
// '1' = select all active oscillators 
// '0' = deselect all active oscillators 
// '2' = turn on 'R Feedback' to Force System into Desired Phase Coherence 
// 'a' = freeze in current parameter states to selected oscillators 
// 'f' = toggle back and forth between oscillator grid view or circle map view.
// nolan lem 2-9-23

PrintWriter output; 
String thefilename; 

ControlFrame cf; // for separate control window 

Boolean fullScreenCircleFlag = false; 

int maxN = 100; // max num of oscillators in ensemble
int N = 8; // current num of oscillators in ensemble
//String couplingType = "kura"; // coupling type: kura (continuous), pulse
String couplingType = "kura";

ArrayList<Oscillator> o = new ArrayList<Oscillator>();

float R = 0.0; // |R|
// for |R| feedback (|R|(kn))
int lenWindow = 10; 
float[] R_avg = new float[lenWindow]; // for |R| moving window (avg)
float[] last_R_avg = new float[lenWindow]; // for storing previous array of |R| of lenWindow
float R_target = 0.3; 
boolean fb_R_flag = false; 

float psi = 0.0; 
float radius = 20; // radius of circle map angular frequency
float coupling = 0.0; // no initial coupling 
float init_freq = 0.25; // intrinsic rad freq initialized
float pulse_scaling_coupling_coeff = 2.0; // scaling pulse 

float[] kn_inc = new float[maxN]; // for R feedback
float inc_amt = 0.02; 


int row = int(sqrt(N)); // num rows, NB: right now, N needs to be pow of 2
int col = int(sqrt(N)); // num cols
int maxrow = 10, maxcol = 10; 
int delay = 2; // tau, how many samples to delay adjustment? 
int graphlen = 100; 
float[] rmag = new float[graphlen];


// to save states
int[] states = new int[maxN]; // hold matrix of buttons to indicate active states
float[] kn_states = new float[maxN]; 
float[] state_kn = new float[maxN];
float[] state_freq = new float[maxN]; 
//int[] toggles = new int[maxN]; 

float ff = 0.0; // ext. forcing function 
float freq_e = 1; // radian frequency of forcing function 
float cff = 0.0; 
//Date d = new Date();
//long current = d.getTime()/1000.;

int x = 60, y = x, h=int(radius), off = int(radius*2)+10, grid = 10, many = grid*grid;  // 10 x 10 array of   
float[][] metricmod = {{PI}, {0}}; 
// sequencer stuff 
int timesteps = 8; 
int tempo = 100; 
int smallestloopsteps = 4;
int largestloopsteps = 4*4; 
int totalsteps = 4*(largestloopsteps/smallestloopsteps)+1; // first timestep is null
float[][] triggers = new float[10][totalsteps];   

// osc colors , loop thru
//color[] colors  = { #6699dd,#6393d4,#5f8dcb,#5c87c1,#5881b8,#557bae,#5175a5,#4e6f9b,#4a6992,#476288,#435c7f,#405675,
//#3c506c,
//#394a62,
//#354459,
//#323e4f,
//#2e3846,
//#2b323c,
//#272c33,
//#242629
//};

// more colorful
//color[] colors = {
//#a6cee3,
//#1f78b4,
//#b2df8a,
//#33a02c,
//#fb9a99,
//#e31a1c,
//#fdbf6f,
//#ff7f00,
//#cab2d6,
//#6a3d9a,
//#ffff99,
//#b15928,
//#a6cee3,
//#1f78b4,
//#b2df8a,
//#33a02c,
//#fb9a99,
//#e31a1c,
//#fdbf6f,
//#ff7f00
//};

color[] colors = {#000005, #000005}; // all black 

float[] fqz = {0.75,
0.75,
0.75,
0.75,
0.75,
0.75,
0.75,
0.75,
0.75,
0.75,
1.5,
1.5,
1.5,
1.5,
1.5,
1.5,
1.5,
1.5,
1.5,
1.5,
2.25,
2.25,
2.25,
2.25,
2.25,
2.25,
2.25,
2.25,
2.25,
2.25,
3.0,
3.0,
3.0,
3.0,
3.0,
3.0,
3.0,
3.0,
3.0,
3.0,
3.75,
3.75,
3.75,
3.75,
3.75,
3.75,
3.75,
3.75,
3.75,
3.75,
4.5,
4.5,
4.5,
4.5,
4.5,
4.5,
4.5,
4.5,
4.5,
4.5,
5.25,
5.25,
5.25,
5.25,
5.25,
5.25,
5.25,
5.25,
5.25,
5.25,
6.0,
6.0,
6.0,
6.0,
6.0,
6.0,
6.0,
6.0,
6.0,
6.0,
6.75,
6.75,
6.75,
6.75,
6.75,
6.75,
6.75,
6.75,
6.75,
6.75,
7.5,
7.5,
7.5,
7.5,
7.5,
7.5,
7.5,
7.5,
7.5,
7.5
};

int wwidth = 800, wheight = 800; 

void settings(){
   size(wwidth,wheight);
}

void setup(){
 //int d = day(); int mon = month(); int y = year(); int s = second();int min = minute(); int h = hour();
 //String thetime = str(d) + "_" + str(mon) + "_" + str(y) + "-" + str(h) + ":" + str(min) + ":" + str(s) + ".txt";
 thefilename = "savedstates/" + "thestate.txt" ;
 output = createWriter(thefilename); // object to write to file with 

 makeControls(); // controlP5 stuff in tab 
  
 noStroke();

      for(int i = 0; i < N; i++){
         o.add(new Oscillator(new PVector(x + (i%grid)*(radius+off), 
           y + (floor(i/grid))*(radius+off)), 
           random(0, TWO_PI), 
           coupling, 
           init_freq*(fqz[i])/9.5, 
           wwidth/radius,
           metricmod[0],
           i, 
           colors[int(random(colors.length))]));                 
      
     }
   
   for(int i = 0; i < maxN; i++){
     kn_inc[i] = 0.0; 
   }   
   initializeDelays();
   
   for(int i = 0; i < lenWindow; i++){
    last_R_avg[i] = 0.0;  
   }
   
  cf = new ControlFrame(this, 500, 600, "Controls");
  surface.setLocation(515, 10);
  
  


}

void initializeDelays(){
 for(int i = 0; i < o.size(); i++){
   for(int t = 0; t < delay; t++){
    o.get(i).state[t] = 0.0;
   }
 }
}


void randomizePhases(){
  for(int i = 0; i < o.size(); i++){
   o.get(i).angle = random(0, TWO_PI); 
  }
}



void draw(){
 background(255);
 if (couplingType == "kura") {
   iterateDelay();
 }
 if (couplingType == "pulse") {
   iteratePulse(); 
 }
  
   if(fullScreenCircleFlag == true){ 
     plotR_thiswindow(R, psi);
     plotCOP_thiswindow(R, psi);
   }

}

///////////////////for KURAMOTO coupling ////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
// for kuramoto coupling 
void iterateDelay(){
  OscMessage myMessage = new OscMessage("/trig");
 
  for(int t = 1; t < delay; t++){    
    for(int i = 0; i < o.size(); i++){
     o.get(i).state[t-1] = o.get(i).angle;  
    }
   float x = 0.0; // complex order param components
   float y = 0.0;
   for(int i = 0; i < o.size(); i++){     
       o.get(i).state[t] = o.get(i).state[t-1]; // curr angle = last angle        
       x += cos(o.get(i).state[t]); // look at c.o.p of last timestep
       y += sin(o.get(i).state[t]);
   }
   
    R = sqrt(x*x + y*y)/o.size(); // get cop
    psi = atan2(y,x);
 
    ///////// R FEEDBACK INTO KN ///////////
    if (fb_R_flag == true){
      
      R_avg[lenWindow - 1] = R; // R[4] = current R
      for(int i = 2; i < lenWindow; i++){
        R_avg[lenWindow - i] = last_R_avg[lenWindow - i + 1]; 
      }
      // calc mean of array 
      float meanR = 0.; 
      for(int i = 0; i<lenWindow; i++){
        meanR += R_avg[i]/(R_avg.length);
      }
      println(R, meanR);
      if (frameCount > 5) {
        last_R_avg = R_avg; 
      }
      
          for(int i = 0; i < N; i++){
            if (meanR > R_target){
              kn_inc[i] = o.get(i).kn; 

              kn_inc[i] -= inc_amt;        
            }
            if (meanR < R_target){
             kn_inc[i] = o.get(i).kn; 

              kn_inc[i] += inc_amt;
            }
          }
      
      }  
 ///////////////////////////////////////////////
   
   for(int i = 0; i < o.size(); i++){          
       o.get(i).adj[t] = R*(o.get(i).kn+kn_inc[i])*sin(psi-o.get(i).state[t]); // get adjustment 
       o.get(i).state[t] = o.get(i).state[t] + o.get(i).w + o.get(i).adj[t]; // get state
   }                   
 }
 
  // update angles with time delayed adjustment and iterate / integrate ang vel
  for(int i = 0; i < o.size(); i++){  
     //o.get(i).angle = o.get(i).angle + cff*sin(ff) + o.get(i).w + o.get(i).adj[1];  // only apply oldest adj state to update eq 
     o.get(i).angle = o.get(i).angle + cff + o.get(i).w + o.get(i).adj[1];  // only apply oldest adj state to update eq 

     o.get(i).checkZC();    
     o.get(i).lastangle = o.get(i).state[delay-1]; 
     
     myMessage.add(o.get(i).trig);
     o.get(i).draw();    
  }
      // update forcing function with w (omega) 
   ff = (ff + freq_e/9.5)%(TWO_PI); // assuming framerate = 60./(2*PI)
  
  oscP5.send(myMessage, myRemoteLocation);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////// PULSE///// coupling routing for pulse coupling 
/////////////////////////////////////////////
void iteratePulse(){
    OscMessage myMessage = new OscMessage("/trig");
    
    float x = 0.0; 
    float y = 0.0; 
    for(int i = 0; i < o.size(); i++){ 
      o.get(i).angle = o.get(i).angle + o.get(i).w; // iterate forward with w_i 
      
       x += cos(o.get(i).angle); // look at c.o.p of last timestep
       y += sin(o.get(i).angle);            
       
      // pulse coupling: check if ZC has occured, advance or retract phases
      if (o.get(i).angle > 2*PI){ 
        //o.get(i).trig = 1;
        
        for(int j = 0; j < o.size(); j++){ // for all other oscillators, adjust phase angle up or down according to prc
          o.get(j).angle = o.get(j).angle - (pulse_scaling_coupling_coeff*o.get(j).kn)*sin(o.get(j).angle - o.get(i).angle); // update 
        }
       }      
    }
    

    R = sqrt(x*x + y*y)/o.size(); // get complex order params, update global phase coherence variables 
    psi = atan2(y,x);  
  
    // append trigs to array and send out OSC bundle   
    for(int i = 0; i < o.size(); i++){  
     o.get(i).checkZC();     
     myMessage.add(o.get(i).trig);

     o.get(i).draw();  
    }
     oscP5.send(myMessage, myRemoteLocation);

        
}


void plotR_thiswindow(float r, float ang){
  pushMatrix();
  if (fullScreenCircleFlag == true){
    //translate(-100+ width/2, 530);
    translate(300,520);
  }
  else{
     //translate(20, 700);
     translate(300,520); 

  }
   rmag[graphlen-1] = r/o.size();
   rmag[graphlen-1] = map(rmag[graphlen-1], 0, 1, 100, 0);
   for (int i = 0; i < graphlen-1; i++){
     //if(rmag[i] != 0){
       fill(0);
       stroke(#C92718); // red line
       ellipse(i*2, rmag[i], 1, 1);
     //} //height- rmag[i]
     rmag[i] = rmag[i+1]; 
     
   }
   
   fill(0);
   stroke(0);
   line(0, 0, 0, graphlen);
   stroke(0);
   line(0, 0, graphlen*2, 0);
   stroke(0);
   line(graphlen*2, 0, graphlen*2, graphlen);

   fill(0); 
   stroke(0); 
   line(0, graphlen, 2*graphlen, graphlen);
   
   textSize(12);
   text("|R|", graphlen-120, 50);
   
   stroke(0); 

   popMatrix();
}

void plotCOP_thiswindow(float r, float ang){
  //println(r + ", " + ang);
  
  if (fullScreenCircleFlag == true){
      pushMatrix();
      translate(width/2, height/2);
      stroke(0);
      noFill();
      //ellipse(0, 0, 100, 100);
      stroke(#C92718);
      fill(100);
        //line(0, 0, 50*r*cos(psi)/o.size(), -50*r*sin(psi)/o.size()); 
    
      line(0, 0, 100*r*sin(psi)/o.size(), 100*r*cos(psi)/o.size()); 
      //print(psi);
      popMatrix();
  
  }
  else{
    pushMatrix();
    translate(300, 740);
    stroke(0);
    noFill();
    ellipse(0, 0, 100, 100);
    stroke(255,0,0);
    fill(100);  
    line(0, 0, 50*r*sin(psi)/o.size(), 50*r*cos(psi)/o.size()); 
    //print(psi);
    popMatrix();
  }
}

////////




  
