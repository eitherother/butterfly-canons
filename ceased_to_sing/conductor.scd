// ============================================================
// TVP3 — Conductor
// ============================================================
// Manages scene state, Pdef construction, and hardware control.
// Load after tvp3_signal_flow.scd and tvp3_samples.scd.
// Load ~score (tvp3_score.scd or test score) before calling ~loadScene.
//
// Public API:
//   ~loadScene(index, preAdvance=0) — enter a scene from ~score; preAdvance
//                                     fast-forwards harmony that many steps
//                                     (as if ~advanceHarmony had already been
//                                     pressed that many times) to start
//                                     partway through the harmonic cycle
//   ~advanceHarmony                — step all active flows to next step
//   ~startFlow(i)                  — start flow i
//   ~stopFlow(i)                   — stop flow i
//   ~onDialChange(fi, di, normVal) — MIDI dial, normVal 0.0–1.0
//   ~onFaderChange(fi, normVal)    — MIDI fader, normVal 0.0–1.0
//   ~onLayerToggle(li)             — toggle electronic layer li (0–2) on/off
//   ~onButton1(fi)                 — toggle start/stop on flow i
//   ~onButton2(fi)                 — toggle button effect on flow i
//   ~onGrainCenterBump(fi)         — bump flow i's grainCenter by +1 (0–127, clipped);
//                                     also checks scene's checkpoints: array
//   ~checkCheckpoints              — posts any newly-crossed checkpoint messages
//   ~onHarmonyAdvance              — alias for ~advanceHarmony
//   ~onSceneAdvance                — advance to next scene (wraps)
//   ~advanceRhythm                 — step scene's rhythm sequence (defined in tvp3_rhythm.scd)
//
// Button 2 score format:
//   button: (key: value, ...)     — Event of Pbind overrides applied when active
//   e.g.  button: (rate: Pwhite(0.75, 1.33))
//         button: (centerPos: Pwhite(0.1, 0.9), grainWidth: 0.02)
//   Any \bufferSliceML or \bufferFragment arg can be overridden.
//
// Plugin dial system (per flow):
//   Each flow declares dials: [\type1, \type2] in the score.
//   Physical slot 0 (mid row) → type1, slot 1 (bot row) → type2.
//   Types and internal indices:
//     \grainWidth  → 0  (Pbind via Pfunc, no .set needed)
//     \tremDepth   → 1  (on ~mixers via .set)
//     \grainCenter → 2  (Pbind via Pfunc, no .set needed)
//     \seqDepth    → 3  (on ~seqs via .set)
//     \doubleAmp   → 4  (Pbind via Pfunc on shadow voices, no .set needed)
//     \attack      → 5  (Pbind via Pfunc, no .set needed)
//     \tremDepth2  → 6  (on ~mixers via .set)
//   ~flowDialTypes[fi] stores the two type symbols for each flow.
//   ~dialTypeToInternalIndex maps type → index.
//
// Flow types (flowDef[\type], default \granular):
//   \granular — Pbind-driven grain stream (~buildGranularPdef)
//   \buffer   — Pbind-driven single buffer playback (~buildBufferPdef)
//   \warp     — persistent Warp1 Synth, not Pbind-driven (~buildWarpSynth).
//               flowDef[\pitchScale]/[\stretchScale] (plain Numbers, fixed —
//               no dial control) set playback pitch and buffer-traversal
//               speed independently. Excluded from ~advanceHarmony
//               (continuous single-buffer drone, not a stepped sequence);
//               ~startFlow/~stopFlow gate it instead of playing/stopping a
//               Pdef. Mixer-level dials (tremDepth etc.) still work
//               normally since they act on ~flowBus downstream of it.
// ============================================================

