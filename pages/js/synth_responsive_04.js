// ------------------------------------------------------------------------------
//   synth.js creates a synthesizer with oscillators with webaudio and html5 form
//   in a div with id = "synth" or as childobject of "body"
// ------------------------------------------------------------------------------

// initialize Audio -- must be initialized at the beginning

var Synthesizer = {
  oscMessage : true
};

Synthesizer.init = function () {

  console.log('initialize audio ...');
  var that = this;

  // Fix up prefixing 
  window.AudioContext = window.AudioContext || window.webkitAudioContext;
  
  // Create AudioContext (Initialize webaudio Context)
  if (AudioContext) {
    context = new AudioContext();
    
  } else {
    alert('No audiocontext available');
  };

  // Check if createGain is available
  if (!context.createGain) context.createGain = context.createGainNode;

  Synthesizer.master.init();
  // Synthesizer.view.init();
  // Synthesizer.ctl.init();

};

Synthesizer.master = {

  init : function() {

  // initialize MastergainNode
  this.gainNode = context.createGain();
  this.gainNode.connect(context.destination);

  // set Master-Gain
  this.volume = 0.5;
  this.gainNode.gain = this.volume;
  
  }
}

Synthesizer.set = {

  Oscillator : [
  ['select', 'change', 'Type', ['sine', 'sawtooth', 'triangle', 'square'], 'triangle', 'left', 'Choose type: '],
  ['button', ['mousedown'], 'Hold', 'hold', '----', ''],
  ['slider', 'change', 'Volume', 0, 1000, 0.2, 'volume: '], 
  ['slider', 'change', 'Attack', 0, 1000, 0.01, 'attack: '],
  ['slider', 'change', 'Decay', 0, 1000, 0.1, 'decay: '],
  ['slider', 'change', 'Sustain', 0, 1000, 1, 'sustain-level: '],
  ['slider', 'change', 'Release', 0, 1000, 0.2, 'release: ']
  ], 
  Master : [
  ['slider', 'change', 'masterVolume', 0, 1000, 0.5, 'volume: ']
  // ['button', 'mousedown', 'masterCompressor', 'off', '', 'compressor']
  ]


}

Synthesizer.ctl = {}; 

Synthesizer.ctl.init = function() {

  // init Master - Controls

  for (section in Synthesizer.set) {
    if (section === "Master") {

      console.log('Init ',  section, '...');
      var field = section;
      var elements = Synthesizer.set[section];
      var settings;

      for (var i=0; i < elements.length; i++) {

        var settings = elements[i].slice(0, elements[i].length);
        var type = settings[0];
        var action = settings[1];
        var id = settings[2];
        var defaultValue = settings[5];
       
        settings = settings.slice(2, settings.length);
        // set Eventlistener 
        
        Synthesizer.view[id].addEventListener(
          action,
          function(e) {
            var element = e.target;
            var value;

            if (Synthesizer.view[element.id].type == "range") {  
              value = parseInt(element.value) / parseInt(element.max);
            } else value = element.value;

            console.log('\nEventlistener: ', Synthesizer.view[element.id].type, 
              '\nto: ', element.id, "Value", value);
            Synthesizer[element.id](value) 
          },
            false);

        Synthesizer[id].set(defaultValue);
        console.log("Default Value", id, defaultValue);

      } // end of loop through elements
    } // end section Master
  } // End loop through sections
}

Synthesizer.masterVolume = function(value) {

  ctlValue = value * 1;
  viewValue = value * 1000;

  if (Synthesizer.view.masterVolume.value != viewValue) 
          Synthesizer.view.masterVolume.value = viewValue;

  if (Synthesizer.master.volume != ctlValue) 
    Synthesizer.masterVolume.set(ctlValue);
  
  // console.log('Volume:', Synthesizer.master.volume);
}

Synthesizer.masterVolume.set = function(ctlValue) {
  
  Synthesizer.master.volume = ctlValue;
  Synthesizer.master.gainNode.gain.value = ctlValue;
  Synthesizer.masterVolume(ctlValue);

  console.log(Synthesizer.master.gainNode.gain.value);
}

Synthesizer.masterCompressor = function(value) {

  if (value = "on") {
    this.compressorOn = false;
    Synthesizer.view.masterCompressor.value = "off";
    console.log('mastercompressor Off');
  } else {
    this.compressorOn = true;
    Synthesizer.view.masterCompressor.value = "on";
    console.log('mastercompressor On');
  }
}

Synthesizer.masterCompressor.set = function(value) {

  if (value = "off") {
    Synthesizer.masterCompressor("on")
  } else {
    Synthesizer.masterCompressor("off")
  }
}


