// Collective Rhythms Toolbox (Optimized)
// Extended Kuramoto coupled oscillator model
// This script allows a user to interact with networks of coupled oscillators (<=100) using
// either pulse-coupling or generalized continuous coupling (Kuramoto Model).
// The darker grey matrix on the left is the 'selector matrix'. Each toggle corresponds to an
// oscillator in the ensemble. By clicking on a toggle or a group of toggles you select the oscillators
// that you intend for parameter modification. Using the sliders, the user can adjust the
// selected oscillators coupling ('KN'), natural frequency (FREQ_I), external forcing frequency (FREQ_E),
// and external forcing strength (CFF). The slider labeled 'F_SPREAD', allows you to create a
// normal natural frequency distribution applied to all active oscillators.
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

PrintWriter output;
String thefilename;

ControlFrame cf;

Boolean fullScreenCircleFlag = false;

int maxN = 100;
int N = 8;
String couplingType = "kura";

ArrayList<Oscillator> o = new ArrayList<Oscillator>();

float R = 0.0;
// for |R| feedback (|R|(kn))
int lenWindow = 10;
float[] R_avg = new float[lenWindow];
float[] last_R_avg = new float[lenWindow];
float R_target = 0.3;
boolean fb_R_flag = false;

float psi = 0.0;
float radius = 20;
float coupling = 0.0;
float init_freq = 0.25;
float pulse_scaling_coupling_coeff = 2.0;

float[] kn_inc = new float[maxN];
float inc_amt = 0.02;

int row = int(sqrt(N));
int col = int(sqrt(N));
int maxrow = 10, maxcol = 10;
int delay = 2;
int graphlen = 100;
float[] rmag = new float[graphlen];

// to save states
int[] states = new int[maxN];
float[] kn_states = new float[maxN];
float[] state_kn = new float[maxN];
float[] state_freq = new float[maxN];

float ff = 0.0;
float freq_e = 1;
float cff = 0.0;

int x = 60, y = x, h=int(radius), off = int(radius*2)+10, grid = 10, many = grid*grid;
float[][] metricmod = {{PI}, {0}};
// sequencer stuff
int timesteps = 8;
int tempo = 100;
int smallestloopsteps = 4;
int largestloopsteps = 4*4;
int totalsteps = 4*(largestloopsteps/smallestloopsteps)+1;
float[][] triggers = new float[10][totalsteps];

