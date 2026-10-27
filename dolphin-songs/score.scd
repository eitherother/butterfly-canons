(
~qn = 60/144.4;  // piano take measures ~144.4 bpm, not 144

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
		delayTime: ~f4,
		stepRate: 16 / ~qn,
		flows: [

			(
				dials:      [\tremDepth, \seqDepth],
				freeze:     false, freeze2: false, delay: false, chorus: true,
				amp:        3.0,
				dur:        202,
				pan: -0.1,
				attack: 0.05, release: 0.05,
				rate: Pwhite(0.999, 1.001),
				grainWidth: 1.0, grainCenter: 0.5,
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn, tremSkew: 0, tremWave: 0.0, tremTarget: \pulse,
				seqDepth: [0,1,0],
				steps: [
					(buffers: [
						~poem
					])
				],
			),
			(
				dials:      [\tremDepth, \seqDepth],
				freeze:     false, freeze2: false, delay: false,
				amp:        1.0,
				dur:        ~qn * 134,  // nearest whole beat to the old 55.765 s
				startOffset: ~qn * 12,   // voice enters first; piano comes in 2 bars later, on the beat
				pan: 0.2,
				attack: 0.05, release: 0.05,
				rate: 1,
				grainWidth: 1.0, grainCenter: 0.5,
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn + 0.125, tremSkew: 0, tremWave: 0.0, tremTarget: \pulse,
				seqDepth: [0,1,0],
				steps: [
					(buffers: [
						~piano
					])
				],
			),

			(
				dials:      [\grainWidth, \doubleAmp],
				freeze:     false, freeze2: false, delay: false,
				amp:        1.0,
				dur:        ~qn*2,
				startOffset: ~qn * 12,   // voice enters first; piano comes in 2 bars later, on the beat
				pan: 0.0,
				attack: 0.05, release: 0.05,
				rate: 1,
				grainWidth: [0,1,0], grainCenter: 0.5,
				doubleAmp: [0,1,0], double: [0.5, 0.25],
				steps: [
					(buffers: [
						~whale3
					])
				],
			),

			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     true, freeze2: false, delay: false, chorus: true,
				amp:        0.2,
				dur:        Pwhite(0.1, 0.25),
				pan: -0.3,
				attack: 0.1, release: 0.1,
				rate: Pwhite(0.999, 1.001),
				grainWidth: Pwhite(0.15, 0.2), grainCenter: 0.6,
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0, tremWave: 0.0, tremTarget: \pulse,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn/2, tremSkew2: 0, tremWave2: 0.0, tremTarget2: \pulse,

				doubleAmp: [0,1,0], double: [1.5, 2.0],
				steps: [
					(buffers: [

						~cl[\Bb5], ~cl[\Ab5], ~cl[\G5], ~silence,
					], repeats: [20]),
				],
			),


			(
				dials:      [\tremDepth, \tremDepth2],
				freeze:     false, freeze2: true, delay: false, chorus: true,
				amp:        0.2,
				dur:        Pwhite(0.1, 0.25),
				pan: 0.3,
				attack: 0.1, release: 0.1,
				rate: Pwhite(0.999, 1.001),
				grainWidth: Pwhite(0.15, 0.2), grainCenter: 0.6,
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*8, tremSkew: 0, tremWave: 0.0, tremTarget: \pulse,
				tremDepth2:  [0.0, 1.0, 0.0], tremRate2: ~qn*2, tremSkew2: 0, tremWave2: 0.0, tremTarget2: \pulse,

				doubleAmp: [0,1,0], double: [2.0],
				steps: [
					(buffers: [

						~cl[\G6], ~cl[\F6], ~cl[\Eb6], ~silence,
					], repeats: [20]),
				],
			),




			(
				dials:      [\grainWidth, \doubleAmp],
				freeze:     false, freeze2: false, delay: true,
				amp:        1.0,
				dur:        Pseq([
					~qn, Rest(~qn*12),
				], inf),
				pan: 0.0,
				attack: 0.05, release: 0.05,
				rate: 1,
				grainWidth: [0,1,0], grainCenter: 0.5,
				doubleAmp: [0,1,0], double: [0.5, 0.25],
				steps: [
					(buffers: [
						~flt[\Bb6]
					])
				],
			),
			(
				dials:      [\tremDepth, \doubleAmp],
				freeze:     false, freeze2: false, delay: false,
				amp:        1.0,
				dur:        Pseq([
					~qn, Rest(~qn*24),
				], inf),
				pan: 0.0,
				attack: 0.05, release: 0.05,
				rate: 1,
				grainWidth: 1.0, grainCenter: 0.5,
				doubleAmp: [0,1,0], double: [2.0],
				tremDepth:  [0.0, 1.0, 0.0], tremRate: ~qn*16, tremSkew: 0, tremWave: 0.0, tremTarget: \pulse,

				steps: [
					(buffers: [
						~bass[\C2]
					])
				],
			),

			nil


		],
		rhythm: \flutter,
	),
];
"Score loaded: % scenes.".format(~score.size).postln;
)
