// -------------------------------------------------------------------------------------
//                                    Synthdefs
// -------------------------------------------------------------------------------------

// Synth 1 - Definition - Sinus Oscillator – Frequenz und Ampl. Contr.
SynthDef("Synth1", {
	arg outBus = 0, volume = 0, freq = 200, ctrin1 = 0, ctrin2 = 1, anzahl = 1;
	var ctr1 = In.kr(ctrin1,1)+1, ctr2 = In.kr(ctrin2,1)+1;

	var output = SinOsc.ar(ctr1*freq, 0, ctr2*volume);

	Out.ar(outBus, output);
	SendReply.kr(Impulse.kr(20), '/dodec',
		[output, ctr1*freq], 4);

}).add;

// Synth 2 - Definition - Additiver Synth mit zufälligen Obertönen – Frequenz und Ampl. Contr.
SynthDef("Synth2", {
	arg outBus = 0, volume = 0.2, freq = 200, randmin = 0.9, randmax = 1.1, ctrin1 = 2, ctrin2 = 3,
	ts = 1, atactime = 0.01, rel= 0.8, reltime = 0.5,
	sus = 0.8, sustime = 2, dectime = 0.5, curve = -4;

	var n = 10, output, ctr1 = In.kr(ctrin1,1)+1, ctr2 = In.kr(ctrin2,1)+1, random;

	var env = EnvGen.kr(Env([0, 1, rel, sus, 0],
		[atactime, reltime, sustime, dectime], curve),
		timeScale: ts,
		doneAction: 2);

	output = Mix.fill(n, {|i|
		random = (freq  * Rand(randmin,(randmax * (i+1))));
		SinOsc.ar(ctr1 * random, 0, 1/n)})
	* volume * ctr2 * env;

	Out.ar(outBus, output);
	SendReply.kr(Impulse.kr(20), '/dodec',
		[output, ctr1*freq], 2);


}).add;


// Synth 3 - Definition - White Noise mit Resonanz-Filter, Frequenz- und Volumen- Control
SynthDef("Synth3", {
	arg outBus = 0, volume = 1, freq = 1, bwr = 0.2, ctrin1 = 10, ctrin2 = 11, ctrin3 = 12;
	var output, fade = 2.0, ctr1, ctr2, ctr3;

	ctr1 = In.kr(ctrin1,1)+1;
	ctr2 = In.kr(ctrin2,1)+1;
	ctr3 = In.kr(ctrin3,1)+1;

	output = Resonz.ar(BrownNoise.ar(ctr2), freq*ctr1, bwr*ctr3);

	SendReply.kr(Impulse.kr(20), '/dodec',
		[output, ctr1*freq], 3);

	Out.ar(outBus, output*volume.lag(fade, 0.1))
}).add;

//  Grainsynth 1 - Sinuston mit perkusiver Envelope
SynthDef("GrainSynth1", {
	arg outBus = 0, freq = 440, volume = 0.2, grainpuls = 10, ts=1,
	atack = 0.01, decay = 0.05, level = 0.5, release = 0.05, sustain = 0.1, curve = -3,
	ctrin1 = 4, ctrin2 = 5, pos = 0.5;

	var ctr1 = In.kr(ctrin1, 1)+1, ctr2 = In.kr(ctrin2, 1)+1, output;

	var env = EnvGen.ar(Env([0, 1, level, level, 0], [atack, decay, sustain, release], curve),
		levelScale: volume, timeScale: ts, doneAction:2);

	// output = Mix.fill(4, {|i| SinOsc.ar(freq*ctr1*(i+1), 0, ctr2*(i+1).reciprocal)}) * env;
	output = Pulse.ar(freq*ctr1*BrownNoise.ar(0.2, 0.9), 0.2, ctr2)* env;

	OffsetOut.ar(outBus, Pan2.ar(output, pos));
}, \ir.dup(5)).add;

//  Signalgrain 2 - Granulator eines beliebigen Eingangssignals
SynthDef("Signalgrain", {
	arg inBus = 80, outBus = 60,
	volume = 0.2, sustain = 0.1, ts=1, delay = 0.2,
	ctrinsustain, ctrinvol = 4, pan = 0.5;

	var ctrsustain = In.kr(ctrinsustain, 1)+1, ctrvol = In.kr(ctrinvol, 1)+1;
	var input = DelayN.ar((In.ar(inBus, 2)), delay, delay);

	var env = EnvGen.ar(Env.sine(sustain * ctrsustain, volume),
		timeScale: ts, doneAction:2);

	var output = input * env * ctrvol;
	OffsetOut.ar(outBus, Pan2.ar(output, pan));

	},
	\ir.dup(5)).add;

// Samplegrain 3 - Granulator eines im Buffer gespeicherten Samples

SynthDef("Samplegrain" , {
	arg outBus = 0,
	bufnum = 0, pan = 0.0, rate = 1, startPos = 0.0, volume = 0.1, sustain = 0.04, ts = 1,
	ctrinvolume = 141, ctrinsustain = 140;

	var ctrsustain = In.kr(ctrinsustain, 1)+1, ctrvol = In.kr(ctrinvolume, 1)+1;

	var env = EnvGen.ar(Env.sine(sustain * ctrsustain),
		timeScale: ts, doneAction:2);

	var grain = PlayBuf.ar(1,bufnum, BufRateScale.kr(bufnum)*rate, 1,
		BufFrames.ir(bufnum)*startPos, 0);

	var output = Pan2.ar(grain*env, pan, ctrvol*volume);

	OffsetOut.ar(outBus, output);

	},
	\ir.dup(5)).add;


