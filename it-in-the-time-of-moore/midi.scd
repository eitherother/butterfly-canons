// ============================================================
// TVP3 — MIDI (Novation Launch Control XL)
// ============================================================
// Load after tvp3_conductor.scd and tvp3_rhythm.scd.
//
// Novation XL CC layout:
//   Dial row 1 (top): CC 13–20
//   Dial row 2 (mid): CC 21–28
//   Dial row 3 (bot): CC 29–36
//   Faders:           CC  5–12
//   Button row 1:     CC 37–44
//   Button row 2:     CC 45–52
//
// Column assignments (all 8 cols are flow columns):
//   Cols 1–8 → flows 0–7
//
// Per-flow layout (same for all 8 columns):
//   Top dial → GLOBAL (see below, not per-flow)
//   Mid dial → per-flow dial slot 0 (type declared in score's dials:)
//   Bot dial → per-flow dial slot 1 (type declared in score's dials:)
//   Fader    → amplitude
//   Btn top  → button effect
//   Btn bot  → global action (see below)
//
// Global top row (CC 13–20):
//   CC 13 → freeze level
//   CC 14 → freeze shimmer (pitch-shifted feedback loop, 0–1)
//   CC 15 → spectral send amount
//   CC 16 → delay amp
//   CC 17 → delay feedback
//   CC 18 → global seqDepth (sets \depth on all 8 ~seqs at once)
//           — was distortion drive amount (wavefold); drive code is still
//           intact (~driveFlows, ~mixers driveDepth) but ~gDrive is pinned
//           to 0 and no longer wired to a knob
//   CC 19 → reverb mix
//   CC 20 → master volume
//   (LPF left fully open)
//
// Global bottom button row (CC 45–52):
//   CC 45 → advance harmony
//   CC 46 → advance rhythm
//   CC 47 → advance scene
//   CC 48–49 → spare
//   CC 50–52 → layer toggles 1–3
// ============================================================


// --- MIDI output, global state, and feedback -----------------
(
~feedbackChan = 0;   // XL receive channel (0-indexed); LCXL3 uses channel 0
~lcxl         = nil;
~lcxl = MIDIOut.newByName("LCXL3 1", "MIDI In"); ~lcxl.latency = 0;
~toMidi = { |normVal| (normVal * 127).round.asInteger.clip(0, 127) };

~gFreeze      = 0.0;
~gShimmer     = 0.0;
~gSpectral    = 0.0;
~gDelayAmp    = 0.0;
~gDelay       = 0.0;
~gDrive       = 0.0;   // pinned to 0 — CC18 no longer drives this; kept intact for later re-use
~gSeqDepth    = 0.0;
~gReverb      = 0.0;
~gMasterVol   = 1.0;

~sendFeedback = {
    if (~lcxl.notNil && ~currentScene.notNil) {
        var fc = ~feedbackChan;
        // Top row: global dials (CC 13–20)
        ~lcxl.control(fc, 13, ~toMidi.(~gFreeze));
        ~lcxl.control(fc, 14, ~toMidi.(~gShimmer));
        ~lcxl.control(fc, 15, ~toMidi.(~gSpectral));
        ~lcxl.control(fc, 16, ~toMidi.(~gDelayAmp));
        ~lcxl.control(fc, 17, ~toMidi.(~gDelay));
        ~lcxl.control(fc, 18, ~toMidi.(~gSeqDepth));
        ~lcxl.control(fc, 19, ~toMidi.(~gReverb));
        ~lcxl.control(fc, 20, ~toMidi.(~gMasterVol));
        // Per-flow: mid (CC 21–28), bot (CC 29–36), fader (CC 5–12)
        8.do { |fi|
            var t    = ~flowDialTypes[fi];
            var idx0 = ~dialTypeToInternalIndex.(t[0]);
            var idx1 = ~dialTypeToInternalIndex.(t[1]);
            ~lcxl.control(fc, 21 + fi, ~flowDials[fi][idx0].round.asInteger.clip(0, 127));
            ~lcxl.control(fc, 29 + fi, ~flowDials[fi][idx1].round.asInteger.clip(0, 127));
            ~lcxl.control(fc,  5 + fi, ~toMidi.(~flowFaders[fi]));
        };
    };
};
)


