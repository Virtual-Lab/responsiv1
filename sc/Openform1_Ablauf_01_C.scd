// -------------------------------------------------------------------------------------
//                                  Steuerung der Routinen
// -------------------------------------------------------------------------------------


~stimmen.do ({ |x|

	~set[x] = Routine({

		var wahl = ~wahl[x];
		var variation, time, einsatz;
		var repeat = (60-x).rrand(80-x);
		var gleichzeitig;

		var channels = Array.fill(~channelsOut, {|i| i});
		var maxpan = ((~channelsOut - 1) * 2) / ~channelsOut;
		var granulator1levelctr, granulator1panctr, granulator1widthctr, granulator1out, granulator2out;
		var delaysynth1levelctr, delaysynth1panctr, delaysynth1widthctr, delaysynth1out, delaysynth2out;
		var rauschen1levelctr, rauschen1panctr, rauschen1widthctr, rauschen1out, rauschen2out;
		var sinusglissandi1levelctr, sinusglissandi1panctr, sinusglissandi1widthctr, sinusglissandi1out;
		var sinusglissandi2out, samplegrain1levelctr, samplegrain1out, samplegrain2out;
		var start2, spielen;

		einsatz = (40*x).rrand(100*x);
		postf("START PROZEDURE % in % Sekunden, Repeat: %\n", x, einsatz.round(1e-1), repeat);

		einsatz.wait;

		granulator1levelctr = Synth.head(~control, "line",
			[\outBus, 150+(100*x), \start, 0, \end, 1, \time, 0.1]);

		granulator1out = Synth.head(~master, "out",
			[\outBus, 0, \inBus, 50+(2*x), \ctrincomp, 150+(100*x), \level, 1]);
		granulator2out = Synth.head(~master, "out",
			[\outBus, 1, \inBus, 51+(2*x), \ctrincomp, 150+(100*x), \level, 1]);

		samplegrain1levelctr = Synth.head(~control, "line",
			[\outBus, 190+(100*x), \start, 0, \end, 1, \time, 0.1]);

		samplegrain1out = Synth.head(~master, "out",
			[\outBus, 0, \inBus, 90+(2*x), \ctrincomp, 190+(100*x), \level, 1]);
		samplegrain2out = Synth.head(~master, "out",
			[\outBus, 1, \inBus, 91+(2*x), \ctrincomp, 190+(100*x), \level, 1]);

		delaysynth1levelctr = Synth.head(~control, "line",
			[\outBus, 160+(100*x), \start, 0, \end, 1, \time, 0.1]);

		delaysynth1out = Synth.head(~master, "out",
			[\outBus, 0, \inBus, 60+(2*x), \ctrincomp, 160+(100*x), \level, 1]);
		delaysynth2out = Synth.head(~master, "out",
			[\outBus, 1, \inBus, 61+(2*x), \ctrincomp, 160+(100*x), \level, 1]);

		rauschen1levelctr = Synth.head(~control, "line",
			[\outBus, 170+(100*x), \start, 0, \end, 1, \time, 0.1]);

		rauschen1out = Synth.head(~master, "out",
			[\outBus, 0, \inBus, 70+(2*x), \ctrincomp, 170+(100*x), \level, 1]);
		rauschen2out = Synth.head(~master, "out",
			[\outBus, 1, \inBus, 71+(2*x), \ctrincomp, 170+(100*x), \level, 1]);

		sinusglissandi1levelctr = Synth.head(~control, "line",
			[\outBus, 180+(100*x), \start, 0, \end, 1, \time, 2]);

		sinusglissandi1out = Synth.head(~master, "out",
			[\outBus, 0, \inBus, 80+(2*x), \ctrincomp, 180+(100*x), \level, 1]);
		sinusglissandi2out = Synth.head(~master, "out",
			[\outBus, 1, \inBus, 81+(2*x), \ctrincomp, 180+(100*x), \level, 1]);

		repeat.do ({

			switch(wahl.choose,

				1, {
					//var outputBus = [0, 1, 2, 3, 4].choose;


					if (~setgranulator[x] == 0,

						{
							var outBus1 = 0, outBus2 = 0;
							while({outBus1 == outBus2}, { outBus1=0.rrand(~channelsOut-1);
								outBus2=0.rrand(~channelsOut-1);});

							if (outBus1 == outBus2,
								{outBus2 = outBus1+1;
									if (outBus2 > (~channelsOut-1), {outBus2 = outBus1 - 1;})
							});
							outBus1 = outBus1 + 200;
							outBus2 = outBus2 + 200;

							variation = ~tonlaenge[x]*3.rrand(6);
							time = 0;

							~repeatgranular[x] = 1.rrand(3);
							~durationgranular[x] = Array.fill(~repeatgranular[x], {variation.choose});
							~timegranular[x] = Array.fill(~repeatgranular[x], {(~tonlaenge[x].choose)/2});
							~repeatgranular[x].do ({|i|
								time = time + ~durationgranular[x][i] + ~tonlaenge[x][i]});


							granulator1out.set(\outBus, outBus1);
							granulator2out.set(\outBus, outBus2);

							~setgranulator[x] = 1;
							~granulator[x].start;

							postf("GROUP % - Output % % – Granulartextur - % Sekunden\n", x,
								outBus1, outBus2, time.round(1e-2));


						},{}
					);


				},


				2, {
					//var outputBus = [0, 1, 2, 3, 4].choose;

					if (~setsamplegrain[x] == 0,

						{
							var outBus1 = 0, outBus2 = 0;
							while({outBus1 == outBus2}, { outBus1=0.rrand(~channelsOut-1);
								outBus2=0.rrand(~channelsOut-1);});

							if (outBus1 == outBus2,
								{outBus2 = outBus1+1;
									if (outBus2 > (~channelsOut-1), {outBus2 = outBus1 - 1;})
							});
							outBus1 = outBus1 + 240;
							outBus2 = outBus2 + 240;
							variation = ~tonlaenge[x]*3.rrand(6);
							time = 0;

							~repeatsamplegrain[x] = 2.rrand(6);
							~durationsamplegrain[x] = Array.fill(~repeatsamplegrain[x],
								{variation.choose});
							~timesamplegrain[x] = Array.fill(~repeatsamplegrain[x],
								{(~tonlaenge[x].choose)/2});
							~repeatsamplegrain[x].do ({|i|
								time = time + ~durationsamplegrain[x][i] + ~timesamplegrain[x][i]});

							samplegrain1out.set(\outBus, outBus1);
							samplegrain2out.set(\outBus, outBus2);


							~setsamplegrain[x] = 1;
							~samplegrain[x].start;

							postf("GROUP % - Output % % – Granularsample - % Sekunden\n", x,
								outBus1, outBus2, time.round(1e-2));


						},{}
					);


				},

				3, {
					//var outputBus= [0, 1, 2, 3, 4].choose;



					if (~setdelaysynth[x] == 0,

						{
							var outBus1 = 0, outBus2 = 0;
							while({outBus1 == outBus2}, { outBus1=0.rrand(~channelsOut-1);
								outBus2=0.rrand(~channelsOut-1);});

							if (outBus1 == outBus2,
								{outBus2 = outBus1+1;
									if (outBus2 > (~channelsOut-1), {outBus2 = outBus1 - 1;})
							});
							outBus1 = outBus1 + 210;
							outBus2 = outBus2 + 210;

							variation = ~tonlaenge[x]*3.rrand(6);
							time = 0;

							~repeatdelaysynth[x] = 2.rrand(6);
							//~tonfolgedelaysynth[x]=Array.fill(~repeatdelaysynth, {Rand(1,3)});

							~durationdelaysynth[x] = Array.fill(~repeatdelaysynth[x],
								{(variation).choose});

							~timedelaysynth[x] = Array.fill(~repeatdelaysynth[x],
								{(~tonlaenge[x].choose)/2});

							~repeatdelaysynth[x].do ({|i|
								time = time + ~durationdelaysynth[x][i] + ~timedelaysynth[x][i]});

							delaysynth1out.set(\outBus, outBus1);
							delaysynth2out.set(\outBus, outBus2);

							~setdelaysynth[x] = 1;
							~glockensynth[x].start;


							postf("GROUP % - Output % % – Glockensynth - % Sekunden\n", x,
								outBus1, outBus2, time.round(1e-2));

						}, {}
					);

				},


				4, {

					//var outputBus = [0, 1, 2, 3, 4].choose;

					if (~setrauschen[x] == 0,

						{
							var outBus1 = 0, outBus2 = 0;
							while({outBus1 == outBus2}, { outBus1=0.rrand(~channelsOut-1);
								outBus2=0.rrand(~channelsOut-1);});

							if (outBus1 == outBus2,
								{outBus2 = outBus1+1;
									if (outBus2 > (~channelsOut-1), {outBus2 = outBus1 - 1;})
							});
							outBus1 = outBus1 + 220;
							outBus2 = outBus2 + 220;

							variation = ~tonlaenge[x];
							time = 0;

							~repeatrauschen[x] = 1.rrand(4);

							~tonfolgerauschen[x]=Array.fill(~repeatrauschen[x], {1.rrand(4)});

							~durationrauschen[x]=Array.fill(~repeatrauschen[x],
								(~tonlaenge[x].choose)/2);

							~timerauschen[x]= Array.fill(~repeatrauschen[x], { |irepeat|
								Array.fill(~tonfolgerauschen[x][irepeat],
									{variation.choose})});


							~repeatrauschen[x].do ({|irepeat|

								time = time + ~durationrauschen[x][irepeat];
								~tonfolgerauschen[x][irepeat].do ({ |i|
									time = time + ~timerauschen[x][irepeat][i];
								});
							});

							~sequenzdauerrauschen[x] = time;
							~setrauschen[x] = 1;
							~windrauschen[x].start;

							rauschen1out.set(\outBus, outBus1);
							rauschen2out.set(\outBus, outBus2);

							postf("GROUP % - Output % % – Rauschen - % Sekunden\n", x,
								outBus1, outBus2, time.round(1e-2));

						},

						{

						}
					);


				},


				5, {
					//var outputBus= [0, 1, 2, 3, 4, 5].choose;

					if (~setsinusglissandi[x] == 0,

						{
							var outBus1 = 0, outBus2 = 0;
							while({outBus1 == outBus2}, { outBus1=0.rrand(~channelsOut-1);
								outBus2=0.rrand(~channelsOut-1);});

							if (outBus1 == outBus2,
								{outBus2 = outBus1+1;
									if (outBus2 > (~channelsOut-1), {outBus2 = outBus1 - 1;})
							});
							outBus1 = outBus1 + 230;
							outBus2 = outBus2 + 230;

							variation = ~tonlaenge[x];
							time = 0;

							~repeatsinusglissandi[x] = 2.rrand(4);
							~durationsinusglissandi[x] = Array.fill(~repeatsinusglissandi[x],
								{(~tonlaenge[x].choose)/2});

							~tonfolgesinusglissandi[x] = Array.fill(~repeatsinusglissandi[x],
								{1.rrand(4)});

							~timesinusglissandi[x]= Array.fill(~repeatsinusglissandi[x],
								{ |irepeat| Array.fill(~tonfolgesinusglissandi[x][irepeat],
									{variation.choose})});


							~repeatsinusglissandi[x].do ({|irepeat|
								time = time + ~durationsinusglissandi[x][irepeat];
								~tonfolgesinusglissandi[x][irepeat].do ({ |i|
									time = time + ~timesinusglissandi[x][irepeat][i]
								});
							});

							~sequenzdauersinusglissandi[x] = time;

							sinusglissandi1out.set(\outBus, outBus1);
							sinusglissandi2out.set(\outBus, outBus2);

							~setsinusglissandi[x] = 1;
							~sinusglissandi[x].start;

							postf("GROUP % - Output % % - Sinusglissandi - % Sekunden\n", x,
								outBus1, outBus2, time.round(1e-2));
						},

						{

						}
					);
					// ~sinusglissandi1.value(variation);


				}

			);

			spielen = ~setsinusglissandi[x] + ~setrauschen[x] + ~setdelaysynth[x] +
			~setsamplegrain[x] + ~setgranulator[x];

			if (spielen < wahl.size,

				{
					gleichzeitig = 0.rrand(3);

					if (gleichzeitig == 3,
						{
							postf("Gleichzeitiger Start, Routine %\n", x);

						},{
							(time+2.0).wait;
						}
					);

				},

				{(time+2.0).wait}
			);




		});

		granulator1levelctr = Synth.head(~control, "line",
			[\outBus, 150+(100*x), \start, 1, \end, 0, \time, 2]);

		delaysynth1levelctr = Synth.head(~control, "line",
			[\outBus, 160+(100*x), \start, 1, \end, 0, \time, 2]);

		rauschen1levelctr = Synth.head(~control, "line",
			[\outBus, 170+(100*x), \start, 1, \end, 0, \time, 2]);

		sinusglissandi1levelctr = Synth.head(~control, "line",
			[\outBus, 180+(100*x), \start, 1, \end, 0, \time, 2]);

		samplegrain1levelctr = Synth.head(~control, "line",
			[\outBus, 190+(100*x), \start, 1, \end, 0, \time, 2]);


		2.2.wait;

		granulator1out.free;
		delaysynth1out.free;
		rauschen1out.free;
		sinusglissandi1out.free;
		samplegrain1out.free;

		granulator2out.free;
		delaysynth2out.free;
		rauschen2out.free;
		sinusglissandi2out.free;
		samplegrain2out.free;

		postf("END OF PROZEDURE: %\n\n",x);

	});
});