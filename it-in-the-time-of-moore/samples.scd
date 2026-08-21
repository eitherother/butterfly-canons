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
//   ~vla  — viola pizz
//   ~vcl  — cello pizz
//   ~bass — double bass pizz
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

~music = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/Berceuse.mp3");
~music = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/byrd_kyrie_mass_for_4.mp3");
~music = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/etude_mcmillan.wav");
~music = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/Lulalu.mp3");
~music = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/Liszt- Mephisto Waltz #1.mp3");

(
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

	~moore = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/It in a Time of Moore.wav");

	PathName(vibFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~vib[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(pnmfFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(0).asSymbol;
		~pnmf[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(clFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~cl[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(fltFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(3).asSymbol;
		~flt[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(bassfltFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~bassflt[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(oboeFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~ob[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(bassoonFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~bsn[noteName] = Buffer.read(s, file.fullPath);
	};

	[
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulC.C1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulC.Db1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulC.D1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulC.Eb1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulE.E1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulE.F1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulE.Gb1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulE.G1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulE.Ab1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulA.A1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulA.Bb1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulA.B1.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulA.C2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulA.Db2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulD.D2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulD.Eb2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulD.E2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulD.F2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulD.Gb2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.G2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.Ab2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.A2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.Bb2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.B2.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.C3.stereo.aif",

		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.Db3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.D3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.Eb3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.E3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.F3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.Gb3.stereo.aif",
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.G3.stereo.aif",

	].do { |path|
		var noteName = PathName(path).fileNameWithoutExtension.split($.).at(4).asSymbol;
		~bass[noteName] = Buffer.read(s, path);
	};


	s.sync;
	"Buffers loaded:".postln;
	("  pnmf:   " ++ ~pnmf.size).postln;
	("  pnpp:   " ++ ~pnpp.size).postln;
	("  cl:   " ++ ~cl.size).postln;
	("  flt:   " ++ ~flt.size).postln;
	("  bassflt:   " ++ ~bassflt.size).postln;
	("  oboe:   " ++ ~ob.size).postln;
	("  bsn:   " ++ ~bsn.size).postln;

	("  vla:  " ++ ~vla.size).postln;
	("  vcl:  " ++ ~vcl.size).postln;
	("  bass: " ++ ~bass.size).postln;
}.play;
)
