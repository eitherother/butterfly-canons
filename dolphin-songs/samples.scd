// ============================================================
// Whale Songs — Samples
// ============================================================
// Load order: synths → signal_flow → samples
//
// Defines the buffers used by the score:
//   ~whales1     — whale song sequence
//   ~b2, ~b5–~b7 — beats (horse, whale, fireworks)
//   ~flt, ~pnmf  — flute / piano mf, keyed by note name
// ============================================================

(
var clFolder    = ~sampleLibraryRoot ++ "Clarinet/post2012";
var fltFolder    = ~sampleLibraryRoot ++ "Flute";
var crotalesFolder = ~sampleLibraryRoot ++ "Crotale.ff.stereo";

~cl  = Dictionary.new;
~flt = Dictionary.new;
~bass = Dictionary.new;
~crotale = Dictionary.new;


// Signaled once loading finishes — init.scd waits on this instead of
// s.sync, since buffer loading runs in its own Routine (~load_samples),
// independent of whatever fork/routine called load() on this file.
~buffersLoaded = Condition.new;

~load_samples = Routine {

	~silence = Buffer.read(s, ~sampleLibraryRoot ++ "silence.wav");

	~poem = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/poem.wav");

	~piano = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_piano.wav");

	~whale1 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/whale_beats/b7.wav");
	~whale2 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/whale_beats/b9.wav");
	~whale3 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/whale_beats/b14.wav");
	~whale4 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/whale_beats/b33.wav");
	~dolphin1 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_01.wav");
	~dolphin2 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_02.wav");
	~dolphin3 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_03.wav");
	~dolphin4 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_04.wav");
	~dolphin5 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_05.wav");
	~dolphin6 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_06.wav");
	~dolphin7 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_07.wav");
	~dolphin8 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_08.wav");
	~dolphin9 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_09.wav");
	~dolphin10 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_10.wav");
	~dolphin11 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_11.wav");
	~dolphin12 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_12.wav");
	~dolphin13 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_13.wav");
	~dolphin14 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_14.wav");
	~dolphin15 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_15_mod.wav");
	~dolphin16 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_16_mod.wav");
	~dolphin17 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_17_mod.wav");
	~dolphin18 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/dolphin/dolphin_sample_18_mod.wav");


	// Skip macOS "._" sidecar files — they'd parse to the same note name
	// and overwrite the real buffer with an unreadable one.
	PathName(clFolder).files.reject { |file| file.fileName.beginsWith("._") }.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~cl[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(fltFolder).files.reject { |file| file.fileName.beginsWith("._") }.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(3).asSymbol;
		~flt[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(crotalesFolder).files.reject { |file| file.fileName.beginsWith("._") }.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~crotale[noteName] = Buffer.read(s, file.fullPath);
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
/*		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulD.E2.stereo.aif",
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
		"/Volumes/Samsung_T1/SoundFiles/Bass-pizz/Bass.pizz.ff.sulG.G3.stereo.aif",*/

	].do { |path|
		var noteName = PathName(path).fileNameWithoutExtension.split($.).at(4).asSymbol;
		~bass[noteName] = Buffer.read(s, path);
	};



	s.sync;
	"Buffers loaded:".postln;
	~buffersLoaded.test = true;
	~buffersLoaded.signal;
}.play;
)
