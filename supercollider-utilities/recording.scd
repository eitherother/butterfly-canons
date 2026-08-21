// Shared recording helpers, common to every piece. Reads ~recordDir (set
// by config.scd) as the default output directory.
(
~record = { |baseName = "improv", dir|
	var i = 1, path;
	if (dir.isNil) { dir = ~recordDir };
	while {
		path = dir ++ baseName ++ i.asString.padLeft(2, "0") ++ ".wav";
		File.exists(path)
	} { i = i + 1 };
	s.record(path: path);
	("Recording to: " ++ path).postln;
};
~stopRecording = { s.stopRecording };
)