var Sound = function (freq, gain, type, envelope, time, envelope2) {

  // set frequency and volume as defined or default
  if (freq) this.freq = freq; else this.freq = 220;
  if (gain) this.gain = gain; else this.gain = 0.2;
  if (time) this.sustainTime = time; else this.sustainTime = 0;

  // set default Soundtype
  if (type) this.type = type; else this.type = 'sinesynth';

  if (envelope) this.attack = envelope[0]; else this.attack = 0.001;
  if (envelope) this.decay = envelope[1]; else this.decay = 0.1;
  if (envelope) this.sustainLevel = envelope[2]; this.sustainLevel = 0.4;
  if (envelope) this.release = envelope[3]; this.release = 0.4;
  if (envelope) this.sustainTime = envelope[4]; this.sustainTime = 0.1;
  if (envelope) this.volume = envelope[5]; this.volume = 0.5;

  // create Envelope
  this.envelope = context.createGain();
  this.envelope.gain.value = 0;
  this.envelope.connect(Synthesizer.master.gainNode);
  this.adsr = [this.attack, this.decay, this.sustainLevel, this.release, this.volume, this.sustainTime];

  // optional if additional Envelope is needed:
  if (envelope2) this.adsrFilter = envelope2; else
  this.adsrFilter = [this.attack, this.decay, this.sustainLevel, this.release, this.volume, this.sustainTime];
  
  this.hold = false;
  this.active = false;

};


Sound.prototype.adsr = function(a, d, s, r, v, time) {

    // set adsr as defined or default
    if (a) this.attack = a; 
    if (d) this.decay = d; 
    if (s) this.sustainLevel = s; 
    if (r) this.release = r; 
    if (v) this.volume = v;

    // calculate SustainTime and full time
    if (time) {
      this.sustainTime = time;

      if (time - this.attack > this.attack) this.sustainTime = time - this.attack;
      if (time - this.attack + this.decay > this.attack + this.decay) 
        {this.sustainTime = time - this.attack - this.decay};
    };
    
    this.loop = false;

  };

Sound.prototype.sinesynth = function () {

  var that = this;

   // create oscillator and gainNode
  this.wave = context.createOscillator();
  this.gainNode = context.createGain();

  // connect to GainNode and Envelope
  this.wave.connect(this.gainNode);
  this.gainNode.connect(this.envelope);

  // values of oscillator and gainNode
  this.gainNode.gain.value = this.gain;
  this.wave.frequency.value = this.freq;
  this.wave.type = "sine";

  this.sinesynth.start = function (time) {

    that.wave.start(time);
    that.active = true;
    that.gate(that.adsr);
  };

  this.sinesynth.stop = function (time) {
    that.wave.stop(time);
    that.active = false;
  }
}

Sound.prototype.play = function (freq, volume, time) {

  if (freq) this.freq = freq;
  if (volume) this.volume = volume;
  // Calculate Time for envelope
  if (time) {
    this.sustainTime = time;

    if (time - this.attack > this.attack) this.sustainTime = time - this.attack;
    if (time - this.attack + this.decay > this.attack + this.decay) 
      this.sustainTime = time - this.attack - this.decay;
    
  };

  this[this.type]();
  this[this.type].start(0);
  //if (!Adsr.loop) this.wave.stop(context.currentTime + this.time)

};


Sound.prototype.gate = function (envelope) {

    var time = context.currentTime + 0.001;

    var attack = envelope[0];
    var decay = envelope[1];
    var sustainLevel = envelope[2];
    var release = envelope[3];
    var volume = envelope[4];
    var sustainTime = envelope[5];

    console.log(envelope, time);

    // set on 0 Level
    //this.envelope.gain.linearRampToValueAtTime(0, time);
    // set on attack Level (highest Volume) 
    this.envelope.gain.linearRampToValueAtTime(volume, time + attack);
    // decay to sustain 
    this.envelope.gain.linearRampToValueAtTime(volume*sustainLevel, time + attack+decay);
    
    if (sustainTime) {// sustain - 
      this.envelope.gain.linearRampToValueAtTime(volume*sustainLevel, time + attack+decay+sustainTime);
      // this.decay - 
      this.envelope.gain.linearRampToValueAtTime(0, time + attack+decay+sustainTime+release);
      this[this.type].stop(time + attack+decay+sustainTime+release);
    }

}

Sound.prototype.stop = function () {

  var time = context.currentTime;
  var volume = this.volume;
  // this stop
  
  if (!this.hold && this.active) {

    this.envelope.gain.cancelScheduledValues(0);
    this.envelope.gain.linearRampToValueAtTime(0, time+this.release)
    this[type].stop(time+this.release);
  }
  // console.log("tone stopped");

}

