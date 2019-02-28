/**
 * First test of p5js - Script
 * see also: open Form - cube
 */

// Definieren der Variablen

var objectnumber = 5;
var objectcopies = 8;
var poly = 10;
var dw, dh;
var variation = 40;

var program = "";
var freq = new Array(objectnumber);
var vol = new Array(objectnumber);
var duration = new Array(objectnumber);
var dur = new Array(objectnumber);
var zaehler = new Array(objectnumber);
var variation = new Array(objectnumber);
var tone = new Array(poly);

var client;
var enter, output;
var isUnlocked = false;
var rotfront = 0, rotback= 0, rotdir= 0, rotNow=0;
var horizont = false, rotactiv = false;
var position = 0, oldposition = 0;
var objectchoose = 0;
var object = {};
var backgr;
var audioplay;


// Setup - Main part
function setup() {
  // size(600,400);

  Synthesizer.init();
  dw = windowWidth;
  dh = windowHeight;

  freq.fill(0);
  duration.fill(0);
  dur.fill(0);
  zaehler.fill(0);

  backgr = select('#wrap');
  // audioplay = createAudio('http://localhost:9500/RV');

  for (var i=0; i<objectnumber; i++) {
    variation[i] = new Array(objectcopies);
    variation[i].fill(0);
  };

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
  
  // testtone.play(500, 0.5, 0.5);

  // var fs = fullscreen();
  // fullscreen(!fs);
  enter.hide();

  isUnlocked = true;
  //enter.remove;

  window.addEventListener('deviceorientation', 
    function (e) { deviceOrientationHandler(e)}, false);
  
  horizont = false;
  // audioplay.play();
  
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
      object["test"] = args[0]; 
      freq[obj] = args[1];
      vol[obj] = args[2];
      duration[obj] = args[3]*60;

      tone[zaehler[obj]][obj].play((obj+1)*freq[obj], vol[obj], duration[obj]);
      console.log("received message: ", obj, freq[obj], vol[obj], duration[obj]);
      zaehler[obj]=(zaehler[obj]+1)%poly;
      program = name;
      
    };

    if (address == "/kick") {

      var name = "kick";
      var obj = args[0];
      object["kick"] = args[0];
      freq[obj] = args[1];
      vol[obj] = args[2];
      dur[obj] = args[3];
      duration[obj] = args[3]*60;
      program = name;

      if (obj == 1) {
      tone[zaehler[obj]][obj].play(freq[obj]*2, vol[obj], dur[obj]);
      zaehler[obj]=(zaehler[obj]+1)%poly;
      };

      console.log("received message: ", address, obj, freq[obj], vol[obj], duration[obj]);      
    };

    if (address == "/klank") {

      var name = "klank";
      var obj = args[0];
      object["klank"] = args[0];
      freq[obj] = args[1];
      vol[obj] = args[2];
      dur[obj] = args[3];
      duration[obj] = args[3]*60;
      program = name;
      

      // if (obj == 0) {
      // tone[zaehler[obj]][obj].play(freq[obj]*2, vol[obj], dur[obj]);
      // zaehler[obj]=(zaehler[obj]+1)%poly;
      // };

      console.log("received message: ", address, obj, freq[obj], vol[obj], duration[obj]);      
    };

    if (address == "/grain") {

      var name = "grain";
      var obj = args[0];
      object["grain"] = args[0];
      freq[obj] = args[1];
      vol[obj] = args[2];
      dur[obj] = args[3];
      duration[obj] = args[3]*60;
      program = name;
      

      // if (obj == 0) {
      // tone[zaehler[obj]][obj].play(freq[obj]*2, vol[obj], dur[obj]);
      // zaehler[obj]=(zaehler[obj]+1)%poly;
      // };

      console.log("received message: ", address, obj, freq[obj], vol[obj], duration[obj]);      
    };

    if (address == "/dodec") {

      var name = "dodec";
      var obj = args[0];
      object[name] = args[0];
      freq[obj] = args[2];
      vol[obj] = args[1];
      dur[obj] = args[3];
      duration[obj] = args[3]*60;
      program = name;
      
      // if (obj == 0) {
      // tone[zaehler[obj]][obj].play(freq[obj]*2, vol[obj], dur[obj]);
      // zaehler[obj]=(zaehler[obj]+1)%poly;
      // };

      console.log("received message: ", address, obj, freq[obj], vol[obj], duration[obj]);      
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


  if (rotactiv) {
    if (!horizont) rotNow = rotfront; else rotNow = rotback;
    position = (oldposition - rotNow)/360*2*Math.PI;
    
    rotate(position);

    oldposition = rotNow;
  };

  
  // text(position, 100, 50);
  // text(rotfront, 100, 150);

  if (program == "kick" && isUnlocked) {

    for (var i=0; i<objectnumber; i++) {
    
      duration[i]--;
    
        if (duration[i] > 0) {
          kick(i, freq[i], vol[i], dur[i]);
          //console.log("kick: ", i, freq[i], vol[i], duration[i])
        };
    }
  };

  if (program == "klank" && isUnlocked) {
    var i = object[program];
    //console.log("Dodec now");
    klank(i, freq[i], vol[i], duration[i])
  }

  if (program == "grain" && isUnlocked) {
    var i = object[program];
    //console.log("Dodec now");
    klank(i, freq[i], vol[i], duration[i])
  }

  if (program == "dodec" && isUnlocked) {
    var i = object[program];
    console.log("Dodec now");
    dodec(i, freq[i], vol[i], dur[i])
  };

}
       
