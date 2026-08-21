// ============================================================
// TVP3 — Score
// ============================================================
// Each scene has a flows array of exactly 8 elements (nil = inactive).
// Each flow is a granular voice. Each flow declares its own dial types via dials:.
//
// ---- Flow type: type: \granular (default) | \buffer | \warp ----
//   \granular/\buffer are Pbind-driven — see the granular/buffer params below.
//   \warp is a persistent Synth (Warp1), not Pbind-driven: it continuously
//   loops through steps[0]'s single buffer. Its own params (replace
//   grainWidth/grainCenter/dur/attack/etc — those are ignored):
//     pitchScale:   1.0  — playback pitch multiplier (fixed Number, no dial);
//                          0.5 = octave down, 2.0 = octave up
//     stretchScale: 1.0  — buffer-traversal speed (fixed Number, no dial);
//                          1.0 = natural/"at speed", smaller = slower/smeared
//   Mixer-level dials (tremDepth etc.) still work normally. Excluded from
//   harmony-advance stepping — steps[0] is all it ever plays.
//
// ---- Value formats ----
// Most flow/step params accept three formats:
//   Number              fixed value, dial has no effect
//   Pattern             e.g. Pwhite(0.18, 0.24) — per-grain random, dial has no effect
//   [min, max]          dial-controlled, starts at min (normalised 0.0)
//   [min, max, init]    dial-controlled, starts at init
//
// ---- Flow-level params and defaults ----
//   freeze:     false         — route grains to freeze bus (pre-fader)
//   spectral:   false         — route grains to spectral bus (pre-fader, like freeze)
//   delay:      false         — tap flow to global delay send
//   amp:        0.08          — grain amplitude
//   dur:        0.5           — grain firing interval (seconds); Pattern for variation
//   attack:     0.05          — grain attack (seconds); use 0.5 for smooth wash
//   release:    0.05          — grain release (seconds); use 0.5 for smooth wash
//   grainWidth: 0.2           — playback window as buffer fraction; Number/Pattern/[min,max,init]
//   grainCenterLag: 0.15      — fraction of remaining distance to new grainCenter target
//                               closed per grain (0-1); 1.0 = instant jump (old behavior),
//                               smaller = slower glide when the counter is bumped
//   seqDepth:   0.0           — step-sequencer gating depth; Number or [min,max,init]; overridden live by MIDI dial if declared in dials:
//   tremDepth:  0.0           — tremolo depth; Number or [min,max,init]
//   tremRate:   4.0           — tremolo rate (Hz); fixed, not dial-controlled
//   tremPhase:  0.0           — tremolo phase offset (radians, 0–2pi); default 0
//   tremDepth2: 0.0           — second tremolo depth; Number or [min,max,init]
//   tremRate2:  2.0           — second tremolo rate (Hz)
//   tremPhase2: 0.0           — second tremolo phase offset (radians, 0–2pi); default 0
//   rate:       1             — playback rate multiplier
//
// ---- Step-level params ----
//   buffers:    (required)    — array of buffer objects (~flt[\G3] etc.)
//   repeats:    [1]           — repeat counts; cycles via LCM with buffers array
//   grainCenter: 0.3          — buffer position (0.0–1.0); seeds Dial 2 on load
//
// ---- Scene-level params ----
//   name:           (required)
//   stepRate:       8         — sequencer steps per second (8 = 120 BPM at 16 steps)
//   delayTime:      0.35      — global delay time (seconds)
//   delayAmp:       0.0       — delay output level; bring up in performance
//   delayFeedback:  0.35      — delay feedback (0.0–1.0)
//   rhythm:         nil       — named sequence from tvp3_rhythm.scd, or nil
//   layers:         nil       — up to 3 electronic layer entries (nil = inactive slot)
//   checkpoints:    nil       — array of [fraction, message] pairs; fraction is
//                               0.0-1.0 of ~grainCenterCounter's 0-127 range.
//                               Posts message the first time the counter (shared
//                               across all flows' grainCenter-bump buttons) crosses
//                               fraction*127 within this scene. Fires once per
//                               scene load. e.g. checkpoints: [[0.2, "Part 2 starts"], [0.6, "Part 3 starts"]]
//
// ---- Layer entry format ----
//   def:      (required)  — SynthDef name; must have gate param for toggle-off fadeout
//   notes:    [n1, n2, …] — note names (\Eb4, \G4) or raw MIDI ints; → freq1/freq2/…
//   (any other keys are passed directly as synth args)
//
//   Example:
//     layers: [
//         (def: \triTriad, notes: [\Eb4, \G4, \Bb4], peakAmp: 0.1, cycleDur: 8),
//         nil, nil,
//     ]
// ============================================================