Sound.prototype.controller = function() {

  var that = this;
  for (section in Synthesizer.set) {

    if (section === "Oscillator") {

      console.log('Init ',  section, '...');
      var field = section;
      var elements = Synthesizer.set[section];
      var settings;

      for (var i=0; i < elements.length; i++) {

        var settings = elements[i].slice(0, elements[i].length);
        var type = settings[0];
        var action = settings[1];
        var id = settings[2];
        var ctl = "ctl"+id;
        var set = "set"+id;
        var defaultValue = settings[5];
        if (type != "slider") defaultValue = settings[4];

       
        settings = settings.slice(2, settings.length);
        //console.log('Controller -', type, '\nenabled id: ', id, 'Element Nr.: ', i,
        // '\naction: ', action, '\nsettings: ', settings);

          // Add Eventlistener to form 
          Synthesizer.view[id].addEventListener(
            action,
            function(e) { 
              console.log("action");
              var element = e.target;
              var ectl = "ctl"+ element.id;
              var id = element.id;
              var value = element.value;

              if (Synthesizer.view[element.id].type == "range") {  
              value = parseInt(element.value) / parseInt(element.max);
                } else value = element.value;

            console.log('\nEventlistener: ', Synthesizer.view[id].type, 
              '\nto: ', id, "Value", value);
            that[ectl](value) 
          }, false);
        
        console.log("id controller: ", set);

        that[set](defaultValue);

      }; // end of loop through elements
    }; // end section Oscillator
  } // End loop through sections
};


Sound.prototype.ctlAttack = function (value) { 
  
  var ctlValue = (value + 0.0005) * 1.995;
  var viewValue = value * 1000;

  if (Synthesizer.view.Attack.value != viewValue) 
          Synthesizer.view.Attack.value = viewValue;

  if (this.attack != ctlValue) 
    this.attack = ctlValue;
  console.log("attack =", ctlValue, viewValue)

 }

Sound.prototype.setAttack = function(value) {
  
  var ctlValue = (value/1.995) - 0.0005;
  this.ctlAttack(ctlValue);

  console.log("Attack: ", value);
}

Sound.prototype.ctlDecay = function (value) { 

  var ctlValue = (value + 0.0005) * 1.995;
  var viewValue = value * 1000;

  if (Synthesizer.view.Decay.value != viewValue) 
          Synthesizer.view.Decay.value = viewValue;

  if (this.decay != ctlValue) 
        this.decay = ctlValue;
}

Sound.prototype.setDecay = function (value) { 

  var ctlValue = (value/1.995) - 0.0005;
  this.ctlDecay(ctlValue);

  console.log("Decay: ", value);
}

Sound.prototype.ctlSustain = function (value) { 
  
  var ctlValue = value * 2;
  var viewValue = value * 1000;

  if (Synthesizer.view.Sustain.value != viewValue) 
          Synthesizer.view.Sustain.value = viewValue;

  if (this.sustainLevel != ctlValue) 
      this.sustainLevel = ctlValue
}

Sound.prototype.setSustain = function (value) { 
  
  var ctlValue = value / 2;
  this.ctlSustain(ctlValue);
}

Sound.prototype.ctlRelease = function (value) {
  
  var ctlValue = (value + 0.0005) * 1.995;
  var viewValue = value * 1000;

  if (Synthesizer.view.Release.value != viewValue) 
      Synthesizer.view.Release.value = viewValue;

  if (this.release != ctlValue) 
      this.release = value;
}

Sound.prototype.setRelease = function (value) {
  
  var ctlValue = (value/1.995) - 0.0005;
  this.ctlRelease(ctlValue)
  
}

Sound.prototype.ctlVolume = function (value) { 
  
  var ctlValue = value;
  var viewValue = value * 1000;
  
  if (Synthesizer.view.Volume.value != viewValue) 
      Synthesizer.view.Volume.value = viewValue;

  if (this.volume != ctlValue) this.volume = value;
}

Sound.prototype.setVolume = function (value) { 

  this.ctlVolume(value);
}

Sound.prototype.ctlHold = function (value) { 

  if (!this.hold) {
    value = "----";
    this.hold = true;
  }
  else {
    value = "hold";
    this.hold = false;
    if (this.active) this.stop();
  };

  Synthesizer.view.Hold.value = value;
  console.log('Hold: ', this.hold);
}

Sound.prototype.setHold = function (value) { 
  this.ctlHold(value);
}

