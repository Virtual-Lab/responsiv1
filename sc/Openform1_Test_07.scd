// Stereo Out

~test1 = Routine {

	~stimmen. do({ |x|

		var inBus = ~modul.granulatoreffectBus[x];
		var time = 0;
		var outBus1 = ~channelsOut.rand;
		var outBus2 = ~channelsOut.rand;

		postf("Starte Granular-Schleife %:\n", x);

		~modul.repeatgranular[x] = 2.rrand(8);
		~modul.timegranular[x] = Array.fill(~modul.repeatgranular[x], ~tonlaenge[x].choose);
		~modul.durationgranular[x] = Array.fill(~modul.repeatgranular[x],
			{(~tonlaenge[x].choose)*2.rrand(4)});
		~modul.repeatgranular[x].do ({|i| time = time + ~modul.durationgranular[x][i]});

		postf("Repeat: % mal Duration gesamt, % sec. \n", ~modul.repeatgranular[x], time);

		~modul.granulator[x].start;
		~modul.granulator1out[x] = Synth.head(~master, "out",
			[\inBus, inBus, \outBus, outBus1, \level, 1.5]);
		~modul.granulator2out[x] = Synth.head(~master, "out",
			[\inBus, inBus.index+1, \outBus, outBus2, \level, 1.5]);

		~modul.granulator2out[x] = Synth.head(~master, "out",
			[\inBus, inBus.index+1, \outBus, outBus2, \level, 1.5]);

		~modul.granulatormix[x] = Synth.head(~master, "out2",
			[\inBus, inBus, \outBus, 0, \level, 1.5]);

		(time/(x+2)).wait;
	});

};

// Stereo Out

~test2 = Routine {

	~stimmen. do({ |x|

		var inBus1 = Array.fill(~channelsOut, { |i| ~modul.samplegraineffectBus1[x].index+i});
		var inBus2 = Array.fill(~channelsOut, { |i| ~modul.samplegraineffectBus2[x].index+i});
		var time = 0;
		var outBus1 = ~modul.samplegrainBusarray1[x];
		var outBus2 = ~modul.samplegrainBusarray2[x];
		var variation = ~tonlaenge[x]/((x+1)/2);

		postf("Starte Granularsample-Schleife %:\n", x);


		~modul.repeatsamplegrain[x] = 2.rrand(8);
		~modul.timesamplegrain[x] = Array.fill(~modul.repeatsamplegrain[x],~tonlaenge[x].choose);
		~modul.durationsamplegrain[x] = Array.fill(~modul.repeatsamplegrain[x], {(variation.choose)*1.rrand(3)});
		~modul.repeatsamplegrain[x].do ({|i| time = time + ~modul.durationsamplegrain[x][i]});

		postf("Repeat: % mal Duration gesamt, % sec. \n", ~modul.repeatsamplegrain[x], time);

		~modul.samplegrain[x].start;

		~channelsOut.do { |i|
			~modul.samplegrain1out[x] = Synth.head(~master, "out", [\inBus, inBus1[i], \outBus, outBus1[i]+2, \level, 1.0]);
			~modul.samplegrain2out[x] = Synth.head(~master, "out", [\inBus, inBus2[i], \outBus, outBus2[i]+2, \level, 1.0]);
		};

		~modul.samplegrainmix[x] = Synth.head(~master, "out2multi", [\inBus1, inBus1, \inBus2, inBus2, \outBus, 0, \level, 1.0]);



		10.rand.wait;
	});

};

//

~test3 = Routine {
	~stimmen. do({ |x|

		var inBus1 = Array.fill(5, { |i| ~modul.delaysyntheffectBus1[x].index+i});
		var inBus2 = Array.fill(5, { |i| ~modul.delaysyntheffectBus2[x].index+i});
		var time = 0;
		var variation = ~tonlaenge[x]/((x+1)/4);
		var outBusses = ~dodecout1;
		var outBus1, outBus2;

		while ( {outBus1 == outBus2}, {outBus1 = outBusses.choose; outBus2 = outBusses.choose;});
		10.rand.wait;
		x.postln;

		time = 0;

		~modul.repeatdelaysynth[x] = 4.rrand(8);
		~modul.timedelaysynth[x] = Array.fill(~modul.repeatdelaysynth[x], {variation.choose});
		~modul.tonfolgedelaysynth[x]=Array.fill(~modul.repeatdelaysynth[x], {Rand(1,3)});
		~modul.durationdelaysynth[x] = Array.fill(~modul.repeatdelaysynth[x],
			{variation.choose});
		~modul.repeatdelaysynth[x].do ({|i| time = time + ~modul.durationdelaysynth[x][i]});

		~modul.delaysynth1out[x] = Array.newClear(5);
		~modul.delaysynth2out[x] = Array.newClear(5);


		5.do { |i|
			~modul.delaysynth1out[x][i] = Synth.head(~master, "out", [\inBus, inBus1[i], \outBus, outBus1[i]+2, \level, 1]);
			~modul.delaysynth2out[x][i] = Synth.head(~master, "out", [\inBus, inBus2[i], \outBus, outBus2[i]+2, \level, 1]);
		};

		~modul.delaysynthmix[x] = Synth.head(~master, "out2fuenf", [\inBus1, inBus1, \inBus2, inBus2, \outBus, 0, \level, 1]);

		~modul.glockensynth[x].start;
	});

};


