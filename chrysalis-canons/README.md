# chrysalis-canons

A generative improvisation piece for SuperCollider, driven by a conductor/
score system with MIDI input.

## Loading

Copy `config.example.scd` (repo root) to `config.scd` and fill in your local
`~sampleLibraryRoot`/`~recordDir` paths. Then open `init.scd` and evaluate
the one block at the top — it boots the server, loads everything in order,
and wires up MIDI. Watch the post window for "Ready to play." Scene
selection, recording, and MIDI teardown are separate, performance-time
calls listed below that block (`~loadScene`, `~record`, `~stopRecording`,
`~teardownMidi`).

## External audio dependency

`samples.scd` loads audio via `Buffer.read` from `~sampleLibraryRoot`,
including tracks from the commercial recording *Piffaro: Back Before Bach —
Musical Journeys*. That audio is **not included** in this repository and is
not covered by the repo's MIT license — you'll need your own copy of the
recording, laid out under your `~sampleLibraryRoot` to match the relative
paths in `samples.scd`.
