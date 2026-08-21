# it-in-the-time-of-moore

A generative improvisation piece for SuperCollider, driven by a conductor/
score system with MIDI input.

## Loading

Copy `config.example.scd` (repo root) to `config.scd` and fill in your local
`~sampleLibraryRoot`/`~recordDir` paths — `init.scd` loads it first and
errors with instructions if it's missing. Then see `init.scd` for load
order (synths → signal flow → samples, then conductor → rhythm → score).

## External audio dependency

`samples.scd` loads audio via `Buffer.read` from `~sampleLibraryRoot`,
some of which reference commercial recordings. That audio is **not
included** in this repository and is not covered by the repo's MIT license
— you'll need your own copies, laid out under your `~sampleLibraryRoot` to
match the relative paths in `samples.scd`.
