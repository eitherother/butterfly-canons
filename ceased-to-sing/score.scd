(
~bpm = 88;
~qn  = 60 / ~bpm;  // seconds per quarter note (period) — used by ~fN durations below


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
				dur:        252,
				pan: -0.4,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn/2, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*3, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~footsteps
					], repeats: [1]),

				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: true, delay: false, drive: false,
				amp:        1.0,
				dur:        240,
				pan: -0.2,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn/2.1, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*4, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~traffic
					], repeats: [1]),

				],
			),
			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: true, delay: false, drive: false,
				amp:        2.0,
				dur:        228,
				pan: 0.2,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn/2.2, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*3 + 0.125, tremSkew2: 0.5, tremWave2: 1.0, tremTarget2: \saw,
				steps: [
					(buffers: [
						~piano
					], repeats: [1]),

				],
			),

			(
				dials:      [\tremDepth, \grainWidth],
				freeze:     false, spectral: true, delay: false, drive: false,
				amp:        0.3,
				dur:        2,
				attack:     0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				attack:     0.1, release: 0.3,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*4 - 0.125, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				steps: [
					(buffers: [
						~vib[\Eb6], ~vib[\C6], ~vib[\G5], ~silence, ~silence,
						~vib[\Eb6], ~vib[\C6], ~vib[\G5], ~vib[\F5], ~silence, ~silence, ~silence,
						~vib[\G5], ~vib[\A5], ~vib[\D6], ~vib[\Eb6], ~vib[\F6], ~silence, ~silence, ~silence,
					], repeats: [1]),
				],
			),


			(
				dials:      [\tremDepth, \grainWidth],
				freeze:     true, spectral: false, delay: true, drive: false,
				amp:        1.0,
				dur:        Pwhite(0.9, 1.2),
				attack:     0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				attack:     0.1, release: 0.3,

				grainWidth: 1.0, grainCenter: 0.5,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*4 - 0.125, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				steps: [
					(buffers: [
						~bass[\Db2], ~bass[\C2], ~silence, ~silence,
						~bass[\Db2], ~bass[\C2], ~silence, ~bass[\B1], ~silence, ~silence, ~silence,
						~bass[\Eb1], ~bass[\G1], ~silence, ~silence,
						~bass[\C3], ~bass[\G2], ~silence, ~silence, ~silence,
						~bass[\Eb3], ~bass[\C3], ~bass[\G2], ~silence, ~silence, ~silence, ~silence,
					], repeats: [1]),
				],
			),


			(
				dials:      [\tremDepth, \grainWidth],
				freeze:     true, spectral: false, delay: true, drive: false,
				amp:        0.3,
				dur:        Pwhite(0.1, 0.2),
				attack:     0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				attack:     0.1, release: 0.3,

				grainWidth: Pwhite(0.35, 0.45), grainCenter: 0.35,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*4 - 0.125, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				steps: [
					(buffers: [
						~cl[\G6], ~cl[\Eb6], ~cl[\F6], ~silence,
						~cl[\Eb6], ~cl[\D6], ~cl[\F6], ~cl[\C6], ~silence,
						~cl[\Bb5], ~cl[\Eb5], ~cl[\F5], ~silence,
					], repeats: [
						4, 4, 4, 30,
						4, 4, 4, 8, 60,
						5, 6, 7, 40,
					]),
				],
			),

			nil,nil


		],
		rhythm: \leaves,
		layers: [
			nil,
			nil,
			nil,
		],
		checkpoints: [],
	),
];
"Score loaded: % scenes.".format(~score.size).postln;
)

