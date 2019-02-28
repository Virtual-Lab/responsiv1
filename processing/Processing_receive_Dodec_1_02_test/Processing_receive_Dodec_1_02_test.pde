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
float[][] variation = new float[objectnumber][objectcopies];
float[] impuls = new float[objectnumber];
float[] wert = new float[objectnumber];
int[] zaehler = new int[objectnumber];
float[] siney = new float[1440];
float[] sineyold = new float[1440];


// int[] channel;



// Setup - Main part
void setup() {
  //size(1024, 768);
  size(displayWidth, displayHeight);
  //frameRate(24);
  if (frame != null) {
    frame.setResizable(true);
  }

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12001);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
  
  /* Plug Message - leitet die message auf die Funktion "test" */
  oscP5.plug(this,"dodec","/dodec");
}

boolean sketchFullScreen() {
  return true;
}


public void dodec(int i, float a, float b) {
  // println("### Message erhalten ..... /test.");
  println(" 3 variablen empfangen: "+i+", "+a+", "+b);  
  
  object = i;
  impuls[i] = a;
  wert[i] = b;
  zaehler[i] = 60;
}


void draw() {
  
  background(0);
  
    for (int i = 0; i < objectnumber; i++) {
  
      puls(i, impuls[i], wert[i]);
      
       zaehler[i]--;
      if (zaehler[i] == 0) 
      {
          impuls[i] = 0; 
          wert[i] = 0;
      };
   }
}
       
void puls(int number, float farbe, float position) {
  
  farbe = int((farbe + 1)/2 * 255);
  
//  for (int i=0; i<objectnumber; i++) {
//      zaehler[i]--;
//      if (zaehler[i] <= 0) 
//        position = 0.0;
//  }
      
    if (position == 0) {} else {
      
      for (int i = 0; i < objectcopies; i++) {
           
           variation[number][i] = variation[number][i] + random(-2, 2);
           //variation[number][i] = variation[number][i] + noise(frameCount)-0.5;
           println("Variation("+i+" ="+variation[number][i]);
           if (variation[number][i] > (displayHeight/2)) variation[number][i] = variation[number][i] - 2;
           if (variation[number][i] < -(displayHeight/2)) variation[number][i] = variation[number][i] + 2;
      };
      
      // Objekt 0: Grain - Synth
      if (number == 0) {
      
         for (int i = 0; i < objectcopies; i++) {
      
           noStroke();
           fill(farbe);
           position = position/10;
           rect(displayWidth/(log(variation[number][i])*3), (displayHeight/(2+position)),(displayWidth/variation[number][i]), displayHeight/(5+position));
         };
      };
        
      // Object 2: Granulator, Sample
      if (number == 1) {
        
          position = (position+1)*50;   
          fill(farbe);
          noStroke();
          rect((displayWidth/100)*position, 0,(displayWidth)/(50+variation[number][0]), displayHeight);
    
      };
   
      // Object 3: Glockenklang
      if (number == 2) {
      
         for (int i = 0; i < objectcopies; i++) {
      
           position = position/10;
           fill(farbe);
           noStroke();
           //fill(255);
           triangle(position, displayHeight/(5+position), position+variation[number][i], displayHeight/(2+position), position + 2* variation[number][i],  displayHeight/(position));
         };
        };
      
        if (number == 3) {
      
         for (int i = 0; i < objectcopies; i++) {
      
           position = position/100;
           noStroke();
           fill(farbe);
           rect((displayWidth/2)+variation[number][i], (displayHeight/2),(20+variation[number][i]), displayHeight/(1+position));
         };
        };
      
        if (number == 4) {
          
           sineyold[0] = displayHeight/2+variation[number][0];
           
           for (int i = 1; i < (displayWidth); i++) { 
             
            // for (int k = 0; k < objectcopies; k++) {
             
               siney[i] = (farbe*2) * sin(i*2*PI*(position/10)/(displayWidth)); // *variation[number][k]
            
               stroke(255-(farbe));
               // point(i, siney[i]+(displayHeight/2+variation[number][k]));
               line(i-1, sineyold[i-1], i, siney[i]+(displayHeight/2+variation[number][0]));
               sineyold[i] = siney[i] + (displayHeight/2+variation[number][0]);
               
             // }
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