/*(
~bpm = 112;
~qn  = ~bpm / 60;
~f1 = 0.33*~qn;
~f2 = 0.11*~qn;
~f3 = 1.5*0.33*~qn;
~f4 = 2*~qn;
~music = ~mephisto;
~music1 = ~tremoloBuffer.(~music, ~f4, \saw, { |b| "musicTrem ready: %".format(b).postln });
~music2 = ~tremoloBuffer.(~music, ~f4, \triangle, { |b| "musicTrem ready: %".format(b).postln });
~music3 = ~tremoloBuffer.(~music, ~f4, \trem, { |b| "musicTrem ready: %".format(b).postln });
)*/

(
// Renders a tremolo-modulated copy of buf at frequency f (Hz) and returns it
// immediately (still filling in), or pass action to be notified when it's
// done rendering. type: \trem (sine), \triangle, \saw, \revSaw, \pulse.
// Does not modify buf — always allocates and writes to a new buffer.
~tremoloBuffer = { |buf, f = 4, type = \trem, action|
	var newBuf = Buffer.alloc(buf.server, buf.numFrames, buf.numChannels);
	var typeIdx = [\trem, \saw, \triangle, \revSaw, \pulse].indexOf(type) ?? 0;
	Routine {
		{
			var sig    = PlayBuf.ar(buf.numChannels, buf, BufRateScale.kr(buf), loop: 0);
			var phasor = Phasor.ar(0, f * SampleDur.ir, 0, 1);
			var shape  = Select.ar(typeIdx, [
				(phasor * 2pi).sin,             // trem (sine)
				(phasor * 2 - 1),               // saw
				1 - ((phasor * 2 - 1).abs * 2), // triangle
				(phasor * 2 - 1).neg,           // revSaw
				((phasor < 0.5) * 2) - 1,       // pulse
			]).range(0, 1);
			RecordBuf.ar(sig * shape, newBuf, loop: 0, doneAction: 2);
			Silent.ar;
		}.play(buf.server);
		buf.server.sync;
		(buf.duration + 0.05).wait;
		action.value(newBuf);
	}.play;
	newBuf
};

~keyToHz = { |key|
	var noteMap = Dictionary[
		\C  -> 0,  \Db -> 1,  \D  -> 2,  \Eb -> 3,  \E  -> 4,
		\F  -> 5,  \Gb -> 6,  \G  -> 7,  \Ab -> 8,  \A  -> 9,
		\Bb -> 10, \B  -> 11
	];
	var str    = key.asString;
	var octave = str[str.size - 1].digit;
	var name   = str[0 .. str.size - 2].asSymbol;
	var midi   = (octave + 1) * 12 + noteMap[name];  // A4=69 → 440Hz
	midi.midicps
};

~bpm = 88;
~qn  = 60 / ~bpm;  // seconds per quarter note (period) — used by ~fN durations below

~tn = ~qn;

~f1 = ~qn;
~f2 = ~qn/2;
~f4 = ~qn/4;
~f8 = ~qn/8;
~f3 = ~qn / 3;
~f6 = ~qn / 6;
~f9 = ~qn / 9;

~music = ~in_nomine_6;



~s3qn = 60/88;
~s3f2 = ~s3qn/2;
~s3f4 = ~s3qn/4;
~s3f8 = ~s3qn/8;
~s3f3 = ~s3qn / 3;
~s3f6 = ~s3qn / 6;
~s3f9 = ~s3qn / 9;



~score = [
	// ---- Scene 1 -----------------------------------------------
	(
		name: \scene1,
		delayTime: ~f2,
		stepRate: 12 / ~qn,  // 3 steps/beat (triplet 8ths), locked to ~bpm
		flows: [
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: true, delay: false, drive: false,
				amp:        1.0,
				dur:        32,
				pan: -0.4,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn/2, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*3, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piffaro_1_1
					], repeats: [1]),

				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        1.0,
				dur:        32,
				pan: -0.2,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn/2.1, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*4, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piffaro_1_2
					], repeats: [1]),

				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        1.0,
				dur:        32,
				pan: 0.2,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn/2.2, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*3 + 0.125, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piffaro_1_3
					], repeats: [1]),

				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        1.0,
				dur:        32,
				pan: 0.4,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn/2.3, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*3 - 0.125, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piffaro_1_4
					], repeats: [1]),

				],
			),

			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        1.0,
				dur:        Pwhite(0.2, 0.4),
				pan: -0.1,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.2, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*3, tremSkew: 0.5, tremWave2: 0.0, tremTarget2: \saw,

				doubleAmp: [0,1,0], double: [1.5, 2.25],
				steps: [
					(buffers: [
						~bass[\Bb2],
						~bass[\C3],
						~bass[\Db3],
						~bass[\Eb3],
						~bass[\F3],
						~bass[\Bb1],
					], repeats: [16, 8]),
				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: true, delay: true, drive: false,
				amp:        0.2,
				dur:        Pwhite(0.2, 0.3),
				pan: -0.1,
				rate: Pwhite(0.989, 0.991),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*16, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [4.0],
				steps: [
					(buffers: [
						~cl[\Bb4], ~cl[\C5], ~cl[\Db5], ~cl[\Eb5], ~cl[\F5], ~cl[\Bb4], ~cl[\C5], ~cl[\Eb5], ~cl[\Db5], ~cl[\C5], ~cl[\C5], ~silence,
						~cl[\Eb5], ~cl[\F5], ~cl[\Ab5], ~cl[\Ab5],
						~cl[\Ab5], ~cl[\G5], ~cl[\F5], ~cl[\Eb5], ~cl[\F5], ~cl[\G5], ~cl[\G5], ~cl[\G5], ~silence,
						~cl[\F5], ~cl[\F5], ~cl[\Ab5], ~cl[\Bb5], ~cl[\Ab5], ~cl[\Ab5], ~cl[\G5], ~cl[\F5], ~cl[\Eb5], ~cl[\F5], ~cl[\Eb5], ~cl[\Db5], ~cl[\C5], ~cl[\C5], ~cl[\Bb4], ~cl[\Db5], ~cl[\Eb5], ~cl[\F5], ~silence,
						~cl[\Bb4], ~cl[\C5], ~cl[\Db5], ~cl[\Eb5], ~cl[\F5], ~cl[\Eb4], ~cl[\Db5], ~cl[\Eb5], ~cl[\Db5], ~cl[\C5], ~silence,

					], repeats: [4]),
				],
			),

			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     0.4, spectral: true, delay: false, drive: false,
				amp:        0.2,
				dur:        Pwhite(0.2, 0.3),
				pan: -0.1,
				rate: Pwhite(0.989, 0.991),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*6, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				steps: [
					(buffers: [


						~ob[\Bb4], ~ob[\C5], ~ob[\Db5], ~ob[\Eb5], ~ob[\F5], ~ob[\Bb4], ~ob[\C5], ~ob[\Eb5], ~ob[\Db5], ~ob[\C5], ~ob[\C5], ~silence,
						~ob[\Eb5], ~ob[\F5], ~ob[\Ab5], ~ob[\Ab5],
						~ob[\Ab5], ~ob[\G5], ~ob[\F5], ~ob[\Eb5], ~ob[\F5], ~ob[\G5], ~ob[\G5], ~ob[\G5], ~silence,
						~ob[\F5], ~ob[\F5], ~ob[\Ab5], ~ob[\Bb5], ~ob[\Ab5], ~ob[\Ab5], ~ob[\G5], ~ob[\F5], ~ob[\Eb5], ~ob[\F5], ~ob[\Eb5], ~ob[\Db5], ~ob[\C5], ~ob[\C5], ~ob[\Bb4], ~ob[\Db5], ~ob[\Eb5], ~ob[\F5], ~silence,
						~ob[\Bb4], ~ob[\C5], ~ob[\Db5], ~ob[\Eb5], ~ob[\F5], ~ob[\Eb4], ~ob[\Db5], ~ob[\Eb5], ~ob[\Db5], ~ob[\C5], ~silence,

					], repeats: [5]),
				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        0.2,
				dur:        Pwhite(0.2, 0.3),
				pan: -0.1,
				rate: Pwhite(0.989, 0.991),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*12, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [5/3],
				steps: [
					(buffers: [
						~flt[\Bb4], ~flt[\C5], ~flt[\Db5], ~flt[\Eb5], ~flt[\F5], ~flt[\Bb4], ~flt[\C5], ~flt[\Eb5], ~flt[\Db5], ~flt[\C5], ~flt[\C5], ~silence,
						~flt[\Eb5], ~flt[\F5], ~flt[\Ab5], ~flt[\Ab5],
						~flt[\Ab5], ~flt[\G5], ~flt[\F5], ~flt[\Eb5], ~flt[\F5], ~flt[\G5], ~flt[\G5], ~flt[\G5], ~silence,
						~flt[\F5], ~flt[\F5], ~flt[\Ab5], ~flt[\Bb5], ~flt[\Ab5], ~flt[\Ab5], ~flt[\G5], ~flt[\F5], ~flt[\Eb5], ~flt[\F5], ~flt[\Eb5], ~flt[\Db5], ~flt[\C5], ~flt[\C5], ~flt[\Bb4], ~flt[\Db5], ~flt[\Eb5], ~flt[\F5], ~silence,
						~flt[\Bb4], ~flt[\C5], ~flt[\Db5], ~flt[\Eb5], ~flt[\F5], ~flt[\Eb4], ~flt[\Db5], ~flt[\Eb5], ~flt[\Db5], ~flt[\C5], ~silence,

					], repeats: [6]),
				],
			),


		],
		rhythm: \scene1,
		layers: [
			nil,
			nil,
			nil,
		],
		checkpoints: [[0.0, "Kyrie"], [0.26, "Christe"], [0.566, "Kyrie"]],
	),













	(
		name: \scene2,
		delayTime: ~f1,
		stepRate: 12 / ~qn,  // 3 steps/beat (triplet 8ths), locked to ~bpm
		flows: [
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        90,
				pan: -0.4,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn/2, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*3, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piffaro_2_1
					], repeats: [1]),

				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        90,
				pan: -0.2,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn/2.1, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*4, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piffaro_2_2
					], repeats: [1]),

				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        90,
				pan: 0.2,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn/2.2, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*3 + 0.125, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piffaro_2_3
					], repeats: [1]),

				],
			),
		/*	(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        90,
				pan: 0.4,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn/2.3, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*3 - 0.125, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piffaro_2_4
					], repeats: [1]),

				],
			),*/

			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        1.0,
				dur:        Pwhite(0.2, 0.4),
				pan: -0.1,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.2, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*9, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*3, tremSkew: 0.5, tremWave2: 0.0, tremTarget2: \saw,

				doubleAmp: [0,1,0], double: [1.5, 2.25],
				steps: [
					(buffers: [
						~bass[\F2],
						~bass[\Bb1],
						~bass[\C2],
						~bass[\Db2],
						~bass[\Eb2],
					], repeats: [16, 8]),
				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: true, delay: false, drive: false,
				amp:        0.2,
				dur:        Pwhite(0.2, 0.3),
				pan: -0.1,
				rate: Pwhite(0.989, 0.991),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*16, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				steps: [
					(buffers: [
						~flt[\Bb4], ~flt[\C5], ~flt[\Db5], ~flt[\Eb5], ~flt[\F5], ~flt[\Bb4], ~flt[\C5], ~flt[\Eb5], ~flt[\Db5], ~flt[\C5], ~flt[\C5], ~silence,
						~flt[\Eb5], ~flt[\F5], ~flt[\Ab5], ~flt[\Ab5],
						~flt[\Ab5], ~flt[\G5], ~flt[\F5], ~flt[\Eb5], ~flt[\F5], ~flt[\G5], ~flt[\G5], ~flt[\G5], ~silence,
						~flt[\F5], ~flt[\F5], ~flt[\Ab5], ~flt[\Bb5], ~flt[\Ab5], ~flt[\Ab5], ~flt[\G5], ~flt[\F5], ~flt[\Eb5], ~flt[\F5], ~flt[\Eb5], ~flt[\Db5], ~flt[\C5], ~flt[\C5], ~flt[\Bb4], ~flt[\Db5], ~flt[\Eb5], ~flt[\F5], ~silence,
						~flt[\Bb4], ~flt[\C5], ~flt[\Db5], ~flt[\Eb5], ~flt[\F5], ~flt[\Eb4], ~flt[\Db5], ~flt[\Eb5], ~flt[\Db5], ~flt[\C5], ~silence,

					], repeats: [6]),
				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: true, delay: false, drive: false,
				amp:        0.2,
				dur:        Pwhite(0.2, 0.3),
				pan: -0.1,
				rate: 3/2*Pwhite(0.989, 0.991),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*6, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [5/3],
				steps: [
					(buffers: [
						~flt[\Bb4], ~flt[\C5], ~flt[\Db5], ~flt[\Eb5], ~flt[\F5], ~flt[\Bb4], ~flt[\C5], ~flt[\Eb5], ~flt[\Db5], ~flt[\C5], ~flt[\C5], ~silence,
						~flt[\Eb5], ~flt[\F5], ~flt[\Ab5], ~flt[\Ab5],
						~flt[\Ab5], ~flt[\G5], ~flt[\F5], ~flt[\Eb5], ~flt[\F5], ~flt[\G5], ~flt[\G5], ~flt[\G5], ~silence,
						~flt[\F5], ~flt[\F5], ~flt[\Ab5], ~flt[\Bb5], ~flt[\Ab5], ~flt[\Ab5], ~flt[\G5], ~flt[\F5], ~flt[\Eb5], ~flt[\F5], ~flt[\Eb5], ~flt[\Db5], ~flt[\C5], ~flt[\C5], ~flt[\Bb4], ~flt[\Db5], ~flt[\Eb5], ~flt[\F5], ~silence,
						~flt[\Bb4], ~flt[\C5], ~flt[\Db5], ~flt[\Eb5], ~flt[\F5], ~flt[\Eb4], ~flt[\Db5], ~flt[\Eb5], ~flt[\Db5], ~flt[\C5], ~silence,

					], repeats: [6]),
				],
			),

			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     3.0, spectral: false, delay: false, drive: false,
				amp:        1.0,
				dur:        168,
				pan: -0.1,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*12, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				steps: [
					(buffers: [
						~piffaro_piano
					], repeats: [1]),
				],
			),
			(
				type: \warp,
				dials:      [\tremDepth, \tremDepth2],
				freeze:     3.0, spectral: true, delay: false, drive: false,
				amp:        0.3,
				pan: -0.4,
				pitchScale: 2**(7/12),  // perfect fifth up (equal-tempered)
				stretchScale: 1.0,

				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn/4, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*6, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piffaro_piano
					], repeats: [1]),

				],
			),

		],
		rhythm: \scene2,
		layers: [
			nil,
			nil,
			nil,
		],
		checkpoints: [[0.0, "Kyrie"], [0.26, "Christe"], [0.566, "Kyrie"]],
	),










	(
		name: \scene3,
		delayTime: 1,
		stepRate: 12 / ~s3qn,  // 3 steps/beat (triplet 8ths), locked to ~bpm
		flows: [
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: true, delay: true, drive: false,
				amp:        0.3,
				dur:        90,
				pan: -0.4,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~s3qn/3, tremPhase: 0, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*3, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piffaro_3_1
					], repeats: [1]),

				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        90,
				pan: -0.4,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~s3qn/2, tremPhase: 0, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*4, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piffaro_3_2
					], repeats: [1]),

				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        90,
				pan: -0.4,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~s3qn/4, tremPhase: 0, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*2, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piffaro_3_3
					], repeats: [1]),

				],
			),


			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: true, delay: false, drive: false,
				amp:        2.0,
				dur:        Pwhite(0.2, 0.4),
				pan: -0.1,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.2, 0.4), grainCenter: 0.18,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*9, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*3, tremSkew: 0.5, tremWave2: 0.0, tremTarget2: \saw,

				doubleAmp: [0,1,0], double: [1.5, 2.25],
				steps: [
					(buffers: [
						~bass[\Eb1],
						~bass[\Gb1],
						~bass[\Bb1],
						~bass[\Db2],
						~bass[\F2],
						~silence,
						~bass[\Gb1],
						~bass[\A1],
						~bass[\Db1],
						~bass[\E2],
						~bass[\Ab2],
						~silence
					], repeats: [16, 8]),
				],
			),

			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: false, delay: false, drive: false,
				amp:        0.2,
				dur:        Pwhite(0.2, 0.3),
				pan: -0.5,
				rate: Pwhite(0.989, 0.991),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~s3qn*16, tremSkew: 0.5, tremPhase: pi/2, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [1.5],
				steps: [
					(buffers: [
						~flt[\Eb6], ~flt[\F6], ~flt[\Gb6], ~flt[\Ab6], ~flt[\Bb6], ~flt[\Eb6], ~flt[\F6], ~flt[\Ab6], ~flt[\Gb6], ~flt[\F6], ~flt[\F6], ~silence,
						~flt[\Ab6], ~flt[\Bb6], ~flt[\Db7], ~flt[\Db7],
						~flt[\Db7], ~flt[\C7], ~flt[\Bb6], ~flt[\Ab6], ~flt[\Bb6], ~flt[\C7], ~flt[\C7], ~flt[\C7], ~silence,
						~flt[\Bb6], ~flt[\Bb6], ~flt[\Db7], ~flt[\C7], ~flt[\Db7], ~flt[\Db7], ~flt[\C7], ~flt[\Bb6], ~flt[\Ab6], ~flt[\Bb6], ~flt[\Ab6], ~flt[\Gb6], ~flt[\F6], ~flt[\F6], ~flt[\Eb6], ~flt[\Gb6], ~flt[\Ab6], ~flt[\Bb6], ~silence,
						~flt[\Eb6], ~flt[\F6], ~flt[\Gb6], ~flt[\Ab6], ~flt[\Bb6], ~flt[\Ab5], ~flt[\Gb6], ~flt[\Ab6], ~flt[\Gb6], ~flt[\F6], ~silence,
					], repeats: [15]),
				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: false, delay: true, drive: false,
				amp:        0.2,
				dur:        Pwhite(0.2, 0.3),
				pan: 0.25,
				rate: Pwhite(0.989, 0.991),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~s3qn*8, tremSkew: 0.5, tremPhase: 0, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [5/3],
				steps: [
					(buffers: [
						~flt[\F5], ~flt[\G5], ~flt[\Ab5], ~flt[\Bb5], ~flt[\C6], ~flt[\F5], ~flt[\G5], ~flt[\Bb5], ~flt[\Ab5], ~flt[\G5], ~flt[\G5], ~silence,
						~flt[\Bb5], ~flt[\C6], ~flt[\Eb6], ~flt[\Eb6],
						~flt[\Eb6], ~flt[\D6], ~flt[\C6], ~flt[\Bb5], ~flt[\C6], ~flt[\D6], ~flt[\D6], ~flt[\D6], ~silence,
						~flt[\C6], ~flt[\C6], ~flt[\Eb6], ~flt[\F6], ~flt[\Eb6], ~flt[\Eb6], ~flt[\D6], ~flt[\C6], ~flt[\Bb5], ~flt[\C6], ~flt[\Bb5], ~flt[\Ab5], ~flt[\G5], ~flt[\G5], ~flt[\F5], ~flt[\Ab5], ~flt[\Bb5], ~flt[\C6], ~silence,
						~flt[\F5], ~flt[\G5], ~flt[\Ab5], ~flt[\Bb5], ~flt[\C6], ~flt[\Bb4], ~flt[\Ab5], ~flt[\Bb5], ~flt[\Ab5], ~flt[\G5], ~silence,

					], repeats: [12]),
				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: false, delay: false, drive: false,
				amp:        0.2,
				dur:        Pwhite(0.2, 0.3),
				pan: -0.25,
				rate: Pwhite(0.989, 0.991),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~s3qn*6, tremSkew: 0.5, tremPhase: pi, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [1.5],
				steps: [
					(buffers: [
				~ob[\Bb5], ~ob[\C6], ~ob[\Db6], ~ob[\Eb6], ~ob[\F6], ~ob[\Bb5], ~ob[\C6], ~ob[\Eb6], ~ob[\Db6], ~ob[\C6], ~ob[\C6], ~silence,
~ob[\Eb6], ~ob[\F6], ~ob[\Ab6], ~ob[\Ab6],
~ob[\Ab6], ~ob[\G6], ~ob[\F6], ~ob[\Eb6], ~ob[\F6], ~ob[\G6], ~ob[\G6], ~ob[\G6], ~silence,
~ob[\F6], ~ob[\F6], ~ob[\Ab6], ~flt[\Bb6], ~ob[\Ab6], ~ob[\Ab6], ~ob[\G6], ~ob[\F6], ~ob[\Eb6], ~ob[\F6], ~ob[\Eb6], ~ob[\Db6], ~ob[\C6], ~ob[\C6], ~ob[\Bb5], ~ob[\Db6], ~ob[\Eb6], ~ob[\F6], ~silence,
~ob[\Bb5], ~ob[\C6], ~ob[\Db6], ~ob[\Eb6], ~ob[\F6], ~ob[\Eb5], ~ob[\Db6], ~ob[\Eb6], ~ob[\Db6], ~ob[\C6], ~silence,
						// ~ob[\Eb5], ~ob[\Gb5], ~ob[\Bb5], ~ob[\Db6], ~ob[\F6], ~silence
					], repeats: [48]),
				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        0.2,
				dur:        Pwhite(0.2, 0.3),
				pan: 0,
				rate: Pwhite(0.989, 0.991),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~s3qn*12, tremSkew: 0.5, tremPhase: 3*pi/2, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [1.5],
				steps: [
					(buffers: [
						~cl[\Db6], ~cl[\Eb6], ~cl[\E6], ~cl[\Gb6], ~cl[\Ab6], ~cl[\Db6], ~cl[\Eb6], ~cl[\Gb6], ~cl[\E6], ~cl[\Eb6], ~cl[\Eb6], ~silence,
						~cl[\Gb6], ~cl[\Ab6], ~cl[\B6], ~cl[\B6],
						~cl[\B6], ~cl[\Bb6], ~cl[\Ab6], ~cl[\Gb6], ~cl[\Ab6], ~cl[\Bb6], ~cl[\Bb6], ~cl[\Bb6], ~silence,
						~cl[\Ab6], ~cl[\Ab6], ~cl[\B6], ~flt[\Db7], ~cl[\B6], ~cl[\B6], ~cl[\Bb6], ~cl[\Ab6], ~cl[\Gb6], ~cl[\Ab6], ~cl[\Gb6], ~cl[\E6], ~cl[\Eb6], ~cl[\Eb6], ~cl[\Db6], ~cl[\E6], ~cl[\Gb6], ~cl[\Ab6], ~silence,
						~cl[\Db6], ~cl[\Eb6], ~cl[\E6], ~cl[\Gb6], ~cl[\Ab6], ~cl[\Gb5], ~cl[\E6], ~cl[\Gb6], ~cl[\E6], ~cl[\Eb6], ~silence,
						// ~cl[\Eb5], ~cl[\Gb5], ~cl[\Bb5], ~cl[\Db6], ~cl[\F6], ~silence
						// ~flt[\Eb5], ~flt[\Gb5], ~flt[\Bb5], ~flt[\Db6], ~flt[\F6], ~silence
					], repeats: [24]),
				],
			),

		],
		rhythm: \scene3,
		layers: [
			nil,
			nil,
			nil,
		],
		checkpoints: [[0.0, "Kyrie"], [0.26, "Christe"], [0.566, "Kyrie"]],
	),




];
"Score loaded: % scenes.".format(~score.size).postln;
)

