
///////////////////////////////////////////////////////////////////// 
class Pendulum  {
//Many, many variables to keep track of the Pendulum’s various properties
  PVector location;    // Location of bob
  PVector origin;      // Location of arm origin
  float r;             // Length of arm
  float angle;         // Pendulum arm angle
  float angle_;        // old angle 
  float aVelocity;     // Angle velocity
  float aAcceleration; // Angle acceleration
  //float damping;       // Arbitrary damping amount
  float bob;              // bob radius
  int idx;  // for indexing/labeling
  int state;
  float L; 
  float movingrefx; // x-dir motion of the driven and coupled forces acting on/thru the table
 // OscMessage myMessage; 
 
  Pendulum(PVector origin_, float r_, int idx_) {
    origin = origin_.get(); // location of bob
    location = new PVector(); // location of arm origin 
    r = r_;                  // length of arm
    angle = random(-PI/4, PI/4); // initial pendulum arm angle
    angle_ = angle;
    aVelocity = 0.0;            // angle velocity
    aAcceleration = 0.0;        //angle acceleration 
    bob = 5.0;
    idx  = idx_;
    state = 0;

}
 
  void go() {
    update();
    checkZC();
    display();
  }
   
  void update() {
    
    angle_ = angle; // save old angle for zero crossing comparison 
    //Formula we worked out for angular acceleration
    // dw/dt = omega - damping*w + ExtForce + Coupling
    
    //aAcceleration = (-1 * gravity / r) * sin(angle) - damping*aVelocity - amp*sin(TWO_PI*frameCount/period); 
    
    // terms (l to right) 
    // gravity - damping(velocity) 
    // - escapement/inherent_oscillation (accels motion if omega_i < omega_0 and damps for omega_i > omega_0, 
    // where omega_0 is set by function) 
    // + external_forcing (allow table to be pushed externally) 
    // + coupling of table from metronome moments of I (moving reference frame (motion of table generates moments of intertia which act back on the metronomes ) 
    aAcceleration = (-1 * gravity / r) * sin(angle) - damping*aVelocity - amp*sin(TWO_PI*frameCount/period) + coupleAccel; 
    // amp is the strength of the applied motion and period is 
    
    //aAcceleration = (-1 * gravity / r) * sin(angle) - damping*aVelocity + amp*sin(TWO_PI*frameCount/period); 
    
    aVelocity += aAcceleration; // integrate acceleration
    aVelocity -= epsilon*((angle/omega_0)*(angle/omega_0) - 0.1)*aVelocity; 
    angle += aVelocity;

  }
 
 // check for Zero Crossings so we can send out OSC messages at right time 
  void checkZC(){
    state = 0;
    if (aVelocity > 0.01){
      if((angle > 0) && (angle_ < 0)){
          bob = 15;
          state = 1; 
      }
      if((angle < 0) && (angle_ > 0)){
          bob = 15;
         state = 1;
      }
      if(angle > TWO_PI){
          bob = 15;
          state = 1;
      }
      if(angle < -TWO_PI){
          bob = 15; 
          state = 1; 
    } 
    }
    angle = angle % TWO_PI; // wrap phases
}
 
  void display() {
    if(bob > 5){
     bob = bob - 0.4; 
    }
    
    // Where is the bob relative to the origin? Polar to Cartesian coordinates will tell us!
    location.set(r*sin(angle),r*cos(angle),0);
    location.add(origin);
     
    stroke(0);
    // moving reference frame!
    movingrefx = (platformfreq + coupleAccel)*xdist; 
    
    ///// The arm
    //line(origin.x + platformfreq*xdist, origin.y, location.x + platformfreq*xdist, location.y); // this is kinda cool, looks like the bob is being thrown 
    line(origin.x + movingrefx, origin.y, location.x + movingrefx, location.y); 

    fill(100);

    ///// the center line;     
    //line(origin.x, origin.y, origin.x + platformfreq*xdist, 10 + L + origin.y);
    //line(origin.x + platformfreq*xdist, origin.y, origin.x + platformfreq*xdist, 10 + r + origin.y);
    line(origin.x + movingrefx, origin.y, origin.x + movingrefx, 10 + r + origin.y);
    
    fill(10);
    // the bob
    ellipse(location.x + movingrefx,location.y,bob,bob); 
    noStroke();
    
    stroke(0);
    //// the platform    
    //line(origin.x+platformfreq*xdist-10, origin.y+r+10, origin.x + platformfreq*xdist + 10, origin.y+r+10);
    line(origin.x+movingrefx-10, origin.y+r+10, origin.x + movingrefx + 10, origin.y+r+10);
 
  //  stroke(188, 48, 200);
  //line(origin.x + coupleAccel*xdist + 20, origin.y + r + 20, origin.x + coupleAccel*xdist -20, origin.y + r + 20);
  //  rect(width/30, 0, 20, 20);
    
  //  // table moment of inertia (green) as a sum of the driving force and the coupled force
  //  stroke(48, 188, 100);
  //  line(origin.x + movingrefx + 30, origin.y + r + 30, origin.x + movingrefx - 30, origin.y + r + 30);
  
  }
  
  
}
