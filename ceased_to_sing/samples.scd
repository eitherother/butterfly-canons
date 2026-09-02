
	~piano = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/forest/ceased_to_sing_piano.mp3");
~vib[\G6].play

(

~bass = Dictionary.new;
~cl   = Dictionary.new;
~vib = Dictionary.new;

// Signaled once loading finishes — init.scd waits on this instead of
// s.sync, since buffer loading runs in its own Routine (~load_samples),
// independent of whatever fork/routine called load() on this file.
~buffersLoaded = Condition.new;

~load_samples = Routine {
	var clFolder = ~sampleLibraryRoot ++ "Clarinet/post2012/";
	var vibFolder = ~sampleLibraryRoot ++ "Vibraphone.bow.stereo/";

	~silence = Buffer.read(s, ~sampleLibraryRoot ++ "silence.wav");

	~footsteps = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/forest/ceased_to_sing_footsteps.mp3");

	~piano = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/forest/ceased_to_sing_piano.mp3");

	~traffic = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/forest/ceased_to_sing_traffic.mp3");

/*	~leaves_1 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/forest/ceased_to_sing_leaves.mp3", 0);
	~leaves_2 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/forest/ceased_to_sing_leaves.mp3", 44100);
	~leaves_3 = Buffer.read(s, "/Volumes/Samsung_T1/SoundFiles/recordings/forest/ceased_to_sing_leaves.mp3", 44100*2);*/


	PathName(vibFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~vib[noteName] = Buffer.read(s, file.fullPath);
	};


	PathName(clFolder).files.do { |file|
		var noteName = file.fileNameWithoutExtension.split($.).at(2).asSymbol;
		~cl[noteName] = Buffer.read(s, file.fullPath);
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
	~buffersLoaded.test = true;
	~buffersLoaded.signal;
}.play;
)
