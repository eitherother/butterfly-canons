// ============================================================
// Purcell In Nomine — Samples
// ============================================================
// Load order: synths → signal_flow → samples
//
// Defines the buffers used by the score:
//   ~in_nomine_6 — Purcell In Nomine recording (as ~music in score.scd)
//   ~silence     — silent buffer, used as a rest in step buffer lists
//   ~cl          — clarinet, keyed by note name (\Gb6 etc.)
//   ~flt         — flute, keyed by note name
//   ~bass        — double bass arco, keyed by note name (\Gb1 etc.)
//   ~woodlands, ~seawash — BBC SFX atmospheres
//   ~whale3, ~whale4     — whale recordings (left channel, duplicated to stereo)
// ============================================================

(
~cl   = Dictionary.new;
~flt  = Dictionary.new;
~bass = Dictionary.new;


// Signaled once loading finishes — init.scd waits on this instead of
// s.sync, since buffer loading runs in its own Routine (~load_samples),
// independent of whatever fork/routine called load() on this file.
~buffersLoaded = Condition.new;

~load_samples = Routine {
	var clFolder = ~sampleLibraryRoot ++ "Clarinet/post2012/";
	var fltFolder = ~sampleLibraryRoot ++ "Flute/";
	var whaleFolder = ~sampleLibraryRoot ++ "recordings/whale-sounds/whale-sounds-wav/";

	~in_nomine_6 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/purcell_in_nomine_6.wav");
	~silence = Buffer.read(s, ~sampleLibraryRoot ++ "silence.wav");

	~woodlands = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Sound Effects - Exterior Atmosphere/2-12 Woodland Atmosphere (Mixed Deciduous) On A Windy Day (Occasional Flying Insect).wav");
	~seawash = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Sound Effects - Exterior Atmosphere/2-03 Seawash, Gentle With Occasional Seagull.wav");

	~whale3 = Buffer.readChannel(s, whaleFolder ++ "minke-whale-balaenoptera-acutorostrata.wav", channels: [0, 0]);
	~whale4 = Buffer.readChannel(s, whaleFolder ++ "fin-whale-balaenoptera physalus.wav", channels: [0, 0]);

	PathName(clFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~cl[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(fltFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(3).asSymbol;
		~flt[noteName] = Buffer.read(s, file.fullPath);
	};

	[
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulC.C1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulC.Db1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulC.D1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulC.Eb1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulE.E1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulE.F1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulE.Gb1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulE.G1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulE.Ab1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulA.A1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulA.Bb1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulA.B1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulA.C2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulA.Db2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulD.D2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulD.Eb2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulD.E2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulD.F2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulD.Gb2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.G2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.Ab2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.A2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.Bb2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.B2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.C3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.Db3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.D3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.Eb3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.E3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.F3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.Gb3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-arco/Bass.arco.ff.sulG.G3.stereo.aif",
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
