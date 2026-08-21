# python-utilities

General-purpose scripts not tied to any one piece. Run with `uv run python
python-utilities/<script>.py ...` from the repo root.

## midi_notes.py

Transcribe a MIDI file into `melody.txt`-style lines: extracts note-ons,
splits them into groups on a delimiter note (default `A0`, used as a manual
"next line" marker while playing), and prints each group as a
`["C4", "E4", ...]` array.

```
uv run python python-utilities/midi_notes.py <file.mid> [--delimiter A0]
```

## midi_notes_chunked.py

Same as `midi_notes.py`, but splits into fixed-size groups instead of on a
delimiter note.

```
uv run python python-utilities/midi_notes_chunked.py <file.mid> [--chunk-size 4]
```
