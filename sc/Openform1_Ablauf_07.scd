// -------------------------------------------------------------------------------------
//                                  Steuerung der Routinen
// -------------------------------------------------------------------------------------


~stimmen.do { |x|

	~modul.ablauf[x] = {

		//~ablauf.do { |index|

		var wahl = ~wahl[x];//(~wahl[index].sputter((1/~wahl[index].size), ~ablauf-x)).scramble; //
		var variation, time, einsatz;
		var repeat = (8-(x/2)).rrand(12-(x/2));
		var gleichzeitig;

		var channels = Array.fill(~channelsOut, {|i| i});
		var granulator1out, granulator2out, samplegrain1out, samplegrain2out;
		var delaysynth1out, delaysynth2out, rauschen1out, rauschen2out;
		var sinusglissandi1out, sinusglissandi2out;
		var granulatormix, samplegrainmix, delaysynthmix, rauschenmix, sinusmix;
		var start2, spielen;


		einsatz = (20*x).rrand(30*x);
		postf("START PROZEDURE % in % Sekunden, Repeat: %\n", x, einsatz.round(1e-1), repeat);

		einsatz.wait;

		granulator1out = Synth.head(~master, "out",
			[\outBus, 2, \inBus, ~modul.granulatoreffectBus[x].index, \ctrincomp, 150+(100*x), \level, 0]);
		granulator2out = Synth.head(~master, "out",
			[\outBus, 3, \inBus, (~modul.granulatoreffectBus[x].index)+1, \ctrincomp, 150+(100*x), \level, 0]);
		granulatormix = Synth.head(~master, "out2",
			[\outBus, 0, \inBus, ~modul.granulatoreffectBus[x]]);


		samplegrain1out = Array.newClear(~cannelsOut);
		samplegrain2out = Array.newClear(~cannelsOut);

		~cannelsOut.do { |i|
			samplegrain1out[i] = Synth.head(~master, "out",
				[\outBus, 2, \inBus, ~modul.samplegraineffectBus1[x].index+i, \level, 0]);
			samplegrain2out[i] = Synth.head(~master, "out",
				[\outBus, 3, \inBus, ~modul.samplegraineffectBus2[x].index+i, \level, 0]);
		};

		samplegrainmix = Synth.head(~master, "out2multi",
			[\outBus, 0, \inBus1, ~modul.samplegraineffectBus1[x], \inBus2, ~modul.samplegraineffectBus2[x]]);

		delaysynth1out = Array.newClear(~cannelsOut);
		delaysynth2out = Array.newClear(~cannelsOut);

		5.do { |i|
			delaysynth1out[i] = Synth.head(~master, "out",
				[\outBus, i, \inBus, ~modul.delaysyntheffectBus1[x].index+i, \level, 0]);
			delaysynth2out[i] = Synth.head(~master, "out",
				[\outBus, i, \inBus, ~modul.delaysyntheffectBus2[x].index+i, \level, 0]);
		};

		delaysynthmix = Synth.head(~master, "out2fuenf",
			[\outBus, 0, \inBus1, ~modul.delaysyntheffectBus1[x], \inBus2, ~modul.delaysyntheffectBus2[x], \level, 1.5]);

		rauschen1out = Synth.head(~master, "out",
			[\outBus, 2, \inBus, ~modul.rauscheneffectBus[x].index, \smooth, 1.0, \level, 0]);
		rauschen2out = Synth.head(~master, "out",
			[\outBus, 3, \inBus, (~modul.rauscheneffectBus[x].index)+1, \smooth, 1.0, \level, 0]);

		rauschenmix = Synth.head(~master, "out2",
			[\outBus, 0, \inBus, ~modul.rauscheneffectBus[x], \smooth, 1.0, \level, 0.0]);

		sinusglissandi1out = Synth.head(~master, "out",
			[\outBus, 2, \inBus, ~modul.sinusglissandieffectBus[x].index, \smooth, 1.0, \level, 0]);
		sinusglissandi2out = Synth.head(~master, "out",
			[\outBus, 3, \inBus, (~modul.sinusglissandieffectBus[x].index)+1, \smooth, 1.0, \level, 0]);

		sinusmix = Synth.head(~master, "out2",
			[\outBus, 0, \inBus, ~modul.sinusglissandieffectBus[x],  \smooth, 1.0, \level, 0.0]);

		repeat.do {

			wahl.do { |auswahl|

				switch(auswahl,

					1, {
						//var outputBus = [0, 1, 2, 3, 4].choose;


						if (~modul.setgranulator[x] == 0,

							{
								var outBus1, outBus2;
								while({outBus1 == outBus2}, { outBus1 = rand(~channelsOut);
									outBus2 = rand(~channelsOut) });

								outBus1 = (~modul.granulatorBus.index)+outBus1;
								outBus2 = (~modul.granulatorBus.index)+outBus2;

								variation = ~tonlaenge[x]*3.rrand(6);
								time = 0;

								~modul.repeatgranular[x] = 1.rrand(3);
								~modul.durationgranular[x] = Array.fill(~modul.repeatgranular[x], {variation.choose});
								~modul.timegranular[x] = Array.fill(~modul.repeatgranular[x], {(~tonlaenge[x].choose)/2});
								~modul.repeatgranular[x].do ({|i|
									time = time + ~modul.durationgranular[x][i] + ~tonlaenge[x][i]});


								granulator1out.set(\outBus, outBus1, \level, 1.5);
								granulator2out.set(\outBus, outBus2, \level, 1.5);

								~modul.setgranulator[x] = 1;
								~modul.granulator[x].start;

								postf("GROUP % - Output % % – Granulartextur - % Sekunden\n", x,
									outBus1, outBus2, time.round(1e-2));


							},

							{spielen = 3}
						);


					},


					2, {
						//var outputBus = [0, 1, 2, 3, 4].choose;

						if (~modul.setsamplegrain[x] == 0,

							{
								var outBus1, outBus2;

								outBus1 = ~modul.samplegrainBusarray1[x];
								outBus2 = ~modul.samplegrainBusarray2[x];

								variation = ~tonlaenge[x]*3.rrand(6);
								time = 0;

								~modul.repeatsamplegrain[x] = 2.rrand(6);
								~modul.durationsamplegrain[x] = Array.fill(~modul.repeatsamplegrain[x],
									{variation.choose});
								~modul.timesamplegrain[x] = Array.fill(~modul.repeatsamplegrain[x],
									{(~tonlaenge[x].choose)/2});
								~modul.repeatsamplegrain[x].do ({|i|
									time = time + ~modul.durationsamplegrain[x][i] + ~modul.timesamplegrain[x][i]});

								~channelsOut.do { |i|
									samplegrain1out[i].set(\outBus, outBus1[i]+2, \level, 1);
									samplegrain2out[i].set(\outBus, outBus2[i]+2, \level, 1);
								};

								~modul.setsamplegrain[x] = 1;
								~modul.samplegrain[x].start;

								postf("GROUP % - Output % % – Granularsample - % Sekunden\n", x,
									outBus1, outBus2, time.round(1e-2));


							},

							{spielen = 3}
						);


					},

					3, {
						//var outputBus= [0, 1, 2, 3, 4].choose;



						if (~modul.setdelaysynth[x] == 0,

							{
								var outBusses = ~dodecout1;
								var outBus1, outBus2;

								outBus1 = outBusses.take(outBusses.choose);
								outBus2 = outBusses.take(outBusses.choose);

								/*outBus1 = (~modul.delaysynthBus.index)+outBus1;
								outBus2 = (~modul.delaysynthBus.index)+outBus2;*/

								variation = ~tonlaenge[x]*3.rrand(6);
								time = 0;

								~modul.repeatdelaysynth[x] = 2.rrand(6);
								//~tonfolgedelaysynth[x]=Array.fill(~repeatdelaysynth, {Rand(1,3)});

								~modul.durationdelaysynth[x] = Array.fill(~modul.repeatdelaysynth[x],
									{(variation).choose});

								~modul.timedelaysynth[x] = Array.fill(~modul.repeatdelaysynth[x],
									{(~tonlaenge[x].choose)/2});

								~modul.repeatdelaysynth[x].do ({|i|
									time = time + ~modul.durationdelaysynth[x][i] + ~modul.timedelaysynth[x][i]});

								5.do {|i|
									delaysynth1out[i].set(\outBus, (~modul.delaysynthBus.index)+outBus1[i], \level, 1);
									delaysynth2out[i].set(\outBus, (~modul.delaysynthBus.index)+outBus2[i], \level, 1);
								};

								~modul.setdelaysynth[x] = 1;
								~modul.glockensynth[x].start;


								postf("GROUP % - Output % % – Glockensynth - % Sekunden\n", x,
									outBus1, outBus2, time.round(1e-2));

							},

							{spielen = 3}
						);

					},


					4, {

						//var outputBus = [0, 1, 2, 3, 4].choose;

						if (~modul.setrauschen[x] == 0,

							{
								var outBus1, outBus2;
								while({outBus1 == outBus2}, { outBus1 = rand(~channelsOut);
									outBus2 = rand(~channelsOut)});

								outBus1 = (~modul.rauschenBus.index)+outBus1;
								outBus2 = (~modul.rauschenBus.index)+outBus2;

								variation = ~tonlaenge[x];
								time = 0;

								~modul.repeatrauschen[x] = 1.rrand(4);

								~modul.tonfolgerauschen[x]=Array.fill(~modul.repeatrauschen[x], {1.rrand(4)});

								~modul.durationrauschen[x]=Array.fill(~modul.repeatrauschen[x],
									(~tonlaenge[x].choose)/2);

								~modul.timerauschen[x]= Array.fill(~modul.repeatrauschen[x], { |irepeat|
									Array.fill(~modul.tonfolgerauschen[x][irepeat],
										{variation.choose})});


								~modul.repeatrauschen[x].do ({|irepeat|

									time = time + ~modul.durationrauschen[x][irepeat];
									~modul.tonfolgerauschen[x][irepeat].do ({ |i|
										time = time + ~modul.timerauschen[x][irepeat][i];
									});
								});

								rauschen1out.set(\outBus, outBus1, \level, 0.5);
								rauschen2out.set(\outBus, outBus2, \level, 0.5);

								~modul.sequenzdauerrauschen[x] = time;
								~modul.setrauschen[x] = 1;
								~modul.windrauschen[x].start;

								postf("GROUP % - Output % % – Rauschen - % Sekunden\n", x,
									outBus1, outBus2, time.round(1e-2));

							},

							{
								spielen = 3;
							}
						);


					},


					5, {
						//var outputBus= [0, 1, 2, 3, 4, 5].choose;

						if (~modul.setsinusglissandi[x] == 0,

							{
								var outBus1, outBus2;
								while({outBus1 == outBus2}, { outBus1 = rand(~channelsOut);
									outBus2 = rand(~channelsOut)});

								outBus1 = (~modul.sinusglissandiBus.index) + outBus1;
								outBus2 = (~modul.sinusglissandiBus.index) + outBus2;

								variation = ~tonlaenge[x];
								time = 0;

								~modul.repeatsinusglissandi[x] = 2.rrand(4);
								~modul.durationsinusglissandi[x] = Array.fill(~modul.repeatsinusglissandi[x],
									{(variation.choose)/2});

								~modul.tonfolgesinusglissandi[x] = Array.fill(~modul.repeatsinusglissandi[x],
									{1.rrand(4)});

								~modul.timesinusglissandi[x]= Array.fill(~modul.repeatsinusglissandi[x],
									{ |irepeat| Array.fill(~modul.tonfolgesinusglissandi[x][irepeat],
										{variation.choose})});

								~modul.repeatsinusglissandi[x].do { |irepeat|

									time = time + ~modul.durationsinusglissandi[x][irepeat];
									~modul.tonfolgesinusglissandi[x][irepeat].do { |i|
										time = time + ~modul.timesinusglissandi[x][irepeat][i]
									};
								};

								~modul.sequenzdauersinusglissandi[x] = time;

								sinusglissandi1out.set(\outBus, outBus1, \level, 0.5);
								sinusglissandi2out.set(\outBus, outBus2, \level, 0.5);


								~modul.setsinusglissandi[x] = 1;
								~modul.sinusglissandi[x].start;

								postf("GROUP % - Output % % - Sinusglissandi - % Sekunden\n", x,
									outBus1, outBus2, time.round(1e-2));
							},

							{spielen = 3}
						);
						// ~sinusglissandi1.value(variation);


					}

				);

				spielen = ~modul.setsinusglissandi[x] + ~modul.setrauschen[x] + ~modul.setdelaysynth[x] +
				~modul.setsamplegrain[x] + ~modul.setgranulator[x];

				if (spielen < wahl.size,

					{
						gleichzeitig = rand(3);

						if (gleichzeitig > 0,
							{
								postf("Gleichzeitiger Start, Routine %\n", x);

							},{
								(time+2.0).wait;
							}
						);

					},

					{(time+2.0).wait}
				);




		}};

		granulator1out.set(\level, 0);
		granulator2out.set(\level, 0);

		~channelsOut.do { |i|
			samplegrain1out[i].set(\level, 0);
			samplegrain2out[i].set(\level, 0);
		};

		5.do { |i|
			delaysynth1out[i].set(\level, 0);
			delaysynth2out[i].set(\level, 0);
		};

		rauschen1out.set(\level, 0);
		rauschen2out.set(\level, 0);

		sinusglissandi1out.set(\level, 0);
		sinusglissandi2out.set(\level, 0);


		2.2.wait;

		granulator1out.free;
		granulator2out.free;

		~channelsOut.do { |i|
			samplegrain1out[i].free;
			samplegrain2out[i].free;
		};


		5.do { |i|
			delaysynth1out[i].free;
			delaysynth2out[i].free
		};

		rauschen1out.free;
		rauschen2out.free;

		sinusglissandi1out.free;
		sinusglissandi2out.free;
		//granulatormix.free; samplegrainmix.free; delaysynthmix.free; rauschenmix.free; sinusmix.free;

		postf("END OF PROZEDURE: %\n\n",x);

	};

	//};
};