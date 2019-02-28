(


thisProcess.openUDPPort(9002);
x = NetAddr.new("localhost", 9000);
x.sendMsg("/test", 255.rand, 155.rand);


SynthDef("grain-click", {
	arg outBus = 0, vol = 0.2, ts=1, attac = 0.01, release = 0.001, level = 1, curve = -2;

	var env = EnvGen.ar(Env.perc(attac, release, level, curve),
		timeScale: ts, doneAction: 2);
	var output = WhiteNoise.ar(vol) * env;

	OffsetOut.ar(outBus, output)
}, \ir.dup(5)).add;

SynthDef("impulse-click", {

	arg outBus = 0, freq = 0.5, vol=0.3;

	var output = Impulse.ar(freq, 0, vol);
	Out.ar(outBus, output);

	// Send Trigger - Die Nachricht wird von OSCFUNC empfangen
	SendReply.ar(output, '/test', WhiteNoise.kr(127, 127).round(1, 1), 3);

}).add;

SynthDef("single-click", {

	arg outBus = 0, vol=0.3;

	var output = Impulse.ar(0, 0, vol);
	Out.ar(outBus, output);
	// Send Trigger - Die Nachricht wird von OSCFUNC empfangen
	SendReply.ar(output, '/test', [WhiteNoise.kr(127).round(1), WhiteNoise.kr(127, 127).round(1)], 4);
	FreeSelf.kr(output);

}).add;

SynthDef("dust-click", {

	arg outBus = 0, density = 10, vol=0.3;

	var output = Dust.ar(density, vol);
	Out.ar(outBus, output);

	// Send Trigger - Die Nachricht wird von OSCFUNC empfangen
	SendReply.ar(output, '/test', WhiteNoise.kr(127).round(1), 2);

}).add;
// SendReply.ar(trig: 0, cmdName: '/reply', values, replyID: -1);

/*SynthDef(\mlpitch,{

		var soundin, amp, freq, hasFreq;
		soundin= SoundIn.ar;
amp= Amplitude.kr(soundin);
		#freq, hasFreq = Pitch.kr(soundin)/2;
		Out.ar(0,amp*1.2*SinOsc.ar(freq))
	}).add;*/

// register to receive this message
o = OSCFunc({ arg msg, time, addr, recvPort;
	[msg, recvPort].postln

}, '/test');

// activate impulsclick
//Synth("impulse-click", [\density, 1]);
//Synth("dust-click", [\density, 2, \outBus, 1]);

// Schleife für den Grain click
{
	inf.do{ |i|

		var time = rrand(0.2, 1);
		var position = 100.rand;
		var outbus = 2.rand;

		// Effiziente Methode um den grainclick zu spielen
		// s.sendMsg("s_new", "grain-click", s.nextNodeID, 0, 0, \ts, 0.01);

		//~click1 = Synth("grain-click", [\outBus, outbus, \ts, 0.2]);

		//~click2 = Synth("single-click", [\outBus, outbus]);

		x.sendMsg("/test", outbus, 200.rrand(255), position);
		time.wait;
		//x.sendMsg("/test", outbus, 0, position);

	};


}.fork;
)

// x.free;
SendPeakRMS
