// ============================================================
// TVP3 — Init
// ============================================================
// BLOCK 1: Evaluate first. Boots server, loads synths, signal
//          flow, and starts async buffer loading.
//          Wait for "Buffers loaded" in the post window.
//
// BLOCK 2: Evaluate after "Buffers loaded". Loads conductor,
//          rhythm, score, and calls ~loadScene.(0).
//
// Then load tvp3_midi.scd manually (needs MIDIOut device index).
// ============================================================

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


~record = { |baseName = "improv", dir = "/Volumes/Samsung_T1/improv/"|
    var i = 1, path;
    while {
        path = dir ++ baseName ++ i.asString.padLeft(2, "0") ++ ".wav";
        File.exists(path)
    } { i = i + 1 };
    s.record(path: path);
    ("Recording to: " ++ path).postln;
};
~stopRecording = { s.stopRecording };
)

~record.("Purcell_InNomine_");

~stopRecording.()


~loadScene.(0, 0);



