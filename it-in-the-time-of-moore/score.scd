// ============================================================
// TVP3 — Score
// ============================================================
// Each scene has a flows array of exactly 8 elements (nil = inactive).
// Each flow is a granular voice. Each flow declares its own dial types via dials:.
//
// ---- Value formats ----
// Most flow/step params accept three formats:
// Number fixed value, dial has no effect
// Pattern e.g. Pwhite(0.18, 0.24) — per-grain random, dial has no effect
// [min, max] dial-controlled, starts at min (normalised 0.0)
// [min, max, init] dial-controlled, starts at init
//
// ---- Flow-level params and defaults ----
// freeze: false — route grains to freeze bus (pre-fader)
// spectral: false — route grains to spectral bus (pre-fader, like freeze)
// delay: false — tap flow to global delay send
// drive: false — wavefold-distort this flow via global CC 18 amount (opt-in, like freeze/spectral)
// amp: 0.08 — grain amplitude
// dur: 0.5 — grain firing interval (seconds); Pattern for variation
// attack: 0.05 — grain attack (seconds); use 0.5 for smooth wash
// release: 0.05 — grain release (seconds); use 0.5 for smooth wash
// grainWidth: 0.2 — playback window as buffer fraction; Number/Pattern/[min,max,init]
// tremDepth: 0.0 — tremolo depth; Number or [min,max,init]
// tremRate: 4.0 — tremolo rate (Hz); fixed, not dial-controlled
// tremPhase: 0.0 — tremolo phase offset (radians, 0–2pi); default 0
// tremDepth2: 0.0 — second tremolo depth; Number or [min,max,init]
// tremRate2: 2.0 — second tremolo rate (Hz)
// tremPhase2: 0.0 — second tremolo phase offset (radians, 0–2pi); default 0
// rate: 1 — playback rate multiplier
//
// ---- Step-level params ----
// buffers: (required) — array of buffer objects (~ob[\G3] etc.)
// repeats: [1] — repeat counts; cycles via LCM with buffers array
// grainCenter: 0.3 — buffer position (0.0–1.0); seeds Dial 2 on load
//
// ---- Scene-level params ----
// name: (required)
// stepRate: 8 — sequencer steps per second (8 = 120 BPM at 16 steps)
// delayTime: 0.35 — global delay time (seconds)
// delayAmp: 0.0 — delay output level; bring up in performance
// delayFeedback: 0.35 — delay feedback (0.0–1.0)
// rhythm: nil — named sequence from tvp3_rhythm.scd, or nil
// layers: nil — up to 3 electronic layer entries (nil = inactive slot)
//
// ---- Layer entry format ----
// def: (required) — SynthDef name; must have gate param for toggle-off fadeout
// notes: [n1, n2, …] — note names (\Eb4, \G4) or raw MIDI ints; → freq1/freq2/…
// (any other keys are passed directly as synth args)
//
// Example:
// layers: [
// (def: \triTriad, notes: [\Eb4, \G4, \Bb4], peakAmp: 0.1, cycleDur: 8),
// nil, nil,
// ]
// ============================================================