// --- MIDI input handlers -------------------------------------
(
var chan = 0;
// Top row: global dials (CC 13–20) — absolute 0–127, normalised to 0–1 for global state
MIDIdef.cc(\g_freeze,     { |val| ~gFreeze    = val/127; ~freezeMixer.set(\amp, ~gFreeze) },                    13, chan);
MIDIdef.cc(\g_shimmer,    { |val| ~gShimmer   = val/127; ~freezer.set(\shimmer, ~gShimmer) },                     14, chan);
MIDIdef.cc(\g_spectral,   { |val| ~gSpectral  = val/127; ~spectralProcessor.set(\amp, ~gSpectral) },             15, chan);
MIDIdef.cc(\g_delayamp,   { |val| ~gDelayAmp  = val/127; ~delayProcessor.set(\amp, ~gDelayAmp) },                16, chan);
MIDIdef.cc(\g_delayfb,    { |val| ~gDelay     = val/127; ~delayProcessor.set(\feedback, val.linlin(0, 127, 0, 0.9)) }, 17, chan);
MIDIdef.cc(\g_seqdepth,   { |val| ~gSeqDepth  = val/127; ~seqs.do { |sq| sq.set(\depth, ~gSeqDepth) } },            18, chan);
MIDIdef.cc(\g_reverb,     { |val| ~gReverb    = val/127; ~masterChain.set(\verb, ~gReverb) },                    19, chan);
MIDIdef.cc(\g_mastervol,  { |val| ~gMasterVol = val/127; ~masterChain.set(\amp, ~gMasterVol) },                  20, chan);

// Per-flow: mid (CC 21–28), bot (CC 29–36) — absolute 0–127 passed directly to conductor
8.do { |fi|
    MIDIdef.cc(("f_mid_" ++ fi).asSymbol, { |val|
        ~onDialChange.(fi, 0, val)
    }, 21 + fi, chan);
    MIDIdef.cc(("f_bot_" ++ fi).asSymbol, { |val|
        ~onDialChange.(fi, 1, val)
    }, 29 + fi, chan);
    MIDIdef.cc(("f_fdr_" ++ fi).asSymbol, { |val| ~onFaderChange.(fi, val/127) },              5 + fi, chan);
    MIDIdef.cc(("f_btn_" ++ fi).asSymbol, { |val| if (val > 0 && { fi < 3 }) { ~onGrainCenterBump.(fi); ~sendFeedback.() } }, 37 + fi, chan);
};

// Bottom button row: global actions (CC 45–52)
MIDIdef.cc(\g_harmony, { |val| if (val > 0) { ~advanceHarmony.() } },      45, chan);
MIDIdef.cc(\g_rhythm,  { |val| if (val > 0) { ~advanceRhythm.() } },       46, chan);
MIDIdef.cc(\g_scene,   { |val| if (val > 0) { ~onSceneAdvance.() } },      47, chan);
// CC 48–49: spare global buttons
MIDIdef.cc(\g_layer1,  { |val| if (val > 0) { ~onLayerToggle.(0) } },      50, chan);
MIDIdef.cc(\g_layer2,  { |val| if (val > 0) { ~onLayerToggle.(1) } },      51, chan);
MIDIdef.cc(\g_layer3,  { |val| if (val > 0) { ~onLayerToggle.(2) } },      52, chan);

"MIDI wired — Novation Launch Control XL".postln;
~masterChain.set(\cutoff, 20000);  // LPF fully open — not used in this piece
~masterChain.set(\blend, 0.0);
~sendFeedback.();
)


// --- Scene advance ('n' key) ---------------------------------
/*(
~sceneWin = Window("n → next scene", Rect(10, 10, 180, 36)).front;
~sceneWin.view.keyDownAction = { |v, char|
    if (char == $n) { ~onSceneAdvance.(); "→ scene %".format(~currentScene).postln }
};
)*/


// --- Teardown ------------------------------------------------
MIDIdef.freeAll;
