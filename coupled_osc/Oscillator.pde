class Oscillator {

  PVector location;
  PVector origin;
  float angle;
  float lastangle;
  float prevAngle;
  float kn;
  float r;
  float w;
  float bob;
  float[] state;
  float[] adj;
  int trig;
  float[] metricmod;
  int idx;
  color c;
  ArrayList<TriggerPoint> triggerPoints;

  Oscillator(PVector origin_, float angle_, float kn_, float w_, float r_, float[] metricmod_, int idx_, color c_) {
    origin = origin_.get();
    location = new PVector();
    angle = angle_;
    adj = new float[delay];
    kn = kn_;
    r = r_;
    w = w_;
    bob = 9.0;
    state = new float[delay];
    trig = 0;
    this.metricmod = metricmod_;
    idx = idx_;
    c = c_;
    prevAngle = angle;
    triggerPoints = new ArrayList<TriggerPoint>();
    triggerPoints.add(new TriggerPoint(0, true));
  }

  void draw() {
    if (bob > 5) {
      bob = bob - 0.4;
    }

    if (fullScreenCircleFlag == false) {
      pushMatrix();
      translate(origin.x, origin.y);

      // draw bounding circle
      fill(100, 100, 100, 10);
      noStroke();
      ellipse(0, 0, 2*(r-10), 2*(r-10));

      // draw green selection ring if this oscillator is selected
      if (idx < states.length && states[idx] == 1) {
        noFill();
        stroke(0, 200, 0);
        strokeWeight(2);
        ellipse(0, 0, 2*(r-10), 2*(r-10));
        strokeWeight(1);
      }

      // draw trigger points on the rim
      for (int i = 0; i < triggerPoints.size(); i++) {
        TriggerPoint tp = triggerPoints.get(i);
        float tx = (r-10) * sin(tp.angle);
        float ty = (r-10) * cos(tp.angle);
        stroke(0);
        fill(255);
        strokeWeight(1.5);
        ellipse(tx, ty, 8, 8);
      }
      strokeWeight(1);

      // draw the moving phase dot
      location.set((r-10)*sin(angle), (r-10)*cos(angle), 0);
      stroke(c);
      fill(c);
      ellipse(location.x, location.y, bob, bob);
      popMatrix();
    } else {
      pushMatrix();
      translate(width/2, height/2);
      // [Optimization #7] Background circle is now drawn once in main draw().
      location.set((width/8)*sin(angle), (width/8)*cos(angle), 0);
      stroke(c);
      fill(c);
      ellipse(location.x, location.y, bob, bob);
      popMatrix();
    }
  }

  void checkTriggers() {
    trig = 0;
    float rawDelta = angle - prevAngle;

    if (abs(rawDelta) > 0.0001) {
      for (int i = 0; i < triggerPoints.size(); i++) {
        TriggerPoint tp = triggerPoints.get(i);
        if (!tp.active) continue;

        if (rawDelta > 0) {
          // forward direction
          float d1 = normalizeAngle(tp.angle - prevAngle);
          float d2 = normalizeAngle(rawDelta);
          if (d1 > 0 && d1 <= d2) {
            trig = 1;
            bob = 15;
          }
        } else {
          // backward direction
          float d1 = normalizeAngle(prevAngle - tp.angle);
          float d2 = normalizeAngle(-rawDelta);
          if (d1 > 0 && d1 <= d2) {
            trig = 1;
            bob = 15;
          }
        }
      }
    }

    // wrap angle to [0, TWO_PI)
    angle = normalizeAngle(angle);
  }

  float normalizeAngle(float a) {
    a = a % TWO_PI;
    if (a < 0) a += TWO_PI;
    return a;
  }
}