~test4 = Routine {
	~stimmen.do({ |x|

		var inBus = ~modul.rauscheneffectBus[x];
		var time = 0;
		var variation = ~tonlaenge[x];
		var outBus1 = ~channelsOut.rand, outBus2 = ~channelsOut.rand;
		var randompath = 5.rand;
		var randomlayer = 5.rand;

		15.rand.wait;
		postf("Starte Windrauschen-Schleife %:\n", x);

		~modul.repeatrauschen[x] = 2.rrand(6);
		~modul.durationrauschen[x]=Array.fill(~modul.repeatrauschen[x], {~tonlaenge[x].choose});

		~modul.tonfolgerauschen[x]=Array.fill(~modul.repeatrauschen[x], {1.rrand(4)});

		~modul.timerauschen[x]= Array.fill(~modul.repeatrauschen[x], { |irepeat|
			Array.fill(~modul.tonfolgerauschen[x][irepeat], {variation.choose})});


		~modul.repeatrauschen[x].do ({|irepeat|
			time = time + ~modul.durationrauschen[x][
				irepeat];
			~modul.tonfolgerauschen[x][irepeat].do ({ |i|
				time = time + ~modul.timerauschen[x][irepeat][i];
			});
		});

		~modul.sequenzdauerrauschen[x] = time;

		postf("Repeat: % mal Duration gesamt, % sec. \n", ~modul.repeatrauschen[x], time);
		~modul.repeatrauschen[x].do({ |irepeat|
			postf("%. Tonfolge: % mal\n", irepeat, ~modul.tonfolgerauschen[x][irepeat])});

		~modul.windrauschen[x].start;

		~modul.rauschen1out[x] = Synth.head(~master, "out",
			[\inBus, inBus.index, \outBus, outBus1, \level, 1]);
		~modul.rauschen2out[x] = Synth.head(~master, "out",
			[\inBus, (inBus.index)+1, \outBus, outBus2, \level, 1]);
		~modul.rauschenmix[x] = Synth.head(~master, "out2",
			[\inBus, inBus, \outBus, 0, \level, 1]);

	});

};


~test5 = Routine {

	~stimmen.do({ |x|

		var inBus = ~modul.sinusglissandieffectBus[x];
		var variation = ~tonlaenge[x]/2 * (x+1);
		var outBus1 = ~channelsOut.rand + 2;
		var outBus2 = ~channelsOut.rand + 2;
		var time = 0;

		x.postln;
		postf("Starte Sinusglissandi-Schleife %:\n", x);


		~modul.repeatsinusglissandi[x] = 2.rrand(10);
		~modul.durationsinusglissandi[x]=Array.fill(~modul.repeatsinusglissandi[x], {variation.choose});

		~modul.tonfolgesinusglissandi[x]=Array.fill(~modul.repeatsinusglissandi[x], {1.rrand(4)});

		~modul.timesinusglissandi[x]= Array.fill(~modul.repeatsinusglissandi[x], { |irepeat|
			Array.fill(~modul.tonfolgesinusglissandi[x][irepeat], {variation.choose})});


		~modul.repeatsinusglissandi[x].do ({|irepeat|
			time = time + ~modul.durationsinusglissandi[x][irepeat];
			~modul.tonfolgesinusglissandi[x][irepeat].do ({ |i|
				time = time + ~modul.timesinusglissandi[x][irepeat][i]
			});
		});
		~modul.sequenzdauersinusglissandi[x] = time;

		postf("Repeat: % mal Duration gesamt, % sec. \n", ~modul.repeatsinusglissandi[x], time);

		~modul.sinusglissandi[x].start;
		~modul.sinusglissandi1out[x] = Synth.head(~master, "out", [\inBus, inBus, \outBus, outBus1, \level, 1]);
		~modul.sinusglissandi2out[x] = Synth.head(~master, "out", [\inBus, inBus.index+1, \outBus, outBus2, \level, 1]);
		~modul.sinusmix = Synth.head(~master, "out2", [\inBus, inBus, \outBus, 0, \level, 1]);

		(time/((x+1)*1.2)).wait;

	});

};