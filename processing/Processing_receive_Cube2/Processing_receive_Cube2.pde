/**
 * oscP5plug by andreas schlegel
 * oscP5 website at http://www.sojamo.de/oscP5
 */

// importieren der Bibliotheken
import oscP5.*;
import netP5.*;

// Angabe von Variablen (wahrscheinlich von der Bibliothek)
OscP5 oscP5;
NetAddress myRemoteLocation;
int object = 100;
int dw = displayWidth;
int dh = displayHeight;
int[] impuls = new int[objectnumber];
int[] object = new int[objectnumber];
int[] zaehler = new int[objectnumber];
float[] wert = new float[objectnumber];

// int[] channel;



// Setup - Main part
void setup() {
  // size(600,400);
  size(displayWidth, displayHeight);
  frameRate(24);
  if (frame != null) {
    frame.setResizable(true);
  }

  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
  
  /* Plug Message - leitet die message auf die Funktion "test" */
  oscP5.plug(this,"test","/test");
}

boolean sketchFullScreen() {
  return true;
}


public void test(int a, int b, float c) {
  // println("### Message erhalten ..... /test.");
  println(" 3 variablen empfangen: "+a+", "+b);  
  
  object = a;
  impuls[a] = b;
  zaehler[a] = 100;
  wert[a] = c;
}


void draw() {
  
  background(0);
  puls();

  }
        

void puls() {
  
  for (int i=0; i<objectnumber; i++) {
      zaehler[i]--;
      if (zaehler[i] == 0) {
        impuls[i] = 0;
      }
    fill(impuls[i]);
    rect((displayWidth/objectnumber)*i, 0,((displayWidth)/objectnumber), (displayHeight));
  }
}




// incoming osc message are forwarded to the oscEvent method.
void oscEvent(OscMessage theOscMessage) {

  if(theOscMessage.isPlugged()==false) {
  // print the address pattern and the typetag of the received OscMessage 
  println("### received an osc message.");
  println("### addrpattern\t"+theOscMessage.addrPattern());
  println("### typetag\t"+theOscMessage.typetag());
  }
}

