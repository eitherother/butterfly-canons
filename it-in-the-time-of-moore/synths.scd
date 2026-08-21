// ============================================================
// TVP3 — SynthDefs
// ============================================================
// Evaluate this entire file before tvp3_signal_flow.scd.
//
// IMPORTANT: all Pbinds using bufferSlice or bufferFragment must
// pass \freezeBus, ~freezeSendBus explicitly — the default of 0
// routes audio to hardware output.
//
// Limiter.ar is used throughout as a safety measure. Once Batlib
// is installed, replace with BatLimiter for better transient handling.
// ============================================================

(

// ============================================================
// SEQUENCER
// ============================================================

SynthDef(\stepSeqBufSwap, {
	|out, bufA, bufB, len=16, stepRate=8, depth=0.8, lag=0, pendingBufBus|
	var trig, index, swapTrig, useB, step, val;
	trig     = Impulse.kr(Lag.kr(stepRate, lag));
	index    = Stepper.kr(trig, 0, 0, len - 1, 1, 0);
	swapTrig = HPZ1.kr(index) < 0;
	useB     = Latch.kr(
		In.kr(pendingBufBus),
		swapTrig.max(Impulse.kr(0))
	).round.clip(0, 1);
	step = Select.kr(useB, [
		BufRd.kr(1, bufA, index, loop: 1),
		BufRd.kr(1, bufB, index, loop: 1)
	]);
	val = step.linlin(0, 1, 1 - Lag.kr(depth, lag), 1);
	Out.kr(out, Lag.kr(val, 0.01));
}).add;


// ============================================================
// MIXERS
// ============================================================

// Simple amp + lag — used for freeze send mixer and freeze output mixer
SynthDef(\layerMixer, {
	|inBus, out=0, amp=1, lag=3|
	var sig;
	sig = In.ar(inBus, 2);
	sig = sig * Lag.kr(amp, lag);
	Out.ar(out, sig);
}).add;

// Per-flow channel mixer — tremolo + sequencer gate → master
// tremDepth=0 = no tremolo; tremPhase staggers oscillators across flows
// seqBus=-1 = no gating (transparent)
// tremSkew (0–1): where in the cycle the peak falls (0.5 = symmetric)
// tremWave (0–1): crossfade from sine toward tremTarget shape
// tremTarget (0=saw, 1=triangle, 2=pulse): target waveform
// tremPulseWidth (0–1): fraction of cycle that is loud when target=pulse
SynthDef(\flowMixer, {
	|inBus, out=0, amp=1, lag=3,
	tremDepth=0, tremRate=4, tremPhase=0,
	tremSkew=0.5, tremWave=0, tremTarget=0, tremPulseWidth=0.5,
	tremDepth2=0, tremRate2=2, tremPhase2=0,
	tremSkew2=0.5, tremWave2=0, tremTarget2=0, tremPulseWidth2=0.5,
	seqBus= -1, driveDepth=0,
	delaySend=0, delayBus=0|
	var sig, seqGate, drive, wet;
	var rate, phasor, sk, sineShape, triShape, sawShape, revSawShape, pulseShape, targetShape, trem;
	var rate2, phasor2, sk2, sineShape2, triShape2, sawShape2, revSawShape2, pulseShape2, targetShape2, trem2;
	sig    = In.ar(inBus, 2);
	// --- Tremolo 1 ---
	rate   = Lag.kr(tremRate, lag);
	phasor = (Phasor.kr(0, rate * ControlDur.ir, 0, 1) + (tremPhase / 2pi)).wrap(0, 1);
	sk     = Lag.kr(tremSkew, lag);
	// sine: full cycle, peaks at phasor=sk
	sineShape  = ((phasor - sk + 0.25).wrap(0, 1) * 2pi).sin;
	// triangle: linear ramp, peaks at phasor=sk
	triShape   = 1 - (((phasor - sk + 0.5).wrap(0, 1) * 2 - 1).abs * 2);
	// saw: linear ramp -1→+1, cuts at phasor=sk (swell then cut)
	sawShape    = (phasor - sk).wrap(0, 1) * 2 - 1;
	// revSaw: linear fall +1→-1, cuts at phasor=sk (instant loud then decay)
	revSawShape = sawShape.neg;
	// pulse: loud within tremPulseWidth of phasor=sk
	pulseShape  = (((phasor - sk + 0.5).wrap(0, 1) - 0.5).abs < (Lag.kr(tremPulseWidth,  lag) * 0.5)) * 2 - 1;
	targetShape = Select.kr(tremTarget.round, [sawShape, triShape, pulseShape, revSawShape]);
	trem = XFade2.kr(sineShape, targetShape, Lag.kr(tremWave, lag).linlin(0, 1, -1, 1))
	       .range(1 - Lag.kr(tremDepth, lag), 1);
	// --- Tremolo 2 ---
	rate2   = Lag.kr(tremRate2, lag);
	phasor2 = (Phasor.kr(0, rate2 * ControlDur.ir, 0, 1) + (tremPhase2 / 2pi)).wrap(0, 1);
	sk2     = Lag.kr(tremSkew2, lag);
	sineShape2  = ((phasor2 - sk2 + 0.25).wrap(0, 1) * 2pi).sin;
	triShape2   = 1 - (((phasor2 - sk2 + 0.5).wrap(0, 1) * 2 - 1).abs * 2);
	sawShape2    = (phasor2 - sk2).wrap(0, 1) * 2 - 1;
	revSawShape2 = sawShape2.neg;
	pulseShape2  = (((phasor2 - sk2 + 0.5).wrap(0, 1) - 0.5).abs < (Lag.kr(tremPulseWidth2, lag) * 0.5)) * 2 - 1;
	targetShape2 = Select.kr(tremTarget2.round, [sawShape2, triShape2, pulseShape2, revSawShape2]);
	trem2 = XFade2.kr(sineShape2, targetShape2, Lag.kr(tremWave2, lag).linlin(0, 1, -1, 1))
	        .range(1 - Lag.kr(tremDepth2, lag), 1);
	seqGate   = (seqBus >= 0).if(In.kr(seqBus), 1);
	sig       = sig * Lag.kr(amp, lag);
	Out.ar(delayBus, sig * Lag.kr(delaySend, lag));
	sig       = sig * trem * trem2 * seqGate;
	drive     = Lag.kr(driveDepth, lag).linlin(0, 1, 1, 40);
	wet       = Fold.ar(sig * drive, -1, 1) * 0.8;
	sig       = sig.blend(wet, Lag.kr(driveDepth, lag));
	sig       = Limiter.ar(sig, 0.9);
	Out.ar(out, sig);
}).add;


// ============================================================
// GRANULAR PLAYBACK
// ============================================================


// PlayBuf-based slice — plays a region of a buffer as a timed event
// startPos/endPos: normalized 0-1 positions in buffer
// grainDur > 0 overrides the natural duration (useful for dense grain streams)
// dissolve: pitch smear applied to the freeze send only
// IMPORTANT: always pass \freezeBus, ~freezeSendBus in Pbinds
SynthDef(\bufferSlice, {
	|out=0, buf=0,
	freezeBus=0, freezeSend=0,
	startPos=0.0, endPos=1.0,
	sendLPF=5500,
	attack=0.5, release=0.5,
	rate=1, dissolve=0,
	amp=0.08, pan=0,
	loop=0, grainDur=0|
	var frames, startFrame, endFrame, bufDur, playDur;
	var sig, env, send;
	frames     = BufFrames.kr(buf);
	startFrame = startPos * frames;
	endFrame   = endPos * frames;
	bufDur     = ((endFrame - startFrame) / BufSampleRate.kr(buf)) / rate.abs;
	playDur    = Select.kr(grainDur > 0, [bufDur, grainDur]);
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: startFrame, loop: loop);
	env = EnvGen.kr(
		Env.linen(attack, (playDur - attack - release).max(0.001), release),
		doneAction: 2
	);
	sig  = sig * env;
	sig  = Balance2.ar(sig[0], sig[1], pan);
	send = sig * freezeSend;
	send = BHiShelf.ar(send, 700, 0.7, -5);
	send = BLowShelf.ar(send, 250, 0.7, -8);
	send = PitchShift.ar(
		send,
		0.2,
		LFNoise1.kr(0.25 ! 2).range(1 - (dissolve * 0.012), 1 + (dissolve * 0.012)),
		dissolve * 0.025,
		dissolve * 0.01
	);
	send = Limiter.ar(LeakDC.ar(LPF.ar(send, sendLPF)), 0.7);
	Out.ar(out, sig * amp);
	Out.ar(freezeBus, send);
}).add;

