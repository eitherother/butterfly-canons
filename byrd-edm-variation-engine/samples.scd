// ============================================================
// Byrd Variation Engine — Samples
// ============================================================
// Load order: synths → signal_flow → samples
//
// Defines the buffers used by the score:
//   ~byrd_mass   — Byrd Kyrie, Mass for Four Voices recording (as ~music in score.scd)
//   ~b4, ~b17    — kyrie beats
//   ~wb1         — whale beat
//   ~bass        — double bass arco, keyed by note name (\Gb1 etc.)
// ============================================================

(
~bass = Dictionary.new;

// Signaled once loading finishes — init.scd waits on this instead of
// s.sync, since buffer loading runs in its own Routine (~load_samples),
// independent of whatever fork/routine called load() on this file.
~buffersLoaded = Condition.new;

~load_samples = Routine {
	~byrd_mass = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/byrd_kyrie_mass_for_4.wav");

	~b4  = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/kyrie_beats/b4.wav");
	~b17 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/kyrie_beats/b17.wav");
	~wb1 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/whale_beats/b1.wav");

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
