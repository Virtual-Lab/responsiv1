/**
 * First test of p5js - Script
 * see also: open Form - cube
 */

// Definieren der Variablen

var objectnumber = 2;
var poly = 10;
var dw, dh;
var variation = 40;
var impuls = new Array(objectnumber);
var object = new Array(objectnumber);
var zaehler = new Array(objectnumber);
var wert = new Array(objectnumber);
var tone = new Array(poly);
var client;
var enter, output;
var isUnlocked = false;
var rotfront = 0, rotback= 0, rotdir= 0;
var rotation = 0, oldposition = 0;


impuls.fill(0);
object.fill(0);
zaehler.fill(0);

function unlock() {

      

  // if(isIOS || this.unlocked)

  //   return;



  // create empty buffer and play it

  var buffer = context.createBuffer(1, 1, 22050);

  var source = context.createBufferSource();

  source.buffer = buffer;

  source.connect(context.destination);

  source.start(0);


}



// Setup - Main part
function setup() {
  // size(600,400);

  Synthesizer.init();
  dw = windowWidth;
  dh = windowHeight;

  output = createCanvas( windowWidth, windowHeight );
  output.parent();

  unlock();
  for (var k=0; k<poly; k++) {
    tone[k] = [];
    for (var i=0; i<objectnumber; i++) {
      tone[k][i] = new Sound(220,0.5, 0.2);
    };
  };

  enter = createButton("start performance");
  enter.position((dw/2)-100, (dh/2)-20);
  enter.mousePressed(handleStart);

  oscInit();
}

function windowResized() {
  resize();
}

function deviceTurned() {
  resize();
  oldposition = 0;
}

function resize() {
  resizeCanvas(windowWidth, windowHeight);

  dw = windowWidth;
  dh = windowHeight;
}

function mousePressed() {
//   if (mouseX > 0 && mouseX < 100 && mouseY > 0 && mouseY < 100) {
     var fs = fullscreen();
     fullscreen(!fs);

     tone[poly-1][0].play(500, 0.5, 0.5);
    
     return false;
}
 
function handleStart() {
  //ellipse(mouseX, mouseY, 5, 5);
  // prevent default
  
  tone[poly-1][0].play(500, 0.5, 0.5);

  // var fs = fullscreen();
  // fullscreen(!fs);
  enter.hide();
  //enter.remove;

  window.addEventListener('deviceorientation', 
    function (e) { deviceOrientationHandler(e)}, false);
  
  return false;
}

function touchStarted() {
  //ellipse(mouseX, mouseY, 5, 5);
  // prevent default
  var fs = fullscreen();
  fullscreen(!fs);
  //tone[0][0].play(20, 0.1, 0.2);
  return false;
}

//boolean sketchFullScreen() {
//  return true;
//}

function oscInit() {

  var k = 0;

  client = new rhizome.Client();

  client.start(
    function(err) {
      if (err) {
        console.log('client failed starting : ' + err)
            throw err
          };
    // We want to receive all messages
    client.send('/sys/subscribe', ['/'])
  });
  
  /* Receiving messages - leitet die message auf die Funktion "test" */
  client.on('message', function(address, args) {

     if (address == "/test") {

      var i = args[0];
      var a = args[1];
      var b = args[2];

      tone[k][i].play(((i+1)*220)+(a), b/100, b/100);
      test(i, a, b);
      console.log("received message: ", address, i, a, b);
      k=(k+1)%poly;
      
    }
  });

  // client.on('connected', function() {
  //   alert('connected!')
  // });

  // client.on('connection lost', function() {
  //   alert('connection lost!')
  // });

  // client.on('server full', function() {
  //   alert('server is full!')
  // });
}

function test(i, a, b) {
  // println("### Message erhalten ..... /test.");
  console.log(" 3 variablen empfangen: "+i+", "+a+", "+b);  
  
  impuls[i] = a;
  wert[i] = b;
  zaehler[i] = 20;
}

function draw() {
  
  
  background(0);
  fill(255);

  
  rotation = (oldposition - rotfront)/360*2*Math.PI;
  rotate(rotation);

  oldposition = rotfront;

  
  text(rotation, 100, 50);
  text(rotfront, 100, 150);

  
  for (var i=0; i<objectnumber; i++) {
    puls(i, impuls[i], wert[i]);
  
    zaehler[i]--;
    if (zaehler[i] == 0) 
          impuls[i] = 0;
  }
}
       
function puls(number, farbe, position) {
  
//  for (int i=0; i<objectnumber; i++) {
//      zaehler[i]--;
//      if (zaehler[i] == 0) {
//        impuls[i] = 0;
//      
    if (number == 0) {
      
        fill(farbe);
        rect((dw/100)*position, 0,((dw)/100), dh);
    
    };
    
     if (number == 1) {
       
      variation = variation + Math.random(-2, 2);
      if (variation > dh) variation = dh - 2;
      if (variation <= 0) variation = variation + 2;
      
      
        fill(farbe);
        rect((dw/2)-20, (dh/10),((dw)/variation), dh/(1+position));
    
    };
   //line();
}



function deviceOrientationHandler (eventData) {

  // gamma is the left-to-right tilt in degrees, where right is positive
  rotfront  = Math.round(eventData.gamma);

  // beta is the front-to-back tilt in degrees, where front is positive
  rotback = Math.round(eventData.beta);

  // alpha is the compass direction the device is facing in degrees
  rotdir  = Math.round(eventData.alpha);

  console.log(rotfront, rotback, rotdir);
  // var textxy = document.getElementById("doTiltLR").innerHTML = Math.round(tiltLR);
  // var textyz = document.getElementById("doTiltFB").innerHTML = Math.round(tiltFB);
  // var textxz = document.getElementById("doDirection").innerHTML = Math.round(dir);

  // Apply the transform to the image
  // var logo = document.getElementById("imgLogo");
  // logo.style.webkitTransform =
  //   "rotate("+ tiltLR +"deg) rotate3d(1,0,0, "+ (tiltFB*-1)+"deg)";
  // logo.style.MozTransform = "rotate("+ tiltLR +"deg)";
  // logo.style.transform =
  //   "rotate("+ tiltLR +"deg) rotate3d(1,0,0, "+ (tiltFB*-1)+"deg)";


}