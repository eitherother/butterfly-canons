(
~qn = 0.9;

~f8 = ~qn;
~f4 = ~qn / 2;
~f2 = ~qn / 4;
~f1 = ~qn / 8;
~f3 = ~qn / 3;

~music = ~byrd_mass;

~score = [
	// ---- Scene 1 -----------------------------------------------
	(
		name: \scene1,
		delayTime: ~f2,
		stepRate: 8 / ~qn,
		flows: [
			(
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
				attack: 0.05, release: 0.05,
				rate: Pwhite(0.999, 1.001),
				grainCenter: [0.0, 1.0, 0.0], grainWidth: [0, 0.01, 0],
				grainCenterLag: 0.01,
				doubleAmp: [0,1,0], double: [2.midiratio],
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
				doubleAmp: [0,1,0], double: [4.midiratio],
				steps: [
					(buffers: [
						~music
					])
				],
			),
			(
				dials:      [\doubleAmp, \grainWidth],
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
				doubleAmp: [0.0, 1.0, 0.0], double: [-3.midiratio],
				attack: 0.05, release: 0.05,
				rate: Pwhite(0.999, 1.001),
				grainCenter: [0.0, 1.0, 0.0], grainWidth: [0, 0.01, 0],
				grainCenterLag: 0.02,
				steps: [
					(buffers: [
						~music
					])
				],
			),
			(
				dials:      [\doubleAmp, \grainWidth],
				freeze:     false, spectral: true, delay: false,
				amp:        2.0,
				dur:        Pseq([
					~f2, ~f2,
					Rest(~f1), ~f2, ~f1,
					Rest(~f1), ~f2, ~f1,
				], inf),
				pan: 0.7,
				doubleAmp: [0.0, 1.0, 0.0], double: [-5.midiratio],
				attack: 0.05, release: 0.05,
				rate: Pwhite(0.999, 1.001),
				grainWidth: [0, 0.01, 0],
				grainCenterLag: 0.05,
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
				dur:        Pseq([
					~f4
				], inf),
				pan: 0.15,
				attack: 0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				doubleAmp: [0,1,0], double: [0.25],
				grainCenter: 0.5, grainWidth: [0.0, 1.0, 0.0],
				steps: [
					(buffers: [
						~wb1
					])
				],
			),
			(
				dials:      [\grainWidth, \doubleAmp],
				freeze:     false, spectral: false, delay: true,  reso: true, resoNote: Pseq([\Gb1, \Db2, \Gb2, \Ab2, \A2], inf),
				amp:        2.0,
				dur:        Pseq([
					~f1, ~f1, ~f2, Rest(~f1), ~f2, Rest(~f1),
					~f2, ~f1, Rest(~f1), ~f2, ~f2, ~f1,
				], inf),
				pan: 0.5,
				doubleAmp: [0,1,0], double: [1.001],
				attack: 0.001, release: 0.001,
				rate: Pwhite(0.999, 1.001),
				grainCenter: 0, grainWidth: [0.0, 0.25, 0.0],
				steps: [
					(buffers: [
						~b17
					])
				],
			),
			(
				dials:      [\grainWidth, \doubleAmp],
				freeze:     false, spectral: false, delay: false, reso: true, resoNote: Pseq([\Gb1, \Db2, \Gb2, \Ab2, \A2], inf),
				amp:        2.0,
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
				dials:      [\tremDepth, \grainWidth],
				freeze:     true, spectral: false, delay: false,
				amp:        0.3,
				dur:        ~f8,
				rate: Pwhite(0.999, 1.001),
				attack:     0.1, release: 0.1,

				grainWidth: [0.05, 0.2, 0.05], grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0, tremWave: 0.0,
				doubleAmp: [0,1,0], double: [2.0],
				steps: [
					(buffers: [~bass[\Db1]], repeats: [1]),
				],
			),

		],
		rhythm: \fourFourGrooves,
	),
];
"Score loaded: % scenes.".format(~score.size).postln;
)
