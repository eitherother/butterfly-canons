

(

~vln = Dictionary.new;
~vla  = Dictionary.new;
~vcl  = Dictionary.new;
~bass = Dictionary.new;
~pnmf = Dictionary.new;
~pnff = Dictionary.new;

/*~cl   = Dictionary.new;
~flt  = Dictionary.new;
~bassflt = Dictionary.new;
~ob   = Dictionary.new;
~bsn  = Dictionary.new;
~pnff = Dictionary.new;
~pnmf = Dictionary.new;
~pnpp = Dictionary.new;
~marimba = Dictionary.new;
~vib = Dictionary.new;*/

// Signaled once loading finishes — init.scd waits on this instead of
// s.sync, since buffer loading runs in its own Routine (~load_samples),
// independent of whatever fork/routine called load() on this file.
~buffersLoaded = Condition.new;

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

	~voice_E4 = Buffer.read(s, ~sampleLibraryRoot ++ "female_voice/E4.ah-to-mm.wav");
	~voice_A4 = Buffer.read(s, ~sampleLibraryRoot ++ "female_voice/voice_A4_ahh_to_mm.wav");


/*	PathName(vibFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~vib[noteName] = Buffer.read(s, file.fullPath);
	};*/
/*	PathName(marimbafolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(3).asSymbol;
		~marimba[noteName] = Buffer.read(s, file.fullPath);
	};*/

/*	PathName(vibFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~vib[noteName] = Buffer.read(s, file.fullPath);
	};*/

	PathName(pnffFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(0).asSymbol;
		~pnff[noteName] = Buffer.read(s, file.fullPath);
	};

/*	PathName(pnmfFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(0).asSymbol;
		~pnmf[noteName] = Buffer.read(s, file.fullPath);
	};*/

/*	PathName(pnppFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(0).asSymbol;
		~pnpp[noteName] = Buffer.read(s, file.fullPath);
	};*/

/*	PathName(clFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~cl[noteName] = Buffer.read(s, file.fullPath);
	};*/

/*	PathName(fltFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(3).asSymbol;
		~flt[noteName] = Buffer.read(s, file.fullPath);
	};*/

/*	PathName(bassfltFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~bassflt[noteName] = Buffer.read(s, file.fullPath);
	};*/

/*	PathName(oboeFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~ob[noteName] = Buffer.read(s, file.fullPath);
	};*/

/*	PathName(bassoonFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~bsn[noteName] = Buffer.read(s, file.fullPath);
	};*/


	[
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulG.G3.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulG.Ab3.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulG.A3.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulG.Bb3.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulG.B3.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulG.C4.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulG.Db4.stereo.aif",

		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulD.D4.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulD.Eb4.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulD.E4.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulD.F4.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulG.Gb4.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulD.G4.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulD.Ab4.stereo.aif",

		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulA.A4.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulA.Bb4.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulA.B4.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulA.C5.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulA.Db5.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulA.D5.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulA.Eb5.stereo.aif",

		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.E5.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.F5.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.Gb5.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.G5.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.Ab5.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.A5.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.Bb5.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.B5.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.C6.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.Db6.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.D6.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.Eb6.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.E6.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.F6.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.Gb6.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.G6.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.Ab6.stereo.aif",
		~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.A6.stereo.aif",
		// ~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.Bb6.stereo.aif",
		// ~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.B6.stereo.aif",
		// ~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.C7.stereo.aif",
		// ~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.Db7.stereo.aif",
		// ~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.D7.stereo.aif",
		// ~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.Eb7.stereo.aif",
		// ~sampleLibraryRoot ++ "Violin-arco/Violin.arco.ff.sulE.E7.stereo.aif",
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
