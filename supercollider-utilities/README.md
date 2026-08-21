# supercollider-utilities

Shared SuperCollider helpers, common to every piece — not piece-specific
logic (that stays in each piece's own files; see CONTRIBUTING.md on why
pieces don't share an engine).

## recording.scd

Defines `~record` and `~stopRecording`. `~record.(baseName, dir)` starts
recording to the next available numbered filename (`dir` defaults to
`~recordDir` from `config.scd`); `~stopRecording.()` stops it. Loaded
automatically by every piece's `init.scd`.
