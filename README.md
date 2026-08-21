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

Python dependencies are managed with [uv](https://docs.astral.sh/uv/):

```
uv sync
```

Copy `config.example.scd` to `config.scd` and fill in your local sample
library and recording-output paths — every piece's `init.scd` loads this
before anything else.

SuperCollider pieces are loaded from within the SuperCollider IDE, which
you will need to download: [SuperCollider](https://supercollider.github.io/).

There is one hardware prerequisite, which is the [Novation Launch Control XL](https://us.novationmusic.com/products/launch-control-xl). You could rework the project for a different control surface,
but the project is designed specifically around this 8-channel configuration. The system
is extremely portable, so I recommend starting here.

Wherever possible, I include .mp3 files of available media, though I have extensively
used the freely available instrument samples from the
[University of Iowa's Electronic Music Studio](https://theremin.music.uiowa.edu/MIS.html).

### Running the environment

Plug in the MIDI interface In the SuperCollider IDE, open `init.scd` in the relevant folder.
Run the init block and wait for the whole process to complete. Then, run `loadScene` at the bottom.
From there, the faders need to be lowered to 0 and then brought back up to hear the piece.

## License

Currently all rights reserved, but the hope is to release it under MIT — see [LICENSE](LICENSE). Note that some pieces reference external audio recordings (samples) that are not included in this repository and are not
covered by this license; see the individual piece's README where applicable.

Note that this project was built with assistance from Claude AI.
