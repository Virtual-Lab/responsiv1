({
	/****************************************************
	-----------------------------------------------------
	-----------------    Openform 1 ---------------------
	© Raimund Vogtenhuber - 14.4.2013
	-----------------------------------------------------


	Set Channels: --- >  ~channelsOut = ?;

	Write Path of Folder in which the files are: ----->
	~folder = "/Users/????/Desktop/Openform1_final";

	Start with command+Return (cursor within the brackets)


	****************************************************/

	~channelsOut = 2;
	~folder = thisProcess.nowExecutingPath.dirname +/+ "samples/";


	o = Server.local.options;
	o.memSize = 2.pow(20);
	o.numAudioBusChannels = 256;
	o.sampleRate = 48000;
	o.maxNodes = 1024*20;

	s.quit;
	s.bootSync;
	o.blockSize;
	o.memSize;
	o.numAudioBusChannels;

	~setfile = 6;
	/*~file = Array.newClear(~setfile);
	~file[0] = Buffer.read(s, ~folder +/+ "/baby1_einzeln1.aif");
	~file[1] = Buffer.read(s, ~folder +/+ "/baby2_einzeln1.aif");
	~file[2] = Buffer.read(s, ~folder +/+ "/baby6_einzeln1.aif");
	~file[3] = Buffer.read(s, ~folder +/+ "/baby6_einzeln2.aif");
	~file[4] = Buffer.read(s, ~folder +/+ "/gong_noise1.wav");
	~file[5] = Buffer.read(s, ~folder +/+ "/gong_light2.wav");
	~file[6] = Buffer.read(s, ~folder +/+ "/gong_quietschen1.wav");
	~file[7] = Buffer.read(s, ~folder +/+ "/gong_quietschen2.wav");
	~file[8] = Buffer.read(s, ~folder +/+ "/gong_rubber1.wav");
	~file[9] = Buffer.read(s, ~folder +/+ "/gong_light-vibrato1.wav");
*/
	//~oscsend = NetAddr("localhost", 12000);
	thisProcess.openUDPPort(9002);
	~oscsend = NetAddr.new("localhost", 9000);

	// -------------------------------------------------------------------------------------
	//                                    Synthdefs
	// -------------------------------------------------------------------------------------

	"Openform1_Synthdefs_03.scd".loadRelative;


	// Sync for Synth Definition and boot server

	s.sync;

	// ------------------------------------------------------------------------------------

	(

		// ---------------------------------------------------------------------------------
		//                                Globale Setting
		// ---------------------------------------------------------------------------------

		~stimmen = 3;

		~granulator1out = Array.newClear(~stimmen);
		~delaysynth1out = Array.newClear(~stimmen);
		~rauschen1out = Array.newClear(~stimmen);
		~sinusglissandi1out = Array.newClear(~stimmen);
		~samplegrain1out = Array.newClear(~stimmen);


		~set = Array.fill(~stimmen, 0);

		~granulator = Array.fill(~stimmen, 0);
		~setgranulator = Array.fill(~stimmen, 0);

		~repeatgranular = Array.newClear(~stimmen);
		~tonfolgegranular = Array.newClear(~stimmen);
		~timegranular = Array.newClear(~stimmen);
		~durationgranular = Array.newClear(~stimmen);

		~samplegrain = Array.fill(~stimmen, 0);
		~setsamplegrain = Array.fill(~stimmen, 0);

		~repeatsamplegrain = Array.newClear(~stimmen);
		~tonfolgesamplegrain = Array.newClear(~stimmen);
		~timesamplegrain = Array.newClear(~stimmen);
		~durationsamplegrain = Array.newClear(~stimmen);

		~glockensynth = Array.fill(~stimmen, 0);
		~setdelaysynth = Array.fill(~stimmen, 0);

		~repeatdelaysynth = Array.newClear(~stimmen);
		~tonfolgedelaysynth = Array.newClear(~stimmen);
		~timedelaysynth = Array.newClear(~stimmen);
		~durationdelaysynth = Array.newClear(~stimmen);


		~windrauschen = Array.fill(~stimmen, 0);
		~setrauschen = Array.fill(~stimmen, 0);

		~repeatrauschen = Array.newClear(~stimmen);
		~tonfolgerauschen = Array.newClear(~stimmen);
		~timerauschen = Array.newClear(~stimmen);
		~durationrauschen = Array.newClear(~stimmen);
		~sequenzdauerrauschen = Array.newClear(~stimmen);

		~sinusglissandi = Array.fill(~stimmen, 0);
		~setsinusglissandi = Array.fill(~stimmen, 0);

		~repeatsinusglissandi = Array.newClear(~stimmen);
		~tonfolgesinusglissandi = Array.newClear(~stimmen);
		~timesinusglissandi = Array.newClear(~stimmen);
		~durationsinusglissandi = Array.newClear(~stimmen);
		~sequenzdauersinusglissandi = Array.newClear(~stimmen);


		"----------- START SEQUENZ  ----------------\n\n".postln;

		// -------------------------------------------------------------------------------------
		//                          Frequenzen und Zeitdauern bestimmen
		// -------------------------------------------------------------------------------------

		~modus = Array.newClear(~stimmen);
		~tonlaenge = Array.newClear(~stimmen);
		~basistime = Array.newClear(~stimmen);


		~ausgangsfreq = 16.rrand(35);
		~ausgangszeit = 40.rrand(180);
		postf("Ausgangsfreqenz: % \nAusgangszeit = %\n", ~ausgangsfreq, ~ausgangszeit);

		~stimmen.do ({ |x|

			var modusanzahl = 2.rrand(8);
			var tonlaengeanzahl = 2.rrand(8);
			var basefreq, teilton, ausgangfreq;
			var basistime, timedivisor;

			~modus[x] = Array.newClear(modusanzahl);
			~tonlaenge[x] = Array.newClear(tonlaengeanzahl);


			basefreq = ~ausgangsfreq * [2, 3, 5].choose;
			teilton = [1, 2, 3, 4, 5, 6].choose;
			postf("Basisfreqenz %: %\n", x, basefreq);
			~basistime[x] = ~ausgangszeit / [2, 3, 4].choose;
			timedivisor = 2.rrand(4);

			postf("Basistime %: %, Divisor: %\n", x, ~basistime[x].round(1e-3), timedivisor);

			~modus[x] = basefreq*(Array.series(modusanzahl,teilton,1));
			~tonlaenge[x] =    ~basistime[x]/(Array.series(tonlaengeanzahl,timedivisor,timedivisor));

			~modus[x].postln;
			~tonlaenge[x].round(1e-2).postln;

		});
	);

	// -------------------------------------------------------------------------------------
	//                                Send OSC - Datas
	// -------------------------------------------------------------------------------------

	~oscOut = OSCFunc({
		arg msg, time, cmdname;
		var trig1, trig2, trig3;

		//[time, msg].postln; //- to see the full message

		cmdname = msg[0].value;
		trig1 = msg[2].value;
		trig2 = msg[3].value;
		trig3 = msg[4].value;
		~oscsend.sendMsg(cmdname, trig1, trig3, trig2, trig1);
		//postf("Message: %, %, %\n", trig1, trig2, trig3);
	},'/dodec', s.addr);


	// -------------------------------------------------------------------------------------
	//                                 5 Soundmodelle
	// -------------------------------------------------------------------------------------

	"Openform1_Soundmoduls_03_C.scd".loadRelative;

	/*~wahl = Array.newClear(5);

	~wahl[0] = [1, 2];
	~wahl[1] = [2, 1];
	~wahl[2] = [2, 3];
	~wahl[3] = [4, 5, 1];
	~wahl[4] = [3, 2, 1];*/

	// -------------------------------------------------------------------------------------
	//                                  Ablauf bestimmen
	// -------------------------------------------------------------------------------------

	{

		var oldwahl, zaehler = 0;
		var task = [1, 2, 3, 4, 5];
		~wahl = Array.newClear(100);


		oldwahl = task.take(task.wchoose([0.3, 0.3, 0.3, 0.05, 0.05]));

		100. do ({ |x|

			var auswahl1, auswahl2, auswahl3;

			if (task.size < 1, {task =  [1, 2, 3, 4, 5]; task.remove(oldwahl)});

			auswahl1 = oldwahl;
			auswahl2 = task.take(task.choose);
			oldwahl = auswahl2;
			zaehler = zaehler + 1;

			if (zaehler > 8,
				{
					if (task.size < 1, {
						task =  [1, 2, 3, 4, 5];
						task.remove(auswahl1); task.remove(auswahl2)
					});
					auswahl3 = task.take(task.choose);
					~wahl[x] = [auswahl1, auswahl2, auswahl3];
					zaehler = 0;
				},{
					~wahl[x] = [auswahl1, auswahl2];
			});

			postf("Auwahl[%] = %, task = %\n", x, ~wahl[x], task);
		});

	}.fork;

	// -------------------------------------------------------------------------------------
	//                                  Steuerung der Routinen
	// -------------------------------------------------------------------------------------

	"Openform1_Ablauf_01_C.scd".loadRelative;


	{
		// ------------------------ Audio - Masterbusses -------------------------
		var granularmultiout, samplegrainmultiout, delaysynthmultiout, rauschenmultiout;
		var sinusglissandimultiout, masterout;
		var kontrolBus = Array.fill(9, { Bus.control() });
		var fader = Array.fill(9, 0);


		granularmultiout = Synth.head(~master, "bus", [\inBus, 200, \outBus, 0, \level, 0.3]);
		delaysynthmultiout = Synth.head(~master, "bus", [\inBus, 210, \outBus, 0, \level, 0.9]);
		rauschenmultiout = Synth.head(~master, "bus", [\inBus, 220, \outBus, 0, \level, 0.2]);
		sinusglissandimultiout = Synth.head(~master, "bus", [\inBus, 230, \outBus, 0, \level, 0.8]);
		samplegrainmultiout = Synth.head(~master, "bus", [\inBus, 240, \outBus, 0, \level, 1.0]);

		masterout = Synth.tail(~master, "limiter", [\level, 1]);

		~stimmen.do ({ |x|
			~set[x].play;
		});

	}.fork;

	"Openform1_Test_01.scd".loadRelative;
    ~test1.fork;
	~test2.fork;
	~test3.fork;
    ~test4.fork;
	~test5.fork;



}.fork;

)


/*________________________________________________________________________________________
________________________________________________________________________________________

----------------------------- End of Program -------------------------------------------*/

