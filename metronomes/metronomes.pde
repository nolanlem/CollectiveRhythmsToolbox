// Damped, driven and coupled pendulums (Optimized)
// nolan lem 11-7-22

PrintWriter output;
String thefilename;
String filename = "";

ControlFrame cf;

int N = 3;
int maxN = 100;
int maxmetros = 100;
int curr_i = N;

// equation of motion terms
float coupleAccel = 0.0;
float avgAngle = 0.0;
// coupled platform
float init_L = 25.0;
float gravity = 0.4;
float damping = 0.01;
float period = 60.0;
float platformfreq;
int xdist = 500;
float amp = 0.003;
float kn = 0.5;

// grid indications for metronome position on screen
int maxrow = 10, maxcol = 10;

// to save states matrices
int[] states = new int[maxN];
float[] kn_states = new float[maxN];

// define arraylist of pendulum objects
ArrayList<Pendulum> p = new ArrayList<Pendulum>();

// grid stuff
int x = 60, y = x, h=int(init_L), off = int(init_L*2)+10, grid = 10, many = grid*grid;

float omega_0 = 1.3;
float epsilon = 0.05;

int freqspread = 60;
int num_states = 10;

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

float[] ls = new float[maxmetros];

void settings() {
  size(wwidth, wheight);
}

void setup() {
  noStroke();
  cf = new ControlFrame(this, 500, 600, "Controls");
  surface.setLocation(520, 10);

  int s = second();
  int m = minute();
  int hr = hour();
  String thetime = str(hr) + "_" + str(m) + "_" + str(s) + ".txt";
  thefilename = "savedstates/" + thetime;
  output = createWriter(thefilename);

  makeControls();

  for (int i = 0; i < N; i++) {
    float randomangleL = random(-PI/2, -PI/4);
    float randomangleR = random(PI/4, PI/2);
    float[] randomangarr = {randomangleL, randomangleR};
    int randint = int(random(0, 2));
    p.add(new Pendulum(new PVector(x + (i%grid)*(init_L+off), y + (floor(i/grid))*(init_L+off)), init_L, randomangarr[randint], i));
    ls[i] = init_L;
  }
}

void draw() {
  background(255);

  OscMessage myMessage = new OscMessage("/trig");
  boolean anyTriggered = false; // [Optimization #5] track triggers

  platformfreq = amp*cos(TWO_PI * frameCount/period);

  couplePendulums();

  for (int i = 0; i < p.size(); i++) {
    Pendulum pen = p.get(i); // [Optimization #4] cache reference
    pen.go();
  }

  for (int i = 0; i < p.size(); i++) {
    Pendulum pen = p.get(i); // [Optimization #4] cache reference
    myMessage.add(pen.state);
    if (pen.state == 1) anyTriggered = true; // [Optimization #5]
  }

  // [Optimization #5] Only send OSC when at least one trigger fired
  if (anyTriggered) {
    oscP5.send(myMessage, myRemoteLocation);
  }
}

void couplePendulums() {
  float xc = 0.0;
  float yc = 0.0;
  coupleAccel = 0.0;
  avgAngle = 0.0;

  // [Optimization #4] cache ArrayList references
  for (int i = 0; i < p.size(); i++) {
    Pendulum pen = p.get(i);
    coupleAccel += pen.aAcceleration;
    avgAngle += pen.angle/(TWO_PI);

    xc += cos(pen.angle);
    yc += sin(pen.angle);
  }
  xc /= p.size();
  yc /= p.size();
  R = sqrt(xc*xc + yc*yc);
  psi = atan2(yc, xc);

  coupleAccel = kn*coupleAccel/p.size();

  avgAngle = avgAngle/p.size();
}

// function to display graphical phase coherence
void plotR(float r, float ang) {
  rmag[graphlen-1] = r;
  rmag[graphlen-1] = map(rmag[graphlen-1], 0, 1, 0, 100);

  // [Optimization #6] Set stroke/fill once before the loop
  stroke(0);
  fill(0);
  for (int i = 0; i < graphlen-1; i++) {
    if (rmag[i] != 0) {
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
void plotCOP(float r, float ang) {
  translate(1*width/3, 6*height/7);
  stroke(0);
  noFill();
  ellipse(0, 0, 100, 100);
  stroke(255, 0, 0);
  fill(100);
  line(0, 0, 100*r*cos(ang)/2, 100*r*sin(ang)/2);
}

// draw the platforms
void drawPlatform() {
  pushMatrix();
  fill(175);
  noStroke();
  translate(platformfreq*4000, 10 + int(init_L) + height/2);
  rect(width/14, 0, 520, 20);
  popMatrix();
}

// randomize the metronome phases
void randomize() {
  println("randomize phases:");
  for (int i = 0; i < p.size(); i++) {
    p.get(i).angle = random(-PI/2, PI/2);
  }
}

// randomize the pendulum length (natural tempo/freq)
void randomizeFreqs(float theValue) {
  println("modify pendula lengths");
  for (int i = 0; i < p.size(); i++) {
    p.get(i).r = random(init_L+0, init_L+theValue);
  }
}
