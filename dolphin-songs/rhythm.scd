// ============================================================
// Whale Songs — Rhythm
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


// 4/4 grid (n=16 = straight 16ths) — a five-step flutter.
// Flows 1–3 hand single 16ths back and forth like wingbeats: nearly every
// 16th belongs to exactly one voice, so the pulse flickers between them.
// Flows 4–8 are nil (their sequencers are left alone).
~rhythmSequences[\flutter] = [
	// 1. Takeoff — gaps between hand-offs shrink across the bar
	//    beat:  1 . . . 2 . . . 3 . . . 4 . . .
	[
		(pat: [1,0,0,0, 0,0,0,0, 1,0,0,0, 0,1,0,0]),
		(pat: [0,0,0,1, 0,0,0,0, 0,0,1,0, 0,0,1,0]),
		(pat: [0,0,0,0, 0,0,1,0, 0,0,0,0, 1,0,0,1]),
		nil, nil, nil, nil, nil,
	],
	// 2. Shimmer — unbroken 1→2→3 rotation, groups of three against the bar
	[
		(pat: [1,0,0,1, 0,0,1,0, 0,1,0,0, 1,0,0,1]),
		(pat: [0,1,0,0, 1,0,0,1, 0,0,1,0, 0,1,0,0]),
		(pat: [0,0,1,0, 0,1,0,0, 1,0,0,1, 0,0,1,0]),
		nil, nil, nil, nil, nil,
	],
	// 3. Wingbeats — 1→2→3 sweep, then back 3→2→1, a breath after each
	[
		nil,//(pat: [1,0,0,0, 0,0,1,0, 1,0,0,0, 0,0,1,0]),
		(pat: [0,1,0,0, 0,1,0,0, 0,1,0,0, 0,1,0,0]),
		(pat: [0,0,1,0, 1,0,0,0, 0,0,1,0, 1,0,0,0]),
		nil, nil, nil, nil, nil,
	],
	// 4. Trill — 1/2 trill the first half, 2/3 the second; 1 picks it back up on 16
	[
		(pat: [1,0,1,0, 1,0,1,0, 0,0,0,0, 0,0,0,1]),
		(pat: [0,1,0,1, 0,1,0,1, 0,1,0,1, 0,1,0,0]),
		(pat: [0,0,0,0, 0,0,0,0, 1,0,1,0, 1,0,1,0]),
		nil, nil, nil, nil, nil,
	],
	// 5. Settle — flutter decays: tight rotation up front, thinning out
	[
		(pat: [1,0,0,1, 0,0,0,0, 0,0,1,0, 0,0,0,0]),
		(pat: [0,1,0,0, 0,1,0,0, 0,0,0,0, 0,1,0,0]),
		(pat: [0,0,1,0, 0,0,0,1, 0,0,0,0, 0,0,0,0]),
		nil, nil, nil, nil, nil,
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

"Whale Songs rhythm ready — ~advanceRhythm / ~silenceRhythm".postln;

)

