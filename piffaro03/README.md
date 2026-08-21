# piffaro03

A generative improvisation piece for SuperCollider, driven by a conductor/
score system with MIDI input and Python-generated score data.

## Loading

See `init.scd` for load order (synths → signal flow → samples, then
conductor → rhythm → score).

## External audio dependency

`samples.scd` loads audio via `Buffer.read` from absolute local paths (e.g.
`/Volumes/Samsung_T1/SoundFiles/recordings/Piffaro/...`), referencing tracks
from the commercial recording *Piffaro: Back Before Bach — Musical
Journeys*. That audio is **not included** in this repository and is not
covered by the repo's MIT license — you'll need your own copy of the
recording and will need to update the paths in `samples.scd` to match your
local file layout.

## Python scripts

`score_raw.py`, `score_emit.py`, `harmony_octaves.py`, and `midi_notes.py`
generate/process score data (see `harmony.txt`, `melody.txt`, and
`score_generated.scd`). Run via `uv run python <script>.py` from the repo
root, or `cd piffaro03 && uv run --project .. python <script>.py`.
