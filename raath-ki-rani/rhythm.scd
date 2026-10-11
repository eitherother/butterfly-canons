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
// Each entry is an array of steps.
// Steps are arrays [flow0_entry, flow1_entry, flow2_entry, flow3_entry, ...].
// Flows 4-6 omitted here — extend the arrays if those flows get sequencers.

~rhythmSequences = Dictionary.new;


~rhythmSequences[\imitation] = [
	[
		(pat: #[1,0,0,0, 1,0,1,0, 1,1,1,0, 0,1,1,0]),

		(pat: #[1,0, 1,0,0,0, 1,0,1,0, 1,1,1,0, 0,1]),

		(pat: #[0,1,1,0, 1,0,0,0, 1,0,1,0, 1,1,1,0]),
		nil,nil,nil,nil,
		(pat: #[1,0, 0,1,1,0, 1,0,0,0, 1,0,1,0, 1,1]),
	],
	[
		(pat: #[1,0,1,0, 0,1,1,0, 1,0,1,0, 1,0,0,0]),
		(pat: #[1,0,0,0, 1,0,0,0, 1,0,1,0, 0,1,1,0]),
		(pat: #[0,0, 1,0,1,0, 0,1,1,0, 1,0,1,0, 1,0]),

		nil,nil,nil,nil,
		(pat: #[1,0, 1,0,0,0, 1,0,0,0, 1,0,1,0, 0,1]),
	],
	[
		(pat: #[1,0,0,1, 1,0,1,0, 0,0,1,0, 1,0,0,0]),
		(pat: #[0,0, 1,0,0,1, 1,0,1,0, 0,0,1,0, 1,0]),
		(pat: #[1,0,0,0, 1,0,1,0, 1,0,0,0, 1,0,0,0]),

		nil,nil,nil,nil,
		(pat: #[0, 1,0,0,0, 1,0,1,0, 1,0,0,0, 1,0, 0]),
	],
];



~rhythmSequences[\gloria] = [
	[
		(pat: #[1,0,0,1, 1,0,1,0, 1,0,1,1, 0,1,1,0]),

		(pat: #[1,0, 1,0,0,1, 1,0,1,0, 1,0,1,1, 0,1]),

		(pat: #[0,1,1,0, 1,0,0,1, 1,0,1,0, 1,0,1,1]),
		nil,nil,nil,nil,nil
	],

];

~rhythmSequences[\scene3] = [
	// 3. Filling in
	[
		(k: 6, n: 16, r: 2),
		(k: 5, n: 16, r: 8),
		(k: 5, n: 16, r: 13),
		nil,//(k: 4, n: 16, r: 4),
		nil,//(k: 5, n: 16, r: 0),
		nil,//(k: 5, n: 16, r: 6),
		nil,//(k: 4, n: 16, r: 11),
		(k: 5, n: 16, r: 2),
	],
	// 4. Approaching climax
	[
		(k: 8, n: 16, r: 2),
		(k: 7, n: 16, r: 7),
		(k: 7, n: 16, r: 10),
		nil,//(k: 6, n: 16, r: 5),
		nil,//(k: 7, n: 16, r: 0),
		nil,//(k: 6, n: 16, r: 5),
		nil,//(k: 6, n: 16, r: 8),
		(k: 7, n: 16, r: 3),
	],
	// 5. Dense drive — climax
/*	[
		(k: 10, n: 16, r: 2),
		nil,//(k: 8, n: 16, r: 7),
		nil,//(k: 8, n: 16, r: 10),
		(k: 8, n: 16, r: 5),
		(k: 9, n: 16, r: 0),
		(k: 7, n: 16, r: 5),
		(k: 9, n: 16, r: 8),
		nil,//(k: 7, n: 16, r: 3),
	],*/
	// 6. Five-against-seven — climax continues
	[
		(k: 6, n: 16, r: 2),
		(k: 8, n: 16, r: 8),
		(k: 6, n: 16, r: 13),
		(k: 8, n: 16, r: 4),
		nil,//(k: 5, n: 16, r:  0),
		nil,//(k: 7, n: 16, r:  6),
		nil,//(k: 5, n: 16, r: 11),
		(k: 7, n: 16, r:  2),
	],
	// 7. Interlocking offsets — receding
	[
		(k: 6, n: 16, r: 2),
		(k: 8, n: 16, r: 2),
		(k: 6, n: 16, r: 10),
		(k: 4, n: 16, r: 5),
		(k: 5, n: 16, r: 0),
		nil,//(k: 7, n: 16, r: 0),
		nil,//(k: 5, n: 16, r: 8),
		nil,//(k: 3, n: 16, r: 3),
	],
	// 8. Thinning
/*	[
		nil,//(k: 5, n: 16, r: 2),
		nil,//(k: 6, n: 16, r: 10),
		nil,//(k: 4, n: 16, r: 6),
		(k: 5, n: 16, r: 14),
		(k: 4, n: 16, r: 0),
		(k: 5, n: 16, r: 8),
		(k: 3, n: 16, r: 4),
		(k: 4, n: 16, r: 12),
	],*/
	// 9. Fade — sparser than the opening, before the loop back to step 1
	[
		(k: 2, n: 16, r: 2),
		(k: 3, n: 16, r: 10),
		(k: 2, n: 16, r: 6),
		(k: 3, n: 16, r: 14),
		(k: 1, n: 16, r: 0),
		(k: 2, n: 16, r: 8),
		(k: 1, n: 16, r: 4),
		(k: 2, n: 16, r: 12),
	],
	[
		nil,nil,nil,nil,nil,nil,nil,nil
	]
];


// Additive grid (n=24). Every k below is a divisor of 24 (4, 6, 8, 12), so
// every voice's gap-decomposition remainder is exactly 0 — each flow taps a
// perfectly even pulse (period = 24/k: 6, 4, 3, or 2 steps) with no internal
// syncopation. Rotations are chosen deliberately (not just spread out) so
// that r mod period collapses across flows into 2-3 clean shared phases per
// k-value, instead of 8 flows landing at 8 scattered phases — e.g. step 1's
// k=6 flows all land on phase 0 or phase 2 (mod 4), so there are really only
// two rhythmic identities in that family, each doubled, rather than four
// independent ones. That's what keeps a step feeling locked-in rather than
// smeared even as density rises. Pairing periods 4&6 (ratio 2:3) or 3&2
// (ratio 3:2) also keeps every step's cross-rhythm a genuine consonant
// polymeter (a 2-against-3 family relationship) rather than an arbitrary
// clash. The arc climbs through the divisor lattice — 6&4 -> 6&12 -> 12&8 —
// getting denser (shorter periods) each step while staying exactly this
// clean the whole way.
~rhythmSequences[\scene1] = [
	// 1. Building — periods 4 & 6 (ratio 2:3), 2 phases each
	[
		(k: 6, n: 24, r: 2),
		(k: 4, n: 24, r: 14),
		(k: 6, n: 24, r: 8),
		(k: 4, n: 24, r: 20),
		nil,// (k: 4, n: 24, r: 0),
		(k: 6, n: 24, r: 12),
		(k: 4, n: 24, r: 6),
		(k: 6, n: 24, r: 18),
	],
];


~rhythmSequences[\scene2] = [
	[
		(k: 6,  n: 24, r: 2),
		(k: 12, n: 24, r: 0),
		(k: 6,  n: 24, r: 8),
		nil,//(k: 12, n: 24, r: 1),
		nil,//(k: 12, n: 24, r: 12),
		nil,//(k: 6,  n: 24, r: 12),
		nil,//(k: 12, n: 24, r: 13),
		nil,//(k: 6,  n: 24, r: 18),
		// nil,nil,nil,nil
	],
];

// Fluttering leaves — genuinely randomised, irregular gating so no pulse
// ever reads as "the beat". Each flow gets its own odd/prime-ish pattern
// length (11, 13, 17, 19, 23, 29, 31...) so the flows never share a common
// period and can't lock into an obvious meter against each other, and each
// step's hits are coin-flipped at a low probability so the pattern itself
// has no internal repeat either. Re-evaluate this file to reroll all five.
// Advance through the 5 steps live (~advanceRhythm) to audition them.
~rhythmSequences[\leaves] = [
	// 1. Faint breeze — very sparse, only a few flows stirring
	[
		(pat: Array.fill(11, { if (0.15.coin) { 1 } { 0 } })),
		nil,
		(pat: Array.fill(17, { if (0.12.coin) { 1 } { 0 } })),
		nil,
		nil,
		(pat: Array.fill(13, { if (0.15.coin) { 1 } { 0 } })),
		nil,
		(pat: Array.fill(19, { if (0.10.coin) { 1 } { 0 } })),
	],
	// 2. Gathering flutter — more flows join, still light
	[
		(pat: Array.fill(13, { if (0.22.coin) { 1 } { 0 } })),
		(pat: Array.fill(19, { if (0.18.coin) { 1 } { 0 } })),
		(pat: Array.fill(11, { if (0.20.coin) { 1 } { 0 } })),
		nil,
		(pat: Array.fill(23, { if (0.15.coin) { 1 } { 0 } })),
		nil,
		(pat: Array.fill(17, { if (0.18.coin) { 1 } { 0 } })),
		(pat: Array.fill(29, { if (0.12.coin) { 1 } { 0 } })),
	],
	// 3. Uneven gusts — some flows agitated, others nearly still
	[
		(pat: Array.fill(11, { if (0.35.coin) { 1 } { 0 } })),
		(pat: Array.fill(17, { if (0.08.coin) { 1 } { 0 } })),
		(pat: Array.fill(23, { if (0.30.coin) { 1 } { 0 } })),
		(pat: Array.fill(13, { if (0.10.coin) { 1 } { 0 } })),
		nil,
		(pat: Array.fill(19, { if (0.32.coin) { 1 } { 0 } })),
		(pat: Array.fill(29, { if (0.09.coin) { 1 } { 0 } })),
		nil,
	],
	// 4. Full canopy — all flows stirring, moderate and even density
	[
		(pat: Array.fill(23, { if (0.20.coin) { 1 } { 0 } })),
		(pat: Array.fill(19, { if (0.20.coin) { 1 } { 0 } })),
		(pat: Array.fill(29, { if (0.20.coin) { 1 } { 0 } })),
		(pat: Array.fill(17, { if (0.20.coin) { 1 } { 0 } })),
		(pat: Array.fill(31, { if (0.20.coin) { 1 } { 0 } })),
		(pat: Array.fill(13, { if (0.20.coin) { 1 } { 0 } })),
		(pat: Array.fill(11, { if (0.20.coin) { 1 } { 0 } })),
		(pat: Array.fill(23, { if (0.20.coin) { 1 } { 0 } })),
	],
	// 5. Dying breeze — mostly silent, the odd leaf still twitching
	[
		(pat: Array.fill(19, { if (0.08.coin) { 1 } { 0 } })),
		nil,
		nil,
		(pat: Array.fill(13, { if (0.06.coin) { 1 } { 0 } })),
		nil,
		nil,
		(pat: Array.fill(17, { if (0.07.coin) { 1 } { 0 } })),
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

"TVP3 rhythm ready — ~advanceRhythm / ~silenceRhythm".postln;

)

