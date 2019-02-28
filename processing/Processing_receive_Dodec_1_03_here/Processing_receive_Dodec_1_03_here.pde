/**
 * oscP5plug by andreas schlegel
 * oscP5 website at http://www.sojamo.de/oscP5
 */

// importieren der Bibliotheken
import oscP5.*;
import netP5.*;
import codeanticode.syphon.*;

PGraphics canvas;
SyphonServer server;

// Angabe von Variablen (wahrscheinlich von der Bibliothek)
OscP5 oscP5;
NetAddress myRemoteLocation;
int objectnumber = 5;
int objectcopies = 10;
int object = 0;
int canvasWidth = 3840; // 1280;
int canvasHeight = 720; // 240
float[][] variation = new float[objectnumber][objectcopies];
float[] impuls = new float[objectnumber];
float[] wert = new float[objectnumber];
int[] zaehler = new int[objectnumber];
float[] siney = new float[1440];
float[] sineyold = new float[1440];


// int[] channel;



// Setup - Main part
void setup() {
  size(canvasWidth, canvasHeight, P3D);
  canvas = createGraphics(canvasWidth, canvasHeight, P3D);

  server = new SyphonServer(this, "Processing_receive_Dodec_1_03");
  
    frameRate(30);
    if (frame != null) {
    frame.setResizable(true);
  }

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("localhost", 12000);
  
  // "169.254.4.168" "169.254.123.93" "localhost" 
  /* Plug Message - leitet die message auf die Funktion "test" */
  oscP5.plug(this,"dodec","/dodec");
}

//boolean sketchFullScreen() {
//  return true;
//}


public void dodec(int i, float a, float b) {
  // println("### Message erhalten ..... /test.");
  // println(" 3 variablen empfangen: "+i+", "+a+", "+b);  
  
  object = i;
  impuls[i] = a;
  wert[i] = b;
  zaehler[i] = 60;
}


void draw() {
  
  background(0);
  
  canvas.beginDraw();
  canvas.background(0);
  
    for (int i = 0; i < objectnumber; i++) {
  
      puls(i, impuls[i], wert[i]);
      
       zaehler[i]--;
      if (zaehler[i] == 0) 
      {
          impuls[i] = 0; 
          wert[i] = 0;
      };
   }
    canvas.endDraw();
    image(canvas, 0, 0);
    server.sendImage(canvas);
    
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
           if (variation[number][i] > (canvasHeight/2)) variation[number][i] = variation[number][i] - 2;
           if (variation[number][i] < -(canvasHeight/2)) variation[number][i] = variation[number][i] + 2;
      };
      
      // Objekt 0: Grain - Synth
      if (number == 0) {
      
         for (int i = 0; i < objectcopies; i++) {
      
           canvas.noStroke();
           canvas.fill(farbe);
           position = position/10;
           canvas.rect(canvasWidth/(log(variation[number][i])*3), (canvasHeight/(2+position)),(canvasWidth/variation[number][i]), canvasHeight/(5+position));
         };
      };
        
      // Object 2: Granulator, Sample
      if (number == 1) {
        
          position = (position+1)*50;   
          canvas.fill(farbe);
          canvas.noStroke();
          canvas.rect((canvasWidth/100)*position, 0,(canvasWidth)/(50+variation[number][0]), canvasHeight);
    
      };
   
      // Object 3: Glockenklang
      if (number == 2) {
      
         for (int i = 0; i < objectcopies; i++) {
      
           position = position/10;
           canvas.fill(farbe);
           canvas.noStroke();
           //fill(255);
           canvas.triangle(position, canvasHeight/(5+position), position+variation[number][i], canvasHeight/(2+position), position + 2* variation[number][i],  canvasHeight/(position));
         };
        };
      
        if (number == 3) {
      
         for (int i = 0; i < objectcopies; i++) {
      
           position = position/100;
           canvas.noStroke();
           canvas.fill(farbe);
           canvas.rect((canvasWidth/2)+variation[number][i], (canvasHeight/2),(20+variation[number][i]), canvasHeight/(1+position));
         };
        };
      
        if (number == 4) {
          
           sineyold[0] = canvasHeight/2+variation[number][0];
           
           for (int i = 1; i < (canvasWidth); i++) { 
             
            // for (int k = 0; k < objectcopies; k++) {
             
               siney[i] = (farbe*2) * sin(i*2*PI*(position/10)/(canvasWidth)); // *variation[number][k]
            
               canvas.stroke(255-(farbe));
               // point(i, siney[i]+(canvasHeight/2+variation[number][k]));
               canvas.line(i-1, sineyold[i-1], i, siney[i]+(canvasHeight/2+variation[number][0]));
               sineyold[i] = siney[i] + (canvasHeight/2+variation[number][0]);
               
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

