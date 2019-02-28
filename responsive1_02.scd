(

~channels = 2;
~folder = thisProcess.nowExecutingPath.dirname +/+ "samples/";
s.quit;

o = Server.local.options;
o.memSize = 2.pow(20);
o.numAudioBusChannels = 256;
o.sampleRate = 44100;
o.maxNodes = 1024*20;

thisProcess.openUDPPort(9002);
~oscsend = NetAddr.new("localhost", 9000);
//~oscsend.sendMsg("/test", 255.rand, 155.rand);

s.waitForBoot  {
SynthDef(\kick,
	{ arg out = 0, freq = 50, mod_freq = 5, mod_index = 5, sustain = 0.4, gate = 1.0, amp = 0.8, beater_noise_level = 0.025;

		var pitch_contour, drum_osc, drum_lpf, drum_env;
		var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
		var kick_mix, trigger1, trigger2;

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
		kick_mix = Mix.new([drum_env, beater_env]) * 2 * amp;
		trigger1 = Impulse.kr(0, 0, amp);
		trigger2 = Impulse.kr(10, 0, amp);

		SendReply.kr(trigger1, '/kick', [freq, amp, sustain], 0);
		SendReply.kr(trigger2, '/dyn', [freq, amp, sustain], 1);
		Out.ar(out, [kick_mix, kick_mix])
	}
).add;

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

	var input = In.ar(inBus, 2);
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
)


(
a = Synth(\kick)
a.free;

(

// activate reverb
~reverb = Synth(\reverb1);

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

// Schleife für den Grain click
{
	inf.do{ |i|

		var time = rrand(0.2, 1);
		var position = 100.rand;
		var outbus = 2.rand;

		//x.sendMsg("/test", outbus, 200.rrand(255), position);
		time.wait;
		//x.sendMsg("/test", outbus, 0, position);

	};


}.fork;

);

// x.free;
SendPeakRMS