// PlayBuf-based grain — plays [centerPos - grainWidth/2, centerPos + grainWidth/2]
// grainWidth is a buffer fraction (0.0–1.0); position and duration are both derived from it
// freezeSend=1 routes to freezeBus; 0 suppresses (for flows with freeze: false)
SynthDef(\bufferSliceML, {
	|out=0, buf=0,
	freezeBus=0, freezeSend=0,
	spectralBus=0, spectralSend=0,
	centerPos=0.5, grainWidth=0.2,
	attack=0.5, release=0.5,
	rate=1,
	amp=0.08, pan=0,
	loop=0|
	var frames, startFrame, endFrame, bufDur;
	var sig, env;
	frames     = BufFrames.kr(buf);
	startFrame = ((centerPos - (grainWidth * 0.5)).clip(0, 1)) * frames;
	endFrame   = ((centerPos + (grainWidth * 0.5)).clip(0, 1)) * frames;
	bufDur     = ((endFrame - startFrame) / BufSampleRate.kr(buf)) / rate.abs;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: startFrame, loop: loop);
	env = EnvGen.kr(Env.linen(attack, (bufDur - attack - release).max(0.001), release), doneAction: 2);
	sig = Balance2.ar(sig[0], sig[1], pan) * env;
	Out.ar(out, sig * amp);
	Out.ar(freezeBus,   sig * freezeSend);
	Out.ar(spectralBus, sig * spectralSend);
}).add;

