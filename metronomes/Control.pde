import controlP5.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void makeControls() {
  oscP5 = new OscP5(this, 57120);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);
}

void states(int n) {
  // [Optimization #9] Simplified from loop+repeated if-blocks to direct lookup
  if (n >= 0 && n < num_states) {
    String filename = "savedstates/" + str(n) + ".txt";
    println("loading " + filename);
    loadTxtFile(filename);
  }
}

void writer() {
  output.println(period + "," + kn + "," + amp + "," + damping + "," + freqspread);
  println("writing " + thefilename + " to txtfile");
  output.flush();
  output.close();
  exit();
}

void loadTxtFile(String thetxtfile) {
  String[] lines = loadStrings(thetxtfile);
  println("there are " + lines.length + " lines");
  for (String line : lines) {
    String[] l = split(line, ',');
    period = float(l[0]);
    kn = float(l[1]);
    amp = float(l[2]);
    damping = float(l[3]);
    freqspread = int(l[4]);
    println(period + "," + kn + "," + amp + "," + damping + "," + freqspread);
  }
}

// [Optimization #8] Use .equals() for string comparison
void controlEvent(ControlEvent theEvent) {
  if (theEvent.getController().getName().equals("random")) {
    randomize();
  }
  if (theEvent.getController().getName().equals("freqspread")) {
    randomizeFreqs(freqspread);
    println("randomize freqs");
  }
}