color[] colors = {#000005, #000005};

float[] fqz = {
  0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75,
  1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5,
  2.25, 2.25, 2.25, 2.25, 2.25, 2.25, 2.25, 2.25, 2.25, 2.25,
  3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
  3.75, 3.75, 3.75, 3.75, 3.75, 3.75, 3.75, 3.75, 3.75, 3.75,
  4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
  5.25, 5.25, 5.25, 5.25, 5.25, 5.25, 5.25, 5.25, 5.25, 5.25,
  6.0, 6.0, 6.0, 6.0, 6.0, 6.0, 6.0, 6.0, 6.0, 6.0,
  6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75, 6.75,
  7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5
};

int wwidth = 800, wheight = 800;

// click-to-select state
float hitRadius = 18; // center zone radius for selection clicks
int dragMode = -1; // -1 = no drag, 1 = selecting, 0 = deselecting
boolean[] dragVisited = new boolean[maxN]; // prevent re-toggling during a single drag

// trigger point drag state
int dragOscIdx = -1;       // which oscillator's trigger is being dragged
int dragTrigIdx = -1;      // which trigger index
float dragStartX, dragStartY; // initial click position
boolean isDraggingTrigger = false; // did mouse move enough to count as drag?

// group tracking state
int[] oscGroup = new int[maxN];  // group ID per oscillator (0 = no group)
int nextGroupId = 1;
color[] groupColors = {#E6194B, #3CB44B, #4363D8, #F58231, #911EB4,
                       #42D4F4, #F032E6, #BFEF45, #469990, #E6BEFF};
boolean shiftHeld = false;

void settings() {
  size(wwidth, wheight);
}

void setup() {
  int d_ = day(); int mon_ = month(); int y_ = year();
  int s_ = second(); int min_ = minute(); int h_ = hour();
  String thetime = str(d_) + "_" + str(mon_) + "_" + str(y_) + "-" + str(h_) + ":" + str(min_) + ":" + str(s_) + ".txt";
  thefilename = "./savedstates/" + thetime;
  output = createWriter(thefilename);

  makeControls();
  noStroke();

  for (int i = 0; i < N; i++) {
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

  for (int i = 0; i < maxN; i++) {
    kn_inc[i] = 0.0;
  }
  initializeDelays();

  for (int i = 0; i < lenWindow; i++) {
    last_R_avg[i] = 0.0;
  }

  cf = new ControlFrame(this, 500, 600, "Controls");
  surface.setLocation(515, 10);
}

void initializeDelays() {
  for (int i = 0; i < o.size(); i++) {
    Oscillator osc = o.get(i);
    for (int t = 0; t < delay; t++) {
      osc.state[t] = 0.0;
    }
  }
}

void randomizePhases() {
  for (int i = 0; i < o.size(); i++) {
    o.get(i).angle = random(0, TWO_PI);
  }
}

void draw() {
  background(255);

  // [Optimization #8] Use .equals() for string comparison
  if (couplingType.equals("kura")) {
    iterateDelay();
  }
  if (couplingType.equals("pulse")) {
    iteratePulse();
  }

  if (fullScreenCircleFlag == true) {
    plotR_thiswindow(R, psi);
    plotCOP_thiswindow(R, psi);
  }
}

/////////////////// KURAMOTO coupling //////////////////////////////////////////////
void iterateDelay() {
  OscMessage myMessage = new OscMessage("/trig");
  boolean anyTriggered = false; // [Optimization #5] track if any trigger fired

  for (int t = 1; t < delay; t++) {
    // [Optimization #4] Cache ArrayList references
    for (int i = 0; i < o.size(); i++) {
      Oscillator osc = o.get(i);
      osc.state[t-1] = osc.angle;
    }

    float xc = 0.0; // complex order param components
    float yc = 0.0;
    for (int i = 0; i < o.size(); i++) {
      Oscillator osc = o.get(i);
      osc.state[t] = osc.state[t-1];
      xc += cos(osc.state[t]);
      yc += sin(osc.state[t]);
    }

    R = sqrt(xc*xc + yc*yc)/o.size();
    psi = atan2(yc, xc);

    ///////// R FEEDBACK INTO KN ///////////
    if (fb_R_flag == true) {
      R_avg[lenWindow - 1] = R;
      for (int i = 2; i < lenWindow; i++) {
        R_avg[lenWindow - i] = last_R_avg[lenWindow - i + 1];
      }
      // calc mean of array
      float meanR = 0.;
      for (int i = 0; i < lenWindow; i++) {
        meanR += R_avg[i] / (R_avg.length);
      }
      println(R, meanR);
      if (frameCount > 5) {
        // [Optimization #10] Use arrayCopy instead of reference assignment
        arrayCopy(R_avg, last_R_avg);
      }

      for (int i = 0; i < N; i++) {
        Oscillator osc = o.get(i);
        if (meanR > R_target) {
          kn_inc[i] = osc.kn;
          kn_inc[i] -= inc_amt;
        }
        if (meanR < R_target) {
          kn_inc[i] = osc.kn;
          kn_inc[i] += inc_amt;
        }
      }
    }
    ///////////////////////////////////////////////

    for (int i = 0; i < o.size(); i++) {
      Oscillator osc = o.get(i);
      osc.adj[t] = R*(osc.kn+kn_inc[i])*sin(psi-osc.state[t]);
      osc.state[t] = osc.state[t] + osc.w + osc.adj[t];
    }
  }

  // [Optimization #7] Draw background circle once before all oscillators
  if (fullScreenCircleFlag) {
    drawCircleBackground();
  }

  // update angles with time delayed adjustment and iterate / integrate ang vel
  for (int i = 0; i < o.size(); i++) {
    Oscillator osc = o.get(i);
    osc.prevAngle = osc.angle;
    osc.angle = osc.angle + cff + osc.w + osc.adj[1];
    osc.checkTriggers();
    osc.lastangle = osc.state[delay-1];

    myMessage.add(osc.trig);
    if (osc.trig == 1) anyTriggered = true; // [Optimization #5]
    osc.draw();
  }

  // update forcing function with w (omega)
  ff = (ff + freq_e/9.5)%(TWO_PI);

  // [Optimization #5] Only send OSC when at least one trigger fired
  if (anyTriggered) {
    oscP5.send(myMessage, myRemoteLocation);
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////// PULSE coupling ///////////////////////////////////////////////////////////////////
// [Optimization #3] Use mean-field (order parameter) instead of O(N^2) pairwise adjustment
void iteratePulse() {
  OscMessage myMessage = new OscMessage("/trig");
  boolean anyTriggered = false; // [Optimization #5]

  float xc = 0.0;
  float yc = 0.0;

  // First pass: save prevAngle, iterate angles forward, compute order parameter
  for (int i = 0; i < o.size(); i++) {
    Oscillator osc = o.get(i);
    osc.prevAngle = osc.angle;
    osc.angle = osc.angle + osc.w;
    xc += cos(osc.angle);
    yc += sin(osc.angle);
  }

  R = sqrt(xc*xc + yc*yc)/o.size();
  psi = atan2(yc, xc);

  // Second pass: apply mean-field pulse coupling for any oscillator that crossed zero
  // Instead of O(N^2) pairwise loop, use the order parameter (R, psi) as a mean-field proxy.
  // When oscillator i fires, adjust all others using mean-field:
  //   angle_j -= K_j * sin(angle_j - psi)
  // We count how many fired and apply a single combined adjustment.
  int numFired = 0;
  for (int i = 0; i < o.size(); i++) {
    Oscillator osc = o.get(i);
    if (osc.angle > TWO_PI) {
      numFired++;
    }
  }

  if (numFired > 0) {
    for (int j = 0; j < o.size(); j++) {
      Oscillator osc = o.get(j);
      osc.angle = osc.angle - (pulse_scaling_coupling_coeff * osc.kn) * numFired * sin(osc.angle - psi);
    }
  }

  // [Optimization #7] Draw background circle once before all oscillators
  if (fullScreenCircleFlag) {
    drawCircleBackground();
  }

  // Third pass: check trigger crossings, build OSC message, draw
  for (int i = 0; i < o.size(); i++) {
    Oscillator osc = o.get(i);
    osc.checkTriggers();
    myMessage.add(osc.trig);
    if (osc.trig == 1) anyTriggered = true; // [Optimization #5]
    osc.draw();
  }

  // [Optimization #5] Only send OSC when at least one trigger fired
  if (anyTriggered) {
    oscP5.send(myMessage, myRemoteLocation);
  }
}


void plotR_thiswindow(float r, float ang) {
  pushMatrix();
  if (fullScreenCircleFlag == true) {
    translate(300, 520);
  } else {
    translate(300, 520);
  }
  rmag[graphlen-1] = r/o.size();
  rmag[graphlen-1] = map(rmag[graphlen-1], 0, 1, 100, 0);

  // [Optimization #6] Set fill/stroke once before the loop
  fill(0);
  stroke(#C92718);
  for (int i = 0; i < graphlen-1; i++) {
    ellipse(i*2, rmag[i], 1, 1);
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

// [Optimization #7] Draw the shared background circle once before all oscillators
void drawCircleBackground() {
  pushMatrix();
  translate(width/2, height/2);
  fill(230, 230, 230, 10);
  noStroke();
  ellipse(0, 0, (width/4), (width/4));
  popMatrix();
}

void plotCOP_thiswindow(float r, float ang) {
  if (fullScreenCircleFlag == true) {
    pushMatrix();
    translate(width/2, height/2);
    stroke(0);
    noFill();
    stroke(#C92718);
    fill(100);
    line(0, 0, 100*r*sin(psi)/o.size(), 100*r*cos(psi)/o.size());
    popMatrix();
  } else {
    pushMatrix();
    translate(300, 740);
    stroke(0);
    noFill();
    ellipse(0, 0, 100, 100);
    stroke(255, 0, 0);
    fill(100);
    line(0, 0, 50*r*sin(psi)/o.size(), 50*r*cos(psi)/o.size());
    popMatrix();
  }
}

// Shift key tracking for group selection
void keyPressed() {
  if (keyCode == SHIFT) shiftHeld = true;
}
void keyReleased() {
  if (keyCode == SHIFT) shiftHeld = false;
}

/////////////////// Click-to-select oscillators on the main visualization ///////////////////

// Find which oscillator index the mouse is over, or -1 if none
int hitTestOscillator(float mx, float my) {
  if (fullScreenCircleFlag) return -1; // skip in circle map mode
  for (int i = 0; i < N; i++) {
    Oscillator osc = o.get(i);
    float d = dist(mx, my, osc.origin.x, osc.origin.y);
    if (d < hitRadius) {
      return i;
    }
  }
  return -1;
}

// Toggle an oscillator's selection and sync with the ControlFrame buttons
void setOscSelection(int idx, int selState) {
  states[idx] = selState;
  if (cf != null && cf.cp5 != null) {
    if (selState == 1) {
      cf.cp5.get(Button.class, "st_" + str(idx)).setOn();
    } else {
      cf.cp5.get(Button.class, "st_" + str(idx)).setOff();
    }
  }
}

void mousePressed() {
  if (fullScreenCircleFlag) return;

  for (int i = 0; i < N; i++) {
    Oscillator osc = o.get(i);
    float d = dist(mouseX, mouseY, osc.origin.x, osc.origin.y);

    if (d < 18) {
      if (shiftHeld && oscGroup[i] > 0) {
        // Select all oscillators in this group, deselect others
        int group = oscGroup[i];
        for (int j = 0; j < N; j++) {
          setOscSelection(j, oscGroup[j] == group ? 1 : 0);
        }
        return;
      }
      // Center zone: toggle selection
      int newState = (states[i] == 1) ? 0 : 1;
      dragMode = newState;
      dragVisited = new boolean[maxN];
      dragVisited[i] = true;
      setOscSelection(i, newState);
      return;
    }

    if (d >= 18 && d <= 42) {
      // Rim zone: trigger point interaction
      float mx = mouseX - osc.origin.x;
      float my = mouseY - osc.origin.y;
      float clickAngle = atan2(mx, my);
      if (clickAngle < 0) clickAngle += TWO_PI;

      // Check if click is near an existing trigger point
      int nearIdx = -1;
      float nearDist = 10;
      for (int j = 0; j < osc.triggerPoints.size(); j++) {
        TriggerPoint tp = osc.triggerPoints.get(j);
        float tpx = (osc.r - 10) * sin(tp.angle);
        float tpy = (osc.r - 10) * cos(tp.angle);
        float td = dist(mx, my, tpx, tpy);
        if (td < nearDist) {
          nearDist = td;
          nearIdx = j;
        }
      }

      if (nearIdx >= 0) {
        // Near existing trigger: prepare for drag or toggle
        dragOscIdx = i;
        dragTrigIdx = nearIdx;
        dragStartX = mouseX;
        dragStartY = mouseY;
        isDraggingTrigger = false;
      } else {
        // Not near any trigger: add a new active trigger point
        osc.triggerPoints.add(new TriggerPoint(clickAngle, true));
      }
      return;
    }
  }
}

void mouseDragged() {
  if (dragOscIdx >= 0) {
    float movedDist = dist(mouseX, mouseY, dragStartX, dragStartY);
    if (movedDist > 5) {
      isDraggingTrigger = true;
    }
    if (isDraggingTrigger) {
      Oscillator osc = o.get(dragOscIdx);
      float mx = mouseX - osc.origin.x;
      float my = mouseY - osc.origin.y;
      float newAngle = atan2(mx, my);
      if (newAngle < 0) newAngle += TWO_PI;
      osc.triggerPoints.get(dragTrigIdx).angle = newAngle;
    }
    return;
  }

  // Existing selection paint drag
  if (dragMode < 0) return;
  int hit = hitTestOscillator(mouseX, mouseY);
  if (hit >= 0 && !dragVisited[hit]) {
    dragVisited[hit] = true;
    setOscSelection(hit, dragMode);
  }
}

void mouseReleased() {
  if (dragOscIdx >= 0) {
    if (!isDraggingTrigger) {
      // Small click: remove the trigger point
      Oscillator osc = o.get(dragOscIdx);
      osc.triggerPoints.remove(dragTrigIdx);
    }
    dragOscIdx = -1;
    dragTrigIdx = -1;
    isDraggingTrigger = false;
    return;
  }
  dragMode = -1;
}