function kick(obj, freq, vol, dur) {

  //console.log("kick: ", obj, freq, vol, dur);
  
//  for (int i=0; i<objectobj; i++) {
//      vol[i]--;
//      if (vol[i] == 0) {
//        freq[i] = 0;
//      
    if (obj == 0) {
        var color = vol*200+55;
        var width = dw / (freq/10);
        //var bgcolor = color(col);
        rotactiv=false; position = 0; rotNow = 0;

        backgr.style("background-color", "rgb(vol,vol,vol)");
        fill(color);
        rect(0, 0, dw, dh);
        
    
    };
    
     if (obj == 1) {
       
        var color = vol*100+155;
        var width = dw/freq/30;
        var height = dh/freq/30*vol;
        rotactiv=true;

        fill(color);
        rect(dw/2-width/2, dh/2-height/2, width, height);
    
    };

    if (obj == 2) {
       
        variation[obj][0] = variation[obj][0] + random(-2, 2);
        if (variation[obj][0] > dh) variation[obj][0] = dh - 2;
        if (variation[obj][0] <= 0) variation[obj][0] = variation[obj][0] + 2;
        
        
          fill(freq);
          rect((dw/2)-20, (dh/10),((dw)/variation[obj][0]), dh/(1+vol));
          rotactiv=false; position = 0; rotNow = 0;

    };

   //line();
}

function klank(obj, freq, vol, dur) {

  console.log("klank: ", obj, freq, vol, dur);
  
//  for (int i=0; i<objectobj; i++) {
//      vol[i]--;
//      if (vol[i] == 0) {
//        freq[i] = 0;
//      
    if (obj == 0) {
        var color = vol*255;
        var width = dw / (freq/10);

        fill(color);
        rect(0, 0, dw, dh);
        
    };

};

function grain(obj, freq, vol, dur) {

  console.log("grain: ", obj, freq, vol, dur);
  
//  for (int i=0; i<objectobj; i++) {
//      vol[i]--;
//      if (vol[i] == 0) {
//        freq[i] = 0;
//      
    if (obj == 0) {
        var color = vol*255;
        var width = dw / (freq/10);

        fill(color);
        rect(0, 0, dw, dh);
        
    };

};

function dodec(obj, freq, vol, dur) {

  console.log("dodec: ", obj, freq, vol, dur);

  var farbe = (vol+1)/2  * 300;
  var position = freq/10;

    if (position == 0) {} else {
          
          for (var i = 0; i < objectcopies; i++) {
               
               variation[obj][i] = variation[obj][i] + random(-2, 2);
               
               if (variation[obj][i] > (dh/4)) variation[obj][i] = variation[obj][i] - 2;
               if (variation[obj][i] < -(dh/4)) variation[obj][i] = variation[obj][i] + 2;
          };
          
          if (obj == 0) {
          
             for (var i = 0; i < objectcopies; i++) {
          
               noStroke();
               fill(farbe);
               rect(dh/(log(variation[obj][i])), (dh/3.149+(variation[obj][i]*2)),((dh/5)+variation[obj][i]), dh/(1+position));
             };
          };
            
          if (obj == 1) {
          
              fill(farbe);
              noStroke();
              rect((dh/100)*position, 0,(dh)/(50+variation[obj][0]), dh);
        
          };
       
          
          if (obj == 2) {
          
             for (var i = 0; i < objectcopies; i++) {
          
               //fill(farbe);
               noStroke();
               fill(farbe);
               triangle(dh/(log(variation[obj][i])), (dh/2), 80, dh/(1+position), 50 + variation[obj][i], 50 + variation[obj][i]);
             };
            };
          
            if (obj == 3) {
          
             for (var i = 0; i < objectcopies; i++) {
          
               noStroke();
               fill(farbe);
               rect((dh/2)+variation[obj][i], (dh/2),(20+variation[obj][i]), dh/(1+position));
             };
            };
          
            if (obj == 4) {
          
               for (var i = 0; i < (dh); i++) { 
                 
                 for (var k = 0; k < objectcopies; k++) {
                 
                   siney[i] = (50*variation[obj][k]) * sin(i*2*PI*(position)/(dh));
                
                   stroke(255-farbe);
                   point(i, siney[i]+(dh/2+variation[obj][k]));
                 }
               }
            };
     
        };
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
  horizont = !horizont;
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