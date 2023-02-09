class Oscillator{
 
 //ArrayList<Oscillator> o = new ArrayList<Oscillator>(); 
  
 PVector location;
 PVector origin;
 float angle;
 float lastangle; 
 float kn; 
 float r;
 float w; // actually freq now but keep omega
 float bob;
 float[] state;
 float[] adj;
 int trig;
 float[] metricmod; 
 int idx; 
 color c; 

  
 Oscillator(PVector origin_, float angle_, float kn_, float w_, float r_, float[] metricmod_, int idx_, color c_){
    origin = origin_.get();    
    location = new PVector(); 
    angle = angle_;
    adj = new float[delay]; 
    kn = kn_;
    r = r_;
    w = w_; // divided by frame rate bc freq -> radians/sec
    bob = 9.0;
    state = new float[delay]; 
    trig = 0; 
    this.metricmod = metricmod_; 
    idx = idx_; 
    c = c_; 

  }
  
  //void update(float R, float psi){
  //  adj = R*kn*sin(psi-angle); 
  //  angle = angle + w + adj;
  //}
  
  
  void draw(){ 
    if (fullScreenCircleFlag == false){
      if(bob > 5){
       bob = bob - 0.4;  
      }
      pushMatrix();
      translate(origin.x, origin.y);
      fill(100,100,100,10);
      noStroke();
      ellipse(0, 0, 2*(r-10), 2*(r-10)); // draw bounding circle
      location.set((r-10)*sin(angle), (r-10)*cos(angle), 0);    
      stroke(c);
      fill(c);
      ellipse(location.x, location.y, bob, bob);
      popMatrix();
    }
    else{
      if(bob > 5){
       bob = bob - 0.4;  
      }
      pushMatrix();
      translate(width/2, height/2);
      fill(230,230,230,10);
      noStroke();
      ellipse(0,0,(width/4), (width/4));
      location.set((width/8)*sin(angle), (width/8)*cos(angle), 0);    
      stroke(c);
      fill(c);
      ellipse((width/8)*sin(angle), (width/8)*cos(angle), bob, bob);
      popMatrix();
      
    }
  }
 
  void checkZC(){
    trig = 0; 
    
  //  for(int m = 0; m < triggers[idx].length; m++){  //  
   for(int m = 0; m < N; m++){

      if((angle >= TWO_PI)){
          bob = 15;
          trig = 1; 
          // send an OSC message here
          angle = angle % TWO_PI;   
      }
      if((angle <= -TWO_PI)){
          bob = 15;
          trig = 1; 
          // send an OSC message here
          angle = angle % -TWO_PI;   
      }
      //if((lastangle < triggers[idx][m]) && (angle > triggers[idx][m])){
      //  bob = 15; 
      //  trig = 1; 
      //}
      //if((-lastangle < triggers[idx][m]) && (-angle > triggers[idx][m])){
      //  bob = 15; 
      //  trig = 1;
      //}
    }
    
    // wrap phase
    if((angle > TWO_PI)){
     //bob = 15; 
     //trig = 1;
     angle = angle % TWO_PI; 
    }
    if((angle < -TWO_PI)){
     //bob = 15; 
     //trig = 1; 
     angle = angle % -TWO_PI;
    }
  }
  
}
