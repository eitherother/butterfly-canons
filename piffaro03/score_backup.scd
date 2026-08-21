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
//   buffers:    (required)    — array of buffer objects (~ob[\G3] etc.)
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

~qn = 0.75;
~durScale = 1;
~eighth = ~qn/2;
~sixteenth = ~qn/4;
~thirtysecond = ~qn/8;
~half = ~qn * 2;
~whole = ~qn * 4;
~breve = ~qn * 8;

~tn = ~qn*1.5;

~f1 = ~qn;
~f2 = ~qn/3;
~f3 = ~qn * 3;

// ~flowSteps[i] collects the i-th entry of every ~rawSteps step (0-3:
// harmony/pnpp arpeggios, 4-7: melody), wrapped as step events for
// ~buildBufSeq.
~flowSteps = (0..7).collect { |i|
	~rawSteps.collect { |step| (buffers: step[i], repeats: [1]) }
};

~music = ~mephisto;



~score = [
	// ---- Scene 1 -----------------------------------------------
	(
		name: \scene1,
		delayTime: ~f1/2,
		stepRate: 6,
		flows: [
			// Flow 1
			(
				dials:      [\attack, \grainWidth],
				freeze:     false, spectral: true, delay: true,
				amp:        1.0,
				dur:        Pseq([
					~f1, ~f1, ~f1,
					// ~f1/3, ~f1/3, ~f1/3, ~f1, ~f1, ~f1
				], inf),
				pan: 0.6,
				attack: [0.001, 0.3, 0.001], release: 0.001,
				rate: Pwhite(0.999, 1.001),
				double: [0], doubleAmp: [0.0, 1.0, 0.0],
				grainCenter: [0.0, 1.0, 0.0], grainWidth: [0.001, 0.02, 0.001],
				steps: [
					(buffers: [
						~music
					])
				],
			),
			(
				dials:      [\attack, \grainWidth],
				freeze:     false, spectral: false, delay: false,
				amp:        1.0,
				dur:        Pseq([
					~f2, ~f2, ~f2,
					// ~f2*2, ~f2,
				], inf),
				pan: 0,
				attack: [0.001, 0.3, 0.001], release: 0.001,
				rate: Pwhite(0.999, 1.001),
				double: [0], doubleAmp: [0.0, 1.0, 0.0],
				grainCenter: [0.0, 1.0, 0.0], grainWidth: [0.001, 0.02, 0.001],
				// seqDepth: 0.8,
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*4, tremSkew: 0.5, tremWave: 1.0, tremTarget: \saw,
				// tremDepth2:  1.0, tremRate2: ~qn/4, tremSkew2: 0.5, tremWave2: 0.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~music
					])
				],
			),
			(
				dials:      [\attack, \grainWidth],
				freeze:     5.0, spectral: false, delay: false,
				amp:        1.0,
				dur:        Pseq([
					~f3, ~f3, ~f3, //~f3/3, ~f3/3, ~f3/3,
				], inf),
				pan: -0.3,
				attack: [0.001, 0.3, 0.001], release: 0.001,
				rate: Pwhite(0.999, 1.001),
				grainCenter: [0.0, 1.0, 0.0], grainWidth: [0.001, 0.02, 0.001],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*6, tremSkew: 0.5, tremWave: 0.5, tremTarget: \triangle,
				steps: [
					(buffers: [
						~music
					])
				],
			),

			/////// Strings ///////
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     0.2, spectral: false, delay: false,
				amp:        0.05,
				dur:        Pwhite(0.15, 0.35),
				pan: -0.4,
				attack: 0.2, release: 0.2,
				rate: Pwhite(0.999, 1.001)*Pseg([1.0, 0.98, 1.0, 1.02, 1.0], [8, 8, 8, 8], 'lin', inf),
				grainCenter: 0.3, grainWidth: Pwhite(0.35, 0.45),
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~tn, tremSkew: 0.5, tremWave: 0.0, tremTarget: \triangle,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~tn/2, tremSkew2: 0.5, tremWave2: 0.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~vcl[\E2], ~vla[\Gb3], ~vla[\D4], ~vln[\A4], ~vln[\E5]
					], repeats: [10, 13, 16])
				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false,
				amp:        0.05,
				dur:        Pwhite(0.15, 0.35),
				pan: -0.2,
				attack: 0.2, release: 0.2,
				rate: Pwhite(0.999, 1.001)*Pseg([1.0, 0.98, 1.0, 1.02, 1.0], [10, 10, 10, 10], 'lin', inf),
				// double: [1.5], doubleAmp: 1.0,
				grainCenter: 0.3, grainWidth: Pwhite(0.35, 0.45),
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~tn*3, tremSkew: 0.5, tremWave: 0.0, tremTarget: \triangle,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~tn/3, tremSkew2: 0.5, tremWave2: 0.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~vcl[\E2], ~vla[\Gb3], ~vla[\D4], ~vln[\A4], ~vln[\E5]
					], repeats: [12, 16, 19])
				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false,
				amp:        0.05,
				dur:        Pwhite(0.15, 0.35),
				pan: 0.0,
				attack: 0.2, release: 0.2,
				rate: Pwhite(0.999, 1.001),
				// double: [1.5], doubleAmp: 1.0,
				grainCenter: 0.3, grainWidth: Pwhite(0.35, 0.45),
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~tn*3 + 0.111, tremSkew: 0.5, tremWave: 0.0, tremTarget: \triangle,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~tn/3 + 0.333, tremSkew2: 0.5, tremWave2: 0.5, tremTarget2: \saw,
				steps: [
					(buffers: [
						~vcl[\E2], ~vla[\Gb3], ~vla[\D4], ~vln[\A4], ~vln[\E5]
					], repeats: [14, 18, 20])
				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false,
				amp:        0.05,
				dur:        Pwhite(0.15, 0.35),
				pan: 0.2,
				attack: 0.2, release: 0.2,
				rate: Pwhite(0.999, 1.001),
				double: [1.5], doubleAmp: 1.0,
				grainCenter: 0.3, grainWidth: Pwhite(0.35, 0.45),
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~tn*3 - 0.111, tremSkew: 0.5, tremWave: 0.0, tremTarget: \triangle,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~tn/3 - 0.333, tremSkew2: 0.5, tremWave2: 0.5, tremTarget2: \saw,
				steps: [
					(buffers: [
						~vcl[\E2], ~vla[\Gb3], ~vla[\D4], ~vln[\A4], ~vln[\E5]
					], repeats: [9, 12, 15])
				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: false, delay: false,
				amp:        0.05,
				dur:        Pwhite(0.1, 0.2),
				pan: 0.4,
				attack: 0.2, release: 0.2,
				rate: Pwhite(0.999, 1.001),
				double: [1.5], doubleAmp: 1.0,
				grainCenter: 0.25, grainWidth: Pwhite(0.3, 0.4),
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~tn*4, tremSkew: 0.5, tremWave: 0.0, tremTarget: \triangle,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~tn/6, tremSkew2: 0.5, tremWave2: 0.5, tremTarget2: \saw,
				steps: [
					(buffers: [
						~vcl[\E2], ~vla[\Gb3], ~vla[\D4], ~vln[\A4], ~vln[\E5]
					], repeats: [9, 12, 15])
				],
			),
		],
		rhythm: \tripletGrooves,
		layers: [
			nil,
			nil,
			nil,
		],
	),

];
"Score loaded: % scenes.".format(~score.size).postln;
)
