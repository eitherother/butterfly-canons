// ============================================================
// TVP3 — Samples
// ============================================================
// Load order: tvp3_synths → tvp3_signal_flow → tvp3_samples
//
// Defines short buffer aliases used throughout the score:
//   ~cl   — clarinet
//   ~bcl  — bass clarinet
//   ~flt  — flute
//   ~ob   — oboe
//   ~bsn  — bassoon
//   ~vla  — viola arco
//   ~vcl  — cello arco
//   ~bass — double bass arco
//   ~pnmf — piano mf
//   ~pnff — piano ff
// ============================================================
/*
"vla".postln;
~vla.keys;
"vcl".postln;
~vcl.keys;
"bass".postln;
~bass.keys;
"cl".postln;
~cl.keys
"flt".postln;
~flt.keys;
"bassflt".postln;
~bassflt.keys;
"ob".postln;
~ob.keys;
"bsn".postln;
~bsn.keys;
"pnmf".postln;
~pnmf.keys;
"pnpp".postln;
~pnpp.keys;
*/

~in_nomine_60 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/purcell_in_nomine_6.wav", 0);
~in_nomine_61 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/purcell_in_nomine_6.wav", 22040*2);
~in_nomine_62 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/purcell_in_nomine_6.wav", 44100*2);
~in_nomine_63 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/purcell_in_nomine_6.wav", 66140*2);



(
// Fragments buf into alternating chunks of n seconds of sound followed by
// n seconds of silence, repeated across the whole buffer. Returns the new
// buffer immediately (still filling in), or pass action to be notified when
// it's done rendering. Does not modify buf — always allocates and writes to
// a new buffer.
~fragmentBuffer = { |buf, n = 0.25, action|
	var sr = buf.sampleRate;
	var segFrames = (n * sr).round.asInteger;
	var numSegments = (buf.numFrames / segFrames).ceil.asInteger;
	var newNumFrames = buf.numFrames + (numSegments * segFrames);
	var newBuf = Buffer.alloc(buf.server, newNumFrames, buf.numChannels);
	Routine {
		numSegments.do { |i|
			var readStart = i * segFrames;
			var segLen = segFrames.min(buf.numFrames - readStart);
			var writeStart = i * segFrames * 2;
			var synth = {
				var sig = PlayBuf.ar(buf.numChannels, buf, BufRateScale.kr(buf), startPos: readStart, loop: 0);
				RecordBuf.ar(sig, newBuf, offset: writeStart, loop: 0);
				Silent.ar;
			}.play(buf.server);
			buf.server.sync;
			((segLen / sr) + 0.02).wait;
			synth.free;
		};
		action.value(newBuf);
	}.play;
	newBuf
};
);

// ~in_nomine_fragment = ~fragmentBuffer.(~in_nomine_6);
// ~gloria_fragment = ~fragmentBuffer.(~mass_gloria);
// ~kyrie_fragment = ~fragmentBuffer.(~mass_kyrie);

