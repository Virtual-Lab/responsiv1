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
int objectcopies = 5;
int object = 0;
int canvasWidth = 1920; // 1280 3840;
int canvasHeight = 640; // 240  720;
float[][] variation = new float[objectnumber][objectcopies];
float[] impuls = new float[objectnumber];
float[] wert = new float[objectnumber];
int[] zaehler = new int[objectnumber];
float[] siney = new float[canvasWidth];
float[] sineyold = new float[canvasWidth];


// Setup - Main part
void setup() {
  size(canvasWidth, canvasHeight, P3D); //, P3D
  canvas = createGraphics(canvasWidth, canvasHeight, P3D); //, P3D

  server = new SyphonServer(this, "Processing_receive_Dodec_1_03");
  
    // frameRate(30);
    // if (frame != null) {
    // frame.setResizable(true);
  //}

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12001);
  // myRemoteLocation = new NetAddress("169.254.123.93", 12001);
  
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
  zaehler[i] = 20;
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
           if (variation[number][i] == 0) variation[number][i] = variation[number][i] + (random(1, 2)*2-1);
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
        
          for (int i = 0; i < objectcopies; i++) {
            position = (position+1)*50;   
            canvas.noStroke();
            canvas.fill(farbe);

            canvas.rect((canvasWidth/100)*position*(1+variation[number][i]/canvasWidth), 0,(canvasWidth)/(50+variation[number][i]), canvasHeight);
          };
      };
   
      // Object 3: Glockenklang
      if (number == 2) {
      
         for (int i = 0; i < objectcopies; i++) {
      
           position = position/2;
           canvas.fill(farbe);
           canvas.noStroke();
           //fill(255);
           canvas.triangle(position + (i*canvasWidth/5), canvasHeight/10 + (variation[number][i]), 
           position+(i*canvasWidth/5) + 5*variation[number][i], canvasHeight/2+(variation[number][i]/2), 
           position+(i*canvasWidth/5) + 10* variation[number][i],  canvasHeight/1.2+(variation[number][i]/4));
         };
        };
      
        if (number == 3) {
      
         for (int i = 0; i < objectcopies; i++) {
      
           position = position/100;
           canvas.noStroke();
           canvas.fill(farbe);
           canvas.rect((canvasWidth/5*i)+variation[number][i]+20, canvasHeight/(4+i),(50+variation[number][i]), canvasHeight/(1+position));
         };
        };
      
        if (number == 4) {
          
           sineyold[0] = canvasHeight/2+variation[number][0];
           
           for (int i = 1; i < (canvasWidth); i++) { 
             
             //for (int k = 0; k < objectcopies-3; k++) {
             
               siney[i] = ((canvasHeight/200)*(255-farbe)/2) * sin(i*2*PI*(position/10)/(canvasWidth)); // *variation[number][k]);
            
               canvas.stroke(255-(farbe));
               canvas.strokeWeight(8);
               // point(i, siney[i]+(canvasHeight/2+variation[number][k]));
               canvas.line(i-1, sineyold[i-1], i, siney[i]+(canvasHeight/2+variation[number][0]));
               sineyold[i] = siney[i] + (canvasHeight/2+variation[number][0]);
               
             //}
           }
        };
 
    };
}
  
// void welle (freq) {
  
    





//   incoming osc message are forwarded to the oscEvent method.
//   void oscEvent(OscMessage theOscMessage) {

//   if(theOscMessage.isPlugged()==false) {
//    print the address pattern and the typetag of the received OscMessage 
//     println("### received an osc message.");
//     println("### addrpattern\t"+theOscMessage.addrPattern());
//     println("### typetag\t"+theOscMessage.typetag());
//    }
//}

