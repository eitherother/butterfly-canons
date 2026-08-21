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

	~piffaro_3_1 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/16 - Christum wir sollen loben schon (Hymnus).mp3", 0);
	~piffaro_3_2 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/16 - Christum wir sollen loben schon (Hymnus).mp3", 1/3*44100);
	~piffaro_3_3 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/16 - Christum wir sollen loben schon (Hymnus).mp3", 2/3*44100);
	~piffaro_3_4 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/16 - Christum wir sollen loben schon (Hymnus).mp3", 3/3*44100);


~piffaro_4_1 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/18 - A solis ortus (Motet).mp3", 0);



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
	var pnffFolder    = ~sampleLibraryRoot ++ "pnff/";
	var pnmfFolder    = ~sampleLibraryRoot ++ "pnmf/";
	var pnppFolder    = ~sampleLibraryRoot ++ "pnpp/";
	var clFolder     = ~sampleLibraryRoot ++ "Clarinet/post2012/";
	var fltFolder    = ~sampleLibraryRoot ++ "Flute/";
	var oboeFolder   = ~sampleLibraryRoot ++ "Oboe/";
	var bassoonFolder = ~sampleLibraryRoot ++ "Bassoon/";
	var bassfltFolder = ~sampleLibraryRoot ++ "BassFlute";
	var marimbafolder = ~sampleLibraryRoot ++ "Marimba.cord.ff.stereo/";
	var vibFolder = ~sampleLibraryRoot ++ "Vibraphone.bow.stereo/";

	~silence = Buffer.read(s, ~sampleLibraryRoot ++ "silence.wav");
	~piffaro_1_1 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/13 - A solis ortus cardine.mp3", 0);
	~piffaro_1_2 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/13 - A solis ortus cardine.mp3", 44100/4);
	~piffaro_1_3 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/13 - A solis ortus cardine.mp3", 44100/2);
	~piffaro_1_4 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/13 - A solis ortus cardine.mp3", 3/4*44100);

	~piffaro_2_1 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/14 - A solis ortus cardine.mp3", 0);
	~piffaro_2_2 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/14 - A solis ortus cardine.mp3", 44100/3);
	~piffaro_2_3 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/14 - A solis ortus cardine.mp3", 2/3*44100);
	~piffaro_2_4 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/14 - A solis ortus cardine.mp3", 44100);


	~piffaro_3_1 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/16 - Christum wir sollen loben schon (Hymnus).mp3", 0);
	~piffaro_piano = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/piffaro_piano.WAV");


	PathName(marimbafolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(3).asSymbol;
		~marimba[noteName] = Buffer.read(s, file.fullPath);
	};

/*
	PathName(vibFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~vib[noteName] = Buffer.read(s, file.fullPath);
	};*/

/*	PathName(pnffFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(0).asSymbol;
		~pnff[noteName] = Buffer.read(s, file.fullPath);
	};*/

	PathName(pnmfFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(0).asSymbol;
		~pnmf[noteName] = Buffer.read(s, file.fullPath);
	};

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
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulA.A4.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.E5.stereo.aif",
	].do { |path|
		var noteName = PathName(path).fileNameWithoutExtension.split($.).at(4).asSymbol;
		~vln[noteName] = Buffer.read(s, path);
	};

	[
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulC.C3.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulC.Db3.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulC.D3.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulC.Eb3.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulC.E3.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulC.F3.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulC.Gb3.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulG.G3.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulG.Ab3.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulG.A3.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulG.Bb3.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulG.B3.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulG.C4.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulG.Db4.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulD.D4.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulD.Eb4.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulD.E4.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulD.F4.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulD.Gb4.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulD.G4.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulD.Ab4.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.A4.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.Bb4.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.B4.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.C5.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.Db5.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.D5.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.Eb5.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.E5.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.F5.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.Gb5.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.G5.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.Ab5.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.A5.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.Bb5.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.B5.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.C6.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.Db6.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.D6.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.Eb6.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.E6.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.F6.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.Gb6.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.G6.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.Ab6.stereo.aif",
		~sampleLibraryRoot ++ "Viola-arco/Viola.arco.ff.sulA.A6.stereo.aif",

	].do { |path|
		var noteName = PathName(path).fileNameWithoutExtension.split($.).at(4).asSymbol;
		~vla[noteName] = Buffer.read(s, path);
	};

	[
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulC.C2.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulC.Db2.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulC.D2.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulC.Eb2.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulC.E2.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulC.F2.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulC.Gb2.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulG.G2.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulG.Ab2.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulG.A2.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulG.Bb2.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulC.B2.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulG.C3.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulG.Db3.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulD.D3.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulD.Eb3.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulD.E3.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulD.F3.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulD.Gb3.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulD.G3.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulD.Ab3.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulA.A3.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulA.Bb3.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulA.B3.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulA.C4.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulA.Db4.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulA.D4.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulA.Eb4.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulA.E4.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulA.F4.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulA.Gb4.stereo.aif",
		~sampleLibraryRoot ++ "Cello-arco/Cello.arco.ff.sulA.G4.stereo.aif",

	].do { |path|
		var noteName = PathName(path).fileNameWithoutExtension.split($.).at(4).asSymbol;
		~vcl[noteName] = Buffer.read(s, path);
	};

	[
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulC.C1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulC.Db1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulC.D1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulC.Eb1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulE.E1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulE.F1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulE.Gb1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulE.G1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulE.Ab1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulA.A1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulA.Bb1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulA.B1.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulA.C2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulA.Db2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulD.D2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulD.Eb2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulD.E2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulD.F2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulD.Gb2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.G2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.Ab2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.A2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.Bb2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.B2.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.C3.stereo.aif",

		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.Db3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.D3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.Eb3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.E3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.F3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.Gb3.stereo.aif",
		~sampleLibraryRoot ++ "Bass-pizz/Bass.pizz.ff.sulG.G3.stereo.aif",

	].do { |path|
		var noteName = PathName(path).fileNameWithoutExtension.split($.).at(4).asSymbol;
		~bass[noteName] = Buffer.read(s, path);
	};


	s.sync;
	"Buffers loaded:".postln;
}.play;
)
