// ============================================================
// Chrysalis Canons — Rhythm
// ============================================================
// Load after signal_flow.scd.
//
// Named rhythm sequences referenced by scene via rhythm: \name.
// Each sequence is an array of steps; each step is an array
// indexed by flow. Entry format:
//   Bjorklund : (k:, n:, r:)
//   Manual    : (pat:)   — Array of 1s and 0s
//   nil       : no sequencer — clears that flow's pattern to neutral (no gating)
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
		if (i < ~seqData.size) {
			if (entry.notNil) {
				if (entry[\pat].notNil) {
					~updateSeqRaw.(i, entry[\pat].as(FloatArray))
				} {
					if (entry[\k].notNil) {
						~updateSeq.(i, entry[\k], entry[\n], entry[\r] ? 0)
					}
				}
			} {
				// nil = no sequencer for this flow — clear to neutral rather
				// than leaving a previous scene/step's pattern in place.
				~updateSeqRaw.(i, FloatArray.fill(~seqNumSteps, { 1.0 }))
			}
		}
	}
};

~silenceRhythm = {
	~seqs.do { |sq| sq.set(\depth, 0.0) }
};

// Resets every flow's pattern buffers to all-1.0 (transparent — no gating
// regardless of depth) and drops the double-buffer pending state. Used when
// a scene declares rhythm: nil, so a stale pattern from the previous scene
// can't reappear the moment seqDepth is raised again.
~clearRhythm = {
	~seqData.do { |d, i|
		d[\bufA].sendCollection(FloatArray.fill(~seqNumSteps, { 1.0 }));
		d[\bufB].sendCollection(FloatArray.fill(~seqNumSteps, { 1.0 }));
		d[\pending].set(0);
		~seqs[i].set(\len, ~seqNumSteps);
	};
	~bjPending = Array.fill(8, { 0 });
};


// --- Named sequences ---

~rhythmSequences = Dictionary.new;

~rhythmSequences[\scene1] = [
	[
		(k: 6, n: 24, r: 2),
		(k: 4, n: 24, r: 14),
		(k: 6, n: 24, r: 8),
		nil,
		nil,
		(k: 6, n: 24, r: 12),
		(k: 4, n: 24, r: 6),
		(k: 6, n: 24, r: 18),
	],
	[
		(k: 9, n: 24, r: 0),
		(k: 8, n: 24, r: 3),
		(k: 9, n: 24, r: 5),
		nil,
		nil,
		(k: 9, n: 24, r: 13),
		(k: 8, n: 24, r: 19),
		(k: 9, n: 24, r: 21),
	],
	[
		(k: 6, n: 24, r: 0),
		(k: 8, n: 24, r: 2),
		(k: 9, n: 24, r: 4),
		nil,
		nil,
		(k: 8, n: 24, r: 14),
		(k: 9, n: 24, r: 18),
		(k: 6, n: 24, r: 22),
	],
];


~rhythmSequences[\scene2] = [
	[
		(k: 6,  n: 24, r: 2),
		(k: 12, n: 24, r: 0),
		(k: 6,  n: 24, r: 8),
		nil,
		nil,
		nil,
		nil,
		nil,
	],
	[
		(k: 5, n: 24, r: 2),
		(k: 7, n: 24, r: 9),
		(k: 5, n: 24, r: 16),
		nil,nil,nil,nil,nil,
	],
	[
		(k: 9, n: 18, r: 0),
		(k: 6, n: 18, r: 2),
		(k: 9, n: 18, r: 9),
		(k: 6, n: 18, r: 11),
		nil,nil,nil,nil,
	],
	[
		(k: 8,  n: 24, r: 2),
		(k: 12, n: 24, r: 0),
		(k: 8,  n: 24, r: 11),
		(k: 12, n: 24, r: 12),
		(k: 6,  n: 24, r: 8),
		nil,nil,nil,
	],
	[
		(k: 11, n: 24, r: 0),
		(k: 13, n: 24, r: 3),
		(k: 7,  n: 24, r: 9),
		(k: 11, n: 24, r: 14),
		(k: 13, n: 24, r: 17),
		(k: 7,  n: 24, r: 21),
		nil,nil,
	],
];


~rhythmSequences[\scene3] = [
	[
		(k: 6, n: 16, r: 2),
		(k: 5, n: 16, r: 8),
		(k: 5, n: 16, r: 13),
		nil,
		nil,
		nil,
		nil,
		(k: 5, n: 16, r: 2),
	],
	[
		(k: 8, n: 16, r: 2),
		(k: 7, n: 16, r: 7),
		(k: 7, n: 16, r: 10),
		nil,
		nil,
		nil,
		nil,
		(k: 7, n: 16, r: 3),
	],
	[
		(k: 6, n: 16, r: 2),
		(k: 8, n: 16, r: 8),
		(k: 6, n: 16, r: 13),
		(k: 8, n: 16, r: 4),
		nil,
		nil,
		nil,
		(k: 7, n: 16, r:  2),
	],
	[
		(k: 6, n: 16, r: 2),
		(k: 8, n: 16, r: 2),
		(k: 6, n: 16, r: 10),
		(k: 4, n: 16, r: 5),
		(k: 5, n: 16, r: 0),
		nil,
		nil,
		nil,
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

"Chrysalis Canons rhythm ready — ~advanceRhythm / ~silenceRhythm".postln;

)

