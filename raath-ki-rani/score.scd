(
~bpm = 88;
~qn  = 60 / ~bpm;  // seconds per quarter note (period) — used by ~fN durations below


~score = [
	// ---- Scene 1 -----------------------------------------------
	(
		name: \scene1,
		delayTime: 1.5,
		stepRate: 12 / ~qn,  // 3 steps/beat (triplet 8ths), locked to ~bpm
		flows: [
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: true, delay: false, drive: false,
				amp:        0.1,
				dur:        Pwhite(0.1, 0.2),
				attack:     0.01, release: 0.01,
				rate: Pseg([1.00, 0.99, 1.01, 1.00, 1.00], [10], 'lin', inf) * Pwhite(0.999, 1.001),
				attack:     0.1, release: 0.3,
				double: [1.5], doubleAmp: [0.0, 1.0, 0.0],
				grainWidth: Pwhite(0.35, 0.45), grainCenter: 0.35,
				steps: [
					(buffers: [
						~vcl[\B2], ~vla[\Gb3], ~vla[\A3], ~vla[\D4], ~silence,
						~vla[\Db3], ~vla[\Gb3], ~vla[\A3], ~vla[\D4], ~silence,
						~vla[\D3], ~vla[\Gb3], ~vla[\A3], ~vla[\D4], ~silence,
						~vcl[\B2], ~vla[\Gb3], ~vla[\A3], ~vla[\D4], ~silence,
						~vcl[\A2], ~vla[\Gb3], ~vla[\A3], ~vla[\D4], ~silence,
						~vcl[\D2], ~vla[\Gb3], ~vla[\A3], ~vla[\D4], ~silence,
					], repeats: [20, 15, 24]),
				],
			),

			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: true, delay: false, drive: false,
				amp:        0.1,
				dur:        Pwhite(0.1, 0.2),
				attack:     0.01, release: 0.01,
				rate: Pseg([1.00, 0.99, 1.01, 1.00, 1.00], [11], 'lin', inf) * Pwhite(0.999, 1.001),
				attack:     0.1, release: 0.3,
				double: [1.5], doubleAmp: [0.0, 1.0, 0.0],
				grainWidth: Pwhite(0.35, 0.45), grainCenter: 0.35,
				steps: [
					(buffers: [
						~vla[\A3], ~vla[\D4], ~vla[\Gb4], ~vla[\Db5], ~silence,
						~vla[\A3], ~vla[\D4], ~vla[\Gb4], ~vla[\D5], ~silence,
						~vla[\A3], ~vla[\D4], ~vla[\Gb4], ~vla[\E5], ~silence,
					], repeats: [15, 18, 22]),
				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: false, delay: false, drive: false,
				amp:        0.1,
				dur:        Pwhite(0.1, 0.2),
				attack:     0.01, release: 0.01,
				rate: Pseg([1.00, 0.99, 1.01, 1.00, 1.00], [12], 'lin', inf) * Pwhite(0.999, 1.001),
				attack:     0.1, release: 0.3,
				double: [1.5], doubleAmp: [0.0, 1.0, 0.0],
				grainWidth: Pwhite(0.35, 0.45), grainCenter: 0.35,
				steps: [
					(buffers: [
						~vln[\Gb4], ~vln[\Db5], ~vln[\A5], ~vln[\Db6], ~silence,
						~vln[\Gb4], ~vln[\D5], ~vln[\A5], ~vln[\Db6], ~silence,
						~vln[\Gb4], ~vln[\E5], ~vln[\A5], ~vln[\Db6], ~silence,
					], repeats: [14, 10, 21]),
				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: false, delay: false, drive: false,
				amp:        0.1,
				dur:        Pwhite(0.1, 0.2),
				attack:     0.01, release: 0.01,
				rate: Pseg([1.00, 0.99, 1.01, 1.00, 1.00], [13], 'lin', inf) * Pwhite(0.999, 1.001),
				attack:     0.1, release: 0.3,
				double: [1.5], doubleAmp: [0.0, 1.0, 0.0],
				grainWidth: Pwhite(0.35, 0.45), grainCenter: 0.35,
				steps: [
					(buffers: [
						~vln[\Db5], ~vln[\A5], ~vln[\Db6], ~silence,
						~vln[\D5], ~vln[\A5], ~vln[\Db6], ~vln[\A6], ~silence,
						~vln[\E5], ~vln[\A5], ~vln[\Db6],  ~vln[\A6], ~silence,
					], repeats: [12, 8, 24]),
				],
			),


			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: true, delay: false, drive: false,
				amp:        1.0,
				dur:        Pwhite(0.1, 0.2),
				attack:     0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				attack:     0.1, release: 0.3,
				double: [1.5], doubleAmp: [0.0, 1.0, 0.0],
				grainWidth: Pwhite(0.35, 0.45), grainCenter: 0.35,
				steps: [
					(buffers: [
						~bass[\D1], ~bass[\A1], ~silence
					], repeats: [50, 40, 30]),
				],
			),

			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        2.0,
				dur:        Pwhite(0.1, 0.2),
				attack:     0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				attack:     0.1, release: 0.3,
				double: [1.5], doubleAmp: [0.0, 1.0, 0.0],
				grainWidth: Pwhite(0.35, 0.45), grainCenter: 0.2,
				steps: [
					(buffers: [
						~voice_E4
					], repeats: [1]),
				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: false, delay: false, drive: false,
				amp:        2.0,
				dur:        Pwhite(0.1, 0.2),
				attack:     0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				attack:     0.1, release: 0.3,
				double: [1.5], doubleAmp: [0.0, 1.0, 0.0],
				grainWidth: Pwhite(0.35, 0.45), grainCenter: 0.2,
				steps: [
					(buffers: [
						~voice_A4
					], repeats: [1]),
				],
			),




	(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: false, delay: true, drive: false,
				amp:        4.0,
				dur:        Pseq([
					1, 6,
					0.001, 1, 0.001, 6,
					0.001, 0.001, 1, 0.001, 0.001, 6
				], inf),
				attack:     [0.01, 0.3, 0.01], release: 0.2,
				rate: Pwhite(0.999, 1.001),
				grainWidth: 1.0, grainCenter: 0.5,
				doubleAmp: [0.0, 1.0, 0.0], double: [1.5],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*3, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				steps: [
					(buffers: [
						~pnff[\Db5], ~pnff[\E5],
						~pnff[\Db5], ~pnff[\Db6], ~pnff[\E5], ~pnff[\E6],
						~pnff[\Db5], ~pnff[\Db6], ~pnff[\Db7], ~pnff[\E5], ~pnff[\E6], ~pnff[\E7]
					], repeats: [1])
				],
			),

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