// Non-granular buffer playback — plays buffer straight through on a \dur pattern
// Intended for \buffer type flows: piano hits, longer samples, voiced events
// Mixed downstream by \flowMixer (tremolo + amp).
SynthDef(\bufferFragment, {
	|out=0, buf=0,
	freezeBus=0, freezeSend=0,
	spectralBus=0, spectralSend=0,
	startPos=0.0, endPos=1.0,
	attack=0.05, release=0.05,
	rate=1,
	amp=0.08, pan=0|
	var frames, startFrame, endFrame, playDur;
	var sig, env, send;
	frames     = BufFrames.kr(buf);
	startFrame = startPos * frames;
	endFrame   = endPos * frames;
	playDur    = ((endFrame - startFrame) / (BufSampleRate.kr(buf) * rate.abs));
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: startFrame, loop: 0, doneAction: 0);
	env = EnvGen.kr(
		Env.linen(attack, (playDur - attack - release).max(0.001), release),
		doneAction: 2
	);
	sig  = sig * env;
	send = Limiter.ar(LeakDC.ar(sig * freezeSend), 0.7);
	Out.ar(freezeBus,   send);
	Out.ar(spectralBus, sig * spectralSend);
	Out.ar(out, sig * amp);
}).add;


// ============================================================
// FREEZE
// ============================================================

// Resonant freeze — tunes the frozen signal to harmonics of fund
// violinKeep: crossfade between tuned resonance and raw input
// combDecay: feedback decay in seconds (fixed, no longer MIDI-controlled)
// shimmer: pitch-shifted feedback loop — each pass through the loop is shifted
// up an octave and fed back in, building a rising, detuning drone under the
// freeze the harder it's driven. Limiter inside the loop keeps it from blowing up.
SynthDef(\freezeLike, {
	|inBus=0, out=0, amp=0.4,
	fund=311.13, rq=0.018,
	harmAmp=1.5, violinKeep=0.25,
	combDecay=8, verbMix=0.85,
	room=0.9, damp=0.55,
	shimmer=0|
	var in, tuned, preDiffuse, diffuse, held, sig;
	var harms, fb, shifted, fbGain;
	harms = [2, 3, 5, 8, 13];
	in = In.ar(inBus, 2);
	tuned = Splay.ar(
		Resonz.ar(Mix.ar(in), fund * harms, rq, [1, 0.85, 0.6, 0.35, 0.2])
	) * harmAmp;
	preDiffuse = XFade2.ar(tuned, in, violinKeep.linlin(0, 1, -1, 1));
	diffuse    = AllpassC.ar(preDiffuse, 0.25, LFNoise1.kr(0.15 ! 2).range(0.02, 0.09), 3);
	held       = CombC.ar(diffuse, 4, [0.177, 0.191], combDecay);

	fbGain     = Lag.kr(shimmer, 3).linlin(0, 1, 0, 0.9);
	fb         = LocalIn.ar(2);
	shifted    = PitchShift.ar(fb, 0.2, 2.0, 0, 0.01);
	LocalOut.ar(Limiter.ar(held + (shifted * fbGain), 0.9));
	held       = held + (shifted * fbGain);

	held       = FreeVerb.ar(held, mix: verbMix, room: room, damp: damp);
	sig        = LeakDC.ar(held);
	Out.ar(out, sig * amp);
}).add;

// Freeze send processor — shapes audio before it enters the freezer
// Separate from freezeLike so the freeze send can be processed independently
SynthDef(\freezeProcessor, {
	|inBus, out=0, amp=0.5, dissolve=0, sendLPF=8000, lag=3|
	var sig;
	sig = In.ar(inBus, 2);
	sig = BHiShelf.ar(sig, 700, 0.7, -5);
	sig = BLowShelf.ar(sig, 250, 0.7, -8);
	sig = PitchShift.ar(
		sig, 0.2,
		LFNoise1.kr(0.25 ! 2).range(
			1 - (Lag.kr(dissolve, lag) * 0.012),
			1 + (Lag.kr(dissolve, lag) * 0.012)
		),
		Lag.kr(dissolve, lag) * 0.025,
		Lag.kr(dissolve, lag) * 0.01
	);
	sig = Limiter.ar(LeakDC.ar(LPF.ar(sig, Lag.kr(sendLPF, lag))), 0.7);
	Out.ar(out, sig * Lag.kr(amp, lag));
}).add;