(

// --- Control state ---
// Normalised 0.0–1.0, updated by MIDI handler or directly in tests.
~flowDials     = Array.fill(8, { Array.fill(11, { 0.5 }) });
~flowFaders    = Array.fill(8, { 1.0 });
~flowDialTypes = Array.fill(8, { [\seqDepth, \grainCenter] });

// Per-flow smoothed grainCenter value (0.0-1.0 range of flowGc), eased toward
// the raw dial/counter target by ~resolveGrainCenter. nil = not yet seeded;
// seeded instantly (no lag) on next grain and on scene load.
~flowGrainCenterSmoothed = Array.fill(8, { nil });

// Resolved ranges per flow per internal dial index — populated at scene load.
// Fixed params store [val, val] so the Pfunc returns val regardless of dial.
~dialRanges = Array.fill(8, { Array.fill(11, { [0.0, 1.0] }) });

// --- Scene state ---
~currentScene   = nil;
~currentStep    = Array.fill(8, { 0 });
~currentDurStep = Array.fill(8, { 0 });
~activeFlows    = Array.fill(8, { false });
~buttonActive  = Array.fill(8, { false });
~grainCenterCounter = 0;
~checkpointsFired = [];
~layerSynths    = Array.fill(3, { nil });
~layerActive    = Array.fill(3, { false });

// Persistent per-flow Synth for \warp-type flows (see ~buildWarpSynth).
// nil = not currently running.
~warpSynths = Array.fill(8, { nil });


// ---- Helpers ------------------------------------------------

~dialTypeToInternalIndex = { |type|
    switch (type)
    {\grainWidth}  { 0 }
    {\tremDepth}   { 1 }
    {\grainCenter} { 2 }
    {\seqDepth}    { 3 }
    {\doubleAmp}   { 4 }
    {\attack}      { 5 }
    {\tremDepth2}  { 6 }
    {\tremSkew}    { 7 }
    {\tremWave}    { 8 }
    {\tremSkew2}   { 9 }
    {\tremWave2}   { 10 }
    { 0 }
};

// Convert a note-name symbol like \F5 or \Eb4 to a MIDI number.
// Accidentals: b = flat, s = sharp (e.g. \Bb3, \Cs4).
~noteNameToMidi = { |sym|
    var str, base, accidental, idx, octave;
    str = sym.asString;
    accidental = 0;
    idx = 1;
    base = switch (str[0])
        {$C} {0} {$D} {2} {$E} {4} {$F} {5} {$G} {7} {$A} {9} {$B} {11} {0};
    if (str.size > idx && { str[idx] == $b }) { accidental = -1; idx = idx + 1 };
    if (str.size > idx && { str[idx] == $s }) { accidental =  1; idx = idx + 1 };
    octave = str.copyRange(idx, str.size - 1).asInteger;
    (octave + 1) * 12 + base + accidental
};

~resolveDur = { |flowIndex, flowDef, default = 0.5|
    var dur = flowDef[\dur] ?? default;
    var selected = if (dur.isKindOf(Array)) { dur.wrapAt(~currentDurStep[flowIndex]) } { dur };
    // A dur-step is itself an array of per-note durations (one turn) —
    // wrap it as a Pseq so Pbind cycles through its values per grain
    // instead of receiving the whole array as one invalid \dur value.
    if (selected.isKindOf(Array)) { Pseq(selected, inf) } { selected }
};

~buildBufSeq = { |step|
    var bufs    = step[\buffers];
    var repeats = step[\repeats] ?? [1];
    var lcmLen  = bufs.size.lcm(repeats.size);
    Pseq(lcmLen.collect { |i| Pn(bufs.wrapAt(i), repeats.wrapAt(i)) }, inf)
};

~buildRateSeq = { |step, flowDef, flowIndex|
    var flowRate = flowDef[\rate] ?? 1;
    var rates = step[\rates] ?? (
        if (flowRate.isKindOf(Array)) {
            [flowRate.wrapAt(~currentStep[flowIndex ? 0] ?? 0)]
        } {
            [flowRate]
        }
    );
    var repeats = step[\repeats] ?? [1];
    var lcmLen  = rates.size.lcm(repeats.size);
    Pseq(lcmLen.collect { |i| Pn(rates.wrapAt(i), repeats.wrapAt(i)) }, inf)
};

// Store dial ranges from scene data so Pfuncs and ~onDialChange can look them up.
// Fixed values stored as [v, v] — dial has no effect (Pfunc always returns v).
~storeDialRanges = { |flowIndex, flowDef|
    var gw  = flowDef[\grainWidth];
    var td  = flowDef[\tremDepth];
    var da  = flowDef[\doubleAmp];
    var atk = flowDef[\attack];
    var td2 = flowDef[\tremDepth2];
    var ts  = flowDef[\tremSkew];
    var tw  = flowDef[\tremWave];
    var ts2 = flowDef[\tremSkew2];
    var tw2 = flowDef[\tremWave2];
    var sd  = flowDef[\seqDepth];
    ~dialRanges[flowIndex][0] = case
        { gw.isKindOf(Array) }  { gw }
        { gw.isKindOf(Number) } { [gw, gw] }
        { [0.0, 0.6] };
    ~dialRanges[flowIndex][1] = case
        { td.isKindOf(Array) }  { td }
        { td.isKindOf(Number) } { [td, td] }
        { [0.0, 0.8] };
    ~dialRanges[flowIndex][2] = [0.0, 1.0];
    ~dialRanges[flowIndex][3] = case
        { sd.isKindOf(Array) }  { sd }
        { sd.isKindOf(Number) } { [sd, sd] }
        { [0.0, 1.0] };
    ~dialRanges[flowIndex][4] = case
        { da.isKindOf(Array) }  { da }
        { da.isKindOf(Number) } { [da, da] }
        { [0.0, 1.0] };
    ~dialRanges[flowIndex][5] = case
        { atk.isKindOf(Array) }  { atk }
        { atk.isKindOf(Number) } { [atk, atk] }
        { [0.01, 2.0] };
    ~dialRanges[flowIndex][6] = case
        { td2.isKindOf(Array) }  { td2 }
        { td2.isKindOf(Number) } { [td2, td2] }
        { [0.0, 0.8] };
    ~dialRanges[flowIndex][7] = case
        { ts.isKindOf(Array) }  { ts }
        { ts.isKindOf(Number) } { [ts, ts] }
        { [0.0, 1.0] };
    ~dialRanges[flowIndex][8] = case
        { tw.isKindOf(Array) }  { tw }
        { tw.isKindOf(Number) } { [tw, tw] }
        { [0.0, 1.0] };
    ~dialRanges[flowIndex][9] = case
        { ts2.isKindOf(Array) }  { ts2 }
        { ts2.isKindOf(Number) } { [ts2, ts2] }
        { [0.0, 1.0] };
    ~dialRanges[flowIndex][10] = case
        { tw2.isKindOf(Array) }  { tw2 }
        { tw2.isKindOf(Number) } { [tw2, tw2] }
        { [0.0, 1.0] };
};

// Resolve three-mode grainWidth for use in the Pbind.
~resolveGrainWidth = { |flowIndex, flowDef|
    var gw = flowDef[\grainWidth] ?? 0.2;
    case
    { gw.isKindOf(Pattern) } { gw }
    { gw.isKindOf(Array) } {
        Pfunc({
            ~flowDials[flowIndex][0].linlin(0, 127,
                ~dialRanges[flowIndex][0][0],
                ~dialRanges[flowIndex][0][1])
        })
    }
    { gw }
};

// Eases ~flowGrainCenterSmoothed[flowIndex] a fraction of the way toward
// target each call (per-grain exponential lag, since grains are discrete
// events rather than a continuous control-rate signal). nil seeds instantly.
~easeGrainCenter = { |flowIndex, target, lagCoef|
    if (~flowGrainCenterSmoothed[flowIndex].isNil) { ~flowGrainCenterSmoothed[flowIndex] = target };
    ~flowGrainCenterSmoothed[flowIndex] = ~flowGrainCenterSmoothed[flowIndex]
        + ((target - ~flowGrainCenterSmoothed[flowIndex]) * lagCoef);
    ~flowGrainCenterSmoothed[flowIndex]
};

// grainCenter three-mode: Array → dial-mapped Pfunc, else Pfunc reading ~flowDials[2] directly.
// On scene load, ~flowDials[i][2] is seeded from the first step's grainCenter.
// grainCenterLag (0-1, default 0.15): fraction of the remaining distance to
// close per grain; 1.0 = instant jump (old behavior), smaller = slower glide.
~resolveGrainCenter = { |flowIndex, flowDef, step|
    var flowGc = flowDef[\grainCenter];
    var stepGc = step[\grainCenter];
    var lagCoef = flowDef[\grainCenterLag] ?? 0.15;
    case
    { flowGc.isKindOf(Pattern) } { flowGc }
    { flowGc.isKindOf(Array) }   {
        Pfunc({
            ~easeGrainCenter.(flowIndex, ~flowDials[flowIndex][2].linlin(0, 127, flowGc[0], flowGc[1]), lagCoef)
        })
    }
    { flowGc.isKindOf(Number) }  { flowGc }
    { stepGc.isKindOf(Pattern) } { stepGc }
    { stepGc.isKindOf(Number) }  { stepGc }
    { Pfunc({ ~easeGrainCenter.(flowIndex, ~flowDials[flowIndex][2] / 127, lagCoef) }) }
};

~resolveAttack = { |flowIndex, flowDef|
    var atk = flowDef[\attack] ?? 0.05;
    case
    { atk.isKindOf(Pattern) } { atk }
    { atk.isKindOf(Array) }   {
        Pfunc({
            ~flowDials[flowIndex][5].linlin(0, 127,
                ~dialRanges[flowIndex][5][0],
                ~dialRanges[flowIndex][5][1])
        })
    }
    { atk }
};

~applyStepToMixer = { |flowIndex, step|
    ~mixers[flowIndex].set(\amp, ~flowFaders[flowIndex]);
};

// Apply flow-level mixer params at scene load.
// MIDI-ranged params initialise to the current dial position mapped through range.
// Pattern-driven tremRate is not yet implemented — fixed value only.
~tremTargetToInt = { |sym|
    switch (sym)
    {\saw}      { 0 }
    {\triangle} { 1 }
    {\pulse}    { 2 }
    {\revSaw}   { 3 }
    { 0 }
};

~applyFlowToMixer = { |flowIndex, flowDef|
    var tremDepth  = flowDef[\tremDepth]  ?? 0.0;
    var tremRate   = flowDef[\tremRate]   ?? 4.0;
    var tremDepth2 = flowDef[\tremDepth2] ?? 0.0;
    var tremRate2  = flowDef[\tremRate2]  ?? 2.0;
    var tremSkew   = flowDef[\tremSkew]   ?? 0.5;
    var tremWave   = flowDef[\tremWave]   ?? 0.0;
    var tremSkew2  = flowDef[\tremSkew2]  ?? 0.5;
    var tremWave2  = flowDef[\tremWave2]  ?? 0.0;

    case
    { tremDepth.isKindOf(Pattern) } { }
    { tremDepth.isKindOf(Array) } {
        ~mixers[flowIndex].set(\tremDepth,
            ~flowDials[flowIndex][1].linlin(0, 127, tremDepth[0], tremDepth[1]))
    }
    { ~mixers[flowIndex].set(\tremDepth, tremDepth) };

    if (tremRate.isKindOf(Pattern).not) {
        ~mixers[flowIndex].set(\tremRate, tremRate)
    };

    case
    { tremDepth2.isKindOf(Pattern) } { }
    { tremDepth2.isKindOf(Array) } {
        ~mixers[flowIndex].set(\tremDepth2,
            ~flowDials[flowIndex][6].linlin(0, 127, tremDepth2[0], tremDepth2[1]))
    }
    { ~mixers[flowIndex].set(\tremDepth2, tremDepth2) };

    if (tremRate2.isKindOf(Pattern).not) {
        ~mixers[flowIndex].set(\tremRate2, tremRate2)
    };

    ~mixers[flowIndex].set(\tremPhase,  flowDef[\tremPhase]  ?? 0.0);
    ~mixers[flowIndex].set(\tremPhase2, flowDef[\tremPhase2] ?? 0.0);

    // tremTarget: symbol → integer (fixed, no dial)
    ~mixers[flowIndex].set(\tremTarget,  ~tremTargetToInt.(flowDef[\tremTarget]  ?? \saw));
    ~mixers[flowIndex].set(\tremTarget2, ~tremTargetToInt.(flowDef[\tremTarget2] ?? \saw));

    // tremPulseWidth: Number only, fixed
    ~mixers[flowIndex].set(\tremPulseWidth,  flowDef[\tremPulseWidth]  ?? 0.5);
    ~mixers[flowIndex].set(\tremPulseWidth2, flowDef[\tremPulseWidth2] ?? 0.5);

    case
    { tremSkew.isKindOf(Array) } {
        ~mixers[flowIndex].set(\tremSkew,
            ~flowDials[flowIndex][7].linlin(0, 127, tremSkew[0], tremSkew[1]))
    }
    { ~mixers[flowIndex].set(\tremSkew, tremSkew) };

    case
    { tremWave.isKindOf(Array) } {
        ~mixers[flowIndex].set(\tremWave,
            ~flowDials[flowIndex][8].linlin(0, 127, tremWave[0], tremWave[1]))
    }
    { ~mixers[flowIndex].set(\tremWave, tremWave) };

    case
    { tremSkew2.isKindOf(Array) } {
        ~mixers[flowIndex].set(\tremSkew2,
            ~flowDials[flowIndex][9].linlin(0, 127, tremSkew2[0], tremSkew2[1]))
    }
    { ~mixers[flowIndex].set(\tremSkew2, tremSkew2) };

    case
    { tremWave2.isKindOf(Array) } {
        ~mixers[flowIndex].set(\tremWave2,
            ~flowDials[flowIndex][10].linlin(0, 127, tremWave2[0], tremWave2[1]))
    }
    { ~mixers[flowIndex].set(\tremWave2, tremWave2) };
};

~setDelaySend = { |flowIndex, enabled|
    ~mixers[flowIndex].set(\delaySend, enabled.if(1, 0));
    ~mixers[flowIndex].set(\delayBus, ~delaySendBus);
};


~buildGranularPdef = { |flowIndex, flowDef, stepIndex, withOffset = false|
    var step, offset, b2, b2On, pdefName, pairs, mainPat, double, shadows;
    step     = flowDef[\steps][stepIndex];
    offset   = if (withOffset) { flowDef[\startOffset] ?? 0 } { 0 };
    b2       = flowDef[\button];
    b2On     = ~buttonActive[flowIndex] && b2.notNil;
    pdefName = ("flow" ++ flowIndex).asSymbol;
    pairs    = [
        \instrument,  \bufferSliceML,
        \group,       ~flowGroup,
        \out,         ~flowBus[flowIndex],
        \freezeBus,   ~freezeSendBus,
        \freezeSend,  if (flowDef[\freeze].isKindOf(Number)) { flowDef[\freeze] } { (flowDef[\freeze] ? false).if(1, 0) },
        \spectralBus, ~spectralSendBus,
        \spectralSend,(flowDef[\spectral] ? false).if(1, 0),
        \buf,         ~buildBufSeq.(step),
        \centerPos,  ~resolveGrainCenter.(flowIndex, flowDef, step),
        \grainWidth, ~resolveGrainWidth.(flowIndex, flowDef),
        \rate,       ~buildRateSeq.(step, flowDef, flowIndex),
        \dur,        ~resolveDur.(flowIndex, flowDef, 0.5),
        \attack,     ~resolveAttack.(flowIndex, flowDef),
        \release,    flowDef[\release] ?? 0.05,
        \amp,        flowDef[\amp] ?? 0.08,
    ];
    if (b2On) { b2.keysValuesDo { |k, v| pairs = pairs ++ [k.asSymbol, v] } };
    mainPat = if ((step[\double] ?? flowDef[\double]).notNil) {
        double  = step[\double] ?? flowDef[\double];
        if (double.isKindOf(Pattern)) {
            Ppar([Pbind(*pairs), Pbind(*(pairs ++ [
                \rate,         ~buildRateSeq.(step, flowDef, flowIndex) * double,
                \amp,          Pfunc({ (flowDef[\amp] ?? 0.08) * ~flowDials[flowIndex][4].linlin(0, 127, ~dialRanges[flowIndex][4][0], ~dialRanges[flowIndex][4][1]) }),
                \freezeSend,   0,
                \spectralSend, 0,
            ]))])
        } {
            shadows = double.collect { |r|
                Pbind(*(pairs ++ [
                    \rate,         ~buildRateSeq.(step, flowDef, flowIndex) * r,
                    \amp,          Pfunc({ (flowDef[\amp] ?? 0.08) * ~flowDials[flowIndex][4].linlin(0, 127, ~dialRanges[flowIndex][4][0], ~dialRanges[flowIndex][4][1]) }),
                    \freezeSend,   0,
                    \spectralSend, 0,
                ]))
            };
            Ppar([Pbind(*pairs)] ++ shadows)
        }
    } {
        Pbind(*pairs)
    };
    Pdef(pdefName, if (offset > 0) {
        Pseq([Pbind(\type, \rest, \dur, Pn(offset, 1)), mainPat], 1)
    } { mainPat })
};

~buildBufferPdef = { |flowIndex, flowDef, stepIndex, withOffset = false|
    var step, b2, b2On, pdefName, pairs, offset;
    step     = flowDef[\steps][stepIndex];
    b2       = flowDef[\button];
    b2On     = ~buttonActive[flowIndex] && b2.notNil;
    pdefName = ("flow" ++ flowIndex).asSymbol;
    offset   = if (withOffset) { flowDef[\startOffset] ?? 0 } { 0 };
    pairs    = [
        \instrument,  \bufferFragment,
        \group,       ~flowGroup,
        \out,         ~flowBus[flowIndex],
        \freezeBus,   ~freezeSendBus,
        \freezeSend,  if (flowDef[\freeze].isKindOf(Number)) { flowDef[\freeze] } { (flowDef[\freeze] ? false).if(1, 0) },
        \spectralBus, ~spectralSendBus,
        \spectralSend,(flowDef[\spectral] ? false).if(1, 0),
        \buf,         ~buildBufSeq.(step),
        \dur,        ~resolveDur.(flowIndex, flowDef, 2.0),
        \attack,     0.05,
        \release,    0.05,
        \amp,        flowDef[\amp] ?? 0.08,
    ];
    if (b2On) { b2.keysValuesDo { |k, v| pairs = pairs ++ [k.asSymbol, v] } };
    Pdef(pdefName, if (offset > 0) {
        Pseq([Pbind(\type, \rest, \dur, Pn(offset, 1)), Pbind(*pairs)], 1)
    } { Pbind(*pairs) })
};

// Persistent per-flow Synth for \warp-type flows — not Pbind/Pdef-driven.
// pitchScale/stretchScale are fixed Numbers (no dial resolution needed).
~buildWarpSynth = { |flowIndex, flowDef, stepIndex|
    var step = flowDef[\steps][stepIndex];
    var buf  = step[\buffers][0];
    if (~warpSynths[flowIndex].notNil) { ~warpSynths[flowIndex].set(\gate, 0) };
    ~warpSynths[flowIndex] = Synth(\warpFlow, [
        \out,          ~flowBus[flowIndex],
        \buf,          buf,
        \freezeBus,    ~freezeSendBus,
        \freezeSend,   if (flowDef[\freeze].isKindOf(Number)) { flowDef[\freeze] } { (flowDef[\freeze] ? false).if(1, 0) },
        \spectralBus,  ~spectralSendBus,
        \spectralSend, (flowDef[\spectral] ? false).if(1, 0),
        \pitchScale,   flowDef[\pitchScale] ?? 1,
        \stretchScale, flowDef[\stretchScale] ?? 1,
        \amp,          flowDef[\amp] ?? 0.08,
        \pan,          flowDef[\pan] ?? 0,
        \gate,         1,
    ], ~flowGroup);
};

~buildFlowPdef = { |flowIndex, flowDef, stepIndex, withOffset = false|
    case
    { (flowDef[\type] ?? \granular) == \granular } { ~buildGranularPdef.(flowIndex, flowDef, stepIndex, withOffset) }
    { flowDef[\type] == \warp } { ~buildWarpSynth.(flowIndex, flowDef, stepIndex) }
    { ~buildBufferPdef.(flowIndex, flowDef, stepIndex, withOffset) }
};


// ---- Public API ---------------------------------------------

~onLayerToggle = { |li|
    var scene, layers, layerDef, args, notes, synth;
    if (~layerActive[li]) {
        if (~layerSynths[li].notNil) { ~layerSynths[li].set(\gate, 0) };
        ~layerSynths[li] = nil;
        ~layerActive[li] = false;
    } {
        if (~currentScene.notNil) {
            scene    = ~score[~currentScene];
            layers   = scene[\layers];
            layerDef = if (layers.notNil) { layers[li] } { nil };
            if (layerDef.notNil) {
                args  = [\out, ~masterBus, \gate, 1];
                notes = layerDef[\notes];
                if (notes.notNil) {
                    notes.do { |n, i|
                        var midi = if (n.isKindOf(Symbol)) { ~noteNameToMidi.(n) } { n };
                        args = args ++ [("freq" ++ (i + 1)).asSymbol, midi.midicps];
                    };
                };
                layerDef.keysValuesDo { |k, v|
                    if ([\def, \notes].includes(k).not) { args = args ++ [k, v] };
                };
                args  = args ++ [\amp, ~gLayerAmp ?? 1.0];
                synth = Synth(layerDef[\def], args, ~fxGroup);
                synth.register;
                synth.onFree {
                    if (~layerSynths[li] === synth) {
                        ~layerSynths[li] = nil;
                        ~layerActive[li] = false;
                    }
                };
                ~layerSynths[li] = synth;
                ~layerActive[li] = true;
            };
        };
    };
};

~loadScene = { |sceneIndex, preAdvance = 0|
    var scene = ~score[sceneIndex];
    var seqName, seq;

    3.do { |li|
        if (~layerSynths[li].notNil) { ~layerSynths[li].set(\gate, 0) };
        ~layerSynths[li] = nil;
        ~layerActive[li] = false;
    };

    ~currentScene   = sceneIndex;
    ~currentStep    = Array.fill(8, { 0 });
    ~currentDurStep = Array.fill(8, { 0 });
    ~grainCenterCounter = 0;
    ~checkpointsFired = Array.fill((scene[\checkpoints] ? []).size, { false });

    // Hard-kill everything currently sounding from the previous scene —
    // both in-flight grains (which can sustain for minutes on wash-style
    // flows) and persistent \warp synths — so nothing bleeds across the
    // scene boundary. Pdef.stop alone only halts *future* grain triggers.
    ~flowGroup.freeAll;
    ~warpSynths = Array.fill(8, { nil });

    scene[\flows].do { |flowDef, i|
        if (flowDef.notNil) {
            var step0, td, gw, tdRange, gwRange, gc, da, daRange, atk, atkRange, td2, td2Range;
            var ts, tsRange, tw, twRange, ts2, ts2Range, tw2, tw2Range, sd, sdRange;
            step0 = flowDef[\steps][0];
            ~activeFlows[i] = true;
            ~storeDialRanges.(i, flowDef);
            ~flowDialTypes[i] = flowDef[\dials] ?? [\seqDepth, \grainCenter];

            gc = step0[\grainCenter];
            ~flowDials[i][2] = case
                { flowDef[\grainCenter].isKindOf(Array) && { flowDef[\grainCenter].size >= 3 } }
                    { flowDef[\grainCenter][2].linlin(flowDef[\grainCenter][0], flowDef[\grainCenter][1], 0, 127).clip(0, 127) }
                { gc.isKindOf(Number) } { gc * 127 }
                { 63 };
            ~flowGrainCenterSmoothed[i] = nil;

            td      = flowDef[\tremDepth] ?? 0.0;
            tdRange = ~dialRanges[i][1];
            ~flowDials[i][1] = if (td.isKindOf(Array)) {
                if (td.size >= 3) { td[2].linlin(td[0], td[1], 0, 127).clip(0, 127) } { 0 }
            } {
                (tdRange[1] > tdRange[0]).if(td.linlin(tdRange[0], tdRange[1], 0, 127).clip(0, 127), 63)
            };

            gw      = flowDef[\grainWidth] ?? 0.2;
            gwRange = ~dialRanges[i][0];
            ~flowDials[i][0] = case
                { gw.isKindOf(Array) }   { if (gw.size >= 3) { gw[2].linlin(gw[0], gw[1], 0, 127).clip(0, 127) } { 0 } }
                { gw.isKindOf(Pattern) } { 63 }
                { (gwRange[1] > gwRange[0]).if(gw.linlin(gwRange[0], gwRange[1], 0, 127).clip(0, 127), 63) };

            sd      = flowDef[\seqDepth] ?? 0.0;
            sdRange = ~dialRanges[i][3];
            ~flowDials[i][3] = if (sd.isKindOf(Array)) {
                if (sd.size >= 3) { sd[2].linlin(sd[0], sd[1], 0, 127).clip(0, 127) } { 0 }
            } {
                (sdRange[1] > sdRange[0]).if(sd.linlin(sdRange[0], sdRange[1], 0, 127).clip(0, 127), 63)
            };

            da      = flowDef[\doubleAmp] ?? 0.5;
            daRange = ~dialRanges[i][4];
            ~flowDials[i][4] = case
                { da.isKindOf(Array) }  { if (da.size >= 3) { da[2].linlin(da[0], da[1], 0, 127).clip(0, 127) } { 63 } }
                { (daRange[1] > daRange[0]).if(da.linlin(daRange[0], daRange[1], 0, 127).clip(0, 127), 63) };

            atk      = flowDef[\attack] ?? 0.05;
            atkRange = ~dialRanges[i][5];
            ~flowDials[i][5] = case
                { atk.isKindOf(Array) }   { if (atk.size >= 3) { atk[2].linlin(atk[0], atk[1], 0, 127).clip(0, 127) } { 63 } }
                { atk.isKindOf(Pattern) } { 63 }
                { (atkRange[1] > atkRange[0]).if(atk.linlin(atkRange[0], atkRange[1], 0, 127).clip(0, 127), 63) };
            td2      = flowDef[\tremDepth2] ?? 0.0;
            td2Range = ~dialRanges[i][6];
            ~flowDials[i][6] = if (td2.isKindOf(Array)) {
                if (td2.size >= 3) { td2[2].linlin(td2[0], td2[1], 0, 127).clip(0, 127) } { 0 }
            } {
                (td2Range[1] > td2Range[0]).if(td2.linlin(td2Range[0], td2Range[1], 0, 127).clip(0, 127), 63)
            };

            ts      = flowDef[\tremSkew] ?? 0.5;
            tsRange = ~dialRanges[i][7];
            ~flowDials[i][7] = case
                { ts.isKindOf(Array) } { if (ts.size >= 3) { ts[2].linlin(ts[0], ts[1], 0, 127).clip(0, 127) } { 63 } }
                { (tsRange[1] > tsRange[0]).if(ts.linlin(tsRange[0], tsRange[1], 0, 127).clip(0, 127), 63) };

            tw      = flowDef[\tremWave] ?? 0.0;
            twRange = ~dialRanges[i][8];
            ~flowDials[i][8] = case
                { tw.isKindOf(Array) } { if (tw.size >= 3) { tw[2].linlin(tw[0], tw[1], 0, 127).clip(0, 127) } { 0 } }
                { (twRange[1] > twRange[0]).if(tw.linlin(twRange[0], twRange[1], 0, 127).clip(0, 127), 0) };

            ts2      = flowDef[\tremSkew2] ?? 0.5;
            ts2Range = ~dialRanges[i][9];
            ~flowDials[i][9] = case
                { ts2.isKindOf(Array) } { if (ts2.size >= 3) { ts2[2].linlin(ts2[0], ts2[1], 0, 127).clip(0, 127) } { 63 } }
                { (ts2Range[1] > ts2Range[0]).if(ts2.linlin(ts2Range[0], ts2Range[1], 0, 127).clip(0, 127), 63) };

            tw2      = flowDef[\tremWave2] ?? 0.0;
            tw2Range = ~dialRanges[i][10];
            ~flowDials[i][10] = case
                { tw2.isKindOf(Array) } { if (tw2.size >= 3) { tw2[2].linlin(tw2[0], tw2[1], 0, 127).clip(0, 127) } { 0 } }
                { (tw2Range[1] > tw2Range[0]).if(tw2.linlin(tw2Range[0], tw2Range[1], 0, 127).clip(0, 127), 0) };

            ~flowFaders[i]   = 0.0;

            ~applyStepToMixer.(i, step0);
            ~applyFlowToMixer.(i, flowDef);
            Pdef(("flow" ++ i).asSymbol).stop;
            ~buildFlowPdef.(i, flowDef, 0, true);
            if ((flowDef[\type] ?? \granular) != \warp) {
                Pdef(("flow" ++ i).asSymbol).play;
            };
            ~setDelaySend.(i, flowDef[\delay] ? false);
        } {
            ~activeFlows[i]           = false;
            if (~warpSynths[i].notNil) { ~warpSynths[i].set(\gate, 0); ~warpSynths[i] = nil };
            ~flowDials[i]             = [63, 0, 63, 0, 63, 63, 0, 63, 0, 63, 0];
            ~flowFaders[i]            = 0.0;
            ~flowDialTypes[i]         = [\seqDepth, \grainCenter];
            ~flowGrainCenterSmoothed[i] = nil;
            Pdef(("flow" ++ i).asSymbol).stop;
            ~setDelaySend.(i, false);
            ~mixers[i].set(\amp, 0);
        }
    };

    ~delayProcessor.set(\delayTime, scene[\delayTime] ?? 0.35);
    ~delayProcessor.set(\amp,      scene[\delayAmp]  ?? 0);
    ~delayProcessor.set(\feedback, scene[\delayFeedback] ?? 0.35);
    ~gDelayAmp = scene[\delayAmp] ?? 0;
    ~gDelay    = (scene[\delayFeedback] ?? 0.35).linlin(0.0, 0.9, 0.0, 1.0);

    ~seqs.do { |seq| seq.set(\stepRate, scene[\stepRate] ?? 8) };

    ~currentRhythmStep = 0;
    ~silenceRhythm.();
    seqName = scene[\rhythm];
    seq     = if (seqName.notNil) { ~rhythmSequences[seqName] } { nil };
    if (seq.notNil && { seq.size > 0 }) { ~applyRhythmStep.(seq[0]) } { ~clearRhythm.() };

    // seqDepth is normally owned by the global CC 18 fader (~gSeqDepth) and,
    // per flow, the MIDI dial (see ~onDialChange) — both of which
    // ~silenceRhythm above bypasses by zeroing \depth directly. Reassert here:
    // the global fader sets the base for every active flow, then a
    // score-level seqDepth: overrides it if the flow declares a fixed/array
    // value, so the intended depth actually sticks after scene load.
    scene[\flows].do { |flowDef, i|
        if (flowDef.notNil) {
            var sdVal = flowDef[\seqDepth];
            ~seqs[i].set(\depth, ~gSeqDepth ?? 0);
            if (sdVal.isKindOf(Number)) {
                ~seqs[i].set(\depth, sdVal);
            };
            if (sdVal.isKindOf(Array)) {
                var range = ~dialRanges[i][3];
                ~seqs[i].set(\depth, ~flowDials[i][3].linlin(0, 127, range[0], range[1]));
            };
        }
    };

    // Fast-forward harmony as if ~advanceHarmony had been pressed
    // preAdvance times already — a way to drop into the middle of a
    // scene's harmonic cycle instead of always starting at step 0.
    preAdvance.do { ~advanceHarmony.() };

    "Scene loaded: %".format(scene[\name]).postln;
    if (~sendFeedback.notNil) { ~sendFeedback.() };
};

~advanceHarmony = {
    var scene, maxSteps, step;
    if (~currentScene.notNil) {
        scene = ~score[~currentScene];
        scene[\flows].do { |flowDef, i|
            if (flowDef.notNil && { (flowDef[\type] ?? \granular) != \warp }) {
                maxSteps = flowDef[\steps].size;
                ~currentStep[i] = (~currentStep[i] + 1) % maxSteps;
                if (flowDef[\dur].isKindOf(Array)) {
                    ~currentDurStep[i] = (~currentDurStep[i] + 1) % flowDef[\dur].size;
                };
                step = flowDef[\steps][~currentStep[i]];
                { ~applyStepToMixer.(i, step);
                  ~buildFlowPdef.(i, flowDef, ~currentStep[i]);
                  Pdef(("flow" ++ i).asSymbol).quant = 0;
                }.defer(flowDef[\startOffset] ?? 0);
            }
        };
        "Harmony advanced: steps = %".format(~currentStep).postln;
    }
};

~startFlow = { |flowIndex|
    var flowDef = if (~currentScene.notNil) { ~score[~currentScene][\flows][flowIndex] } { nil };
    if (flowDef.notNil && { flowDef[\type] == \warp }) {
        if (~warpSynths[flowIndex].notNil) { ~warpSynths[flowIndex].set(\gate, 1) };
    } {
        Pdef(("flow" ++ flowIndex).asSymbol).play;
    };
    ~activeFlows[flowIndex] = true;
};

~stopFlow = { |flowIndex|
    var flowDef = if (~currentScene.notNil) { ~score[~currentScene][\flows][flowIndex] } { nil };
    if (flowDef.notNil && { flowDef[\type] == \warp }) {
        if (~warpSynths[flowIndex].notNil) { ~warpSynths[flowIndex].set(\gate, 0) };
    } {
        Pdef(("flow" ++ flowIndex).asSymbol).stop;
    };
    ~activeFlows[flowIndex] = false;
};

// Called by MIDI handler when a per-flow dial moves.
// physicalSlot: 0 = mid row, 1 = bot row. val: 0–127.
// Dispatches by the type declared in the score's dials: key.
// grainWidth and grainCenter are read from ~flowDials by Pfuncs — no .set needed.
~onDialChange = { |flowIndex, physicalSlot, normVal|
    var dialType    = ~flowDialTypes[flowIndex][physicalSlot];
    var internalIdx = ~dialTypeToInternalIndex.(dialType);
    var range       = ~dialRanges[flowIndex][internalIdx];
    var mapped      = normVal.linlin(0, 127, range[0], range[1]);
    ~flowDials[flowIndex][internalIdx] = normVal;
    if (~currentScene.notNil) {
        switch (dialType)
        {\tremDepth}  { ~mixers[flowIndex].set(\tremDepth,  mapped) }
        {\tremDepth2} { ~mixers[flowIndex].set(\tremDepth2, mapped) }
        {\seqDepth}   { ~seqs[flowIndex].set(\depth, mapped) }
        {\tremSkew}   { ~mixers[flowIndex].set(\tremSkew,  mapped) }
        {\tremWave}   { ~mixers[flowIndex].set(\tremWave,  mapped) }
        {\tremSkew2}  { ~mixers[flowIndex].set(\tremSkew2, mapped) }
        {\tremWave2}  { ~mixers[flowIndex].set(\tremWave2, mapped) }
    }
};

// Called by MIDI handler when a fader moves. normVal: 0.0–1.0.
~onFaderChange = { |flowIndex, normVal|
    ~flowFaders[flowIndex] = normVal;
    ~mixers[flowIndex].set(\amp, normVal);
};

~onButton1 = { |flowIndex|
    if (~activeFlows[flowIndex]) { ~stopFlow.(flowIndex) } { ~startFlow.(flowIndex) }
};

~onButton2 = { |flowIndex|
    var flowDef;
    ~buttonActive[flowIndex] = ~buttonActive[flowIndex].not;
    if (~currentScene.notNil) {
        flowDef = ~score[~currentScene][\flows][flowIndex];
        if (flowDef.notNil) { ~buildFlowPdef.(flowIndex, flowDef, ~currentStep[flowIndex]) }
    }
};

// Bumps the single shared grainCenter counter by +1 (0–127, clipped), then applies
// the new value to only the flow whose button was pressed — other flows keep
// whatever value they last received until their own button is pressed. The counter
// itself stays shared so checkpoints still track overall progress across all buttons.
// grainCenter is read directly from ~flowDials by Pfuncs — no .set needed.
~onGrainCenterBump = { |flowIndex|
    ~grainCenterCounter = (~grainCenterCounter + 1).clip(0, 127);
    ~flowDials[flowIndex][2] = ~grainCenterCounter;
    ~checkCheckpoints.();
};

// Posts each scene checkpoint's message the first time ~grainCenterCounter
// crosses its threshold (fraction * 127). Fires once per scene load.
~checkCheckpoints = {
    var checkpoints = ~currentScene.notNil.if({ ~score[~currentScene][\checkpoints] }, { nil });
    if (checkpoints.notNil) {
        checkpoints.do { |cp, i|
            if (~checkpointsFired[i].not and: { ~grainCenterCounter >= (cp[0] * 127) }) {
                ~checkpointsFired[i] = true;
                ("★ " ++ cp[1]).postln;
            }
        }
    }
};

~onHarmonyAdvance = ~advanceHarmony;

~onSceneAdvance = {
    var next;
    if (~currentScene.notNil) {
        next = (~currentScene + 1) % ~score.size;
        ~loadScene.(next)
    }
};

"TVP3 conductor ready.".postln;
)
