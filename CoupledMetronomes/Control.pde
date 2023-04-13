import controlP5.*; 
import oscP5.*;
import netP5.*;

// ControlP5 cp5;
OscP5 oscP5; 
NetAddress myRemoteLocation;


void makeControls(){
  oscP5 = new OscP5(this, 57120);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);

      // new ControlFrame(this, 640, 640, "Controls")
  //cp5 = new ControlP5(this);
  
  //cp5.addSlider("amp")
  //.setRange(0,0.01)
  //.setValue(0.000)
  //.setSize(10,100)
  //.setColorValue(0xffff88ff)
  //.setPosition(width-5*40,height-130)
  //.setColorCaptionLabel(0xffff88ff)
  //.setCaptionLabel("amp_d");
  
 
  //cp5.addSlider("damping")
  //.setRange(0.0,0.03)
  //.setValue(0.00)
  //.setSize(10,100)
  //.setColorValue(0xffff88ff)
  //.setPosition(width-4*40, height-130)
  //.setColorCaptionLabel(0xffff88ff);
  
  //cp5.addSlider("period")
  //.setRange(10,120)
  //.setValue(60)
  //.setSize(10,100)
  //.setColorValue(0xffff88ff)
  //.setPosition(width-3*40, height-130)
  //.setColorCaptionLabel(0xffff88ff);

  //cp5.addSlider("freqspread")
  //.setRange(0,60)
  //.setValue(0)
  //.setSize(10,100)
  //.setColorValue(0xffff88ff)
  //.setPosition(width-2*40, height-130)
  //.setColorCaptionLabel(0xffff88ff);

  //cp5.addSlider("kn")
  //.setRange(0.0, 0.70)
  //.setValue(0.0)
  //.setSize(10,100)
  //.setColorValue(0xffff88ff)
  //.setPosition(width-1*40, height-130)
  //.setColorCaptionLabel(0xffff88ff);
  
  //cp5.addButton("random")
  //   .setValue(0)
  //   .setPosition(width-40,height-160)
  //   .setSize(20,20)
  //   .setColorCaptionLabel(0xffff88ff)     
  //   ;
     
  // cp5.addButton("writer")
  // .setPosition(width-100,height-190)
  // .setSize(60,20);
  
 
  // ButtonBar b = cp5.addButtonBar("states")
  //   .setPosition(0, 0)
  //   .setSize(400, 20)
  //   .addItems(split("1 2 3 4 5 6 7 8 9 10"," "))
  //   ;
     
}

void states(int n){
  String filename = "";
  for(int m=0; m<num_states; m++){
    if(n==m){
     filename = "savedstates/" + str(m) + ".txt";
     println("loading " + filename);
    }
  }
  loadTxtFile(filename);  
}

void writer(){
  output.println(period + "," + kn + "," + amp + "," + damping + "," + freqspread);
  println("writing " + thefilename + " to txtfile"); 
  output.flush();
  output.close();  
  exit();
}

void loadTxtFile(String thetxtfile){
   String[] lines = loadStrings(thetxtfile);
   println("there are " + lines.length + " lines");
   for(String line : lines){
    String[] l = split(line, ',');
    period = float(l[0]);
    kn = float(l[1]);
    amp = float(l[2]);
    damping = float(l[3]);
    freqspread = int(l[4]);
    println(period + "," + kn + "," + amp + "," + damping + "," + freqspread);
    
 }  
}

void controlEvent(ControlEvent theEvent){
    if(theEvent.getController().getName() == "random"){
      randomize();
    }    
    if(theEvent.getController().getName() == "freqspread"){
      randomizeFreqs(freqspread);
      println("randomize freqs");
    }
}






    
