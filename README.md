# butterfly-canons

An open source generative music improvisation environment, built primarily
in SuperCollider with supporting Python tooling.

## Structure

Each piece lives in its own top-level folder (e.g. `chrysalis-canons/`) and is
self-contained — its own conductor, synths, score, and any Python helper
scripts. Pieces intentionally don't share a common engine: SuperCollider has
no test framework, so keeping pieces independent means a change to one can't
silently break another.

Shared, general-purpose Python scripts that aren't tied to any one piece
live in `python-utilities/`.

## Getting started

Python dependencies are managed with [uv](https://docs.astral.sh/uv/):

```
uv sync
```

Copy `config.example.scd` to `config.scd` and fill in your local sample
library and recording-output paths — every piece's `init.scd` loads this
before anything else.

SuperCollider pieces are loaded from within the SuperCollider IDE — see each
piece's `init.scd` for load order and instructions.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for the branch workflow and linting.

## License

MIT — see [LICENSE](LICENSE). Note that some pieces reference external audio
recordings (samples) that are not included in this repository and are not
covered by this license; see the individual piece's README where applicable.
