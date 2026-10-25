(
~qn = 1.6;

~f8 = ~qn;
~f4 = ~qn / 2;
~f2 = ~qn / 4;
~f1 = ~qn / 8;
~fh = ~qn / 16;
~f3 = ~qn / 3;

~score = [
	// ---- Scene 1 -----------------------------------------------
	(
		name: \scene1,
		delayTime: ~f1,
		stepRate: 8 / ~qn,
		flows: [

			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, spectral: true, delay: false,
				amp:        1.0,
				dur:        140,
				pan: 0.0,
				attack: 0.05, release: 0.05,
				rate: Pwhite(0.999, 1.001),
				grainWidth: 1.0, grainCenter: 0.5,
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*6, tremSkew: 0, tremWave: 1.0, tremTarget: \pulse,
				tremDepth2: [0.0, 1.0, 0.0], tremRate2: ~qn*3, tremSkew2: 0, tremWave2: 0.0, tremTarget2: \pulse, tremPulseWidth2: 0.9,
				steps: [
					(buffers: [
						~whales1
					])
				],
			),


			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: false, delay: false,
				amp:        0.3,
				dur:        Pwhite(0.2, 0.3),
				pan: -0.1,
				rate: Pwhite(0.999, 1.001),
				attack:     0.1, release: 0.1,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*6, tremSkew: 0, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [1.5],
				steps: [
					(buffers: [

						~flt[\Db7], ~flt[\Bb6], ~silence,
						~flt[\Db7], ~flt[\Bb6], ~silence,
						~flt[\A6], ~flt[\Gb6], ~silence,
						~flt[\Ab6], ~flt[\Db6], ~silence,
					], repeats: [17, 20, 24, 13]),
				],
			),


			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     true, spectral: false, delay: false,
				amp:        0.3,
				dur:        Pwhite(0.2, 0.3),
				pan: 0.25,
				rate: 0.985*Pwhite(0.999, 1.001)*Pseg([0.9, 1.1, 0.9], [~qn*8, ~qn*8], \sin, inf) ,
				attack:     0.1, release: 0.1,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*3, tremSkew: 0, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [1.5],
				steps: [
					(buffers: [

						~flt[\Db7], ~flt[\Bb6], ~silence,
						~flt[\Db7], ~flt[\Bb6], ~silence,
						~flt[\A6], ~flt[\Gb6], ~silence,
						~flt[\Ab6], ~flt[\Db6], ~silence,
					], repeats: [11, 25, 30, 14]),
				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, spectral: false, delay: false,
				amp:        3.0,
				dur:        Pwhite(0.2, 0.3),
				pan: -0.1,
				rate: Pwhite(0.999, 1.001),
				attack:     0.2, release: 0.2,

				grainWidth: Pwhite(0.3, 0.4), grainCenter: 0.25,
				seqDepth: [0.0, 1.0, 0.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*3, tremSkew: 0, tremWave: 1.0, tremTarget: \saw,

				doubleAmp: [0,1,0], double: [7.midiratio],
				steps: [
					(buffers: [

						~pnmf[\Gb4], ~pnmf[\D5],
					], repeats: [20]),
				],
			),

			(
				dials:      [\grainWidth, \doubleAmp],
				freeze:     false, spectral: false, delay: true, ring: true,
				amp:        2.0,
				dur:        Pseq([
					~qn* 2
				], inf),
				pan: 0.15,
				attack: 0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [0.5, 2.0],
				grainCenter: 40/127, grainWidth: [0,1,0],
				steps: [
					(buffers: [
						~b5
					])
				],
			),


			(
				dials:      [\grainWidth, \doubleAmp],
				freeze:     false, spectral: false, delay: false, ring: true,
				amp:        2.0,
				dur:        Pseq([
					~f4,
					~f4,
					~f4,
					~f4,
					~f1, ~f2, Rest(~f1),
				], inf),
				pan: 0.15,
				attack: 0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [0.5, 2.0],
				grainCenter: 0, grainWidth: [0,1,0],
				steps: [
					(buffers: [
						~b2
					])
				],
			),

			(
				dials:      [\grainWidth, \doubleAmp],
				freeze:     false, spectral: false, delay: true, ring: true,
				amp:        2.0,
				dur:        Pseq([
					~fh, ~fh, Rest(~f1),
					~fh, ~fh, Rest(~f1),
					Rest(~f2),
					Rest(~f2),
					Rest(~f2),
					~fh, ~fh, Rest(~f1),
					Rest(~f2),
					Rest(~f2),
					Rest(~f2),
					Rest(~f2),
				], inf),
				pan: -0.15,
				attack: 0.01, release: 0.01,
				rate: Pwhite(0.999, 1.001),
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [0.25],
				grainCenter: 20/127, grainWidth: [0,1,0],
				steps: [
					(buffers: [
						~b7
					])
				],
			),
			(
				dials:      [\attack, \tremDepth],
				freeze:     false, spectral: false, delay: false, ring: true,
				amp:        2.0,
				dur:        Pseq([
					Rest(~f1), ~f1, ~f2,
					Rest(~f1), ~f1, ~f2,
					Rest(~f4),
					Rest(~f2), Rest(~f1), ~f1,


				], inf),
				pan: -0.15,
				attack: [0.01, 0.1, 0.01], release: 0.01,
				rate: Pwhite(0.999, 1.001),
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*24, tremSkew: 0.5, tremWave: 0.0, tremTarget: \saw,
				doubleAmp: [0,1,0], double: [4.0],
				grainCenter: 0, grainWidth: Pwhite(0.1, 0.15),
				steps: [
					(buffers: [
						~b6
					])
				],
			),

		],
		rhythm: \fourFourGrooves,
	),
];
"Score loaded: % scenes.".format(~score.size).postln;
)
