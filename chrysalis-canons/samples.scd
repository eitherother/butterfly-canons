
(
~bass = Dictionary.new;

~cl   = Dictionary.new;
~flt  = Dictionary.new;
~ob   = Dictionary.new;
~marimba = Dictionary.new;
~vib = Dictionary.new;
~vibbow = Dictionary.new;


// Signaled once loading finishes — init.scd waits on this instead of
// s.sync, since buffer loading runs in its own Routine (~load_samples),
// independent of whatever fork/routine called load() on this file.
~buffersLoaded = Condition.new;

~load_samples = Routine {
	var clFolder     = ~sampleLibraryRoot ++ "Clarinet/post2012/";
	var fltFolder    = ~sampleLibraryRoot ++ "Flute/";
	var oboeFolder   = ~sampleLibraryRoot ++ "Oboe/";
	var marimbafolder = ~sampleLibraryRoot ++ "Marimba.cord.ff.stereo/";
	var vibFolder = ~sampleLibraryRoot ++ "Vibraphone.sustain.ff.stereo/";
	var vibBowFolder = ~sampleLibraryRoot ++ "Vibraphone.bow.stereo/";

	~silence = Buffer.read(s, ~sampleLibraryRoot ++ "silence.wav");
	~piffaro_1_1 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/13 - A solis ortus cardine.wav", 0);
	~piffaro_1_2 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/13 - A solis ortus cardine.wav", 44100/4);
	~piffaro_1_3 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/13 - A solis ortus cardine.wav", 44100/2);
	~piffaro_1_4 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/13 - A solis ortus cardine.wav", 3/4*44100);

	~piffaro_2_1 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/14 - A solis ortus cardine.wav", 0);
	~piffaro_2_2 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/14 - A solis ortus cardine.wav", 44100/3);
	~piffaro_2_3 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/14 - A solis ortus cardine.wav", 2/3*44100);
	~piffaro_2_4 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/14 - A solis ortus cardine.wav", 44100);


	~piffaro_piano = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/piffaro_piano.WAV");
	~piffaro_3_1 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/16 - Christum wir sollen loben schon (Hymnus).wav", 0);
	~piffaro_3_2 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/16 - Christum wir sollen loben schon (Hymnus).wav", 1/3*44100);
	~piffaro_3_3 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/16 - Christum wir sollen loben schon (Hymnus).wav", 2/3*44100);
	~piffaro_3_4 = Buffer.read(s, ~sampleLibraryRoot ++ "recordings/Piffaro/Back Before Bach- Musical Journeys/16 - Christum wir sollen loben schon (Hymnus).wav", 3/3*44100);


	PathName(marimbafolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(3).asSymbol;
		~marimba[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(vibFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(3).asSymbol;
		~vib[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(vibBowFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~vibbow[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(clFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~cl[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(fltFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(3).asSymbol;
		~flt[noteName] = Buffer.read(s, file.fullPath);
	};

	PathName(oboeFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~ob[noteName] = Buffer.read(s, file.fullPath);
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
