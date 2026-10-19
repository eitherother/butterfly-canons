// ============================================================
// Purcell In Nomine — Score
// ============================================================
// Each scene has a flows array of exactly 8 elements (nil = inactive).
// Each flow is a granular voice. Each flow declares its own dial types via dials:.
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
//   reso:       false         — run flow through the tuned resonator; CC 18 sets the amount
//   resoNote:   \Gb3          — resonator pitch; note name or raw MIDI int
//   amp:        0.08          — grain amplitude
//   dur:        0.5           — grain firing interval (seconds); Pattern for variation
//   attack:     0.05          — grain attack (seconds); use 0.5 for smooth wash
//   release:    0.05          — grain release (seconds); use 0.5 for smooth wash
//   grainWidth: 0.2           — playback window as buffer fraction; Number/Pattern/[min,max,init]
//   grainCenterLag: 0.15      — fraction of remaining distance to new grainCenter target
//                               closed per grain (0-1); 1.0 = instant jump,
//                               smaller = slower glide when the counter is bumped
//   seqDepth:   0.0           — step-sequencer gating depth; Number or [min,max,init]; overridden live by MIDI dial if declared in dials:
//   tremDepth:  0.0           — tremolo depth; Number or [min,max,init]
//   tremRate:   4.0           — tremolo rate (Hz); fixed, not dial-controlled
//   tremPhase:  0.0           — tremolo phase offset (radians, 0–2pi); default 0
//   tremDepth2: 0.0           — second tremolo depth; Number or [min,max,init]
//   tremRate2:  2.0           — second tremolo rate (Hz)
//   tremPhase2: 0.0           — second tremolo phase offset (radians, 0–2pi); default 0
//   rate:       1             — playback rate multiplier
//   pan:        0             — stereo position (-1..1)
//   startOffset: 0            — seconds to wait before the flow starts on scene load
//   dials:      [\seqDepth, \grainCenter] — the two MIDI dial types for this flow (see conductor.scd)
//   button:     nil           — Event of Pbind overrides applied while button 2 is active
//   double:     nil           — array of rate multipliers, one shadow grain stream per entry
//                               (e.g. [2.0] = octave up); a Pattern scales the main rate instead
//   doubleAmp:  [0.0, 1.0]    — shadow-stream level (multiplies amp); Number or [min,max,init]
//   tremSkew:   0.5           — where in the tremolo cycle the peak falls (0-1); Number or [min,max,init]
//   tremWave:   0.0           — crossfade from sine (0) toward tremTarget shape (1); Number or [min,max,init]
//   tremTarget: \saw          — \saw | \triangle | \pulse | \revSaw
//   tremPulseWidth: 0.5       — loud fraction of the cycle when tremTarget is \pulse
//   (tremSkew2/tremWave2/tremTarget2/tremPulseWidth2 apply to the second tremolo)
//
// ---- Step-level params ----
//   buffers:    (required)    — array of buffer objects (~cl[\G4] etc.)
//   repeats:    [1]           — repeat counts; cycles via LCM with buffers array
//   grainCenter: 0.3          — buffer position (0.0–1.0); seeds Dial 2 on load
//
// ---- Scene-level params ----
//   name:           (required)
//   stepRate:       8         — sequencer steps per second (8 = 120 BPM at 16 steps)
//   delayTime:      0.35      — global delay time (seconds)
//   delayAmp:       0.0       — delay output level; bring up in performance
//   delayFeedback:  0.35      — delay feedback (0.0–1.0)
//   rhythm:         nil       — named sequence from rhythm.scd, or nil
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

