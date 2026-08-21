(
// Clarinet recordings in this project available through Univerisity of Iowa Electronic Music Studios: http://theremin.music.uiowa.edu/MIS.html
e = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "/recordings/BbClarinet.ff.E3.stereo.wav");
g = Buffer.read(s,  thisProcess.nowExecutingPath.dirname +/+ "/recordings/BbClarinet.ff.G3.stereo.wav");
a = Buffer.read(s,  thisProcess.nowExecutingPath.dirname +/+ "/recordings/BbClarinet.ff.A5.stereo.wav");

// A synth to stretch sound files based on the help example for the Warp1 UGen.
SynthDef(\stretch, {|amplitude= 1, attack = 0.01, buffer = 0, durationMod = 0.95, durationScale = 0.25 frequencyScale = 1, outBus = 0 |

	var env, envGen, pointer, out, balance, sustain;
	var windowSize = 0.6;
	var overlaps = 24;
	var release = 0.01;

	// Amplitude envelope, use duationMod to end envelope early to avoid interpolation of sound file wrapping around to beginning
	sustain = (durationMod * BufDur.ir(buffer) / durationScale) - attack - release;
	env = Env([0.001, 1, 1, 0.001], [attack, sustain, release], 'lin');
	envGen = EnvGen.ar(env, doneAction: 2);

	// Phasor to read through sound file with duration and frequency scaled
    pointer = Phasor.ar(0, durationScale*SampleDur.ir/BufDur.ir(buffer));
	out = Warp1.ar(2, buffer, pointer, frequencyScale, windowSize, -1, overlaps, 0.25, 4);
	out = out * envGen * amplitude * 0.1;

	Out.ar(outBus, out);
}).add;)


///////////////////////////////////////////////////////////////
// Play a series of stretched notes and pass them through feedback
(play
{
	var local;
	local = Limiter.ar(
		GVerb.ar(
			PitchShift.ar(
				0.8*LocalIn.ar(2), // read in from local buffer
				1,
				[2, 1.5], // pitch shifted
				0.02,
				0.3),
			20,
			3));

	local = 0.25 * local + In.ar(8,2);	// combine with pbind output
    LocalOut.ar(local); // feedback into local buffer
    Out.ar(0, local);
};

Pbind(
	\instrument, \stretch,
	\outBus, 8,
	\buffer, Pseq([e,g,a], inf),
	\dur, Pseq([3,3,6], inf),
	\durationScale, 0.25,
	\amplitude, Pseq([1, 1, 0.8], inf),
	\frequencyScale, Pseq([0.75, 1, 1], inf)
	).play
)



// Stretch a single clarinet note
(Synth(\stretch, [\buffer, e, \frequencyScale, 1, \durationScale, 0.3]);)



// Play a repeating sequence of notes
(Pbind(
	\instrument, \stretch,
	\buffer, Pseq([e,g,a], inf),
	\dur, Pseq([2, 1.9, 2.1, 1.92, 2.3, 2.13, Rest(1)], inf),
	\attack, 2,
	\frequencyScale, Pseq([1, 1, 1, 0.805, 1.195, 0.9], inf)
).play)

