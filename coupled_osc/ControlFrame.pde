class ControlFrame extends PApplet {

  PApplet parent;
  ControlP5 cp5;

  int w, h;
  int xg = 100, yg = 300, wg = 10, hg = wg, offg = 2, grid = 10, many = grid*grid;
  Button[] btns = new Button[many];
  Button[] btns_kn = new Button[many];

  color slidercolor = #D3DCE3;

  public ControlFrame(PApplet _parent, int _w, int _h, String _name) {
    super();
    parent = _parent;
    w = _w;
    h = _h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w, h);
  }

  public void setup() {
    surface.setLocation(10, 10);
    cp5 = new ControlP5(this);
    cp5.setAutoDraw(false);

    for (int i = 0; i < many; i++) {
      int bx = xg + (i%grid) * (wg+offg);
      int by = yg + (floor(i/grid)) * (hg+offg);
      btns[i] = cp5.addButton("st_"+str(i))
        .setSwitch(true)
        .setColorBackground(color(200, 200, 200))
        .setColorForeground(color(200, 0, 200))
        .setColorActive(color(0, 200, 0))
        .setId(i)
        .setPosition(bx, by)
        .setLabelVisible(false)
        .setSize(wg, hg);

      btns_kn[i] = cp5.addButton("bkn_"+str(i))
        .setSwitch(true)
        .setColorBackground(color(235, 235, 235))
        .setColorForeground(color(240, 171, 166))
        .setColorActive(color(0, 200, 0))
        .setId(i)
        .setPosition(bx+130, by)
        .setLabelVisible(false)
        .setSize(wg, hg);

      states[i] = 0;
    }

    // sequencer matrix
    cp5.addMatrix("sequencer")
      .setPosition(100, 50)
      .setSize(200, 160)
      .setGrid(totalsteps, 10)
      .setInterval(100)
      .setMode(ControlP5.MULTIPLES)
      .setColorBackground(color(120))
      .setBackground(color(40));

    for (int i = 0; i < 10; i++) {
      cp5.get(Matrix.class, "sequencer").set(1, i, true);
    }

    cp5.addButton("writer")
      .setPosition(30, 230)
      .setSize(60, 20);

    cp5.addButton("loader")
      .setPosition(30, 200)
      .setSize(60, 20);

    // intrinsic freq spread
    cp5.addSlider("freq_spread").plugTo(parent, "freq_spread")
      .setPosition(360, 340)
      .setRange(0, 1.0)
      .setValue(0.0)
      .setSize(15, 80)
      .setColorValue(color(100, 0, 0))
      .setColorCaptionLabel(color(0, 0, 0))
      .setColorBackground(#404579)
      .setCaptionLabel("f_spread");

    // external forcing function frequency slider
    cp5.addSlider("freq_e").plugTo(parent, "freq_e")
      .setPosition(365, 170)
      .setRange(0, 3)
      .setValue(0.0)
      .setSize(15, 80)
      .setColorValue(color(100, 0, 0))
      .setColorCaptionLabel(color(0, 0, 0))
      .setColorBackground(#404579)
      .setCaptionLabel("freq_e");

    cp5.addButton("set").plugTo(parent, "set")
      .setPosition(320, 100)
      .setSize(60, 60)
      .setColorBackground(#54DB5C);

    // external forcing function strength/coefficient slider
    cp5.addSlider("cff").plugTo(parent, "cff")
      .setPosition(320, 170)
      .setRange(0, 0.2)
      .setValue(0.0)
      .setSize(15, 80)
      .setColorValue(color(100, 0, 0))
      .setColorCaptionLabel(color(0, 0, 0))
      .setCaptionLabel("cff");

    // intrinsic frequency slider
    cp5.addSlider("f_i").plugTo(parent, "f_i")
      .setPosition(405, 150)
      .setRange(0, 5)
      .setValue(1)
      .setSize(20, 100)
      .setColorValue(color(100, 0, 0))
      .setColorCaptionLabel(color(0, 0, 0))
      .setColorBackground(#404579)
      .setCaptionLabel("freq_i");

    // 'kn' coupling slider
    cp5.addSlider("coupling")
      .setPosition(450, 150)
      .setRange(-0.02, 0.1)
      .setValue(0.000)
      .setSize(20, 100)
      .setColorValue(color(100, 0, 0))
      .setColorForeground(color(240, 200, 200))
      .setColorLabel(0xE60000)
      .setColorCaptionLabel(color(0, 0, 0))
      .setCaptionLabel("kn");

    // R target slider
    cp5.addSlider("R target")
      .setPosition(330, 480)
      .setRange(0, 1.0)
      .setValue(0.000)
      .setSize(20, 100)
      .setColorValue(color(0, 0, 0))
      .setColorForeground(color(240, 200, 200))
      .setColorLabel(0xE60000)
      .setColorCaptionLabel(color(0, 0, 0))
      .setCaptionLabel("R target");

    cp5.addButton("global_kn")
      .setValue(0)
      .setPosition(405, 120)
      .setSize(60, 20);

    cp5.addButton("random").plugTo(parent, "random")
      .setValue(0)
      .setPosition(405, 90)
      .setSize(60, 20);

    ButtonBar b = cp5.addButtonBar("states").plugTo(parent, "states")
      .setPosition(0, 0)
      .setSize(400, 20)
      .addItems(split("1 2 3 4 5 6 7 8 9 10", " "));

    b.onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent ev) {
        ButtonBar bar = (ButtonBar)ev.getController();
        // [Optimization #9] Replaced 7 identical if-blocks with a single index lookup
        int idx = bar.hover();
        String filename = "";
        if (idx >= 0 && idx <= 6) {
          filename = sketchPath("savedstates/" + str(idx + 1) + ".txt");
        }
        if (!filename.equals("")) {
          loadTxtFile(filename);
        }
      }
    });
  }

  // timestep is column, osc is row in sequencer matrix
  void sequencer(int timestep, int osc) {
    triggers[osc][timestep] = TWO_PI*timestep/(totalsteps-1);
  }

  // receive OSC messages from LEMUR
  void oscEvent(OscMessage theOscMessage) {
    for (int i = 0; i < 100; i++) {
      if (theOscMessage.checkAddrPattern("/kn" + str(i) + "/x")) {
        println(theOscMessage);
        float status = theOscMessage.get(0).floatValue();
        println("button " + str(i) + ": " + status);
        states[i] = int(status);
        states[i] = int(btns[i].isOn());
        cp5.get(Button.class, "st_" + str(i)).setOn();
      }
    }
  }

  void controlEvent(ControlEvent theEvent) {
    // [Optimization #8] Use .equals() for string comparison throughout
    for (int i = 0; i < N; i++) {
      if (theEvent.isFrom(cp5.getController("st_" + str(i)))) {
        String name = theEvent.getController().getName();
        int btn = theEvent.getController().getId();
        states[i] = int(btns[btn].isOn());
      }
    }

    if (theEvent.getController().getName().equals("random")) {
      randomizePhases();
    }

    if (theEvent.getController().getName().equals("writer")) {
      println("writing text file");
      writeTxtFile();
    }

    if (theEvent.getController().getName().equals("loader0")) {
      println("loading text file");
      loadTxtFile("savedstates/here.txt");
    }

    if (theEvent.getController().getName().equals("global_kn")) {
      println("toggling on all selectors");
      for (int i = 0; i < N; i++) {
        cp5.get(Button.class, "st_" + str(i)).setOn();
      }
    }

    if (theEvent.getController().getName().equals("coupling")) {
      float knval = cp5.get(Slider.class, "coupling").getValue();
      float cmap = map(knval, 0.00, 0.01, 235, 15);
      cp5.getController("coupling").setColorForeground(color(240, cmap, cmap));
    }

    // modulate R target with slider
    if (theEvent.getController().getName().equals("R target")) {
      R_target = cp5.get(Slider.class, "R target").getValue();
    }
  }

  void draw() {
    background(240, 240, 240);

    // post coupling type
    textSize(14);
    fill(0);
    text("coupling: " + couplingType, 50, 450);
    textSize(14);

    textSize(10);
    text("keystroke guide", 10, 30);
    textSize(9);
    text("'k' Kuramoto model", 5, 40);
    text("'p' Pulse Coupling", 5, 50);
    text("'=' add oscillator", 5, 60);
    text("'-' remove oscillator", 5, 70);
    text("'1' select all active ", 5, 80);
    text("'0' deselect all active ", 5, 90);
    text("'2' toggle |R| target", 5, 100);
    text("'f' toggle display mode", 5, 110);
    text("'a' burn in parameters to selected", 100, 30);

    text("select oscillators in group", 100, 290);
    text("coupling strength indicator", 230, 290);

    // On/Off txt label for R_target flag
    if (fb_R_flag == true) {
      fill(0, 240, 0);
      text("ON", 450, 485);
    } else {
      fill(0);
      text("OFF", 330, 475);
    }

    plotR(R, psi);
    plotCOP(R, psi);

    cp5.draw();

    // group number overlays on selector buttons
    for (int i = 0; i < N; i++) {
      if (oscGroup[i] > 0) {
        int bx = xg + (i % grid) * (wg + offg);
        int by = yg + (floor(i / grid)) * (hg + offg);
        color gc = groupColors[(oscGroup[i] - 1) % groupColors.length];
        fill(gc);
        noStroke();
        textAlign(CENTER, CENTER);
        textSize(8);
        text(str(oscGroup[i]), bx + wg/2, by + hg/2 - 1);
      }
    }
    textAlign(LEFT, BASELINE);
  }

  void keyPressed() {
    // set the slider params to the oscillators
    if (key == 'a') {
      int groupId = nextGroupId;
      boolean anyBurned = false;
      for (int i = 0; i < states.length; i++) {
        if (states[i] == 1) {
          anyBurned = true;
          oscGroup[i] = groupId;

          print(kn_states[states[i]] + " ");
          float knval = cp5.getController("coupling").getValue();
          float freqval = cp5.getController("f_i").getValue();

          kn_states[states[i]] = knval;

          o.get(i).kn = kn_states[states[i]];
          o.get(i).w = freqval/9.5;
          kn_inc[i] = kn_states[states[i]];

          float cmap = map(knval, -0.02, 0.1, 235, 15);
          btns_kn[i].setColorBackground(color(240, int(cmap), int(cmap)));

          float freqspread = cp5.getController("freq_spread").getValue();
          o.get(i).w += randomGaussian()*freqspread/9.5;
        }
      }
      if (anyBurned) nextGroupId++;
    }

    // activate all oscs
    if (key == '1') {
      for (int i = 0; i < N; i++) {
        cp5.get(Button.class, "st_" + str(i)).setOn();
      }
    }

    // turn on R feedback
    if (key == '2') {
      fb_R_flag = !fb_R_flag;
    }

    // clear the selector matrix
    if (key == '0') {
      cp5.get(Matrix.class, "sequencer").clear();
      for (int i = 0; i < maxN; i++) {
        states[i] = 0;
        cp5.get(Button.class, "st_" + str(i)).setOff();
      }
      cp5.get(Slider.class, "coupling").setValue(0);
    }

    // add oscillator
    if ((key == '=') & (N < 100)) {
      o.add(new Oscillator(new PVector(x + (N%grid)*(radius+off),
        y + (floor(N/grid))*(radius+off)),
        random(0, TWO_PI),
        coupling,
        init_freq/9.5,
        wwidth/radius,
        metricmod[0],
        N,
        colors[int(random(colors.length))])
        );
      N += 1;
      println("adding oscillator, N=" + N + " oscillators");
    }

    // remove oscillator
    if ((key == '-') & (N >= 1)) {
      N -= 1;
      o.remove(N);
      println("removing oscillator... N=" + N + " oscillators");
      states[N] = 0;
      cp5.get(Button.class, "st_" + str(N)).setOff();
    }

    if (key == 'f') {
      print("toggling display mode");
      fullScreenCircleFlag = !fullScreenCircleFlag;
    }

    // [Optimization #8] Use .equals() for string comparison
    if (key == 'k') {
      print("kuramoto coupling ");
      couplingType = "kura";
    }

    if (key == 'p') {
      print("pulse coupling");
      couplingType = "pulse";
    }

    if (key == SHIFT) {
    }
  }

  void plotR(float r, float ang) {
    pushMatrix();
    if (fullScreenCircleFlag == true) {
      translate(100, 480);
    } else {
      translate(100, 480);
    }
    rmag[graphlen-1] = r;
    rmag[graphlen-1] = map(rmag[graphlen-1], 0, 1, 100, 0);

    // [Optimization #6] Set fill/stroke once before the loop
    fill(0);
    stroke(#C92718);
    for (int i = 0; i < graphlen-1; i++) {
      ellipse(i*2, rmag[i], 1, 1);
      rmag[i] = rmag[i+1];
    }

    // bounding box
    fill(0);
    stroke(0);
    strokeWeight(0.5);
    line(0, 0, 0, graphlen);
    line(0, -1, graphlen*2, -1);
    line(graphlen*2, 0, graphlen*2, graphlen);
    line(0, graphlen+1, 2*graphlen, graphlen+1);

    textSize(12);
    text("|R|", graphlen-120, 50);

    popMatrix();
  }

  void plotCOP(float r, float ang) {
    if (fullScreenCircleFlag == true) {
      pushMatrix();
      translate(420, 530);
      noStroke();
      fill(230, 230, 230);
      ellipse(0, 0, 100, 100);
      stroke(#C92718);
      fill(100);
      line(0, 0, 100*r*sin(psi)/o.size(), 100*r*cos(psi)/o.size());
      popMatrix();
    } else {
      pushMatrix();
      translate(420, 530);
      noStroke();
      fill(230, 230, 230);
      ellipse(0, 0, 100, 100);
      stroke(255, 0, 0);
      fill(100);
      line(0, 0, 50*r*sin(psi), 50*r*cos(psi));
      popMatrix();
    }
  }

  /////// I/O ///////////
  void writeTxtFile() {
    float freqeval = cp5.get(Slider.class, "freq_e").getValue();
    float cffval = cp5.get(Slider.class, "cff").getValue();

    output.println("N," + str(N));
    output.println("ext_forcing_freq," + str(freqeval));
    output.println("ext_forcing_amp," + str(cffval));

    for (int i = 0; i < o.size(); i++) {
      Oscillator osc = o.get(i);
      output.print("osc" + str(i) + "kn," + osc.kn);
      output.println(",osc" + str(i) + "w," + osc.w);
    }

    println("writing " + thefilename + " to txtfile");
    output.flush();
    output.close();
    exit();
  }

  void loadTxtFile(String thetxtfile) {
    println("Reading " + thetxtfile + " params");

    String[] lines = loadStrings(thetxtfile);

    println(lines.length);
    println("there are " + lines.length + " lines");
    String[] n = split(lines[0], ',');
    println(n[0] + " " + int(n[1]));
    int Ntxt = int(n[1]);
    String[] eff = split(lines[1], ',');
    println(eff[0] + " " + float(eff[1]));
    freq_e = float(eff[1]);
    String[] efa = split(lines[2], ',');
    println(efa[0] + " " + float(efa[1]));
    cff = float(efa[1]);

    // remove all oscillators
    for (int i = N-1; i >= 0; i--) {
      println(i);
      o.remove(i);
    }
    N = 0;

    // add in N oscillators from txt file
    for (int i = 0; i < Ntxt; i++) {
      o.add(new Oscillator(new PVector(x + (N%grid)*(radius+off),
        y + (floor(N/grid))*(radius+off)),
        random(0, TWO_PI),
        coupling,
        init_freq/9.5,
        wwidth/radius,
        metricmod[0],
        N,
        colors[int(random(colors.length))])
        );
      N += 1;
      println("adding oscillator, N=" + N + " oscillators");
    }

    // update the coupling coeff (kn) and intrinsic freq (w) according to txt file
    int idx = 0;
    for (String line : lines) {
      if (idx > 2) {
        String[] l = split(line, ',');
        println(l[0]+ ": " + float(l[1]) + " " + l[2] + ": " + float(l[3]));
        println(idx-3);
        o.get(idx-3).kn = float(l[1]);
        o.get(idx-3).w = float(l[3]);

        // update coupling strength matrix
        float cmap = map(float(l[1]), -0.02, 0.1, 235, 15);
        btns_kn[idx-3].setColorBackground(color(240, int(cmap), int(cmap)));
      }
      idx += 1;
    }
  }
}