(


~music = ~moore;

~bpm = 120;

~durScale = 1;

~qn = ~bpm / 60;
~eighth = ~qn/2;
~sixteenth = ~qn/4;
~thirtysecond = ~qn/8;
~half = ~qn / 2;
~whole = ~qn / 4;
~breve = ~qn / 8;

~f8 = 1*~qn;
~f4 = 0.5*~qn;
~f2 = 0.25*~qn;
~f1 = 0.125*~qn;

~score = [
	// ---- Scene 1 -----------------------------------------------
	(
		name: \scene1,
		delayTime: 1/(2*~qn),
		stepRate: 8,
		flows: [
			// Flow 1
			(
				dials:      [\attack, \grainWidth],
				freeze:     false, spectral: true, delay: true, drive: true,
				amp:        2.0,
				dur:        Pseq([
					4/~qn
				], inf),
				pan: -0.3,
				attack:     [0.2, 0.5, 0.2], release: 0.2,
				rate: Pwhite(0.999, 1.001),
				grainCenter: [0.0, 1.0, 0], grainWidth: [0.0, 0.025, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*2, tremSkew: 0.5, tremWave: 0.8, tremTarget: \pulse,
				steps: [
					(buffers: [
						~music
					])
				],
			),


			(
				dials:      [\attack, \grainWidth],
				freeze:     true, spectral: false, delay: false, drive: false,
				amp:        2.0,
				// dur:        ~2/~qn*Pseq([
				//
				// ], inf),
				// dur: Pseq([Rest(~f2), ~f1, ~f2, Rest(~f1), ~f2, ~f2], inf),
				dur: Pseq([Rest(~f2), ~f1, ~f2, Rest(~f1), ~f4], inf),

				pan: 0.2,
				attack:     [0.2, 0.5, 0.2], release: 0.2,
				rate: Pwhite(0.999, 1.001),
				grainCenter: [0.0, 1.0, 0], grainWidth: [0.0, 0.01, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*4, tremSkew: 0.5, tremWave: 0.8, tremTarget: \pulse,
				steps: [
					(buffers: [
						~music
					])
				],
			),
			(
				dials:      [\attack, \grainWidth],
				freeze:     true, spectral: false, delay: false, drive: false,
				amp:        2.0,
/*				dur:        ~durScale*Pseq([
					1/~qn
				], inf),*/
				dur: Pseq([~f1, ~f2, Rest(~f1), ~f2, ~f2, Rest(~f2)], inf),

				pan: 0.6,
				attack:     [0.2, 0.5, 0.2], release: 0.2,
				rate: Pwhite(0.999, 1.001),
				grainCenter: [0.0, 1.0, 0], grainWidth: [0.0, 0.01, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*1, tremSkew: 0.5, tremWave: 0.8, tremTarget: \pulse,
				steps: [
					(buffers: [
						~music
					])
				],
			),

			// piano
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: true, delay: false, drive: false,
				amp:        2.0,
				dur:        Pseq([
					0.001, 0.001, 0.001, 0.001, ~durScale*1.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*2.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*2.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*2.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*2.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*2.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*2.5/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1/~qn-0.004,
					0.001, 0.001, 0.001, 0.001, ~durScale*1/~qn-0.004,
				], inf),
				attack:     [0.01, 0.3, 0.01], release: 0.2,
				rate: Pwhite(0.999, 1.001),
				grainWidth: 0.7, grainCenter: 0.35,
				doubleAmp: [0.0, 1.0, 0.0], double: [2.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*3, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn, tremSkew2: 0.5, tremWave2: 0.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~bass[\E2], ~pnmf[\E3], ~pnmf[\Ab3], ~pnmf[\B3], ~pnmf[\Eb4],
						~bass[\Eb2], ~pnmf[\Eb3], ~pnmf[\G3], ~pnmf[\Bb3], ~pnmf[\Db4],
						~bass[\Db2], ~pnmf[\Db3], ~pnmf[\E3], ~pnmf[\Ab3], ~pnmf[\B3],
						~bass[\B1], ~pnmf[\B2], ~pnmf[\Eb3], ~pnmf[\Gb3], ~pnmf[\Bb3],
						~bass[\Eb2], ~pnmf[\Eb3], ~pnmf[\G3], ~pnmf[\Bb3], ~pnmf[\Db4],
						~bass[\Db2], ~pnmf[\Db3], ~pnmf[\F3], ~pnmf[\Ab3], ~pnmf[\B3],
						~bass[\B1], ~pnmf[\B2], ~pnmf[\Eb3], ~pnmf[\Gb3], ~pnmf[\Bb3],
						~bass[\Bb1], ~pnmf[\Bb2], ~pnmf[\D3], ~pnmf[\F3], ~pnmf[\Ab3],
						~bass[\E2], ~pnmf[\E3], ~pnmf[\Ab3], ~pnmf[\B3], ~pnmf[\Eb4],
						~bass[\D2], ~pnmf[\D3], ~pnmf[\Gb3], ~pnmf[\A3], ~pnmf[\Db4],
						~bass[\Db2], ~pnmf[\Db3], ~pnmf[\E3], ~pnmf[\Ab3], ~pnmf[\B3],
						~bass[\B1], ~pnmf[\B2], ~pnmf[\Eb3], ~pnmf[\G3], ~pnmf[\Bb3],
						~bass[\Eb2], ~pnmf[\Eb3], ~pnmf[\G3], ~pnmf[\Bb3], ~pnmf[\Db4],
						~bass[\Db2], ~pnmf[\Db3], ~pnmf[\E3], ~pnmf[\Ab3], ~pnmf[\B3],
						~bass[\B1], ~pnmf[\B2], ~pnmf[\Eb3], ~pnmf[\Gb3], ~pnmf[\Bb3],
						~bass[\Bb1], ~pnmf[\Bb2], ~pnmf[\D3], ~pnmf[\F3], ~pnmf[\Ab3],
						~bass[\Bb1], ~pnmf[\Bb2], ~pnmf[\Db3], ~pnmf[\Eb3], ~pnmf[\G3],
					], repeats: [1])
				],
			),

			// piano
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: true, delay: false, drive: false,
				amp:        2.0,
				dur:        8,
				attack:     0.01, release: 0.2,
				rate: Pwhite(0.999, 1.001),
				grainWidth: 1.0, grainCenter: 0.5,
				doubleAmp: [0.0, 1.0, 0.0], double: [16/15, 2.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*3, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn, tremSkew2: 0.5, tremWave2: 0.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~vib[\Eb5]

					], repeats: [1])
				],
			),


			(
				dials:      [\tremDepth, \grainWidth],
				freeze:     true, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        0.6*Pseq([
					0.125, 0.125, 0.25, 0.125, 0.5, 0.125, 0.125, 0.125, 0.25, 0.5, 0.5, 0.125,
					0.25, 0.125, 0.125, 0.5, 0.125, 0.25, 0.125
				], inf),
				attack:     0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				attack:     0.01, release: 0.01,

				grainWidth: [0.005, 0.3, 0.005], grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*4, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				// tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [~cl[\Db5], ~cl[\Eb5], ~cl[\F5], ~cl[\Gb5], ~silence], repeats: [17, 18, 19]),
					(buffers: [~cl[\Eb5], ~cl[\F5], ~cl[\Gb5], ~cl[\Ab5], ~silence], repeats: [17, 18, 19]),
					(buffers: [~cl[\F5], ~cl[\Gb5], ~cl[\Ab5], ~cl[\Bb5], ~silence], repeats: [13, 14, 15]),
					(buffers: [~cl[\Gb5], ~cl[\Ab5], ~cl[\Bb5], ~cl[\C6], ~cl[\Db6], ~silence], repeats: [10, 11, 12]),
					(buffers: [~cl[\Ab5], ~cl[\Bb5], ~cl[\B5], ~cl[\Db6], ~cl[\D6], ~cl[\E6], ~silence], repeats: [7, 8, 9, 10]),
					(buffers: [~cl[\Ab5], ~cl[\Bb5], ~cl[\B5], ~cl[\Db6], ~cl[\Eb6], ~cl[\F6], ~silence], repeats: [7, 8, 9, 10]),
					(buffers: [~cl[\Gb6], ~cl[\B5], ~cl[\Ab5], ~cl[\Eb6], ~cl[\Bb5], ~cl[\Eb5], ~cl[\Db5], ~cl[\Gb4], ~silence], repeats: [7, 8, 9]),

				],
			),

			(
				dials:      [\tremDepth, \grainWidth],
				freeze:     true, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        0.8*Pseq([
					0.125, 0.125, 0.125, 0.5, 0.25, 0.125, 0.5, 0.5, 0.125, 0.25, 0.125
				], inf),
				attack:     0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				attack:     0.01, release: 0.01,

				grainWidth: [0.005, 0.3, 0.005], grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*4 + 0.125, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				// tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn/2, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [~ob[\Db5], ~ob[\Eb5], ~ob[\F5], ~ob[\Gb5], ~silence], repeats: [15, 18, 22]),
					(buffers: [~ob[\Eb5], ~ob[\F5], ~ob[\Gb5], ~ob[\Ab5], ~silence], repeats: [15, 18, 22]),
					(buffers: [~ob[\F5], ~ob[\Gb5], ~ob[\Ab5], ~ob[\Bb5], ~silence], repeats: [11, 13, 18]),
					(buffers: [~ob[\Gb5], ~ob[\Ab5], ~ob[\Bb5], ~ob[\C6], ~ob[\Db6], ~silence], repeats: [10, 11, 12]),
					(buffers: [~ob[\Ab5], ~ob[\Bb5], ~ob[\B5], ~ob[\Db6], ~ob[\D6], ~ob[\E6], ~silence], repeats: [7, 9, 11, 13]),
					(buffers: [~ob[\Ab5], ~ob[\Bb5], ~ob[\B5], ~ob[\Db6], ~ob[\Eb6], ~ob[\F6], ~silence], repeats: [7, 9, 11, 13]),
					(buffers: [~ob[\Gb6], ~ob[\B5], ~ob[\Ab5], ~ob[\Eb6], ~ob[\Bb5], ~ob[\Eb5], ~ob[\Db5], ~ob[\Gb4], ~silence], repeats: [14, 17, 24]),

				],
			),

			(
				dials:      [\tremDepth, \grainWidth],
				freeze:     true, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        0.9*Pseq([
					0.5, 0.125, 0.125, 0.25, 0.125, 0.125, 0.125, 0.5, 0.25, 0.5, 0.125, 0.125, 0.25
				], inf),
				attack:     0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				attack:     0.01, release: 0.01,

				grainWidth: [0.005, 0.3, 0.005], grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*4 - 0.125, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				// tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn/4, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [~flt[\Db5], ~flt[\Eb5], ~flt[\F5], ~flt[\Gb5], ~silence], repeats: [11, 18, 24]),
					(buffers: [~flt[\Eb5], ~flt[\F5], ~flt[\Gb5], ~flt[\Ab5], ~silence], repeats: [11, 18, 24]),
					(buffers: [~flt[\F5], ~flt[\Gb5], ~flt[\Ab5], ~flt[\Bb5]], repeats: [13, 17, 19]),
					(buffers: [~flt[\Gb5], ~flt[\Ab5], ~flt[\Bb5], ~flt[\C6], ~flt[\Db6], ~silence], repeats: [25, 29, 32]),
					(buffers: [~flt[\Ab5], ~flt[\Bb5], ~flt[\B5], ~flt[\Db6], ~flt[\D6], ~flt[\E6], ~silence], repeats: [17, 18, 19, 20]),
					(buffers: [~flt[\Ab5], ~flt[\Bb5], ~flt[\B5], ~flt[\Db6], ~flt[\Eb6], ~flt[\F6], ~silence], repeats: [17, 18, 19, 20]),
					(buffers: [~flt[\Gb6], ~flt[\B5], ~flt[\Ab5], ~flt[\Eb6], ~flt[\Bb5], ~flt[\Eb5], ~flt[\Db5], ~flt[\Gb4], ~silence], repeats: [7, 8, 9]),

				],
			),
		],
		rhythm: \grooves,
		layers: [
			nil,
			nil,
			nil,
		],
	),

];
"Score loaded: % scenes.".format(~score.size).postln;
)
