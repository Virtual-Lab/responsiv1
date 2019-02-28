// -------------------------------------------------------------------------------------
//                                 5 Soundmodelle
// -------------------------------------------------------------------------------------

~stimmen.do ({ |x|

	// ----------------------------  Synth Granulator Task ---------------------------------

	~granulator[x] = Task ({ //|variation|

		var timescale, tmin, tmax, time, duration;
		var modus, tonlaenge;
		var freq, interv, freqmin, freqmax, freqbereich;
		var volume1, volume2;
		var repeat, pause;
		var volctr5, effect1, effect2, volctreffect, grain1, grain2; // Synths und Controlsignale

		repeat = ~repeatgranular[x];
		modus = ~modus[x]/2;
		tonlaenge = ~tonlaenge[x];

		// init Volumencontrol
		volctr5 = Synth.head(~control, "line", [\outBus, 101+(100*x), \start, 0, \end, 0.6, \time, 1]);

		// Effekt: Reverb
		// arg outBus, inBus, buffer, delaymin, delaymax, decaytime = 0.2, volume = 1;

		effect1 = Synth.head(~effect, "reverb1",
			[\outBus, 50+(2*x), \inBus, 100 + (2*x), \ctrinvolume, 102+(100*x)]);
		effect2 = Synth.head(~effect, "reverb1",
			[\outBus, 51+(2*x),  \inBus, 101 + (2*x), \ctrinvolume, 102+(100*x)]);

		// Figuren -schleife
		repeat.do({|irepeat|

			var mix, room, damp;
			var tonfolge;
			var relation = tonlaenge / tonlaenge[(tonlaenge.size-1)];
			var length = relation.size;
			var divisor = 0;
			var sustain = linrand(0.5)+ 0.005;
			var atack = linrand(0.2).max(0.05);
			var level = 0.4.rrand(0.8), decay = 0.01.rrand(0.2), release = 0.05.rrand(0.2);
			var obertoene = 1.rrand(8);
			var zeitpunkt = 0, vergangenezeit = 0, index = -1, prop = 0;
			var version = 1.rrand(3), gliss = 1.rrand(2);

			duration = ~durationgranular[x][irepeat];
			tonfolge = ((20*duration).rrand(50*duration)).round(1e-0);
			pause = ~timegranular[x][irepeat];

			timescale = 0.8.rrand(1.2);
			freqmin = modus.choose/2;
			freqbereich = Array.fill(1.rrand(7), {|i| ~ausgangsfreq*i});
			interv = 0.2.rrand(10);

			volume1 = 0.2.rand;
			volume2 = 0.2 - volume1;

			length.do ({ |counter|
				divisor = divisor + relation[counter];
			});

			divisor = divisor/length;

			tmin = [(duration/tonfolge)*(divisor), duration/tonfolge/(divisor/2)].choose;

			/*postf("Schleife %, Repeat: %, Tonfolge: %, Duration: % Mintime: %\n",
			x, irepeat, tonfolge, duration, tmin.round(1e-2));*/

			// Effekt: Reverb

			mix = 0.5.rrand(1.0);
			room = 0.1.rand(1.0);
			damp = 0.1.rrand(1.0);

			effect1 = Synth.head(~effect, "reverb1",
				[\outBus, 50+(2*x), \inBus, 100 + (2*x), \ctrinvolume, 102+(100*x),
					\mix, mix, \room, room, \damp, damp]);
			effect2 = Synth.head(~effect, "reverb1",
				[\outBus, 51+(2*x),  \inBus, 101 + (2*x), \ctrinvolume, 102+(100*x),
					\mix, mix, \room, room, \damp, damp]);

			volctreffect = Synth.head(~control, "line",
				[\outBus, 102+(100*x), \start, 0, \end, 1, \time, 0.2]);

			zeitpunkt = thisThread.beats;

			while( {vergangenezeit < duration}, {

				index = index + 1;
				if (index >= tonfolge,
					{prop = 1 - ((index%tonfolge)/tonfolge)},
					{prop = (index%tonfolge)/tonfolge});

				time = (tmin * relation.choose).max(0.1).min(1);
				//time = tmin.rrand(tmax);

				// Set Timescale
				timescale = (timescale + linrand((0.02*1.rand2))).max(0.1);

				switch(version,
					1, {},
					// freqmin = (freqmin + (~ausgangsfreq*1.rand2)).max(~ausgangsfreq*2).min(~ausgangsfreq*16)},

					2, { if (gliss == 1,
						{freqmin = freqmin + 0.01},
						{freqmin = freqmin - 0.01}
					)},
					3, { var aufab = [1, 2].wchoose([0.4, 0.6]);
						var ausschuss;

						if (aufab == 1,
							{
								if (freqbereich.size < 10, {
									freqbereich = freqbereich.add(
										(~ausgangsfreq*freqbereich.size).min(~ausgangsfreq*16))},{})
							},
							{
								if (freqbereich.size > 1,
									{ausschuss = freqbereich.take(freqbereich.choose)},
									{});
							}
						);
					},

				);

				// Set Frequenzbereich
				freqmax = freqbereich.choose;
				freq = freqmin + freqmax;

				volume1 = (volume1+exprand(0.05.rand2, 0.01)).max(0.04).min(0.2);
				volume2 = (volume2+exprand(0.05.rand2, 0.01)).max(0.04).min(0.2);

				// set sustain
				sustain = (sustain + linrand((0.01.rand2)+0.004)).max(0.01).min(0.4);
				decay = (decay + (0.02.rand2)).min(0.4).max(0.01);
				level = (level + (0.002.rand2)).min(0.8).max(0.2);
				release = (release + (0.02.rand2)).min(0.4).max(0.01);
				obertoene = (obertoene + 0.1.rand2).max(1).min(8);

				// [0, 1, level, level, 0], [atack, decay, sustain, release], curve),

				// Grain wird ausgegeben
				grain1 = Synth.head(~grains, "GrainSynth1",
					[\outBus, 100+(2*x), \ctrin2, 101+(100*x),
						\freq, freq+4.rand2, \ts, timescale,
						\volume, volume1, \atack, atack,
						\level, level, \decay, decay, \release, release, \sustain, sustain]);

				grain2 = Synth.head(~grains, "GrainSynth1",
					[\outBus, 101+(2*x), \ctrin2, 101+(100*x),
						\freq, freq+4.rand2+interv, \ts, timescale,
						\volume, volume2, \level, level,
						\atack, atack, \decay, decay, \release, release, \sustain, sustain]);


				// Send OSC Message ......
				~oscsend.sendMsg("/dodec", 0, sustain/0.4, freq);

				// berechneter Zeit-Wert
				time.wait;

				vergangenezeit = thisThread.beats - zeitpunkt;
			});

			volctreffect = Synth.head(~control, "line",
				[\outBus, 102+(100*x), \start, 1, \end, 0, \time, pause]);

			pause.wait;

			effect1.free;
			effect2.free;
		});

		Synth.head(~control, "line", [\outBus, 101+(100*x), \start, 0.6, \end, 0, \time, 1]);

		2.wait;


		~setgranulator[x] = 0;

	});

	// ------------------------------  File Granulator Task ------------------------------

	~samplegrain[x] = Task ({ //|variation|

		var tmin, tmax, time, scale, duration, volume;
		var modus, tonlaenge, rhythm;
		var fileauswahl, grainfile, file;
		var repeat, pause, version;
		var volctr, sustainctr, effect, volctreffect, samplegrain; // Synths und Controlsignale

		// Set globale Rhythmus und Tonhöhen-Reihen für Task[x]
		repeat = ~repeatsamplegrain[x];
		modus = ~modus[x]/2;
		tonlaenge = ~tonlaenge[x];
		rhythm = ~tonlaenge[x];
		version = 1.rrand(4);

		// init Frequenzcontrolsignal und Volumencontrol
		volctr = Synth.head(~control, "line", [\outBus, 141+(100*x), \start, 0, \end, 1, \time, 0.1]);

		if (version == 1, {fileauswahl = 0.rrand(3)},
			{fileauswahl = 4.rrand(~setfile-1)});

		file = Array.newClear(~setfile);
		/* file[0] = ~folder +/+ "/baby1_einzeln1.aif";
		file[1] = ~folder +/+ "/baby2_einzeln1.aif";
		file[2] = ~folder +/+ "/baby6_einzeln1.aif";
		file[3] = ~folder +/+ "/baby6_einzeln2.aif";*/
		file[0] = ~folder +/+ "/gong_noise1.wav";
		file[1] = ~folder +/+ "/gong_light2.wav";
		file[2] = ~folder +/+ "/gong_quietschen1.wav";
		file[3] = ~folder +/+ "/gong_quietschen2.wav";
		file[4] = ~folder +/+ "/gong_rubber1.wav";
		file[5] = ~folder +/+ "/gong_light-vibrato1.wav";


		grainfile = Buffer.read(s, file[fileauswahl]); //file[fileauswahl];
		postf("Fileauswahl: %\nVersion: %\n", file[fileauswahl], version);

		// Effekt: Reverb1: outBus = 0, inBus = 0, mix = 0.33, room = 0.5, damp = 0.5, volume = 1;
		// Effekt: Reverb2: outBus, inBus, buffer, delaymin, delaymax, decaytime = 0.2, volume = 1;


		// Figuren -schleife
		repeat.do({|irepeat|

			var tonfolge, relation, length, divisor = 0;
			var sustain, pan, samplebereich, sampleoffset;
			var volumemax, timescale, rate, random;
			var delaymin, delaymax, decaytime, buffer;
			var index = 0, zeitpunkt = 0, vergangenezeit = 0;
			var effectvol = 1;

			// Set Duration und Anzahl der Grains
			relation = tonlaenge / tonlaenge[(tonlaenge.size-1)];
			duration = ~durationsamplegrain[x][irepeat];
			tonfolge = ((20*duration).rrand(50*duration)).round(1e-0);

			// Set minimale Grainlänge
			length = relation.size;
			length.do ({ |counter|
				divisor = divisor + relation[counter];
			}); divisor = divisor/length;

			tmin = (duration/tonfolge)*exprand(0.8,5);
			pause = ~timesamplegrain[x][irepeat];

			// Set Grain-arguments
			timescale = 0.5.rrand(1.5);
			samplebereich = 0.5.rrand(1.0);
			sampleoffset = (1.0 - samplebereich).rand;
			volumemax = 0.35.rrand(0.7);
			sustain = [0.05, 0.1, 0.2, 0.4].choose;
			pan = 1.0.rand2;
			rate = [0.1, 0.2, 0.5 ,1, 5].wchoose([0.1, 0.2, 0.2, 0.3, 0.2]);
			random = 0.005.rrand(0.01);

			delaymin = 0.1.rand;
			delaymax = (delaymin+0.01).rrand(0.5);
			decaytime = 0.05.rrand(1.0);
			buffer = delaymax+decaytime;

			effect = Synth.head(~effect, "reverb2",
				[\outBus, 90+(2*x), \inBus, 140 + (2*x), \ctrinvolume, 142 + (100*x),
					\buffer, buffer, \delaymin, delaymin, \delaymax, delaymax, \decaytime, decaytime]);

			/*volctreffect = Synth.head(~control, "line",
			[\outBus, 142+(100*x), \start, 0, \end, effectvol, \time, 0.5]);*/

			volctr = Synth.head(~control, "line",
				[\outBus, 141+(100*x), \start, 0, \end, 1, \time, 0.5]);

			zeitpunkt = thisThread.beats;

			// postf("Durchgang: %, Dauer: %, zeitpunkt%\n", irepeat, duration, zeitpunkt);

			while( {vergangenezeit <= duration}, {

				var timestart, timeend, timearea, time, prop;

				index = index + 1;
				if (index >= tonfolge,
					{
						prop = samplebereich - ((index%tonfolge)/tonfolge);
					},
					{
						prop = ((index%tonfolge)/tonfolge)* samplebereich;

				});

				random = (random + 0.001.rand2).max(0).min(1 - prop*0.9);
				timestart = prop*0.9 + sampleoffset;
				timeend = prop*0.9 + random + sampleoffset;

				time = (tmin + 0.01.rand2).max(0.05).min(0.3);
				pan = (pan + ((0.2.rand).rand2)).max(-1.0).min(1.0);
				sustain = (sustain + (linrand(0.01)-0.002)).max(0.01).min(0.3);

				volume = exprand(volumemax, (volumemax/2));

				// {volume = (volumemax*1.5)/index},
				// {volume = volumemax*(1-(index+1).reciprocal)},

				switch(version,
					2, {rate = rate + 0.0025.rand},
					3, {rate = rate - 0.0025.rand}
				);

				samplegrain = Synth.head(~grains, "Samplegrain",
					[\outBus, 140+(x*2), \ctrinsustain, 140 +(x*100), \ctrinvolume, 141 +(x*100),
						\bufnum, grainfile.bufnum, \startPos, rrand(timestart,timeend),
						\volume, volume, \pan, pan, \sustain, sustain, \rate, rate]);

				// Send OSC - Messages
				/*~oscsend.sendMsg("/test", 0, (sustain*600).asInt, );*/
				~oscsend.sendMsg("/dodec", 1, sustain/0.3, pan);

				time.wait;


				vergangenezeit = thisThread.beats - zeitpunkt;

			});
			//
			// volctreffect = Synth.head(~control, "line",
			// [\outBus, 142+(100*x), \start, effectvol, \end, 0, \time, pause]);

			volctr = Synth.head(~control, "line",
				[\outBus, 141+(100*x), \start, 1, \end, 0, \time, pause]);

			// effect.set(\volume, 0, \fadeout, pause);

			// postf("Ende Durchgang: %, Schleife: %\n", irepeat, x);

			pause.wait;

		});


		2.wait;
		effect.free;
		~setsamplegrain[x] = 0;
		grainfile.free;

	});


	// ---------------------------- Sinus Synth + Delay - Routine ------------------------------

	~glockensynth[x] = Task ({ //|variation|

		var time, freq1, freq2, modus, rhythm, tonlaenge, volume1, volume2, repeat;
		var effect1, effect2, effect3, volctreffect, delaysynth1, delaysynth2, delaysynthenv;
		var variation = 1.rrand(2);

		postf("variation: %\n", variation);

		// Wiederholungen
		repeat = ~repeatdelaysynth[x];

		// Rythmus und Frequenzen [0.1, 0.15, 0.2, 0.3, 1, 4, 8];
		rhythm = ~tonlaenge[x] / 2;
		modus = ~modus[x] * 2;
		tonlaenge = ~tonlaenge[x];

		// Variation bestimmen

		if (variation == 1,
			{
				// Effect: Delay
				effect1 = Synth.head(~effect, "delay1",
					[\inBus, 110+(2*x), \outBus, 60+(2*x), \ctrinvolume, 112 + (100*x),
						\delayfreq, 0.4, \delaytime, 1]);
				effect2 = Synth.head(~effect, "delay1",
					[\inBus, 111+(2*x), \outBus, 61+(2*x), \ctrinvolume, 112 + (100*x),
						\delayfreq, 0.4+0.1, \delaytime, 1]);
			},{

				// Effekt: Reverb2: outBus, inBus, buffer, delaymin,
				// delaymax, decaytime = 0.2, volume = 1;

				effect3 = Synth.head(~effect, "reverb2",
					[\inBus, 110 + (2*x), \outBus, 60+(2*x), \ctrinvolume, 112 + (100*x),
						\buffer, 0.3, \delaymin, 0.01, \delaymax, 0.2, \decaytime, 0.5]);

				modus = ~modus[x]/2;
		});

		// 2 Schleifen ineinander verschachtelt
		// 1. Schleife initiert die Sequenz

		repeat.do({ |irepeat|

			var delayfreq, delays, delaytime;
			var randmin, randmax, interv;
			var relation, length, divisor, tmin;
			var duration, tonfolge, pause;
			var atac, rel, reltime, sustime, dectime;
			var zeitpunkt = 0, vergangenezeit = 0, index = 0;

			// Set Zeitdauern
			relation = tonlaenge / tonlaenge[(tonlaenge.size-1)];
			length = relation.size;
			divisor = 0;

			// Set Mindestdauer
			length.do ({ |counter|
				divisor = divisor + relation[counter];
			});

			divisor = divisor/length;

			duration = ~durationdelaysynth[x][irepeat];
			tonfolge = (4*duration.rrand(10*duration)).round(1e-0);
			pause = ~timedelaysynth[x][irepeat];

			// Set Mindestdauer
			tmin = duration/(tonfolge/divisor);

			if (variation == 1, {

				var var12 = 1.rrand(3);

				if (var12 == 1,
					{
						delayfreq = rhythm.choose / (1.rrand(4));
						delays = 10.rand;
						delaytime = delayfreq * delays;
					}, {
						delayfreq = tonlaenge.choose;
						delays = 3.rrand(8);
						delaytime = delayfreq * delays;

						tonfolge = (2*duration.rrand(4*duration)).round(1e-0);
						tmin = duration/(tonfolge/divisor);
				});

				// Set Synth
				randmin = 0.99.rrand(1);
				randmax = 1.rrand(1.001);
				interv = 1.rrand(10);

				// Envelope setzten
				atac = 0.005.rrand(0.01);
				rel = 0.4.rrand(0.8);
				reltime = 0.01.rrand(0.1);
				sustime = 0.05.rrand(0.2);
				dectime = 0.1.rrand(0.2);

				// Set Delaysynth
				effect1.set(\delayfreq, delayfreq, \delaytime, delaytime, \repeat, delays);
				effect2.set(\delayfreq, delayfreq+rand2(delayfreq/4),
					\delaytime, delaytime+rand2 (delayfreq/4), \repeat, delays);

				},{

					var buffer, delaymin, delaymax, decaytime;

					tonfolge = (1*duration.rrand(3*duration)).round(1e-0);
					tmin = duration/(tonfolge/divisor);

					// Set Delays
					delaymin = 0.01.rrand(0.15);
					delaymax = delaymin.rrand(0.4)+0.1;
					decaytime = 0.1.rrand(0.5);
					buffer = delaymax + decaytime;

					// Set Synth
					randmin = 0.999.rrand(1);
					randmax = 1.rrand(1.0001);
					interv = 1.0.rrand(2.0);

					// Envelope setzten
					atac = 0.1.rrand(2.0);
					rel = 0.5.rrand(0.8);
					reltime = 0.2.rrand(0.8);
					sustime = 0.2.rrand(0.8);
					dectime = 0.3.rrand(0.8);

					// Effekt: buffer, delaymin, delaymax, decaytime = 0.2, volume = 1;
					effect3.set(\buffer, buffer, \delaymin, delaymin,
						\delaymax, delaymax, \decaytime, decaytime);
				}
			);

			// 2. Schleife mit einer tonfolge
			// postf("Schleife: %, Repeat: %, Duration: %\n", x, irepeat, duration.round(1e-2));

			volctreffect = Synth.head(~control, "line",
				[\outBus, 112+(100*x), \start, 0, \end, 1, \time, 0.001]);

			// Zeitpunkt festhalten und abspeichern
			zeitpunkt = thisThread.beats;

			while( {vergangenezeit < duration}, {

				freq1 = modus.choose;
				freq2 = freq1+interv;
				time = tmin * relation.choose;

				volume1 = 0.01.rrand(0.15);
				volume2 = 0.15 - volume1;

				// arg outBus = 3, ts = 1, atactime = 0.01, rel= 0.8, reltime = 0.5,
				// sus = 0.8, sustime = 2, dectime = 0.5;

				delaysynth1 = Synth.head(~synths, "Synth2",
					[\outBus, 110 +(2*x), \ctrin1, 110+(100*x), \ctrin2, 111+(100*x),
						\randmin, randmin, \randmax, randmax, \volume, volume1, \freq, freq1,
						\atactime, atac, \rel, rel, \reltime, reltime, \sustime, sustime, \dectime, dectime]);

				delaysynth2 = Synth.head(~synths, "Synth2",
					[\outBus, 111 +(2*x), \ctrin1, 110+(100*x), \ctrin2, 111+(100*x),
						\randmin, randmin, \randmax, randmax, \volume, volume2, \freq, freq2,
						\rel, rel, \reltime, reltime, \sustime, sustime, \dectime, dectime]);

				time.wait;

				vergangenezeit = thisThread.beats - zeitpunkt;

			});

			// Ende 1. Schleife - Pause mit zufälligen Wert zwischen 1 und 10

			volctreffect = Synth.head(~control, "line",
				[\outBus, 112+(100*x), \start, 1, \end, 0, \time, pause]);

			pause.wait;

			/*delaysynth1.free;
			delaysynth2.free;*/

		});

		// Synthdefinitionen werden aufgehoben
		2.wait;
		if (variation == 1,
			{effect1.free; effect2.free;},
			{effect3.free});

		~setdelaysynth[x] = 0;

	});


	// ---------------------------- Rauschgeneratoren - Task ------------------------------

	~windrauschen[x] = Task ({ // |variation|

		var time, freq1, freq2, volume1, volume2, bwr, oldbwr, puls1, puls2;
		var modus, rhythm, repeat, sequenzdauer;
		var rauschen1, rauschen2, reverbrauschen1;
		var volctrrauschen1, volctrrauschen2, volctrrauschen3, volctrrauschen4;
		var bwrctrrauschen1, bwrctrrauschen2, freqctrrauschen1, freqctrrauschen2;

		volume1 = 1;
		volume2 = 1;

		modus = ~modus[x];
		rhythm = ~tonlaenge[x]/4;
		repeat = ~repeatrauschen[x];
		sequenzdauer = ~sequenzdauerrauschen[x];
		freq1 = modus.choose;
		freq2 = freq1 + 10.rand;

		volctrrauschen1 = Synth.head(~control, "line",
			[\outBus, 121+(100*x), \start, 0, \end, 1, \time, 2]);

		volctrrauschen2 = Synth.head(~control, "line",
			[\outBus, 124+(100*x), \start, 0, \end, 1, \time, 2]);

		rauschen1 = Synth.head(~synths, "Synth3",
			[\outBus, 70 +(2*x), \ctrin1, 120+(100*x), \ctrin2, 121+(100*x), \ctrin3, 122+(100*x), \freq, volume1, \volume, 1, \bwr, 0.2]);
		rauschen2 = Synth.head(~synths, "Synth3",
			[\outBus, 71 +(2*x), \ctrin1, 123+(100*x), \ctrin2, 124+(100*x), \ctrin3, 125+(100*x), \freq, volume2, \volume, 1, \bwr, 0.2]);

		oldbwr = 0.2.rrand(0.5);

		bwr = 0.2.rrand(0.5);
		/*sequenzdauer = rauschfolge.do ({|i|
		sequenzdauer = sequenzdauer + ~timerauschen[x][irepeat][i]});*/

		bwrctrrauschen1 = Synth.head(~control, "line",
			[\outBus, 122+(100*x), \start, oldbwr, \end, bwr, \time, sequenzdauer]);
		bwrctrrauschen2 = Synth.head(~control, "line",
			[\outBus, 125+(100*x), \start, oldbwr, \end, bwr, \time, sequenzdauer]);


		/*volctrrauschen3 = Synth.head(~control, "dust",
		[\out, 21, \volume, 1, \add, 0.5, \density, 5.3]);
		volctrrauschen4 = Synth.head(~control, "dust",
		[\out, 24, \volume, 1, \add, 0.5, \density, 5.4]);*/

		/*volctrrauschen1 = Synth.head(~control, "lownoise0",
		[\outBus, 121+(100*x), \minval, 0.9, \maxval, 1.1]);

		volctrrauschen2 = Synth.head(~control, "lownoise0",
		[\outBus, 124+(100*x), \minval, 0.9, \maxval, 1.1]);*/


		repeat.do({ |irepeat|

			var rauschfolge;
			var density1, density2;
			var oldfreq1, oldfreq2;
			var oldvolume1, oldvolume2;
			var pause, repeatdauer = 0;

			rauschfolge = ~tonfolgerauschen[x][irepeat];
			rauschfolge.do({ |i| repeatdauer = repeatdauer + ~timerauschen[x][irepeat][i]});
			repeatdauer = repeatdauer + ~durationrauschen[x][irepeat];

			// Rauschgeneratoren werden gesetzt
			// Set Volumen
			//~fader10 = MIDIFunc.cc( {arg ...args; ampl = ((args[0] / 127) * 5)}, 13);
			oldvolume1 = volume1;
			oldvolume2 = volume2;
			volume1 = 1.0.rrand(2.0);
			volume2 = 2.0 - volume1;
			//postf("Schleife spielt % mal", repeat);

			volctrrauschen1 = Synth.head(~control, "line",
				[\outBus, 121+(100*x), \start, oldvolume1, \end, volume1, \time, repeatdauer]);

			volctrrauschen2 = Synth.head(~control, "line",
				[\outBus, 124+(100*x), \start, oldvolume2, \end, volume2, \time, repeatdauer]);

			// rauschen1.set(\volume, volume1, \fade, 2.0);
			// rauschen2.set(\volume, volume2, \fade, 2.0);

			// Freqenzcontrol (Dust Noise- Generator)6
			/*density1 = 1.0.rrand(20);
			density2 = density1+ 1.0.rrand(5.0);

			volctrrauschen3.set(\density, density1);
			volctrrauschen4.set(\density, density2);*/

			/*puls1 = rhythm.choose;
			puls2 = puls1 + 2.0.rand;*/

			// volctrrauschen3.set(\puls, (1/puls1), \lag, (puls1-0.1));
			// volctrrauschen4.set(\puls, (1/puls2), \lag, (puls2-0.1));

			pause = ~durationrauschen[x][irepeat];

			rauschfolge.do({ |index|

				time = ~timerauschen[x][irepeat][index];
				//postf("Time: %",time);

				oldfreq1 = freq1;
				oldfreq2 = freq2;
				freq1 = modus.choose;
				freq2 = freq1 + 0.05.rand;

				freqctrrauschen1 = Synth.head(~control, "line",
					[\outBus, 120+(100*x), \start, oldfreq1, \end, freq1, \time, time-0.1, \lag, 0.1]);
				freqctrrauschen2 = Synth.head(~control, "line",
					[\outBus, 123+(100*x), \start, oldfreq2, \end, freq2, \time, time-0.1, \lag, 0.1]);

				time.wait;

			});

			pause.wait;

		});
		volctrrauschen1 = Synth.head(~control, "line",
			[\outBus, 121+(100*x), \start, volume1, \end, 0, \time, 1.8]);

		volctrrauschen2 = Synth.head(~control, "line",
			[\outBus, 124+(100*x), \start, volume2, \end, 0, \time, 1.8]);

		2.wait;

		// Die Synthdefinitionen werden aufgehoben
		rauschen1.free;
		rauschen2.free;

		/*volctrrauschen3.free;
		volctrrauschen4.free;*/
		~setrauschen[x] = 0;
	});

	// Routinen, Prozeduren
	// Sinusgenerator mit Ringmodulator und Glissandifrequenzen

	~sinusglissandi[x] = Task ({ //|variation|

		var tonfolge, repeat, ampl, modfreqmin, modfreqmax, anzahl;

		var time, freq1, freq2, oldfreq1, oldfreq2, modfreq, oldmodfreq;
		var	volume1, volume2, oldvolume1, oldvolume2, modvol, oldmodvol;
		var langersynth1, langersynth2, freqmod1, freqmod2, modus, rhythm, duration;
		var ctrvollangersynth1, ctrvollangersynth2, ctrfreqlangersynth1, ctrfreqlangersynth2;
		var ctrfreqmod, ctrvolmod;

		var volout1, volout2, freqout1, freqout2, modvolout, modfreqout;
		var version = 1.rrand(2);

		postf("Variation: %\n", version);

		ampl = 1;
		anzahl = 10.rand;
		repeat = ~repeatsinusglissandi[x];
		modus = ~modus[x];
		rhythm = ~tonlaenge[x];

		freq1 = modus.choose;
		freq2 = freq1 + 20.rand;
		volume1 = 1;
		volume2 = 1;

		modvol = 0.25.rrand(1.5);
		modfreqmin = 500.rand;
		modfreqmax = modfreqmin + 500.rand;

		modfreq = modfreqmin.rrand(modfreqmax);

		// Initialisierung von Synth und Modulationseffekt

		/*langersynth1 = Synth.head(~synths, "Synth1",
		[\outBus, 110+(2*x), \ctrin1, 130+(100*x), \ctrin2, 131+(100*x),\freq, 1, \volume, ampl]);
		langersynth2 = Synth.head(~synths, "Synth1",
		[\outBus, 111+(2*x), \ctrin1, 132+(100*x), \ctrin2, 133+(100*x), \freq, 1, \volume, ampl]);*/
		langersynth1 = Array.newClear(anzahl);
		langersynth2 = Array.newClear(anzahl);

		anzahl.do({ |index|

			var teilton = 0.5 * ((index+1)*10/9).rrand(index+1);
			var teiltonvol = (0.5 / anzahl) / (index+1);

			langersynth1[index] = Synth.head(~synths, "Synth1",
				[\outBus, 130+(2*x), \ctrin1, 130+(100*x), \ctrin2, 131+(100*x), \freq, teilton, \volume, teiltonvol]);
			langersynth2[index] = Synth.head(~synths, "Synth1",
				[\outBus, 131+(2*x), \ctrin1, 132+(100*x), \ctrin2, 133+(100*x), \freq, teilton, \volume, teiltonvol]);

		});

		freqmod1 = Synth.head(~effect, "amplmod",
			[\inBus, 130+(2*x), \outBus, 80+(2*x), \freq, 1, \volume, 0.5, \ctrin1, 134+(100*x), \ctrin2, 135+(100*x)]);
		freqmod2 = Synth.head(~effect, "amplmod",
			[\inBus, 131+(2*x), \outBus, 81+(2*x), \freq, 1, \volume, 0.5, \ctrin1, 135+(100*x), \ctrin2, 135+(100*x)]);

		ctrvollangersynth1 = Synth.head(~control, "line",
			[\outBus, 131+(100*x), \start, 0, \end, 1, \time, 2, \lag, 0]);

		ctrvollangersynth2 = Synth.head(~control, "line",
			[\outBus, 133+(100*x), \start, 0, \end, 1, \time, 2, \lag, 0]);

		if (version == 1, {

			1.do ({ |index|

				var repeatdauer = (~sequenzdauersinusglissandi[x]);

				// neue Frequenz setzen
				oldfreq1 = freq1;
				oldfreq2 = freq2;
				freq1 = modus.choose;
				freq2 = freq1 + 20.rand;

				// neue Volumen setzen
				oldvolume1 = volume1;
				oldvolume2 = volume2;
				volume1 = 0.2.rrand(1.0);
				volume2 = 1 - volume1;

				// neue Modulationsfrequenz und Volumen setzen
				oldmodfreq = modfreq;
				modfreq = modfreqmin.rrand(modfreqmax);
				oldmodvol = modvol;
				modvol = 0.5.rrand(1.5);

				ctrvollangersynth1 = Synth.head(~control, "line",
					[\outBus, 131+(100*x), \start, oldvolume1, \end, volume1, \time, repeatdauer, \lag, 0.1]);

				ctrvollangersynth2 = Synth.head(~control, "line",
					[\outBus, 133+(100*x), \start, oldvolume2, \end, volume2, \time, repeatdauer, \lag, 0.1]);

				ctrfreqlangersynth1 = Synth.head(~control, "line",
					[\outBus, 130+(100*x), \start, oldfreq1, \end, freq1, \time, repeatdauer, \lag, 0.1]);

				ctrfreqlangersynth2 = Synth.head(~control, "line",
					[\outBus, 132+(100*x), \start, oldfreq2, \end, freq2, \time, repeatdauer, \lag, 0.1]);

				ctrfreqmod = Synth.head(~control, "line",
					[\outBus, 134+(100*x), \start, oldmodfreq, \end, modfreq, \time, repeatdauer, \lag, 0.1]);

				ctrvolmod = Synth.head(~control, "line",
					[\outBus, 135+(100*x), \start, oldmodvol, \end, modvol, \time, repeatdauer, \lag, 0.1]);

				repeatdauer.wait;

			});
			}, {


				// Erste Schleife
				repeat.do({ |irepeat|

					// Bestimmung der Tonfolgen, und Pause
					var tonfolge = ~tonfolgesinusglissandi[x][irepeat];
					var pause = ~durationsinusglissandi[x][irepeat];

					modfreqmin = 500.rand;
					modfreqmax = modfreqmin + 500.rand;

					// 2. Schleife
					tonfolge.do({ |index|

						// neue Frequenz setzen
						oldfreq1 = freq1;
						oldfreq2 = freq2;
						freq1 = modus.choose;
						freq2 = freq1 + 20.rand;

						// neue Volumen setzen
						oldvolume1 = volume1;
						oldvolume2 = volume2;
						volume1 = 0.2.rrand(1.0);
						volume2 = 1 - volume1;

						// neue Modulationsfrequenz und Volumen setzen
						oldmodfreq = modfreq;
						modfreq = modfreqmin.rrand(modfreqmax);
						oldmodvol = modvol;
						modvol = 0.5.rrand(1.5);

						// Bestimmung der Tonlänge
						time = (~timesinusglissandi[x][irepeat][index]).max(0.1);

						ctrvollangersynth1 = Synth.head(~control, "line",
							[\outBus, 131+(100*x), \start, oldvolume1, \end, volume1, \time, time-0.1, \lag, 0.1]);

						ctrvollangersynth2 = Synth.head(~control, "line",
							[\outBus, 133+(100*x), \start, oldvolume2, \end, volume2, \time, time-0.1, \lag, 0.1]);

						ctrfreqlangersynth1 = Synth.head(~control, "line",
							[\outBus, 130+(100*x), \start, oldfreq1, \end, freq1, \time, time-0.1, \lag, 0.1]);

						ctrfreqlangersynth2 = Synth.head(~control, "line",
							[\outBus, 132+(100*x), \start, oldfreq2, \end, freq2, \time, time-0.1, \lag, 0.1]);

						ctrfreqmod = Synth.head(~control, "line",
							[\outBus, 134+(100*x), \start, oldmodfreq, \end, modfreq, \time, time-0.1, \lag, 0.1]);

						ctrvolmod = Synth.head(~control, "line",
							[\outBus, 135+(100*x), \start, oldmodvol, \end, modvol, \time, time-0.1, \lag, 0.1]);

						time.wait;


					});

					pause.wait;

				});

		});

		ctrvollangersynth1 = Synth.head(~control, "line",
			[\outBus, 131+(100*x), \start, volume1, \end, 0, \time, 1.5]);

		ctrvollangersynth2 = Synth.head(~control, "line",
			[\outBus, 133+(100*x), \start, volume2, \end, 0, \time, 1.5]);

		2.0.wait;

		anzahl.do({ |index|

			langersynth1[index].free;
			langersynth2[index].free;

		});

		/*langersynth1.free;
		langersynth2.free;*/

		freqmod1.free;
		freqmod2.free;
		~setsinusglissandi[x] = 0;

	});

});