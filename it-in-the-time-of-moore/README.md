# it-in-the-time-of-moore

A generative improvisation piece for SuperCollider, driven by a conductor/
score system with MIDI input.

## Loading

Copy `config.example.scd` (repo root) to `config.scd` and fill in your local
`~sampleLibraryRoot`/`~recordDir` paths. Then open `init.scd` and evaluate
the one block at the top — it boots the server, loads everything in order,
and wires up MIDI. Watch the post window for "Ready to play." Scene
selection and recording are separate, performance-time calls listed below
that block (`~loadScene`, `~record`, `~stopRecording`).

## External audio dependency

`samples.scd` loads audio via `Buffer.read` from `~sampleLibraryRoot`,
some of which reference commercial recordings. That audio is **not
included** in this repository and is not covered by the repo's MIT license
— you'll need your own copies, laid out under your `~sampleLibraryRoot` to
match the relative paths in `samples.scd`.