(
~vln = Dictionary.new;
~vla  = Dictionary.new;
~vcl  = Dictionary.new;
~bass = Dictionary.new;

~cl   = Dictionary.new;
~flt  = Dictionary.new;
~bassflt = Dictionary.new;
~ob   = Dictionary.new;
~bsn  = Dictionary.new;
~pnff = Dictionary.new;
~pnmf = Dictionary.new;
~pnpp = Dictionary.new;
~marimba = Dictionary.new;
~vib = Dictionary.new;


~load_samples = Routine {
	var pnffFolder    = "/Volumes/Samsung_T1/SoundFiles/pnff/";
	var pnmfFolder    = "/Volumes/Samsung_T1/SoundFiles/pnmf/";
	var pnppFolder    = "/Volumes/Samsung_T1/SoundFiles/pnpp/";
	var clFolder     = "/Volumes/Samsung_T1/SoundFiles/Clarinet/post2012/";
	var fltFolder    = "/Volumes/Samsung_T1/SoundFiles/Flute/";
	var oboeFolder   = "/Volumes/Samsung_T1/SoundFiles/Oboe/";
	var bassoonFolder = "/Volumes/Samsung_T1/SoundFiles/Bassoon/";
	var bassfltFolder = "/Volumes/Samsung_T1/SoundFiles/BassFlute";
	var marimbafolder = "/Volumes/Samsung_T1/SoundFiles/Marimba.cord.ff.stereo/";
	var vibFolder = "/Volumes/Samsung_T1/SoundFiles/Vibraphone.bow.stereo/";

	~silence = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/silence.wav");
	// ~mephisto1 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/mephisto_tuning.wav");
	// ~mephisto2 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/mephisto_part2.wav");
	// ~mephisto3 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/mephisto_laughs.wav");
~door = Buffer.read(s, "/Volumes/Samsung_T1/BBC SFX DISCS/BBC Sound Effects Library/BBC Sound FX [Disc 1]/1-36 Destruction, Wooden Door.wav");
	~brick = Buffer.read(s, "/Volumes/Samsung_T1/BBC SFX DISCS/BBC Sound Effects Library/BBC Sound FX [Disc 1]/1-37 Destruction, Brick Wall.wav");

	~shatter = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/shatter.wav");
	~fireworks1 = Buffer.read(s, "/Volumes/Samsung_T1/BBC SFX DISCS/BBC Sound Effects Library/BBC Sound FX [Disc 18]/01 Fireworks, Chrysanthemum Fountain (Fizz).wav");

	~dialect1 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/dialect_minnesota.wav");
	// ~traffic = Buffer.read(s, "/Volumes/Samsung_T1/BBC SFX DISCS/BBC Sound Effects Library/Sound Effects - Exterior Atmosphere/2-08 City Traffic.wav");

	~woodlands = Buffer.read(s, "/Volumes/Samsung_T1/BBC SFX DISCS/BBC Sound Effects Library/Sound Effects - Exterior Atmosphere/2-12 Woodland Atmosphere (Mixed Deciduous) On A Windy Day (Occasional Flying Insect).wav");


	~seawash = Buffer.read(s, "/Volumes/Samsung_T1/BBC SFX DISCS/BBC Sound Effects Library/Sound Effects - Exterior Atmosphere/2-03 Seawash, Gentle With Occasional Seagull.wav");
	~train = Buffer.read(s, "/Volumes/Samsung_T1/BBC SFX DISCS/BBC Sound Effects Library/BBC Sound FX [[Disc 4]]/4-02 Main Line Railway Station, Footsteps, Voices, Trolleys, Destination Indicators And PA Announcements.wav");
	~trucks = Buffer.read(s, "/Volumes/Samsung_T1/BBC SFX DISCS/BBC Sound Effects Library/BBC Sound FX [Disc 18]/20 Quarrying, Dumper Tricks - 3 Start Up And Depart.wav");

	// ~mass_kyrie = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/byrd_kyrie_mass_for_4.mp3");
	// ~mass_gloria = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/byrd_gloria.mp3");

	~lorry = Buffer.read(s, "/Volumes/Samsung_T1/BBC SFX DISCS/BBC Sound Effects Library/BBC Sound FX [Disc 5]/5-01 Diesel Lorry, 10-Ton, Interior, Start-Up, Constant Run, Stop.wav");

	~motorcycle = Buffer.read(s, "/Volumes/Samsung_T1/BBC SFX DISCS/BBC Sound Effects Library/BBC Sound FX [Disc 5]/5-05 Motorcycle, BMW, Start-Up, Constant Run, Stop.wav");

	~whales = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/whales.wav");
~in_nomine_6 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/purcell_in_nomine_6.wav");

/*	PathName(marimbafolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(3).asSymbol;
		~marimba[noteName] = Buffer.read(s, file.fullPath);
	};*/
/*
	PathName(vibFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~vib[noteName] = Buffer.read(s, file.fullPath);
	};*/

/*	PathName(pnffFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(0).asSymbol;
		~pnff[noteName] = Buffer.read(s, file.fullPath);
	};*/

/*	PathName(pnmfFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(0).asSymbol;
		~pnmf[noteName] = Buffer.read(s, file.fullPath);
	};*/

/*	PathName(pnppFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(0).asSymbol;
		~pnpp[noteName] = Buffer.read(s, file.fullPath);
	};*/

	PathName(clFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~cl[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(fltFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(3).asSymbol;
		~flt[noteName] = Buffer.read(s, file.fullPath);
	};

/*	PathName(bassfltFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~bassflt[noteName] = Buffer.read(s, file.fullPath);
	};*/

	PathName(oboeFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~ob[noteName] = Buffer.read(s, file.fullPath);
	};

/*	PathName(bassoonFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~bsn[noteName] = Buffer.read(s, file.fullPath);
	};*/

	~whale1 = Buffer.readChannel(s, "/Volumes/Samsung_T1/SoundFiles/recordings/whale-sounds/whale-sounds-wav/killer-whale-orcinus-orca.wav", channels: [0, 0]);
	~whale2 = Buffer.readChannel(s, "/Volumes/Samsung_T1/SoundFiles/recordings/whale-sounds/whale-sounds-wav/humpback-whale-megaptera-novaeangliae.wav", channels: [0, 0]);
	~whale3 = Buffer.readChannel(s, "/Volumes/Samsung_T1/SoundFiles/recordings/whale-sounds/whale-sounds-wav/minke-whale-balaenoptera-acutorostrata.wav", channels: [0, 0]);
	~whale4 = Buffer.readChannel(s, "/Volumes/Samsung_T1/SoundFiles/recordings/whale-sounds/whale-sounds-wav/fin-whale-balaenoptera physalus.wav", channels: [0, 0]);
	~whale5 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/whale-sounds/whale-sounds-wav/sperm-whale-physeter-macrocephalus.wav");

	[
		"/Volumes/Samsung_T1/SoundFiles/Violin-arco/Violin.arco.ff.sulA.A4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Violin-arco/Violin.arco.ff.sulE.E5.stereo.aif",
	].do { |path|
		var noteName = PathName(path).fileNameWithoutExtension.split($.).at(4).asSymbol;
		~vln[noteName] = Buffer.read(s, path);
	};

	[
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulC.C3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulC.Db3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulC.D3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulC.Eb3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulC.E3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulC.F3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulC.Gb3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulG.G3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulG.Ab3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulG.A3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulG.Bb3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulG.B3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulG.C4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulG.Db4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulD.D4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulD.Eb4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulD.E4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulD.F4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulD.Gb4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulD.G4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulD.Ab4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.A4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.Bb4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.B4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.C5.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.Db5.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.D5.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.Eb5.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.E5.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.F5.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.Gb5.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.G5.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.Ab5.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.A5.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.Bb5.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.B5.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.C6.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.Db6.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.D6.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.Eb6.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.E6.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.F6.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.Gb6.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.G6.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.Ab6.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Viola-arco/Viola.arco.ff.sulA.A6.stereo.aif",

	].do { |path|
		var noteName = PathName(path).fileNameWithoutExtension.split($.).at(4).asSymbol;
		~vla[noteName] = Buffer.read(s, path);
	};

	[
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulC.C2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulC.Db2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulC.D2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulC.Eb2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulC.E2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulC.F2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulC.Gb2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulG.G2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulG.Ab2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulG.A2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulG.Bb2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulC.B2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulG.C3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulG.Db3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulD.D3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulD.Eb3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulD.E3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulD.F3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulD.Gb3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulD.G3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulD.Ab3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulA.A3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulA.Bb3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulA.B3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulA.C4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulA.Db4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulA.D4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulA.Eb4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulA.E4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulA.F4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulA.Gb4.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Cello-arco/Cello.arco.ff.sulA.G4.stereo.aif",

	].do { |path|
		var noteName = PathName(path).fileNameWithoutExtension.split($.).at(4).asSymbol;
		~vcl[noteName] = Buffer.read(s, path);
	};

	[
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulC.C1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulC.Db1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulC.D1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulC.Eb1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulE.E1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulE.F1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulE.Gb1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulE.G1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulE.Ab1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulA.A1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulA.Bb1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulA.B1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulA.C2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulA.Db2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulD.D2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulD.Eb2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulD.E2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulD.F2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulD.Gb2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.G2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.Ab2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.A2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.Bb2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.B2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.C3.stereo.aif",

		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.Db3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.D3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.Eb3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.E3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.F3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.Gb3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-arco/Bass.arco.ff.sulG.G3.stereo.aif",

	].do { |path|
		var noteName = PathName(path).fileNameWithoutExtension.split($.).at(4).asSymbol;
		~bass[noteName] = Buffer.read(s, path);
	};


	s.sync;
	"Buffers loaded:".postln;
}.play;
)