// ============================================================
// GLOBAL SENDS
// ============================================================

// Stereo feedback delay — reads from ~delaySendBus
// delayTime and feedback controlled from column 7 dials
// amp=0 by default; column 7 fader brings it up
// Limiter in feedback path prevents runaway
SynthDef(\globalDelay, {
	|inBus, out=0, delayTime=0.35, feedback=0.35, amp=0, lag=3|
	var sig, fb, delayed;
	sig     = In.ar(inBus, 2);
	fb      = LocalIn.ar(2);
	delayed = DelayC.ar(sig + (fb * Lag.kr(feedback, lag)), 2.0, Lag.kr(delayTime, lag));
	delayed = Limiter.ar(delayed, 0.9);
	LocalOut.ar(delayed);
	Out.ar(out, delayed * Lag.kr(amp, lag));
}).add;

// Copies a stereo bus to another bus — used to tap ~masterBus → ~spectralSendBus.
SynthDef(\spectralTap, { |inBus, outBus|
	Out.ar(outBus, In.ar(inBus, 2))
}).add;

// Send-effect topology: adds WET signal only (dry already lives in ~masterBus).
// blurAmt (0-1): level of spectral-blurred signal added
// verbMix (0-1): level of long reverb added
// amp (0-1): overall spectral contribution — CC 36 moves this
SynthDef(\spectralSend, {
	|inBus, out=0, blurAmt=1, verbMix=0, amp=0, lag=3|
	var sig, mono, chain, blurred, verb, wet;
	sig     = In.ar(inBus, 2);
	mono    = Mix.ar(sig) * 0.5;
	chain   = FFT(LocalBuf(2048, 1), mono);
	chain   = PV_MagSmear(chain, 32);
	blurred = IFFT(chain).dup;
	verb    = FreeVerb2.ar(sig[0], sig[1], mix: 1, room: 0.99, damp: 0.1);
	wet     = (blurred * Lag.kr(blurAmt, lag)) + (verb * Lag.kr(verbMix, lag));
	Out.ar(out, wet * Lag.kr(amp, lag));
}).add;


// ============================================================
// MASTER
// ============================================================

// Global LPF → reverb send → output
// cutoff defaults fully open (20000 Hz); column 8 dial narrows it
// verb (CC19) is dry/wet blend; room/damp/verbHPF can be set via .set() but are not wired to MIDI
// verbHPF keeps bass out of the reverb tank — without it, low end piles up in the tail (boomy/muddy)
SynthDef(\masterChain, {
	|inBus, out=0,
	cutoff=20000, blend=0.0, lag=3,
	verbHPF=200, room=0.8, damp=0.35,
	amp=1, verb=0,
	midFreq=800, midCut=(-3.5), midRQ=1.0,
	clarityFreq=4000, clarityBoost=3.0, clarityRQ=0.8|
	var sig, dry, send, wet;
	sig  = In.ar(inBus, 2);
	sig  = LPF.ar(sig, Lag.kr(cutoff, lag)).blend(sig, Lag.kr(blend, lag));
	dry  = sig;
	send = HPF.ar(sig, Lag.kr(verbHPF, lag));
	wet  = FreeVerb2.ar(send[0], send[1],
		mix:  1.0,
		room: Lag.kr(room, lag),
		damp: Lag.kr(damp, lag)
	);
	sig  = dry.blend(wet, Lag.kr(verb, lag));
	sig  = sig * Lag.kr(amp, lag);
	// --- Mastering EQ: small mid scoop + presence/clarity lift ---
	sig  = BPeakEQ.ar(sig, midFreq, midRQ, midCut);
	sig  = BPeakEQ.ar(sig, clarityFreq, clarityRQ, clarityBoost);
	sig  = Limiter.ar(sig, 0.95);
	Out.ar(out, sig);
}).add;

// ============================================================
// LAYERS
// ============================================================

// Triangle-wave triad with looping sine amplitude breath.
// Cycles 0→peakAmp→0 continuously while gate=1.
// When gate=0, finishes the current descent to 0 then frees itself.
// notes: converted to freq1/freq2/freq3 by conductor from MIDI numbers.
SynthDef(\triTriad, {
	|out=0, freq1=311, freq2=370, freq3=415, peakAmp=0.1, cycleDur=8, amp=1, gate=1|
	var env = EnvGen.kr(
		Env([0, peakAmp, 0, 0], [cycleDur * 0.5, cycleDur * 0.5, 0.001], \sin, releaseNode: 2, loopNode: 0),
		gate, doneAction: 2
	);
	var sig = Mix(LFTri.ar([freq1, freq2, freq3])) / 3;
	Out.ar(out, sig.dup * env * amp);
}).add;

"TVP3 SynthDefs loaded.".postln;

)
