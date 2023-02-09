import controlP5.*; 
import oscP5.*;
import netP5.*;

ControlP5 cp5;
OscP5 oscP5; 
NetAddress myRemoteLocation; 



void makeControls(){
  // osc stuff
  oscP5 = new OscP5(this, 57120);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);
  
}

/// receive OSC messages from LEMUR 
void oscEvent(OscMessage theOscMessage) {
  //println(theOscMessage); 
  
   
        // freq_i slider from lemur 
      if (theOscMessage.checkAddrPattern("/freq_i/x")){
      println(theOscMessage.get(0).floatValue());
      for(int i = 0; i < N; i++){
        if (states[i] == 1){
          o.get(i).w = theOscMessage.get(0).floatValue()/9.5; 
          }
        }
      }
   
   // kn slider from lemur 
      if (theOscMessage.checkAddrPattern("/kn/x")){
      println(theOscMessage.get(0).floatValue());
      for(int i = 0; i < N; i++){
        if (states[i] == 1){
          o.get(i).kn = theOscMessage.get(0).floatValue(); 
        }
      }
  }
    

  for (int i =0; i<100; i++){   
      if (theOscMessage.checkAddrPattern("/kn" + str(i) + "/x")){
                println(theOscMessage); 
                 float status = theOscMessage.get(0).floatValue(); 
                 println("button " + str(i) + ":" + status); 
                 states[i] = int(status); 
                   }
      }
  if (theOscMessage.checkAddrPattern("/kn/value")){
      println(theOscMessage); 
  }
       
}
