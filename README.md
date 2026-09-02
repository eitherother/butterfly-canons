# butterfly-canons

Welcome! Butterfly Canons is an open source generative music improvisation environment,
built primarily in SuperCollider with supporting Python tooling.

The SuperCollider language, interpreter, and server are very powerful, but
they can be hard to work with, so I have made the setup as simple as possible
if you wish to explore it yourself. Read on!

## Structure

Each piece lives in its own top-level folder (e.g. `chrysalis-canons/`) and is
self-contained — its own conductor, synths, score, and any Python helper
scripts. Pieces intentionally don't share a common engine: SuperCollider has
no test framework, so keeping pieces independent means a change to one can't
silently break another.

Small, generic helpers that carry no piece-specific logic — not the engine
itself — are the one exception: `python-utilities/` for Python,
`supercollider-utilities/` for SuperCollider.

## Getting started

### Prerequisites

#### uv

Python dependencies are managed with [uv](https://docs.astral.sh/uv/):

```
uv sync
```

Copy `config.example.scd` to `config.scd` and fill in your local sample
library and recording-output paths — every piece's `init.scd` loads this
before anything else.

#### SuperCollider

SuperCollider pieces are loaded from within the SuperCollider IDE, which
you will need to download: [SuperCollider](https://supercollider.github.io/).

#### MIDI Controller

There is one hardware prerequisite, which is the [Novation Launch Control XL](https://us.novationmusic.com/products/launch-control-xl). You could rework the project for a different control surface,
but the project is designed specifically around this 8-channel configuration and
it's very easy to set up. I recommend starting here.

#### Recommended audio files

Wherever possible, I include .mp3 files of available media, though I have extensively
used the freely available instrument samples from the
[University of Iowa's Electronic Music Studio](https://theremin.music.uiowa.edu/MIS.html).
The `trim_samples.py` script in the python-utilities folder might come in handy for trimming
these files.

### Running the environment

Plug in the MIDI interface In the SuperCollider IDE, open `init.scd` in the relevant folder.
Run the init block and wait for the whole process to complete. Then, run `loadScene` at the bottom.
From there, the faders need to be lowered to 0 and then brought back up to hear the piece.

To run an existing piece, you will need to download the sound files listed in the piece's
readme.

Todo: To create a new piece, follow the comments in the score template.

## Engine

Each piece in the Butterfly Canons generally has the following parts, much of which is similar across folders with minor but important differences, apart from the score file that defines music specific to one composition.

- `conductor.scd` — scene/voice state and logic.
    - Holds all scene and voice state
    - Builds/rebuilds each of the 8 voices' Pdefs from score data (granular, single-buffer, or persistent Warp-synth drone types)
    - Exposes the public API everything else calls: `~loadScene`, `~advanceHarmony`, `~startFlow`/`~stopFlow`, `~onDialChange`, `~onFaderChange`, `~onButton1`/`~onButton2`, `~onGrainCenterBump`, `~onLayerToggle`, `~onSceneAdvance`, etc.
    - No hardware awareness — reacts only to normalized values and indices
- `midi.scd` — hardware binding layer for the Novation Launch Control XL.
    - Sends LED/motorized feedback (`~sendFeedback`) and defines what each physical control does (global dials, per-voice mid/bot dials, faders, buttons)
    - Registers `MIDIdef.cc` handlers that map incoming CCs to conductor calls (e.g. CC 21+fi → `~onDialChange.(voiceIndex, 0, val)`)
    - Owns the non-per-voice global controls: freeze, shimmer, spectral send, delay, reverb, master volume, and transport buttons (advance harmony/rhythm/scene, layer toggles)
- `signal_flow.scd` — the audio graph/bus layout. Runs once at boot, before conductor/midi.
    - Creates the 8 per-voice audio buses (`~flowBus`) that Pdefs write into, plus the freeze, delay, and spectral send buses
    - Creates the 8 step-sequencer control synths (`~seqs`) and their double-buffered step-data buffers
    - Creates the permanent effects chain: per-voice `~mixers` (trem/seq-gated) → `~delayProcessor` / `~spectralProcessor` / `~freezeMixer` → `~masterChain` (LPF + reverb) → output
    - Pure infrastructure — no scene/score awareness, nothing here changes at runtime except via `.set()`
- `synths.scd` - defines the synths used in `signal_flow.scd`
- `rhythm.scd` - defined data for the rhythmic sequencer
- `samples.scd` - loads the samples for that particular piece
- `init.scd` - a centralized initialization script
- `score.scd` - notes and configuration specific to the piece of music
- `README.md` - includes any additional information or instructions around the specific piece

## License

Currently all rights reserved, but the hope is to release it under MIT — see [LICENSE](LICENSE). Note that some pieces reference external audio recordings (samples) that are not included in this repository and are not
covered by this license; see the individual piece's README where applicable.

## AI Usage

Note that this project was built with assistance from Claude AI.
