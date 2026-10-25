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
var pnmfFolder    = ~sampleLibraryRoot ++ "pnmf/";
var fltFolder    = ~sampleLibraryRoot ++ "Flute/";

~flt  = Dictionary.new;
~pnmf = Dictionary.new;

~b2 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/beats/horse02.wav");
~b5 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/whale_beats/b38.wav");
~b6 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/whale_beats/b37.wav");
~b7 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/beats/fireworks01.wav");

// Signaled once loading finishes — init.scd waits on this instead of
// s.sync, since buffer loading runs in its own Routine (~load_samples),
// independent of whatever fork/routine called load() on this file.
~buffersLoaded = Condition.new;

~load_samples = Routine {
	~silence = Buffer.read(s, ~sampleLibraryRoot ++ "silence.wav");

	~whales1 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/whale-song/whale_song_sequence.wav", 0);

	PathName(pnmfFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(0).asSymbol;
		~pnmf[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(fltFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(3).asSymbol;
		~flt[noteName] = Buffer.read(s, file.fullPath);
	};

	s.sync;
	"Buffers loaded:".postln;
	~buffersLoaded.test = true;
	~buffersLoaded.signal;
}.play;
)