// Effekt 1 - Reverb1
SynthDef("reverb1", {
	arg outBus = 0, inBus = 0, mix = 0.33, room = 0.5, damp = 0.5, volume = 1, ctrinvolume = 300;

	var ctrvolume = In.kr(ctrinvolume, 1)+1;
	var input = In.ar(inBus, 1);
	var output = FreeVerb.ar(input, mix, room, damp, volume);
	Out.ar(outBus, output*ctrvolume);
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

		SendReply.ar(input*ctrvolume, '/dodec', [input*ctrvolume, delayfreq], 2);
	});

}).add;

// Effekt 4 - Amplituden-Modulator
SynthDef("amplmod", {
	arg outBus = 0, inBus = 0, freq = 220, volume = 0.2, ctrin1 = 50, ctrin2 = 51, n = 1;
	var input = In.ar(inBus, 2), ctr1 = In.kr(ctrin1,1)+1, ctr2 = In.kr(ctrin2,1)+1, output;

	output = SinOsc.ar(freq * ctr1, 0, volume * ctr2) * input;
	Out.ar(outBus, output);

}).add;

// Effekt 5 - Frequenz-Modulator
SynthDef("freqmod", {
	arg outBus = 0, inBus1 = 0, inBus2 = 2, freq = 220, volume = 0.2, ctrin1 = 52;
	var input1 = In.ar(inBus1, 2);
	var ctr1 = In.kr(ctrin1,1)+1, output;

	output = SinOsc.ar(freq * input1, 0, volume * ctrin1);
	/*SendReply.kr(Impulse.kr(60), '/dodec',
		[output, freq * input1], 4);*/

	Out.ar(outBus, output);

}).add;

// Effekt 6 - Multchannel Panner
SynthDef("multipan", {
	arg outBus = 0, inBus = 0, level = 1, pos = 2, width = 2, orientation = 0, ctrinlevel = 10, ctrinpan = 11, ctrinwidth = 12;

	var input1 = In.ar(inBus, 2);
	var ctrpan = In.kr(ctrinpan,1)+1;
	var ctrwidth = In.kr(ctrinwidth,1)+1;
	var ctrlevel = In.kr(ctrinlevel,1)+1, output;

	output = Limiter.ar(Compander.ar(PanAz.ar(2, input1, pos * ctrpan, level * ctrlevel, width * ctrwidth, orientation), 0.01), 0.05);

	Out.ar(outBus, output);

}).add;

// Effekt 7 - Limiter
SynthDef("limiter", {
	arg outBus = 0, inBus = 0, level = 0.8, dur = 0.02 ;

	var input = In.ar(inBus, ~channelsOut), output;

	output = Limiter.ar(input, level, dur);

	ReplaceOut.ar(outBus, output);

}).add;

// Effekt 8 - Out
SynthDef("out", {
	arg outBus = 0, inBus = 0, level = 0.8, dur = 0.1, comp = 1, ctrincomp = 100;

	var ctrcomp = In.kr(ctrincomp,1)+1;
	var input = In.ar(inBus, 1), output;

	output = Compander.ar(input, mul: comp * ctrcomp);

	Out.ar(outBus, output*level);

}).add;

// Effekt 9 - bus
SynthDef("bus", {
	arg outBus = 0, inBus = 200, level = 0.8, dur = 0.02 ;

	var input = In.ar(inBus, ~channelsOut), output;

	output = Limiter.ar(input, level, dur);

	Out.ar(outBus, output);

}).add;



//  Controlsignal 1 - Definition - LFNoise0
SynthDef("lownoise0", {
	arg outBus = 0, puls = 1, maxval = 0.5, minval = 0.2, lag = 0.1;
	Out.kr(outBus,
		Lag.kr(LFNoise0.kr(puls, maxval-minval, minval), lag)-1)
}).add;



//  Controlsignal 2 - Definition - Line
SynthDef("line", {
	arg outBus = 1, start, end, time, lag = 0;
	var output = Line.kr(start, end, time, doneAction: 2)-1;

	Out.kr(outBus, Lag.kr(output, lag))

}).add;


// Controlsignal 3 - Definition - Dust

SynthDef("dust", {
	arg outBus = 2, density = 10, volume = 1, add = 0, lag = 0;

	var output = Dust.kr(density, volume, add)-1;

	Out.kr(outBus, Lag.kr(output, lag))

}).add;

// Controlsignal 4 - Definition - Envelope Generator

SynthDef("envelope", {
	arg outBus = 3, ts = 1, atactime = 0.01, rel= 0.8, reltime = 0.5,
	sus = 0.8, sustime = 2, dectime = 0.5, curve = -4;

	var output = EnvGen.kr(Env([0, 1, rel, sus, 0],
		[atactime, reltime, sustime, dectime], curve),
		timeScale: ts,
		doneAction: 2) - 1;

	Out.kr(outBus, output)
}).add;

// Init controlsignals

SynthDef("init", {
	arg outBus = 0, on = 1, off = 0;
	Out.kr(outBus, Line.kr(off, on, 0.001))
}).add;

// -------------------------------------------------------------------------------------
//                              Gruppen definieren
// -------------------------------------------------------------------------------------


// Gruppen definieren

~master = Group.new;
~effect = Group.new;
~grains = Group.new;
~synths = Group.new;
~control = Group.new;

// s.queryAllNodes;

// -------------------------------------------------------------------------------------
//                               Midi initialisieren
// -------------------------------------------------------------------------------------


/*MIDIIn.connectAll;

~mastervolume = Bus.control();
~masterfader = MIDIFunc.cc( {arg ...args; ~mastervolume = (args[0] / 127)}, 2);*/