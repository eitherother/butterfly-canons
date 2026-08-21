// ============================================================
// TVP3 — Init
// ============================================================
// BLOCK 0: Evaluate first of all. Loads local machine paths from
//          config.scd (repo root) — see config.example.scd.
//
// BLOCK 1: Evaluate next. Boots server, loads synths, signal
//          flow, and starts async buffer loading.
//          Wait for "Buffers loaded" in the post window.
//
// BLOCK 2: Evaluate after "Buffers loaded". Loads conductor,
//          rhythm, score, and calls ~loadScene.(0).
//
// Then load tvp3_midi.scd manually (needs MIDIOut device index).
// ============================================================

// ---- Block 0: Load local machine config ---------------------
(
var dir = thisProcess.nowExecutingPath.dirname;
var configPath = dir +/+ ".." +/+ "config.scd";
if (File.exists(configPath)) {
	load(configPath);
} {
	Error(
		"Missing %.\nCopy config.example.scd to config.scd (repo root) and fill in your local paths.".format(configPath)
	).throw;
};
)

// ---- Block 1 -----------------------------------------------
(
var dir = thisProcess.nowExecutingPath.dirname;
s.waitForBoot {
	fork {
		load(dir +/+ "synths.scd");
		s.sync;
		load(dir +/+ "signal_flow.scd");
		s.sync;
		load(dir +/+ "samples.scd");
	};
};
)


// ---- Block 2 (after "Buffers loaded") ----------------------
(
var dir = thisProcess.nowExecutingPath.dirname;
load(dir +/+ "conductor.scd");
load(dir +/+ "rhythm.scd");
load(dir +/+ "score.scd");
MIDIIn.connectAll;


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

~record.("Piffaro_butterfly_canon_01_SolorIstus_");

~stopRecording.()


~loadScene.(2, 0);

// to do
// make buffers of different lengths
// button to switch/rotate witch


