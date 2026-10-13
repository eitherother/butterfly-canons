// ============================================================
// Purcell In Nomine — Rhythm
// ============================================================
// Load after signal_flow.scd.
//
// Named rhythm sequences referenced by scene via rhythm: \name.
// Each sequence is an array of steps; each step is an array
// indexed by flow. Entry format:
//   Bjorklund : (k:, n:, r:)
//   Manual    : (pat:)   — Array of 1s and 0s
//   nil       : skip (flow has no sequencer)
//
// Depth is owned by the MIDI \seqDepth dial — not set here.
// Use ~silenceRhythm to kill all sequencers in code.
//
// Public API:
//   ~advanceRhythm        — advance one step in the current scene's sequence
//   ~silenceRhythm        — set all sequencers to depth 0
//   ~applyRhythmStep(step)— apply one step array immediately
//   ~rhythmSequences      — Dictionary of named sequences (add yours here)
// ============================================================

(

// --- State ---
~bjPending        = Array.fill(8, { 0 });
~currentRhythmStep = 0;


// --- Low-level helpers ---

~updateSeq = { |flowIndex, k, n, rot|
	var pat     = Bjorklund(k, n).rotate(rot).as(FloatArray);
	var seqData = ~seqData[flowIndex];
	var seq     = ~seqs[flowIndex];
	seq.set(\len, n);
	if (~bjPending[flowIndex] == 0) {
		seqData[\bufB].sendCollection(pat);
		seqData[\pending].set(1);
		~bjPending[flowIndex] = 1;
	} {
		seqData[\bufA].sendCollection(pat);
		seqData[\pending].set(0);
		~bjPending[flowIndex] = 0;
	};
	"L% k=% n=% r=%".format(flowIndex + 1, k, n, rot).postln;
};

~updateSeqRaw = { |flowIndex, pat|
	var seqData = ~seqData[flowIndex];
	var seq     = ~seqs[flowIndex];
	seq.set(\len, pat.size);
	if (~bjPending[flowIndex] == 0) {
		seqData[\bufB].sendCollection(pat);
		seqData[\pending].set(1);
		~bjPending[flowIndex] = 1;
	} {
		seqData[\bufA].sendCollection(pat);
		seqData[\pending].set(0);
		~bjPending[flowIndex] = 0;
	};
	"L% n=%".format(flowIndex + 1, pat.size).postln;
};


// --- Apply a single step (array indexed by flow) ---

~applyRhythmStep = { |step|
	step.do { |entry, i|
		if (entry.notNil) {
			if (entry[\pat].notNil) {
				~updateSeqRaw.(i, entry[\pat].as(FloatArray))
			} {
				if (entry[\k].notNil) {
					~updateSeq.(i, entry[\k], entry[\n], entry[\r] ? 0)
				}
			}
		}
	}
};

~silenceRhythm = {
	~seqs.do { |sq| sq.set(\depth, 0.0) }
};


// --- Named sequences ---
// Each entry is an array of steps.
// Steps are arrays of 8 entries, one per flow (nil = leave that flow's sequencer as is).

~rhythmSequences = Dictionary.new;


// Compound grid (n=12 = triplet 8ths, 4 beats x 3) — a building arc of
// Bjorklund hits on triplet subdivisions.
~rhythmSequences[\tripletGrooves] = [
	// 1. Building
	[
		(k: 3, n: 12, r: 1),
		(k: 2, n: 12, r: 7),
		nil,nil,
		(k: 2, n: 12, r: 0),
		(k: 3, n: 12, r: 6),
		(k: 2, n: 12, r: 3),
		(k: 3, n: 12, r: 9),
	],
	// 2. Filling in
	[
		(k: 5, n: 12, r: 1),
		(k: 4, n: 12, r: 6),
		nil,nil,
		(k: 4, n: 12, r: 0),
		(k: 4, n: 12, r: 5),
		(k: 3, n: 12, r: 8),
		(k: 4, n: 12, r: 2),
	],
	// 3. Approaching climax
	[
		(k: 6, n: 12, r: 1),
		(k: 5, n: 12, r: 5),
		nil,nil,
		(k: 5, n: 12, r: 0),
		(k: 5, n: 12, r: 4),
		(k: 4, n: 12, r: 6),
		(k: 5, n: 12, r: 2),
	],
	// 4. Four-against-five — climax
	[
		(k: 8, n: 12, r: 1),
		(k: 6, n: 12, r: 5),
		nil,nil,
		(k: 8, n: 12, r: 0),
		(k: 5, n: 12, r: 7),
		(k: 6, n: 12, r: 6),
		(k: 5, n: 12, r: 4),
	],
	// 5. Dense drive — climax continues
	[
		(k: 8, n: 12, r: 1),
		(k: 6, n: 12, r: 5),
		nil,nil,
		(k: 7, n: 12, r: 0),
		(k: 5, n: 12, r: 4),
		(k: 7, n: 12, r: 6),
		(k: 5, n: 12, r: 2),
	],

];


// --- Navigation ---

~advanceRhythm = {
	if (~currentScene.notNil) {
		var seqName = ~score[~currentScene][\rhythm];
		var seq     = if (seqName.notNil) { ~rhythmSequences[seqName] } { nil };
		if (seq.notNil) {
			~currentRhythmStep = (~currentRhythmStep + 1) % seq.size;
			~applyRhythmStep.(seq[~currentRhythmStep]);
			"Rhythm %/% — %[%]".format(
				~currentRhythmStep + 1, seq.size, seqName, ~currentRhythmStep).postln;
		} {
			"Rhythm: scene has no rhythm sequence".postln;
		}
	}
};


// Initialise all sequencers silent
~silenceRhythm.();

"Purcell In Nomine rhythm ready — ~advanceRhythm / ~silenceRhythm".postln;

)

