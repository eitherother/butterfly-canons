// ============================================================
// Purcell In Nomine — Init
// ============================================================
// Evaluate the block below once: loads local config, boots the
// server, loads synths → signal flow → samples (waiting for
// buffers to actually finish loading), then conductor → rhythm →
// score, connects MIDI input, and wires up midi.scd. Watch the
// post window for "Ready to play." when it's done.
//
// Then, whenever you want (performance-time, not init):
//   ~loadScene.(sceneIndex, preAdvance)   — start/switch a scene
//   ~record.(baseName)                    — start recording
//   ~stopRecording.()                     — stop recording
// ============================================================

(
var dir = thisProcess.nowExecutingPath.dirname;
var configPath = dir +/+ ".." +/+ "config.scd";
var utilDir = dir +/+ ".." +/+ "supercollider-utilities";

if (File.exists(configPath)) {
	load(configPath);
} {
	Error(
		"Missing %.\nCopy config.example.scd to config.scd (repo root) and fill in your local paths.".format(configPath)
	).throw;
};

load(utilDir +/+ "recording.scd");

s.waitForBoot {
	fork {
		load(dir +/+ "synths.scd");
		s.sync;
		load(dir +/+ "signal_flow.scd");
		s.sync;
		load(dir +/+ "samples.scd");
		~buffersLoaded.wait;
		load(dir +/+ "conductor.scd");
		load(dir +/+ "rhythm.scd");
		load(dir +/+ "score.scd");
		MIDIIn.connectAll;
		load(dir +/+ "midi.scd");
		"Ready to play. Evaluate ~loadScene.(sceneIndex, preAdvance) to start.".postln;
	};
};
)

// ---- Performance-time actions — evaluate individually, whenever -----
~record.("Purcell_InNomine_");

~stopRecording.()


~loadScene.(0, 0);
