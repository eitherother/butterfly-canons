// ============================================================
// TVP3 — Rhythm
// ============================================================
// Load after tvp3_signal_flow.scd.
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
// Steps are arrays [flow0_entry, flow1_entry, flow2_entry, flow3_entry, ...].
// Flows 4-6 omitted here — extend the arrays if those flows get sequencers.

~rhythmSequences = Dictionary.new;

~rhythmSequences[\grooves] = [
/*	// 1. Open — sparse, mostly space
	[
		(k: 3, n: 16, r: 2),
		(k: 2, n: 16, r: 10),
		(k: 3, n: 16, r: 6),
		nil,//(k: 2, n: 16, r: 14),
		nil,//(k: 2, n: 16, r: 0),
		(k: 3, n: 16, r: 8),
		(k: 2, n: 16, r: 4),
		(k: 3, n: 16, r: 12),
	],
	// 2. Building
	[
		(k: 4, n: 16, r: 2),
		(k: 3, n: 16, r: 10),
		(k: 4, n: 16, r: 6),
		nil,//(k: 3, n: 16, r: 14),
		nil,//(k: 3, n: 16, r: 0),
		(k: 4, n: 16, r: 8),
		(k: 3, n: 16, r: 4),
		(k: 4, n: 16, r: 12),
	],*/
	// 3. Filling in
	[
		(k: 6, n: 16, r: 2),
		(k: 5, n: 16, r: 8),
		(k: 5, n: 16, r: 13),
		nil,//(k: 4, n: 16, r: 4),
		nil,//(k: 5, n: 16, r: 0),
		(k: 5, n: 16, r: 6),
		(k: 4, n: 16, r: 11),
		(k: 5, n: 16, r: 2),
	],
	// 4. Approaching climax
	[
		(k: 8, n: 16, r: 2),
		(k: 7, n: 16, r: 7),
		nil,//(k: 7, n: 16, r: 10),
		nil,//(k: 6, n: 16, r: 5),
		(k: 7, n: 16, r: 0),
		(k: 6, n: 16, r: 5),
		(k: 6, n: 16, r: 8),
		(k: 7, n: 16, r: 3),
	],
	// 5. Dense drive — climax
	[
		(k: 10, n: 16, r: 2),
		(k: 8, n: 16, r: 7),
		(k: 8, n: 16, r: 10),
		nil,//(k: 8, n: 16, r: 5),
		nil,//(k: 9, n: 16, r: 0),
		(k: 7, n: 16, r: 5),
		(k: 9, n: 16, r: 8),
		(k: 7, n: 16, r: 3),
	],
	// 6. Five-against-seven — climax continues
	[
		(k: 6, n: 16, r: 2),
		(k: 8, n: 16, r: 8),
		(k: 6, n: 16, r: 13),
		nil,//(k: 8, n: 16, r: 4),
		nil,//(k: 5, n: 16, r:  0),
		(k: 7, n: 16, r:  6),
		(k: 5, n: 16, r: 11),
		(k: 7, n: 16, r:  2),
	],
	// 7. Interlocking offsets — receding
	[
		(k: 6, n: 16, r: 2),
		(k: 8, n: 16, r: 2),
		(k: 6, n: 16, r: 10),
		nil,//(k: 4, n: 16, r: 5),
		nil,//(k: 5, n: 16, r: 0),
		(k: 7, n: 16, r: 0),
		(k: 5, n: 16, r: 8),
		(k: 3, n: 16, r: 3),
	],
	// 8. Thinning
	[
		(k: 5, n: 16, r: 2),
		(k: 6, n: 16, r: 10),
		(k: 4, n: 16, r: 6),
		nil,//(k: 5, n: 16, r: 14),
		nil,//(k: 4, n: 16, r: 0),
		(k: 5, n: 16, r: 8),
		(k: 3, n: 16, r: 4),
		(k: 4, n: 16, r: 12),
	],
	// 9. Fade — sparser than the opening, before the loop back to step 1
	[
		(k: 2, n: 16, r: 2),
		(k: 3, n: 16, r: 10),
		(k: 2, n: 16, r: 6),
		nil,//(k: 3, n: 16, r: 14),
		nil,//(k: 1, n: 16, r: 0),
		(k: 2, n: 16, r: 8),
		(k: 1, n: 16, r: 4),
		(k: 2, n: 16, r: 12),
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

"TVP3 rhythm ready — ~advanceRhythm / ~silenceRhythm".postln;

)

