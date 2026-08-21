# python-utilities

General-purpose scripts not tied to any one piece. Run with `uv run python
python-utilities/<script>.py ...` from the repo root.

## midi_notes.py

Transcribe a MIDI file into `melody.txt`-style lines: extracts note-ons,
splits them into groups on an A0 note (used as a manual "next line"
delimiter while playing), and prints each group as a `["C4", "E4", ...]`
array.

```
uv run python python-utilities/midi_notes.py <file.mid>
```

## print_notes.py

Chunk a MIDI file's note-ons into SuperCollider buffer references, e.g.
`~bass[\C3], ~pnmf[\E4], ~pnmf[\G4], ~pnmf[\C5],`. Instrument tags, chunk
size, and the bass note's octave shift are all configurable:

```
uv run python python-utilities/print_notes.py <file.mid> \
  --chunk-size 4 --bass-tag bass --other-tag pnmf --bass-shift -12
```
