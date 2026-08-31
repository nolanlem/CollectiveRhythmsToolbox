class TriggerPoint {
  float angle;    // position on rim [0, TWO_PI)
  boolean active; // true = fires when crossed

  TriggerPoint(float angle, boolean active) {
    this.angle = angle;
    this.active = active;
  }
}
