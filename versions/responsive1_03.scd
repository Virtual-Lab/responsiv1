(

~channels = 2;
~channelsOut = Array.fill(~channels, { |i| i});
~folder = thisProcess.nowExecutingPath.dirname +/+ "samples/";

~channelsOut.postln;
o = Server.local.options;
o.memSize = 2.pow(20);
o.numAudioBusChannels = 256;
o.sampleRate = 48000;
o.maxNodes = 1024*20;

	//o.device = "US-144";
	//o.device = "JackRouter";
	//o.device = "Fireface 800 (1EA)";
	//o.device = "MOTU Traveller";
	//o.device = "Fireface UFX (23511554)";


thisProcess.openUDPPort(9002);
~oscsend = NetAddr.new("localhost", 9000);
//~oscsend.sendMsg("/test", 255.rand, 155.rand);

//s.reboot;
s.waitForBoot  {
	SynthDef(\kick,
		{ arg outBus = 0, freq = 50, mod_freq = 5, mod_index = 5, sustain = 0.4, gate = 1.0, amp = 0.8, beater_noise_level = 0.025;

			var pitch_contour, drum_osc, drum_lpf, drum_env;
			var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
			var output, trigger1, trigger2;

			pitch_contour = Line.kr(freq*2, freq, 0.02);

			drum_osc = PMOsc.ar(	pitch_contour,
				mod_freq,
				mod_index/1.3,
				mul: 1,
				add: 0);

			drum_lpf = LPF.ar(in: drum_osc, freq: 1000, mul: 1, add: 0);
			drum_env = drum_lpf * EnvGen.ar(Env.perc(0.005, sustain), gate, doneAction: 1);
			beater_source = WhiteNoise.ar(beater_noise_level);
			beater_hpf = HPF.ar(in: beater_source, freq: 500, mul: 1, add: 0);
			lpf_cutoff_contour = Line.kr(6000, 500, 0.03);
			beater_lpf = LPF.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0);
			beater_env = beater_lpf * EnvGen.ar(Env.perc(), gate, doneAction: 3);
			output = Mix.new([drum_env, beater_env]) * 2 * amp;
			trigger1 = Impulse.kr(0, 0, amp);
			trigger2 = Impulse.kr(10, 0, amp);

			SendReply.kr(trigger1, '/dyn', [freq, amp, sustain], 0);
			//SendReply.kr(trigger2, '/dyn', [freq, amp, sustain], 1);
			Out.ar(outBus, Array.fill(~channels, {output}))
		}
	).add;

	// Synth 1 - Definition - Sinus Oscillator – Frequenz und Ampl. Contr.
	SynthDef(\grain1, {
		arg outBus = 0, volume = 0, freq = 200, ctrin1 = 0, ctrin2 = 1, anzahl = 1;
		var ctr1 = In.kr(ctrin1,1)+1, ctr2 = In.kr(ctrin2,1)+1;

		var output = SinOsc.ar(ctr1*freq, 0, ctr2*volume);

		Out.ar(outBus, output);
		SendReply.kr(Impulse.kr(10), '/dodec',
			[ctr1*freq, output], 4);

	}).add;

	// Synth 2 - Definition - Additiver Synth mit zufälligen Obertönen – Frequenz und Ampl. Contr.
	SynthDef(\klank1, {
		arg outBus = 0, volume = 0.2, freq = 200, randmin = 0.9, randmax = 1.1, ctrin1 = 2, ctrin2 = 3,
		ts = 1, atactime = 0.01, rel= 0.8, reltime = 0.5,
		sus = 0.8, sustain = 2, dectime = 0.5, curve = -4;

		var n = 10, output, ctr1 = In.kr(ctrin1,1)+1, ctr2 = In.kr(ctrin2,1)+1, random;

		var env = EnvGen.kr(Env([0, 1, rel, sus, 0],
			[atactime, reltime, sustain, dectime], curve),
		timeScale: ts,
		doneAction: 2);

		output = Mix.fill(n, {|i|
			random = (freq  * Rand(randmin,(randmax * (i+1))));
			SinOsc.ar(ctr1 * random, 0, 1/n)})
		* volume * ctr2 * env;

		Out.ar(outBus, Array.fill(~channels, output));
		SendReply.kr(Impulse.kr(5), '/klank',
			[ctr1*freq, output, sustain], 0);


	}).add;

	SynthDef(\klank2,{
		arg outBus = 0, ress = 0, amp = 1, freq;
		var klank, env, output, oscil;

		oscil = {Rand(70,21000)}!7*freq/100;
		klank = Klank.ar(`[oscil, {Rand(0.128,0.700)}!7],BrownNoise.ar(0.7));
		klank = klank;
		env = EnvGen.kr(Env.perc(0.07, ress), doneAction:2);
		output = klank*env.dup*0.3*amp;

		Out.ar(outBus, output);
		SendReply.kr(Impulse.kr(0), '/klank',
			[freq, output, ress], 0);
	}).add;

	// Effekt 1 - Reverb Stereo
	SynthDef("reverb", { |gate = 1.0|
		var in, env, delayTime = 0.04;
		in = In.ar(0, ~channels);
		5.do({ in = AllpassN.ar(in, delayTime, [delayTime.rand, delayTime.rand], 2); });
		//env =  EnvGen.kr(Env.perc(0.01, delayTime), gate, doneAction: 2);
		ReplaceOut.ar(0, in);
	}).add;

	// Effekt 1 - Reverb1 Stereo
	SynthDef("reverb1", {
		arg outBus = 0, inBus = 0, mix = 0.5, room = 0.5, damp = 0.5, volume = 1;

		var input = In.ar(inBus, ~channels);
		var output = FreeVerb.ar(input, mix, room, damp, volume);
		ReplaceOut.ar(outBus, output);
	}).add;

	// Effekt 2 - Reverb2
	SynthDef("reverb2", {
		arg outBus = 0, inBus = 0, buffer = 0.2, fadeout = 0.5,
		delaymin = 0.001, delaymax = 0.1, decaytime = 0.2, volume = 1, ctrinvolume = 300;

		var ctrvolume = In.kr(ctrinvolume, 1)+1;
		var input = In.ar(inBus, 2);
		var delaytime = Rand(delaymin, delaymax);

		20.do({ input = AllpassC.ar(input, buffer, delaytime, decaytime, volume)});
		Out.ar(outBus, input*ctrvolume);
	}).add;


	// Effekt 3 - Delay
	SynthDef("delay1", {
		arg outBus = 0, inBus = 0, delayfreq = 0.25, delaytime = 1, repeat = 10, ctrinvolume = 300;
		var input = In.ar(inBus, 1);
		var ctrvolume = In.kr(ctrinvolume, 1)+1;

		10.do({|index|

			var i = index+1;

			input = DelayC.ar(input, delayfreq, delayfreq, 1/i);
			Out.ar(outBus, input*ctrvolume);
		});

	}).add;

};


~tasks = 3;
//var task1, amp, freq, mod_freq, sustain, dur;
~task = Array.newClear(~tasks);
~variation = Array.newClear(~tasks*4);

// register to receive this message
~oscOut = OSCFunc({
	arg msg, time, cmdname;
	var object, trig1, trig2, trig3;

	//[time, msg].postln; //- to see the full message

	cmdname = msg[0].value;
	object =  msg[2].value;
	trig1 = msg[3].value;
	trig2 = msg[4].value;
	trig3 = msg[5].value;
	~oscsend.sendMsg(cmdname, object,  trig1, trig2, trig3);

	postf("Message: % % %, %, %\n", cmdname, object, trig1, trig2, trig3);
},'/klank', s.addr);

// activate reverb
~reverb = Synth(\reverb1);


//~synth = Array.newClear(~channels);

~task[0] = Task({

	~reverb.set(\room, 0.2, \mix, 0.5);

	//~variation[0] = {
		~freq = 50;
		~mod_freq = 2;
		~amp = 0.5;
		~dur = Pseq([0.5, 0.5, 1], inf).asStream;
		~sustain = Pseq([0.1, 0.1, 0.4], inf).asStream;
		~outBus = 20;
		~object = 0;
	//};

	~variation[1] = {
		~freq = 50;
		~mod_freq = 2;
		~amp = Prand([0.2, 0.3, 0.6, 0.2, 0.3, 0.8, 0.3], inf).asStream;
		~dur = Pseq([0.5, 0.5, 1], inf).asStream;
		~sustain = Pseq([0.1, 0.1, 0.2], inf).asStream;
		~outBus =  20;
		~object = 1;
	};

	~variation[2] = {
		~freq = Prand([80.rrand(150), 70.rrand(90), 50, 110, 40.rrand(100)], inf).asStream;
		~amp = Prand([0.15, 0.425, 0.625, 0.6, 0.8, 0.1, 0.3], inf).asStream;
		~mod_freq = Prand([3.33, 1.34, 4.26, 5.51], inf).asStream;
		~sustain = Pseq([0.15, 0.425, 0.625, 0.6], inf).asStream;
		~dur = Pseq([0.15, 0.425, 0.625, 0.6, 0.125], inf).asStream;
		~outBus =  20;
		~object = 1;
	};

	~variation[3] = {
		~freq = Prand([80.rrand(150), 70.rrand(90), 50, 110, 40.rrand(100)], inf).asStream;
		~amp = Prand([0.15, 0.425, 0.625, 0.6, 0.8, 0.1, 0.3], inf).asStream;
		~mod_freq = Prand([3.33, 1.34, 4.26, 5.51], inf).asStream;
		~sustain = Pseq([0.15, 0.425, 0.625, 0.6], inf).asStream;
		~dur = Pseq([0.15, 0.425, 0.625, 0.6, 0.125], inf).asStream;
		~outBus =  20;
		~object = 1;
	};

	loop({
		x.release(2);
		x = Synth(\kick, [
			\gate: 1,
			\amp: ~amp.value,
			\freq: ~freq.value,
			\mod_freq: ~mod_freq.value,
			\sustain: ~dur.value;
			//\outBus: 0;
		]);
		/*~outBus.value.postln;*/
		~oscsend.sendMsg('/kick', ~object.value,  ~freq.value, ~amp.value, ~sustain.value);
		~dur.value.wait;
	});

});

~task[1] = Task({

	~reverb.set(\room, 0.8, \mix, 0.6);

	//~variation[4] = {
		~res1 = 0.2;
		~freq1= {80.rrand(800)}.asStream;
		~amp1 = Prand([0.2, 0.3, 0.6, 0.2, 0.3, 0.8, 0.3], inf).asStream;
		~dur1 = Pseq([0.15, 0.425, 0.625, 0.6, 0.125], inf).asStream;
		~object1 = 2;

	//};

	~variation[5] = {
		~res1 = Pseq([0.2, 1.5, 3], inf).asStream;
		~freq1 = {80.rrand(800)}.asStream;
		~amp1 = Prand([0.2, 0.3, 0.6, 0.2, 0.3, 0.8, 0.3], inf).asStream;
		~dur1 = Pseq([0.05, 0.2, 0.0625, 0.06, 0.125], inf).asStream;
		~object1 = 2;
	};

	~variation[6] = {
		~res1 = Prand([0.15, 0.425, 0.625, 0.6, 0.8, 0.1, 0.3], inf).asStream;
		~freq1 = Prand([80.rrand(150), 70.rrand(90), 50, 110, 40.rrand(100)], inf).asStream;
		~amp1= Prand([0.2, 0.3, 0.6, 0.2, 0.3, 0.8, 0.3], inf).asStream;
		~dur1 = Pseq([0.15, 0.425, 0.625, 0.6, 0.125], inf).asStream;
		~object1 = 2;
	};

	~variation[7] = {
		~res1 = Prand([0.15, 0.425, 0.625, 0.6, 0.8, 0.1, 0.3], inf).asStream;
		~freq1 = Prand([80.rrand(150), 70.rrand(90), 50, 110, 40.rrand(100)], inf).asStream;
		~amp1= Prand([0.2, 0.3, 0.6, 0.2, 0.3, 0.8, 0.3], inf).asStream;
		~dur1 = Pseq([0.15, 0.425, 0.625, 0.6, 0.125], inf).asStream;
		~object1 = 2;
	};
	//~reverb = Synth(\reverb1);

	loop({

		x.release(1);
		x = Synth(\klank1, [
			//\res: ~res1.value,
			\volume: ~amp1.value,
			\freq: ~freq1.value,
			\sustain: ~dur1.value,
		]);

		~dur1.value.wait;
	});
});

~task[2] =Task({

	~reverb.set(\room, 0.2, \mix, 0.5);

	//~variation[8] = {
		~freq2 = 50;
		~mod_freq2 = 2;
		~amp2= 0.5;
		~dur2 = Pseq([0.5, 0.5, 1], inf).asStream;
		~object2 = 1;
	//};

	~variation[9] = {
		~freq2 = 50;
		~mod_freq2 = 2;
		~amp2 = Prand([0.15, 0.425, 0.625, 0.6, 0.8, 0.1, 0.3], inf).asStream;
		~dur2 = Pseq([0.5, 0.5, 1], inf).asStream;
		~object2 = 1;
	};

	~variation[10] = {
		~freq2 = Prand([20.rrand(40), 20.rrand(60), 30, 10, 40.rrand(50)], inf).asStream;
		~amp2 = Prand([0.15, 0.425, 0.625, 0.6, 0.8, 0.1, 0.3], inf).asStream;
		~mod_freq2 = Prand([3.33, 1.34, 4.26, 5.51], inf).asStream;
		~sustain2 = Pseq([0.15, 0.425, 0.625, 0.6], inf).asStream;
		~dur2 = Pseq([0.15, 0.425, 0.625, 0.6, 0.125], inf).asStream;
		~object2 = 0;
	};

	~variation[11] = {
		~freq2 = Prand([20.rrand(40), 20.rrand(60), 30, 10, 40.rrand(50)], inf).asStream;
		~amp2 = Prand([0.15, 0.425, 0.625, 0.6, 0.8, 0.1, 0.3], inf).asStream;
		~mod_freq2 = Prand([3.33, 1.34, 4.26, 5.51], inf).asStream;
		~sustain2 = Pseq([0.15, 0.425, 0.625, 0.6], inf).asStream;
		~dur2 = Pseq([0.15, 0.425, 0.625, 0.6, 0.125], inf).asStream;
		~object2 = 0;
	};

	loop({
		x.release(2);
		x = Synth(\kick, [
			\gate: 1,
			\amp: ~amp2.value,
			\freq: ~freq2.value,
			\mod_freq: ~mod_freq2.value,
			\sustain: ~sustain2.value,
		]);

		~oscsend.sendMsg('/grain', ~object2,  ~freq2.value, ~amp2.value, ~dur2.value);
		~dur.value.wait;
	});
});

w = Window.new("Task Example", Rect(400, 400, 400, 240)).front;
w.view.decorator = FlowLayout(w.view.bounds);
~task.size.do { |i|
	Button.new(w, Rect(0, 100*i, 90, 20)).states_([["Task"+i+"Var1", Color.black, Color.clear]])
	.action_({~variation[i*4].value(); ~task[i].start;});
	Button.new(w, Rect(0, 100*i, 90, 20)).states_([["Task"+i+"Var2", Color.black, Color.clear]])
	.action_({ ~variation[i*4+1].value(); ~task[i].resume(0)});
	Button.new(w, Rect(0, 100*i, 90, 20)).states_([["Task"+i+"Var3", Color.black, Color.clear]])
	.action_({~variation[i*4+2].value(); ~task[i].resume(0)});
	Button.new(w, Rect(0, 100*i, 90, 20)).states_([["Task"+i+"Var3", Color.black, Color.clear]])
	.action_({~variation[i*4+3].value(); ~task[i].resume(0)});
	Button.new(w, Rect(0, 100*i, 90, 20)).states_([["Stop Task1", Color.black, Color.clear]])
	.action_({~task[i].stop; x.release; /*~reverb.release*/});
};

Button.new(w, Rect(0, 220, 400, 20)).states_([["Finish", Color.black, Color.clear]])
.action_({
	~task.size.do { |i| ~task[i].stop; x.release(0.1)};
	~reverb.release; w.close;});
)

// Schleife für den Grain click
{
	inf.do{ |i|

		var time = [0.2, 1, 0.4, 0.15, 0.3].choose;
		var position = 100.rand;
		var outbus = 2.rand;

		~oscsend.sendMsg("/test", outbus, 100.rrand(255), position);
		time.wait;
		//x.sendMsg("/test", outbus, 0, position);

	};


}.fork;



(

// activate reverb
//~reverb = Synth(\reverb1);

// register to receive this message
~oscOut = OSCFunc({
	arg msg, time, cmdname;
	var object, trig1, trig2, trig3;

	[time, msg].postln; //- to see the full message

	cmdname = msg[0].value;
	object =  msg[2].value;
	trig1 = msg[3].value;
	trig2 = msg[4].value;
	trig3 = msg[5].value;
	~oscsend.sendMsg(cmdname, object,  trig1, trig2, trig3);
	//postf("Message: %, %, %\n", trig1, trig2, trig3);
},'/kick', s.addr);

Pbind(
	\instrument, "kick",
	\gate, 1,
	\amp, Prand([0.15, 0.425, 0.625, 0.6, 0.8, 0.1, 0.3], inf),
	\freq, Prand([80.rrand(150), 70.rrand(90), 50, 110, 40.rrand(100)], inf),
	\mod_freq, Prand([3.33, 1.34, 4.26, 5.51], inf),
	\sustain, Pseq([0.15, 0.425, 0.625, 0.6], inf),
	\dur, Pseq([0.15, 0.425, 0.625, 0.6, 0.125], inf);
).play;

);















///////////////////////////////////////////////////////////////
// Figure 3.2 Using Task so you can pause the sequence
(
t = Task({
	loop({	 // loop the whole thing
		3.do({	 // do this 3 times
			x.release(0.1);
			x = Synth(\default, [freq: 76.midicps]);
			0.5.wait;
			x.release(0.1);
			x = Synth(\default, [freq: 73.midicps]);
			0.5.wait;
		});
		"I'm waiting for you to press resume".postln;
		nil.yield;// fermata
		x.release(0.1);
		x = Synth(\default, [freq: 69.midicps]);
		1.wait;
		x.release;
	});
});

w = Window.new("Task Example", Rect(400, 400, 200, 120)).front;
w.view.decorator = FlowLayout(w.view.bounds);
Button.new(w, Rect(0, 0, 100, 20)).states_([["Play/Resume", Color.black, Color.clear]])
.action_({ t.resume(0);});
Button.new(w, Rect(0, 0, 40, 20)).states_([["Pause", Color.black, Color.clear]])
.action_({ t.pause;});
Button.new(w, Rect(0, 0, 40, 20)).states_([["Finish", Color.black, Color.clear]])
.action_({
	t.stop;
	x.release(0.1);
	w.close;
});
)

///////////////////////////////////////////////////////////////
// Figure 3.5 Thanks to polymorphism we can substitute objects that understand the same message
(
p = 64; // a constant note
q = Pseq([1, 2, 0.5], inf).asStream; // ordered sequence of durations
t = Task({
	loop({
		x.release(2);
		x = Synth(\default, [freq: p.value.midicps]);
		q.value.wait;
	});
});
t.start;
)
// now change p
p = Pseq([64, 66, 68], inf).asStream; // to a Pattern: do re mi
freq = { rrand(64, 76) }; // to a Function: random notes from a chromatic octave
t.stop; x.release(2);


///////////////////////////////////////////////////////////////
// Figure 3.3 Nesting tasks inside routines
(
r = Routine({
	c = TempoClock.new; // make a TempoClock
	// start a 'wobbly' loop
	t = Task({
		loop({
			x.release(0.1);
			x = Synth(\default, [freq: 61.midicps, amp: 0.2]);
			0.2.wait;
			x.release(0.1);
			x = Synth(\default, [freq: 67.midicps, amp: 0.2]);
			rrand(0.075, 0.25).wait; // random wait from 0.1 to 0.25 seconds
		});
	}, c); // use the TempoClock to play this Task
	t.start;
	nil.yield;

	// now add some notes
	y = Synth(\default, [freq: 73.midicps, amp: 0.3]);
	nil.yield;
	y.release(0.1);
	y = Synth(\default, [freq: 79.midicps, amp: 0.3]);
	c.tempo = 2; // double time
	nil.yield;
	t.stop; y.release(1); x.release(0.1); // stop the Task and Synths
});
)

r.next; // start loop
r.next; // first note
r.next; // second note; loop goes 'double time'
r.next; // stop loop and fade

// x.free;
SendPeakRMS
