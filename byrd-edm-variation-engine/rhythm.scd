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


// 4/4 grid (n=16 = straight 16ths, 4 beats x 4) — a five-step arc.
// Flows 1–4 interlock as one four-voice part: 1 and 2 are the low pair
// (held 1s = longer pulses on the drones), 3 and 4 the upper hocket.
// Each 16th mostly belongs to one voice; the climax adds unison accents.
// Flows 5–8 are nil (their sequencers are left alone).
~rhythmSequences[\fourFourGrooves] = [
	// 1. Pocket — low pair on the downbeats, 3 on every "and", 4 in the cracks
	//    beat:  1 . . . 2 . . . 3 . . . 4 . . .
	[
		(pat: [1,1,0,0, 0,0,0,0, 1,1,0,1, 0,0,0,0]),
		(pat: [0,0,0,1, 1,0,0,0, 0,0,0,0, 0,1,0,0]),
		(pat: [0,0,1,0, 0,0,1,0, 0,0,1,0, 0,0,1,0]),
		(pat: [0,0,0,0, 0,1,0,1, 0,0,0,0, 1,0,0,0]),
		nil, nil, nil, nil,
	],
	// 2. Call and response — 1 plays 3-3-2 in the first half, 2 answers it
	//    in the second; 3 and 4 fill every remaining 16th
	[
		(pat: [1,0,0,1, 0,0,1,0, 0,0,0,0, 0,0,0,0]),
		(pat: [0,0,0,0, 0,0,0,0, 1,0,0,1, 0,0,1,0]),
		(pat: [0,1,0,0, 1,0,0,0, 0,1,0,0, 1,0,0,0]),
		(pat: [0,0,1,0, 0,1,0,1, 0,0,1,0, 0,1,0,1]),
		nil, nil, nil, nil,
	],
	// 3. Cascade — 1→2→3 roll in groups of three against the 4/4 bar;
	//    4 doubles the pickups on 7 and 15
	[
		(pat: [1,0,0,1, 0,0,1,0, 0,1,0,0, 1,0,0,0]),
		(pat: [0,1,0,0, 1,0,0,1, 0,0,1,0, 0,1,0,0]),
		(pat: [0,0,1,0, 0,1,0,0, 1,0,0,1, 0,0,1,0]),
		(pat: [0,0,0,0, 0,0,0,1, 0,0,0,0, 0,0,0,1]),
		nil, nil, nil, nil,
	],
	// 4. Climax — all four dense, landing together on 1, 2-and, 3, 4-and
	[
		(pat: [1,1,0,1, 0,0,1,0, 1,1,0,1, 0,0,1,0]),
		(pat: [1,0,1,0, 1,0,1,0, 1,0,1,0, 0,1,1,0]),
		(pat: [1,0,0,1, 1,0,1,1, 1,0,0,1, 1,0,1,1]),
		(pat: [1,1,1,0, 0,1,1,0, 1,1,1,0, 0,1,1,1]),
		nil, nil, nil, nil,
	],
	// 5. Breakdown — one swell, then single hits passed down the line
	[
		(pat: [1,1,1,0, 0,0,0,0, 0,0,0,0, 0,0,0,0]),
		(pat: [0,0,0,0, 0,0,1,0, 0,0,0,0, 0,0,0,0]),
		(pat: [0,0,0,0, 0,0,0,0, 0,0,1,0, 0,0,0,0]),
		(pat: [0,0,0,0, 0,0,0,0, 0,0,0,0, 0,1,0,1]),
		nil, nil, nil, nil,
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

