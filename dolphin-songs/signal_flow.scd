// ============================================================
// Whale Songs — Signal Flow
// ============================================================
// Load order: synths → signal_flow → samples
//
// SynthDefs required from synths.scd:
//   \stepSeqBufSwap  — step sequencer
//   \layerMixer      — simple amp + lag
//   \flowMixer       — per-flow mixer with dual tremolo
//   \freezeLike      — freeze processor (two instances: freeze 1 and 2)
//   \globalDelay     — delay send processor
//   \masterChain     — LPF + reverb → output
// ============================================================

(
fork {

// --- Groups ---
~flowGroup = Group.new;
~fxGroup   = Group.after(~flowGroup);

// --- Audio buses ---

// 8 flow input buses — Pdefs write audio here
~flowBus = Array.fill(8, { Bus.audio(s, 2) });

// Freeze path:
//   patterns write to ~freezeSendBus (pass this as \freezeBus in Pbinds)
//   ~freezeSendMixer is the global send level lever
//   ~freezeBus is the freezer's actual input
//   ~freezeOutBus is the frozen output, mixed into master via ~freezeMixer
~freezeSendBus = Bus.audio(s, 2);
~freezeBus     = Bus.audio(s, 2);
~freezeOutBus  = Bus.audio(s, 2);

// Freeze 2: same path, separate buses — flows opt in with freeze2: in the score
~freeze2SendBus = Bus.audio(s, 2);
~freeze2Bus     = Bus.audio(s, 2);
~freeze2OutBus  = Bus.audio(s, 2);

// Global opt-in sends — conductor routes eligible flows here on scene entry
~delaySendBus    = Bus.audio(s, 2);  // flows with delay: true

// Master — all channel mixers and send processors write here
~masterBus = Bus.audio(s, 2);

// --- Control buses (step sequencer gate outputs, one per flow) ---
~seqBus = Array.fill(8, { Bus.control(s, 1) });

// --- Step sequencer data (double-buffered for seamless pattern swap) ---
~seqNumSteps = 32;
~seqData = Array.fill(8, {
	(
		bufA:    Buffer.alloc(s, ~seqNumSteps, 1),
		bufB:    Buffer.alloc(s, ~seqNumSteps, 1),
		pending: Bus.control(s, 1),
	)
});

s.sync;  // wait for Buffer.alloc to complete before creating synths

~seqData.do { |d|
	d[\bufA].sendCollection(FloatArray.fill(~seqNumSteps, { 1.0 }));
	d[\bufB].sendCollection(FloatArray.fill(~seqNumSteps, { 1.0 }));
	d[\pending].set(0);
};

// --- Step sequencers (depth=0 = transparent, no gating effect) ---
~seqs = ~seqData.collect { |d, i|
	Synth.head(~fxGroup, \stepSeqBufSwap, [
		\out,           ~seqBus[i],
		\bufA,          d[\bufA],
		\bufB,          d[\bufB],
		\pendingBufBus, d[\pending].index,
		\len,           ~seqNumSteps,
		\stepRate,      8,
		\depth,         0,
		\lag,           0,
	])
};

// --- Freeze path ---
// ~freezeSendMixer: global lever on how much reaches the freezer
~freezeSendMixer = Synth.after(~seqs.last, \layerMixer, [
	\inBus, ~freezeSendBus, \out, ~freezeBus, \amp, 1, \lag, 3
]);
~freezer = Synth.after(~freezeSendMixer, \freezeLike, [
	\inBus, ~freezeBus, \out, ~freezeOutBus, \amp, 0.5
]);

// Freeze 2 — independent of freeze 1. Shimmer fixed at 0 (freeze 1's
// CC 14 at 0/127); comb settings are the \freezeLike defaults.
~freeze2SendMixer = Synth.after(~freezer, \layerMixer, [
	\inBus, ~freeze2SendBus, \out, ~freeze2Bus, \amp, 1, \lag, 3
]);
~freezer2 = Synth.after(~freeze2SendMixer, \freezeLike, [
	\inBus, ~freeze2Bus, \out, ~freeze2OutBus, \amp, 0.5, \shimmer, 0
]);

// --- Channel mixers → master (one per flow) ---
// tremPhase staggered across flows so they don't pulse in unison
~mixers = Array.fill(8, { |i|
	Synth.tail(~fxGroup, \flowMixer, [
		\inBus,          ~flowBus[i],
		\out,            ~masterBus,
		\seqBus,         ~seqBus[i],
		\tremPhase,      (i / 7) * 2pi,
		\amp,            1,
		\lag,            3,
		\tremDepth,      0,
		\tremRate,       4.0,
		\tremSkew,       0.5,
		\tremWave,       0,
		\tremTarget,     0,
		\tremPulseWidth, 0.5,
		\tremDepth2,     0,
		\tremRate2,      2.0,
		\tremSkew2,      0.5,
		\tremWave2,      0,
		\tremTarget2,    0,
		\tremPulseWidth2, 0.5,
		\delayBus,       ~delaySendBus,
		\delaySend,      0,
	])
});

// --- Global delay processor ---
// Reads ~delaySendBus. Conductor routes delay:true flows there at scene load.
// amp=0 by default — CC 16 (top-row dial) brings it up during performance.
~delayProcessor = Synth.tail(~fxGroup, \globalDelay, [
	\inBus,     ~delaySendBus,
	\out,       ~masterBus,
	\delayTime, 0.35,
	\feedback,  0.35,
	\amp,       0,
	\lag,       3,
]);

// --- Freeze output mixer → master ---
// amp=0 by default — CC 13 (top-row dial) controls freeze presence in the mix
~freezeMixer = Synth.tail(~fxGroup, \layerMixer, [
	\inBus, ~freezeOutBus, \out, ~masterBus, \amp, 0, \lag, 5
]);

// --- Freeze 2 output mixer → master ---
// amp=0 by default — CC 15 (top-row dial) controls freeze 2 presence in the mix
~freeze2Mixer = Synth.tail(~fxGroup, \layerMixer, [
	\inBus, ~freeze2OutBus, \out, ~masterBus, \amp, 0, \lag, 5
]);

// --- Master chain: global LPF → reverb send → output 0 ---
// cutoff defaults fully open (20000 Hz); not wired to MIDI in this piece.
// verbHPF keeps bass out of the reverb send. Reverb mix is CC 19; other
// reverb params adjustable via .set() in performance.
~masterChain = Synth.tail(~fxGroup, \masterChain, [
	\inBus,   ~masterBus,
	\out,     0,
	\cutoff,  20000,
	\verbHPF, 350,
	\room,    0.8,
	\damp,    0.5,
	\lag,     3,
]);

"Whale Songs signal flow ready.".postln;

} // end fork
)
