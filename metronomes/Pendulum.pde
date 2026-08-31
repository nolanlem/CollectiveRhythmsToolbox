/////////////////////////////////////////////////////////////////////
class Pendulum {
  // Properties for the Pendulum
  PVector location;    // Location of bob
  PVector origin;      // Location of arm origin
  float r;             // Length of arm
  float angle;         // Pendulum arm angle
  float angle_;        // old angle
  float aVelocity;     // Angle velocity
  float aAcceleration; // Angle acceleration
  float bob;           // bob radius
  int idx;             // for indexing/labeling
  int state;
  float L;
  float movingrefx;    // x-dir motion of the driven and coupled forces acting on/thru the table
  float kn;

  Pendulum(PVector origin_, float r_, float ang, int idx_) {
    origin = origin_.get();
    location = new PVector();
    r = r_;
    angle = ang;
    aVelocity = 0.0;
    aAcceleration = 0.0;
    bob = 5.0;
    idx = idx_;
    state = 0;
  }

  void go() {
    update();
    checkZC();
    display();
  }

  void update() {
    angle_ = angle; // save old angle for zero crossing comparison
    // dw/dt = omega - damping*w + ExtForce + Coupling
    // terms (l to right):
    // gravity - damping(velocity)
    // - escapement/inherent_oscillation
    // + external_forcing
    // + coupling of table from metronome moments of I
    aAcceleration = (-1 * gravity / r) * sin(angle) - damping*aVelocity - amp*sin(TWO_PI*frameCount/period) + coupleAccel;

    aVelocity += aAcceleration;
    aVelocity -= epsilon*((angle/omega_0)*(angle/omega_0) - 0.1)*aVelocity;
    angle += aVelocity;
  }

  // check for Zero Crossings so we can send out OSC messages at right time
  void checkZC() {
    state = 0;
    if (aVelocity > 0.01) {
      if ((angle > 0) && (angle_ < 0)) {
        bob = 15;
        state = 1;
      } else if ((angle < 0) && (angle_ > 0)) {
        bob = 15;
        state = 1;
      } else if (angle > TWO_PI) {
        bob = 15;
        state = 1;
      } else if (angle < -TWO_PI) {
        bob = 15;
        state = 1;
      }
    }
    angle = angle % TWO_PI; // wrap phases
  }

  void display() {
    if (bob > 5) {
      bob = bob - 0.4;
    }

    // Where is the bob relative to the origin? Polar to Cartesian coordinates
    location.set(r*sin(angle), r*cos(angle), 0);
    location.add(origin);

    stroke(0);
    // moving reference frame
    movingrefx = (platformfreq + coupleAccel)*xdist;

    // The arm
    line(origin.x + movingrefx, origin.y, location.x + movingrefx, location.y);

    fill(100);

    // the center line
    line(origin.x + movingrefx, origin.y, origin.x + movingrefx, 10 + r + origin.y);

    fill(10);
    // the bob
    ellipse(location.x + movingrefx, location.y, bob, bob);
    noStroke();

    stroke(0);
    // the platform
    line(origin.x+movingrefx-10, origin.y+r+10, origin.x + movingrefx + 10, origin.y+r+10);
  }
}
