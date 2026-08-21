// Best-effort syntax check for .scd files: compiles each file without
// executing it, so it catches parse errors without needing a booted
// server, MIDI devices, or sample files. Not a substitute for real
// testing (SuperCollider has no test framework) — just a CI smoke check.
(
var dir = thisProcess.argv[0];
var failed = false;
var files = PathName(dir).deepFiles.select({ |f| f.extension == "scd" });

if (files.isEmpty) {
	"No .scd files found under %".format(dir).postln;
	0.exit;
};

files.do({ |f|
	var code = File.readAllString(f.fullPath);
	var compiled = thisProcess.interpreter.compile(code, f.fullPath);
	if (compiled.isNil) {
		"SYNTAX ERROR: %".format(f.fullPath).postln;
		failed = true;
	} {
		"ok: %".format(f.fullPath).postln;
	};
});

if (failed) {
	"One or more .scd files failed to compile.".postln;
	1.exit;
} {
	"All .scd files compiled successfully.".postln;
	0.exit;
};
)
