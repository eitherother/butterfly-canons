# it-in-the-time-of-moore

A generative improvisation piece for SuperCollider, driven by a conductor/
score system with MIDI input.

## Loading

See `init.scd` for load order (synths → signal flow → samples, then
conductor → rhythm → score).

## External audio dependency

`samples.scd` loads audio via `Buffer.read` from absolute local paths (e.g.
`/Volumes/Samsung_T1/SoundFiles/recordings/...`), some of which reference
commercial recordings. That audio is **not included** in this repository
and is not covered by the repo's MIT license — you'll need your own copies
and will need to update the paths in `samples.scd` to match your local file
layout.
