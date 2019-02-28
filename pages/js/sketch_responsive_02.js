/**
 * First test of p5js - Script
 * see also: open Form - cube
 */

// Definieren der Variablen

var objectnumber = 5;
var poly = 10;
var dw, dh;
var variation = 40;

var program = 0;
var freq = new Array(objectnumber);
var vol = new Array(objectnumber);
var duration = new Array(objectnumber);
var dur = new Array(objectnumber);
var zaehler = new Array(objectnumber);

var object = new Array(objectnumber);
var tone = new Array(poly);

var client;
var enter, output;
var isUnlocked = false;
var rotfront = 0, rotback= 0, rotdir= 0;
var position = 0, oldposition = 0;
var objectchoose = 0;


// Setup - Main part
function setup() {
  // size(600,400);

  Synthesizer.init();
  dw = windowWidth;
  dh = windowHeight;

  freq.fill(0);
  object.fill(0);
  duration.fill(0);
  dur.fill(0);
  zaehler.fill(0);

  output = createCanvas( windowWidth, windowHeight );
  output.parent();

  testtone = new Sound(440, 0.2, "sinesynth");

  for (var k=0; k<poly; k++) {
    tone[k] = [];
    for (var i=0; i<objectnumber; i++) {
      tone[k][i] = new Sound(220, 0.5, "sinesynth");
    };
  };

  enter = createButton("start performance");
  enter.position((dw/2)-100, (dh/2)-20);
  enter.mousePressed(handleStart);

  oscInit();
}
 
function handleStart() {
  //ellipse(mouseX, mouseY, 5, 5);
  // prevent default
  
  testtone.play(500, 0.5, 0.5);

  // var fs = fullscreen();
  // fullscreen(!fs);
  enter.hide();
  //enter.remove;

  program = 1;

  window.addEventListener('deviceorientation', 
    function (e) { deviceOrientationHandler(e)}, false);

  program = 1;
  
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

      var obj = args[0];
      freq[obj] = args[1];
      vol[obj] = args[2];
      duration[obj] = args[3]*60;

      tone[zaehler[obj]][obj].play((obj+1)*freq[obj], vol[obj], duration[obj]);
      console.log("received message: ", obj, freq[obj], vol[obj], duration[obj]);
      zaehler[obj]=(zaehler[obj]+1)%poly;
      programm = "test";
      
    };

    if (address == "/kick") {

      var obj = args[0];
      freq[obj] = args[1];
      vol[obj] = args[2];
      dur[obj] = args[2];
      duration[obj] = args[3]*60;
      program = "kick";

      if (obj == 0) {
      tone[zaehler[obj]][obj].play(freq[obj]*2, vol[obj], dur[obj]);
      zaehler[obj]=(zaehler[obj]+1)%poly;
      };

      //console.log("received message: ", address, obj, freq[obj], vol[obj], duration[obj]);      
    };


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
  
  //freq[i] = a;
  
}

function draw() {
  
  
  background(0);
  fill(255);

  
  position = (oldposition - rotfront)/360*2*Math.PI;
  rotate(position);

  oldposition = rotfront;

  
  text(position, 100, 50);
  text(rotfront, 100, 150);

  if (program == "kick") {

    for (var i=0; i<objectnumber; i++) {
    
      duration[i]--;
    
        if (duration[i] > 0) {
          kick(i, freq[i], vol[i], duration[i]);
          console.log("kick: ", i, freq[i], vol[i], duration[i])
        };
    }
  }
}
       
function kick(obj, freq, vol, dur) {

  console.log("kick: ", obj, freq, vol, dur);
  
//  for (int i=0; i<objectobj; i++) {
//      vol[i]--;
//      if (vol[i] == 0) {
//        freq[i] = 0;
//      
    if (obj == 0) {
        var color = vol*100+155;
        var width = dw / (freq/10);

        fill(color);
        rect(dw/2-width/2, dh/5, width, dh-(2*dh/5));
        
    
    };
    
     if (obj == 1) {
       
      variation = variation + Math.random(-2, 2);
      if (variation > dh) variation = dh - 2;
      if (variation <= 0) variation = variation + 2;
      
      
        fill(freq);
        rect((dw/2)-20, (dh/10),((dw)/variation), dh/(1+vol));
    
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

     testtone.play(500, 0.5, 0.5);
    
     return false;
}

// function touchStarted() {
//   //ellipse(mouseX, mouseY, 5, 5);
//   // prevent default
//   var fs = fullscreen();
//   fullscreen(!fs);
//   //tone[0][0].play(20, 0.1, 0.2);
//   return false;
// }