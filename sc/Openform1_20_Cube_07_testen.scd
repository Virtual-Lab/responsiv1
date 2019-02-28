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

	s.quit;
	//s.reboot;
	o = Server.local.options;
	//o.device = "MADIface USB (23622942)";
	//o.device = nil;
	o.numOutputBusChannels = ~channelsOut+2;
	o.memSize = 2.pow(20);
	o.numAudioBusChannels = 2048;
	o.sampleRate = 44100;
	o.maxNodes = 1024*12;
	s.volume = -16;


	s.bootSync();
	o.blockSize;
	o.memSize;
	o.numAudioBusChannels;

	~folder = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "samples/").pathOnly;
	~files = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "samples/").files;

	~filename = Array.newClear(~files.size);
	~filename = Array.fill(~files.size,
		{ |index| ~folder +/+ ~files[index].fileName});

	~file = Array.newClear(~files.size);
	~files.size. do { |i|
		~file[i] = Buffer.read(s, ~filename[i]);
	};
	~setfile = ~files.size;

	thisProcess.openUDPPort(9002);
	~oscsend = NetAddr.new("localhost", 9000);
	//~oscsend = NetAddr.new("localhost", 12000);
	//~oscsend = NetAddr("224.0.0.1", 12001);
	//"169.254.4.168" "169.254.123.93" "localhost"

	// ---------------------------------------------------------------------------------
	//                                Globale Setting
	// ---------------------------------------------------------------------------------

	~stimmen = 8;
	~ablauf = 8;
	~polygon1 = [[1, 2, 3, 4, 5],
		[3, 4, 9, 14, 8], [2, 3, 8, 13, 7], [1, 6, 12, 7, 2], [5, 10, 11, 6, 1], [4, 9, 15, 10, 5],
		[8, 13, 18, 19, 14], [7, 12, 17, 18, 13], [6, 11, 16, 17, 12], [10, 15, 20, 16, 11], [9, 14, 19, 20, 15],
		[16, 17, 18, 19, 20]];
	~polygon2 = [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10], [11, 12, 13, 14, 15], [16, 17, 18, 19, 20]];
	~dodecout1 = ~polygon1-1;
	~dodecout2 = ~polygon2-1;

	"----------- START SEQUENZ  ----------------\n\n".postln;

	// -------------------------------------------------------------------------------------
	//                          Frequenzen und Zeitdauern bestimmen
	// -------------------------------------------------------------------------------------

	~modus = Array.newClear(~stimmen);
	~tonlaenge = Array.newClear(~stimmen);
	~basistime = Array.newClear(~stimmen);


	~ausgangsfreq = 18.rrand(35);
	~ausgangszeit = 40.rrand(80);
	postf("Ausgangsfreqenz: % \nAusgangszeit = %\n", ~ausgangsfreq, ~ausgangszeit);

	~stimmen.do ({ |x|

		var modusanzahl = 2.rrand(6);
		var tonlaengeanzahl = 2.rrand(6);
		var basefreq, teilton, ausgangfreq;
		var basistime, timedivisor;

		~modus[x] = Array.newClear(modusanzahl);
		~tonlaenge[x] = Array.newClear(tonlaengeanzahl);


		basefreq = ~ausgangsfreq * [2, 3].choose;
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


	// -------------------------------------------------------------------------------------
	//                                    Synthdefs
	// -------------------------------------------------------------------------------------

	"Openform1_Synthdefs_07.scd".loadRelative;

	"Openform1_Soundmoduls_07.scd".loadRelative;

	// Sync for Synth Definition and boot server

	s.sync;

	// ------------------------------------------------------------------------------------



	// -------------------------------------------------------------------------------------
	//                                Send OSC - Datas
	// -------------------------------------------------------------------------------------

	~oscOut = OSCFunc({
		arg msg, time, cmdname;
		var trig1, trig2, trig3, object;

		//[time, msg].postln; //- to see the full message

		cmdname = msg[0].value;
		object = msg[2].value;
		trig1 = msg[3].value;
		trig2 = msg[4].value;
		//trig3 = msg[4].value;
		~oscsend.sendMsg(cmdname, object, trig1, trig2, trig3);
		//postf("Message: %, %, %\n", trig1, trig2, trig3);
	},'/dodec', s.addr);


	// -------------------------------------------------------------------------------------
	//                                 5 Soundmodelle
	// -------------------------------------------------------------------------------------


	~testwahl = {

		~wahl = Array.newClear(~ablauf);


		~wahl[0] = [1, 5];
		~wahl[1] = [1, 5];
		~wahl[2] = [1, 2, 5];
		~wahl[3] = [1, 2, 3];
		~wahl[4] = [2, 3, 4];
		~wahl[5] = [2, 3];
		~wahl[6] = [1, 4];
		~wahl[7] = [1, 2];

		postf("Auwahl = %\n", ~wahl);


	};

	// -------------------------------------------------------------------------------------
	//                                  Ablauf bestimmen
	// -------------------------------------------------------------------------------------

	~prowahl =
	{

		var oldwahl, zaehler = 0;
		var task = [1, 2, 3, 4, 5];
		~wahl = Array.newClear(~ablauf);


		oldwahl = task.take(task.wchoose([0.3, 0.3, 0.3, 0.05, 0.05]));

		~ablauf.do ({ |x|

			var auswahl1, auswahl2, auswahl3;

			if (task.size < 1, {task =  [1, 2, 3, 4, 5]; task.remove(oldwahl)});

			auswahl1 = oldwahl;
			auswahl2 = task.take(task.choose);
			oldwahl = auswahl2;
			zaehler = zaehler + 1;

			if (zaehler > 2,
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

	};

	// -------------------------------------------------------------------------------------
	//                                 Aufnahmeroutinen
	// -------------------------------------------------------------------------------------

	~recordingBuffers = Array.newClear(20);

	~startRecordingToDisk = {
		| title = "Untitled" |

		~channelsOut.do { |i| ~recordingBuffers[i] = Buffer.alloc(s, 262144, 1) };

		// create output files for the buffers
		~recordingBuffers.do { |item,i|
			item.write(("~/Desktop/"++title++(i+1)++".aiff").standardizePath, "aiff",
				"int16", 0, 0, true) };

		// create the diskout node
		~diskoutNode = Synth.tail(nil, "diskout", ["bufnums", ~recordingBuffers]);
	};

	~stopRecordingToDisk = {
		// stop recording
		~diskoutNode.free;

		// close the buffers and the soundfiles. Free the buffers
		~recordingBuffers.do { |item| item.close; item.free };
	};

	// -------------------------------------------------------------------------------------
	//                                  Steuerung der Routinen
	// -------------------------------------------------------------------------------------

	{
		// ------------------------ Audio - Masterbusses -------------------------
		var granularmultiout, samplegrainmultiout, delaysynthmultiout, rauschenmultiout;
		var sinusglissandimultiout, masterout;
		var kontrolBus = Array.fill(9, { Bus.control() });
		var fader = Array.fill(9, 0);


		granularmultiout = Synth.head(~master, "busmulti", [\inBus, ~modul.granulatorBus.index, \outBus, 2, \level, 1.0]);
		delaysynthmultiout = Synth.head(~master, "busmulti", [\inBus, ~modul.samplegrainBus.index, \outBus, 2, \level, 1.0]);
		rauschenmultiout = Synth.head(~master, "busmulti", [\inBus, ~modul.delaysynthBus.index, \outBus, 2, \level, 1.0]);
		sinusglissandimultiout = Synth.head(~master, "busmulti", [\inBus, ~modul.rauschenBus.index, \outBus, 2, \level, 1.0]);
		samplegrainmultiout = Synth.head(~master, "busmulti", [\inBus, ~modul.sinusglissandiBus, \outBus, 2, \level, 1.0]);

		//masterout = Synth.tail(~master, "limiter", [\level, 1]);

	}.fork;

	//~startRecordingToDisk.value("Versuch1_");

    //~testwahl.value;
	~prowahl.value;

	"Openform1_Ablauf_07.scd".loadRelative;

	/*~stimmen.do ({ |x|
			~modul.ablauf[x].fork;
		});*/

	"Openform1_Test_07.scd".loadRelative;

	//~test1.play;
	~test2.play;
	//~test3.play;
	//~test4.play;
	//~test5.play;

	//~test1.stop;
	//~test2.stop;
	//~test3.stop;
	//~test4.stop;
	//~test5.stop;
	//~stopRecordingToDisk.value;

// Routine


}.fork;

)


/*________________________________________________________________________________________
________________________________________________________________________________________

----------------------------- End of Program -------------------------------------------*/

