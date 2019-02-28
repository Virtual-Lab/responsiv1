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
int objectnumber = 5;
int objectcopies = 10;
int object = 0;
int dw = displayWidth;
int dh = displayHeight;
int[][] variation = new int[objectnumber][objectcopies];
int[] impuls = new int[objectnumber];
int[] zaehler = new int[objectnumber];
int[] wert = new int[objectnumber];
float[] sinex = new float[1440];
float[] siney = new float[1440];


// int[] channel;



// Setup - Main part
void setup() {
  // size(600,400);
  size(displayWidth, displayHeight);
  //frameRate(24);
  if (frame != null) {
    frame.setResizable(true);
  }
//    for(int i = 0; i < objectnumber; i++) { 
//      variation[i] = new int[objectcopies];  }

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
  
  /* Plug Message - leitet die message auf die Funktion "test" */
  oscP5.plug(this,"dodec","/dodec");
}

boolean sketchFullScreen() {
  return true;
}


public void dodec(int i, int a, int b) {
  // println("### Message erhalten ..... /test.");
  println(" 3 variablen empfangen: "+i+", "+a+", "+b);  
  
  object = i;
  impuls[i] = a;
  wert[i] = b;
  zaehler[i] = 20;
}


void draw() {
  
  background(0);
  
    puls(object, impuls[object], wert[object]);
  
//    zaehler[i]--;
//    if (zaehler[i] == 0) 
//          impuls[i] = 0; 
//          wert[i] = 0;
  
}
       
void puls(int number, int farbe, int position) {
  
//  for (int i=0; i<objectnumber; i++) {
//      zaehler[i]--;
//      if (zaehler[i] == 0) {
//        impuls[i] = 0;
//      
    if (position == 0) {} else {
      
      for (int i = 0; i < objectcopies; i++) {
           
           variation[number][i] = variation[number][i] + int(random(-2, 2));
           println("Variation("+i+" ="+variation[number][i]);
           if (variation[number][i] > (displayHeight/2)) variation[number][i] = variation[number][i] - 2;
           if (variation[number][i] < -(displayHeight/2)) variation[number][i] = variation[number][i] + 2;
      };
      
      if (number == 0) {
      
         for (int i = 0; i < objectcopies; i++) {
      
           noStroke();
           fill(farbe);
           rect(displayWidth/(log(variation[number][i])), (displayHeight/3.149+(variation[number][i]*2)),((displayWidth/5)+variation[number][i]), displayHeight/(1+position));
         };
      };
        
      if (number == 1) {
      
          fill(farbe);
          noStroke();
          rect((displayWidth/100)*position, 0,(displayWidth)/(50+variation[number][0]), displayHeight);
    
      };
   
      
      if (number == 2) {
      
         for (int i = 0; i < objectcopies; i++) {
      
           //fill(farbe);
           noStroke();
           fill(100-farbe);
           triangle(displayWidth/(log(variation[number][i])), (displayHeight/2), 80, displayHeight/(1+position), 50 + variation[number][i], 50 + variation[number][i]);
         };
        };
      
        if (number == 3) {
      
         for (int i = 0; i < objectcopies; i++) {
      
           noStroke();
           fill(farbe);
           rect((displayWidth/2)+variation[number][i], (displayHeight/2),(20+variation[number][i]), displayHeight/(1+position));
         };
        };
      
        if (number == 4) {
      
           for (int i = 0; i < (displayWidth); i++) { 
             
             for (int k = 0; k < objectcopies; k++) {
             
               siney[i] = (50*variation[number][k]) * sin(i*2*PI*(position)/(displayWidth));
            
               stroke(255-farbe);
               point(i, siney[i]+(displayHeight/2+variation[number][k]));
             }
           }
        };
 
    };
}
  
// void welle (freq) {
  
    





// incoming osc message are forwarded to the oscEvent method.
void oscEvent(OscMessage theOscMessage) {

  if(theOscMessage.isPlugged()==false) {
  // print the address pattern and the typetag of the received OscMessage 
  println("### received an osc message.");
  println("### addrpattern\t"+theOscMessage.addrPattern());
  println("### typetag\t"+theOscMessage.typetag());
  }
}

