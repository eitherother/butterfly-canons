// ============================================================
// TVP3 — Score
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

~qn = 1;

~tn = ~qn;

~f8 = ~qn;
~f4 = ~qn / 2;
~f2 = ~qn / 4;
~f1 = ~qn / 8;
~f3 = ~qn / 3;
~f6 = ~qn / 6;


~music = ~in_nomine_6;


~score = [
	// ---- Scene 2 -----------------------------------------------
	(
		name: \scene1,
		delayTime: ~f3/3,
		stepRate: ~qn*24,
		flows: [
			/*(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: false, delay: true, drive: false,
				amp:        0.3,
				dur:        94,
				pan: -0.4,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				// tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn/4, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~in_nomine_60
					], repeats: [1]),

				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        94,
				pan: -0.2,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				// tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn/4, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~in_nomine_61
					], repeats: [1]),

				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        94,
				pan: 0.2,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				// tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn/4, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~in_nomine_62
					], repeats: [1]),

				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        94,
				pan: 0.4,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				// tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn/4, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~in_nomine_63
					], repeats: [1]),

				],
			),*/





			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        Pwhite(0.03, 0.07),
				attack:     0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.2, 0.3), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*2, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [~bass[\Gb1]


					], repeats: [96]),

				],
			),
	(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        0.3,
				dur:        Pwhite(0.03, 0.07),
				attack:     0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.2, 0.3), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*4, tremSkew: 0.5, tremWave: 01.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [1.5],
				// tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn/4, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [~bass[\Db2]


					], repeats: [96]),

				],
			),


			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: true, delay: false,
				amp:        1.0,
				dur:        Pseq([~f4, ~f2, ~f2, ~f4], inf),//~f4, //Pwhite(0.05, 0.1),//~f8,
				pan: 0.5,
				doubleAmp: [0.0, 1.0, 0.0], double: [0.5],
				attack: 0.05, release: 0.05,
				rate: Pwhite(0.999, 1.001),
				grainCenter: [0.0, 1.0, 0.0], grainWidth: [0, 0.01, 0],
				doubleAmp: [0,1,0], double: [2.0],

				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~f8/4 + 0.125, tremSkew: 0.5, tremWave: 0.0, tremPhase: 2*pi/3, tremPulseWidth: 0.8, tremTarget: \pulse,

				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~f8*4, tremSkew2: 0.5, tremWave2: 0, tremPulseWidth2: 0.3, tremTarget2: \saw,

				steps: [
					(buffers: [
						~music
					])
				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     true, spectral: true, delay: false,
				amp:        1.0,
				dur:        Pseq([~f2, ~f1, ~f2, ~f2, ~f1], inf),//~f4, //Pwhite(0.05, 0.1),//~f8,
				pan: 0.5,
				doubleAmp: [0.0, 1.0, 0.0], double: [0.5],
				attack: 0.05, release: 0.05,
				rate: Pwhite(0.999, 1.001),
				grainCenter: [0.0, 1.0, 0.0], grainWidth: 0.0001,
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~f8/2 + 0.125, tremSkew: 0.5, tremWave: 0.0, tremPhase: 4*pi/3, tremPulseWidth: 0.8, tremTarget: \pulse,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~f8*8 + 0.125, tremSkew2: 0.5, tremWave2: 0, tremPulseWidth2: 0.3, tremTarget2: \saw,

				steps: [
					(buffers: [
						~music
					])
				],
			),




			(
				dials:      [\tremDepth, \grainWidth],
				freeze:     false, spectral: false, delay: true,
				amp:        2.0,
				dur:        Pseq([
					~f2
				], inf),
				pan: -0.6,
				attack: 0.001, release: 0.001,
				rate: Pwhite(0.999, 1.001),
				grainCenter: Pseq([41/127, 63/127], inf), grainWidth: [0.0, 0.005, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*16, tremSkew: 0.5, tremWave: 0.0, tremTarget: \pulse,
				steps: [
					(buffers: [
						~woodlands, ~whale4
					])
				],
			),
			(
				dials:      [\tremDepth, \grainWidth],
				freeze:     false, spectral: false, delay: false,
				amp:        2.0,
				dur:        Pseq([
					~f2, Rest(~f1), ~f1, Rest(~f1), ~f1, Rest(~f2),
					Rest(~f2), ~f1*2, ~f1, Rest(~f1/2), Rest(~f1), ~f1, Rest(~f1/2), ~f2,
				], inf),
				pan: -0.6,
				attack: [0.001, 0.3, 0.001], release: 0.001,
				rate: Pwhite(0.999, 1.001),
				grainCenter: 20/127, grainWidth: [0.0, 0.001, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0.5, tremWave: 0.9, tremPulseWidth: 0.3, tremTarget: \pulse,
				steps: [
					(buffers: [
						~seawash
					])
				],
			),

			(
				dials:      [\doubleAmp, \grainWidth],
				freeze:     false, spectral: false, delay: true,
				amp:        2.0,
				dur:        Pseq([
					~f1, ~f1, Rest(~f1), ~f1,
					Rest(~f4),
					~f1, ~f1, Rest(~f1), ~f1,
					Rest(~f4),
				], inf),
				pan: -0.6,
				attack: 0.001, release: 0.001,
				rate: Pwhite(0.999, 1.001),
				double: [2.0, 0.5], doubleAmp: [0.0, 1.0, 0.0],

				grainCenter: 52/127, grainWidth: [0.0, 0.01, 0.0],
				// tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*16, tremSkew: 0.5, tremWave: 0.9, tremPulseWidth: 0.3, tremTarget: \pulse,
				steps: [
					(buffers: [
						~whale3
					])
				],
			),
/*			(
				dials:      [\tremDepth, \grainWidth],
				freeze:     false, spectral: false, delay: false,
				amp:        1.0,
				dur:        Pseq([
					Rest(~f2), ~f2,
				], inf),
				pan: -0.6,
				attack: 0.001, release: 0.001,
				rate: Pwhite(0.999, 1.001),
				grainCenter: 63/127, grainWidth: [0.0, 0.005, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*64, tremSkew: 0.5, tremWave: 0, tremTarget: \pulse,
				steps: [
					(buffers: [
						~whale4
					])
				],
			),*/

			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: false, delay: false,
				amp:        0.2,
				dur:        Pwhite(0.2, 0.3),
				pan: -0.1,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*4, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [2.0],
				steps: [
					(buffers: [
						~cl[\Gb6], ~cl[\A6], ~cl[\Ab6], ~silence,
						~cl[\Gb6], ~cl[\A6], ~cl[\Ab6], ~silence,
						~cl[\Gb6], ~cl[\A6], ~cl[\Ab6], ~cl[\E6], ~cl[\D6], ~silence,
					], repeats: [12, 14, 13, 11, 15]),
				],
			),

		],
		rhythm: \tripletGrooves,
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
