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
int objectnumber = 2;
int dw = displayWidth;
int dh = displayHeight;
int variation = 40;
int[] impuls = new int[objectnumber];
int[] object = new int[objectnumber];
int[] zaehler = new int[objectnumber];
int[] wert = new int[objectnumber];

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

//boolean sketchFullScreen() {
//  return true;
//}


public void test(int i, int a, int b) {
  // println("### Message erhalten ..... /test.");
  println(" 3 variablen empfangen: "+i+", "+a+", "+b);  
  
  impuls[i] = a;
  wert[i] = b;
  zaehler[i] = 20;
}


void draw() {
  
  background(0);
  
  for (int i=0; i<objectnumber; i++) {
    puls(i, impuls[i], wert[i]);
  
    zaehler[i]--;
    if (zaehler[i] == 0) 
          impuls[i] = 0;
  }
}
       
void puls(int number, int farbe, int position) {
  
//  for (int i=0; i<objectnumber; i++) {
//      zaehler[i]--;
//      if (zaehler[i] == 0) {
//        impuls[i] = 0;
//      
    if (number == 0) {
      
        fill(farbe);
        rect((displayWidth/100)*position, 0,((displayWidth)/100), displayHeight);
    
    };
    
     if (number == 1) {
       
      variation = variation + int(random(-2, 2));
      if (variation > displayHeight) variation = displayHeight - 1;
      if (variation <= 0) variation = variation + 1;
      
      
        fill(farbe);
        rect((displayWidth/2)-20, (displayHeight/10),((displayWidth)/variation), displayHeight/(1+position));
    
    };
   //line();
};
  
  //void zeichen () {
    





// incoming osc message are forwarded to the oscEvent method.
void oscEvent(OscMessage theOscMessage) {

  if(theOscMessage.isPlugged()==false) {
  // print the address pattern and the typetag of the received OscMessage 
  println("### received an osc message.");
  println("### addrpattern\t"+theOscMessage.addrPattern());
  println("### typetag\t"+theOscMessage.typetag());
  }
}