(
~qn = 0.9;

~f8 = ~qn;
~f4 = ~qn / 2;
~f2 = ~qn / 4;
~f1 = ~qn / 8;
~f3 = ~qn / 3;

~music = ~in_nomine_6;

~score = [
	// ---- Scene 1 -----------------------------------------------
	(
		name: \scene1,
		delayTime: ~f2,
		stepRate: 8 / ~qn,  // 16 steps = 2*~qn, the same bar as flow 4's dur loop
		flows: [
			(
				// dials:      [\seqDepth, \grainWidth],
				dials:      [\doubleAmp, \grainWidth],

				freeze:     true, spectral: false, delay: true,
				amp:        2.0,
				dur:        Pseq([
					~f2, ~f2,
					Rest(~f1), ~f2, ~f1,
					Rest(~f2), ~f2,

					~f2, ~f2,
					Rest(~f1), ~f2, ~f1,
					Rest(~f4),


				], inf),
				pan: -0.7,
				doubleAmp: [0.0, 1.0, 0.0], double: [0.5],
				attack: 0.05, release: 0.05,
				rate: Pwhite(0.999, 1.001),
				grainCenter: [0.0, 1.0, 0.0], grainWidth: [0, 0.01, 0],
				grainCenterLag: 0.01,
				doubleAmp: [0,1,0], double: [2.0],
				seqDepth: [0,1,0],

				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~f8/4 + 0.125, tremSkew: 0.5, tremWave: 0.0, tremPhase: 2*pi/3, tremPulseWidth: 0.8, tremTarget: \pulse,

				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~f8*4, tremSkew2: 0.5, tremWave2: 0, tremPulseWidth2: 0.3, tremTarget2: \saw,

				steps: [
					(buffers: [
						~music
					])
				],
			),

			(
				dials:      [\doubleAmp, \grainWidth],
				freeze:     true, spectral: false, delay: false,
				amp:        2.0,
				dur:        Pseq([
					~f1, ~f1, Rest(~f2),
					~f1, ~f1, Rest(~f2),
					Rest(~f2), ~f1, ~f1,
					Rest(~f2), ~f1, ~f1,


					~f1, ~f1, Rest(~f2),
					~f1, ~f1, Rest(~f2),
					Rest(~f2), ~f1, ~f1,
					Rest(~f2), ~f2,

				], inf),
				pan: 0.3,
				doubleAmp: [0.0, 1.0, 0.0], double: [0.5],
				attack: 0.05, release: 0.05,
				rate: Pwhite(0.999, 1.001),
				grainCenter: [0.0, 1.0, 0.0], grainWidth: [0, 0.01, 0],
				grainCenterLag: 0.2,
				doubleAmp: [0,1,0], double: [2.0],
				seqDepth: [0,1,0],

				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~f8/4 + 0.125, tremSkew: 0.5, tremWave: 0.0, tremPhase: 2*pi/3, tremPulseWidth: 0.8, tremTarget: \pulse,

				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~f8*4, tremSkew2: 0.5, tremWave2: 0, tremPulseWidth2: 0.3, tremTarget2: \saw,

				steps: [
					(buffers: [
						~music
					])
				],
			),

			(
				dials:      [\doubleAmp, \grainWidth],
				// dials:      [\seqDepth, \grainWidth],
				freeze:     false, spectral: true, delay: false,
				amp:        2.0,
				dur:        Pseq([
					~f1, ~f2, Rest(~f1),
					Rest(~f1), ~f2, ~f1,
					Rest(~f2), ~f2,
					Rest(~f2), ~f2,

					~f1, ~f2, Rest(~f1),
					Rest(~f1), ~f2, ~f1,
					Rest(~f2), ~f2,
					Rest(~f2), Rest(~f1), ~f1
				], inf),
				pan: -0.25,
				doubleAmp: [0.0, 1.0, 0.0], double: [0.5],
				attack: 0.05, release: 0.05,
				rate: Pwhite(0.999, 1.001),
				grainCenter: [0.0, 1.0, 0.0], grainWidth: [0, 0.01, 0],
				grainCenterLag: 0.02,
				seqDepth: [0,1,0],

				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~f8/4 + 0.125, tremSkew: 0.5, tremWave: 0.0, tremPhase: 2*pi/3, tremPulseWidth: 0.8, tremTarget: \pulse,

				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~f8*4, tremSkew2: 0.5, tremWave2: 0, tremPulseWidth2: 0.3, tremTarget2: \saw,

				steps: [
					(buffers: [
						~music
					])
				],
			),
			(
				// dials:      [\seqDepth, \grainWidth],
				dials:      [\doubleAmp, \grainWidth],
				freeze:     false, spectral: true, delay: false,
				amp:        2.0,
				dur:        Pseq([
					~f2, ~f2,
					Rest(~f1), ~f2, ~f1,
					Rest(~f1), ~f2, ~f1,
				], inf),
				pan: 0.7,
				doubleAmp: [0.0, 1.0, 0.0], double: [0.25],
				attack: 0.05, release: 0.05,
				rate: Pwhite(0.999, 1.001),
				seqDepth: [0,1,0],
				grainCenter: [0.0, 1.0, 0.0], grainWidth: [0, 0.01, 0],//0.0001,
				grainCenterLag: 0.05,

				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~f8/2 + 0.125, tremSkew: 0.5, tremWave: 0.0, tremPhase: 4*pi/3, tremPulseWidth: 0.8, tremTarget: \pulse,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~f8*8 + 0.125, tremSkew2: 0.5, tremWave2: 0, tremPulseWidth2: 0.3, tremTarget2: \saw,

				steps: [
					(buffers: [
						~music
					])
				],
			),


			(
				dials:      [\grainWidth, \doubleAmp],
				freeze:     false, spectral: true, delay: true,
				amp:        2.0,
				// 12 sixteenths = a 3/4 cell against the 4/4 bar;
				// four cycles = 3 bars
				dur:        Pseq([
					~f4



				], inf),
				pan: 0.15,
				attack: 0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				doubleAmp: [0,1,0], double: [0.25],//, 2.0],

				grainCenter: 0.5, grainWidth: [0.0, 1.0, 0.0],
				steps: [
					(buffers: [
						~wb1

					])
				],
			),



			(
				dials:      [\grainWidth, \doubleAmp],
				freeze:     false, spectral: false, delay: true, reso: true, resoNote: \Db2,
				amp:        2.0,
				// 48 sixteenths = 3 bars: straight 8ths, then dotted-8th
				// hemiola slipping across the barline, then a broken fill
				dur:        Pseq([
					~f1, ~f1, ~f2, Rest(~f1), ~f2, Rest(~f1),
					~f2, ~f1, Rest(~f1), ~f2, ~f2, ~f1,
				], inf),
				pan: 0.5,

				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*4, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [1.001],
				attack: 0.001, release: 0.001,
				rate: Pwhite(0.999, 1.001),
				grainCenter: 0/127, grainWidth: [0.0, 0.25, 0.0],
				steps: [
					(buffers: [
						~b17
					])
				],
			),


			(
				dials:      [\grainWidth, \doubleAmp],
				freeze:     false, spectral: false, delay: false,
				amp:        2.0,
				// 12 sixteenths = a 3/4 cell against the 4/4 bar;
				// four cycles = 3 bars
				dur:        Pseq([
					~f1, ~f2, ~f1, Rest(~f2),
					~f2, ~f1, Rest(~f1), Rest(~f2),

					~f1, ~f2, ~f1, Rest(~f2),
					~f2, ~f1, Rest(~f1), Rest(~f2),

					~f1, ~f2, ~f1, Rest(~f2),
					~f2, ~f1, Rest(~f1), Rest(~f2),

					~f1, ~f2, ~f1, Rest(~f2),



				], inf),
				pan: 0.15,
				attack: 0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				doubleAmp: [0,1,0], double: [0.5, 2.0],

				grainCenter: Pwhite(0, 0.8, inf), grainWidth: [0.0, 0.04, 0.0],
				steps: [
					(buffers: [
						~b4
					])
				],
			),


			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: false, delay: false, reso: true, resoNote: \Db2,
				amp:        2.0,
				// 12 sixteenths = a 3/4 cell against the 4/4 bar;
				// four cycles = 3 bars
				dur:        Pseq([
					~f4, //~f1, ~f1,
/*					Rest(~f2), ~f1, ~f1,
					Rest(~f2), ~f1, ~f1,
					Rest(~f2), ~f2,
					~f2, ~f1, ~f1,
					Rest(~f2), ~f1, ~f1,
					Rest(~f2), ~f1, ~f1,
					Rest(~f4),
					Rest(~f2), ~f1, ~f1,*/

				], inf),
				pan: -0.1,
				attack: 0.001, release: 0.001,
				rate: 3*Pwhite(0.999, 1.001),
				doubleAmp: [0,1,0], double: [3.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*32, tremSkew: 0, tremWave: 0.0, tremTarget: \saw,

				grainCenter: 42/127, grainWidth: 72/127,
				steps: [
					(buffers: [
						~b16
					])
				],
			),


		],
		rhythm: \fourFourGrooves,
		layers: [
			nil,
			nil,
			nil,
		],
	),
];
"Score loaded: % scenes.".format(~score.size).postln;
)