Sound.prototype.ctlTrigger = function (value) { 

  if (!this.triggered && !this.active) {
    this.triggered = true;
    this.play();
    Synthesizer.view.Trigger.value = "------"
  }
  else {
    this.stop();
    this.triggered = false;
    Synthesizer.view.Trigger.value = "trigger"
  };

  console.log('Trigger: ', this.triggered);
}

Sound.prototype.setTrigger = function (value) { 

  this.ctlTrigger(value);

}

Sound.prototype.ctlType = function (value) {

  this.type = value;

  if (this.wave) this.wave.type = this.type;
}

Sound.prototype.setType = function (value) {

  this.type = value;

  if (this.wave) this.wave.type = this.type;
}


Sound.prototype.ctlFrequency = function (value) { 

   this.freq = value;

   if (this.active) {
    this.wave.frequency.cancelScheduledValues(0);
    this.wave.frequency.value = this.freq;
  };

}

Sound.prototype.setFrequency = function (value) { 

   this.freq = value;

   if (this.active) {
    this.wave.frequency.cancelScheduledValues(0);
    this.wave.frequency.value = this.freq;
  };

}

var Midi =  function () {

  this.midiAccess = null;  // the MIDIAccess object.
  this.portamento = 0.05;  // this.portamento/glide speed
  
  this.activeNotes = new Array(); // the stack of actively-pressed keys
  this.isSet = false;
  this.selected = false;
  this.device = {};
  this.inputs = null;

};



Midi.prototype.init = function () { 

  if (navigator.requestMIDIAccess)
  {
        navigator.requestMIDIAccess().then( this.success, this.reject );
        console.log('Midi activated ..');
      } 
    else console.log('No Midi available');

};

Midi.prototype.success = function (access) {

  this.midiAccess = access;
  this.selected = document.getElementById("midiInputSelect");
  this.selectedInput = this.selected.value;
  this.inputs = this.midiAccess.inputs.values();

  var that = this;

  if(this.midiAccess.inputs.size > 0) {

    this.device = Midi.getInputs(this.selected, this.inputs);
  };
  
  console.log(this.inputs);
  //this.input = inputs[port];

  if (this.selectedInput == "none" || !this.selectedInput)
    console.log("No MIDI input selected.");
 
  else {

    console.log("Midiinput: ", this.selectedInput)
    //this.input = this.midiAccess.inputs.key[this.selectedInput];
    this.device[this.selectedInput].onmidimessage = function (event) {Midi.message(event)};
  }

  
};

Midi.prototype.getInputs = function (element, inmidi) {

    var inputs = inmidi;
    var selected = element;

    selected.options.length = 0;

    var opt = document.createElement("option");
    opt.text = "none";
    selected.add(opt);
      
    
    // iterate through the devices
    for (input = inputs.next(); input && !input.done; input = inputs.next()) {
          
      var opt = document.createElement("option");

      opt.text = input.value.name;
      selected.add(opt);

      this.isSet = true;
      console.log('Midi-devices dedected:', input.value.name)

      this.device[input.value.name] = input.value;

    };

    return this.device;

};

Midi.prototype.inputRefresh = function(e) {

  this.init();
  console.log('list refreshed');
    
};

Midi.prototype.inputSelect = function(e) {

  var element = e.target;

  this.selectedInput = element.value;
  //this.input = this.midiAccess.inputs.key[this.selectedInput];

  console.log("Midi selected:", this.selectedInput);

  for (var name in this.device) {
    if (name === this.selectedInput)
      this.device[name].onmidimessage = function (event) {Midi.message(event)}
        else
          this.device[name].onmidimessage = null;
      };
    
};

Midi.prototype.message = function(event) {
  // Mask off the lower nibble (MIDI channel, which we don't care about)
  //console.log(event);
  switch (event.data[0] & 0xf0) {
    case 0x90:
      if (event.data[2]!=0) {  // if velocity != 0, this is a note-on message
        Midi.noteOn(event.data[1]);
        return;
      }
      // if velocity == 0, fall thru: it's a note-off.  MIDI's weird, y'all.
    case 0x80:
      Midi.noteOff(event.data[1]);
      return;
  }
};

Midi.prototype.midiToFreq = function ( note ) {
  return 440 * Math.pow(2,(note-69)/12);
};

Midi.prototype.noteOn = function (noteNumber) {


  this.activeNotes.push( noteNumber );

  console.log('Midi-massage note on', noteNumber)

};

Midi.prototype.noteOff = function(noteNumber) {
  var position = this.activeNotes.indexOf(noteNumber);

  console.log('Midi-massage note off', noteNumber)
  if (position!=-1) {
    this.activeNotes.splice(position,1);
  }
};
