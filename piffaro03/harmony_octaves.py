#!/usr/bin/env python3
import ast
import random
import re
import sys

NOTE_RE = re.compile(r'^([A-G]b?)(-?\d+)$')
MIN_OCTAVE = 3

RANGES = {
    "vla":     {"Ab5","A3","G6","B3","Gb3","Db3","C3","E3","Ab3","C6","Eb3","C5","D4","G4","B5","Bb4","E5","F5","Db6","Gb4","Bb3","E6","C4","A5","F6","Db5","F3","Gb5","B4","D3","Bb5","Gb6","A6","Db4","D5","Eb5","D6","G5","A4","E4","Eb4","Eb6","Ab4","F4","G3","Ab6"},
    "vcl":     {"Db4","Gb3","Gb4","A2","Eb3","G3","G2","E4","C2","Bb3","Db3","Eb4","C4","Gb2","E2","F3","A3","Ab2","D2","D3","F4","F2","B2","Db2","E3","Bb2","D4","Ab3","G4","Eb2","C3","B3"},
    "bass":    {"G1","A1","Gb3","Db1","A2","Eb3","C1","G3","G2","Gb1","C2","B1","Db3","Gb2","E2","F3","F1","Eb1","Ab1","Ab2","D2","D3","E1","F2","B2","Db2","E3","Bb1","Bb2","D1","Eb2","C3"},
    "cl":      {"Bb6","Ab5","A3","G6","B3","Gb3","B6","E3","Ab3","C6","Eb3","C5","D4","G4","B5","Bb4","E5","F5","Db6","Gb4","Bb3","E6","C4","A5","F6","Db5","F3","Gb5","B4","D3","Bb5","Gb6","A6","Db4","D5","Eb5","D6","G5","A4","E4","Eb4","Eb6","Ab4","F4","G3","Ab6"},
    "flt":     {"F5","A6","Eb5","Db6","Gb4","Ab4","G6","B6","D4","Gb5","C4","Db4","Db5","C7","D5","Bb5","F6","C6","E5","Eb6","Gb6","B4","B3","Db7","C5","Eb4","F4","G5","A5","Ab5","Ab6","D6","B5","G4","E4","A4","E6","Bb4","Bb6"},
    "bassflt": {"Gb5","Ab3","Gb3","C6","Eb3","A3","C4","C3","Eb4","G3","D4","B5","Eb5","G4","Ab5","Db4","F5","Db3","F4","E4","G5","B4","Db6","Gb4","Bb5","Db5","E3","Bb4","A4","B3","E5","D3","Ab4","Bb3","C5","A5","D5","F3"},
    "ob":      {"C5","B4","Ab4","Ab6","C4","A4","Gb5","Db6","Gb4","Gb6","Eb6","D6","Bb3","Db5","C6","G6","Eb5","B3","G4","D5","Bb5","Eb4","E6","B5","G5","D4","A5","F6","F5","E4","E5","Bb4","Ab5","F4","Db4"},
    "bsn":     {"Ab4","Gb4","G3","G4","Bb4","G2","E2","C3","Eb2","E4","Db2","D3","F2","C2","Bb3","Db4","Eb4","Bb1","D4","Ab3","C4","D5","F3","Ab2","F4","B1","C5","B4","Eb3","Db5","A2","Db3","Gb2","A3","E3","D2","Gb3","Bb2","A4","B2"},
    "pnmf":    {"E7","Db4","B0","A5","Ab7","C7","Db6","Ab2","D5","G6","Ab1","Eb1","C5","Gb6","Gb3","A2","G3","Eb6","B2","Db3","Bb7","D1","C1","B7","F6","Gb2","Gb1","Bb6","D2","Bb5","Bb2","C4","Eb2","E2","C8","E4","B1","Bb1","Eb3","Ab6","A4","Eb5","A0","F7","G1","D6","Eb4","D4","E3","Bb3","A1","Ab4","Db1","Gb4","Ab3","Gb5","Db7","F1","Db2","Eb7","E6","Db5","F5","G7","E5","C2","C6","Bb0","A6","B4","D3","G5","G4","Ab5","D7","C3","Gb7","A7","B5","F4","B6","E1","Bb4","G2","B3","F3","A3","F2"},
    "pnff":    {"E7","Db4","B0","A5","Ab7","C7","Db6","Ab2","D5","G6","Ab1","Eb1","C5","Gb6","Gb3","A2","G3","Eb6","B2","Db3","Bb7","D1","C1","B7","F6","Gb2","Gb1","Bb6","D2","Bb5","Bb2","C4","Eb2","E2","C8","E4","B1","Bb1","Eb3","Ab6","A4","Eb5","A0","F7","G1","D6","Eb4","D4","E3","Bb3","A1","Ab4","Db1","Gb4","Ab3","Gb5","Db7","F1","Db2","Eb7","E6","Db5","F5","G7","E5","C2","C6","Bb0","A6","B4","D3","G5","G4","Ab5","D7","C3","Gb7","A7","B5","F4","B6","E1","Bb4","G2","B3","F3","A3","F2"},
    "pnpp":    {"E7","Db4","B0","A5","Ab7","C7","Db6","Ab2","D5","G6","Ab1","Eb1","C5","Gb6","Gb3","A2","G3","Eb6","B2","Db3","Bb7","D1","C1","B7","F6","Gb2","Gb1","Bb6","D2","Bb5","Bb2","C4","Eb2","E2","C8","E4","B1","Bb1","Eb3","Ab6","A4","Eb5","A0","F7","G1","D6","Eb4","D4","E3","Bb3","A1","Ab4","Db1","Gb4","Ab3","Gb5","Db7","F1","Db2","Eb7","E6","Db5","F5","G7","E5","C2","C6","Bb0","A6","B4","D3","G5","G4","Ab5","D7","C3","Gb7","A7","B5","F4","B6","E1","Bb4","G2","B3","F3","A3","F2"},
}

INSTRUMENT_ALIASES = {"oboe": "ob"}

INNER_LIST_RE = re.compile(r'\[([^\[\]]*)\]')
NOTE_FIELD_RE = re.compile(r'"note":\s*"([^"]+)"')


def arpeggio(note):
    letter, octave = NOTE_RE.match(note).groups()
    octave = int(octave)
    count = random.randint(2, 5)
    notes = [note]
    for _ in range(count - 1):
        octave -= 1
        if octave < MIN_OCTAVE:
            break
        notes.append(f'{letter}{octave}')
    return notes


def transpose_up(note, octaves=1):
    letter, octave = NOTE_RE.match(note).groups()
    return f'{letter}{int(octave) + octaves}'


def canonical_instrument(name):
    return INSTRUMENT_ALIASES.get(name, name)


def parse_melody_line(line):
    note_match = NOTE_FIELD_RE.search(line)
    if not note_match:
        raise ValueError(f'no "note" field found in: {line}')
    note = note_match.group(1)
    inner_lists = INNER_LIST_RE.findall(line)
    if len(inner_lists) != 2:
        raise ValueError(f'expected 2 bracketed lists (instruments, octave), found {len(inner_lists)}: {line}')
    instruments = ast.literal_eval(f'[{inner_lists[0]}]') if inner_lists[0].strip() else []
    octave = ast.literal_eval(f'[{inner_lists[1]}]') if inner_lists[1].strip() else []
    return note, instruments, octave


def read_melody(path):
    entries = []
    with open(path) as f:
        for lineno, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            entries.append((lineno, *parse_melody_line(line)))
    return entries


def build_melody_step(lineno, note, instruments, octave, alerts):
    total = len(instruments) + len(octave)
    if total != 4:
        alerts.append(f'melody.txt line {lineno}: expected 4 instruments total, got {total} ({instruments!r} + {octave!r})')

    refs = []
    for name in instruments:
        canon = canonical_instrument(name)
        ranges = RANGES.get(canon)
        if ranges is None:
            alerts.append(f'melody.txt line {lineno}: unknown instrument "{name}"')
        elif note not in ranges:
            alerts.append(f'melody.txt line {lineno}: "{note}" is out of range for {name}')
        refs.append([f'~{canon}[\\{note}]'])

    for name in octave:
        canon = canonical_instrument(name)
        up_note = transpose_up(note)
        ranges = RANGES.get(canon)
        if ranges is None:
            alerts.append(f'melody.txt line {lineno}: unknown instrument "{name}"')
        elif up_note not in ranges:
            alerts.append(f'melody.txt line {lineno}: "{up_note}" (octave up from {note}) is out of range for {name}')
        refs.append([f'~{canon}[\\{up_note}]'])

    while len(refs) < 4:
        refs.append(['~silence'])
    return refs[:4]


def expand_note(note):
    reps = random.randint(8, 12)
    notes = []
    for _ in range(reps):
        notes.extend(arpeggio(note))
    return notes


def expand_chord(chord):
    return [expand_note(note) for note in chord]


def harmony_step_refs(step):
    return [[f'~pnpp[\\{note}]' for note in notes] for notes in step]


def read_chords(path):
    chords = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            chords.append(ast.literal_eval(line))
    return chords


def fmt_ref_array(refs):
    return f'[{", ".join(refs)}]'


def fmt_step(step):
    lines = ["\t["]
    for ni, refs in enumerate(step):
        comma = "," if ni < len(step) - 1 else ""
        lines.append(f'\t\t{fmt_ref_array(refs)}{comma}')
    lines.append("\t]")
    return "\n".join(lines)


def emit(steps, out_path):
    lines = ["// Auto-generated from harmony.txt + melody.txt by harmony_octaves.py — do not edit by hand.", "("]
    lines.append("~rawSteps = [")
    for si, step in enumerate(steps):
        lines.append(f"\t// Step {si}")
        step_comma = "," if si < len(steps) - 1 else ""
        lines.append(f"{fmt_step(step)}{step_comma}")
    lines.append("];")
    lines.append('"Raw steps loaded: % harmony+melody steps.".format(~rawSteps.size).postln;')
    lines.append(")")
    with open(out_path, "w") as f:
        f.write("\n".join(lines) + "\n")
    print(f"Wrote {len(steps)} steps to {out_path}")


def main(harmony_path, melody_path):
    chords = read_chords(harmony_path)
    melody_entries = read_melody(melody_path)

    if len(chords) != len(melody_entries):
        print(f'ALERT: harmony.txt has {len(chords)} lines but melody.txt has {len(melody_entries)} lines — cannot zip 1:1', file=sys.stderr)

    alerts = []
    steps = []
    line_reports = []
    for chord, (lineno, note, instruments, octave) in zip(chords, melody_entries, strict=False):
        harmony_refs = harmony_step_refs(expand_chord(chord))
        line_alerts = []
        melody_refs = build_melody_step(lineno, note, instruments, octave, line_alerts)
        alerts.extend(line_alerts)
        steps.append(harmony_refs + melody_refs)
        status = "OK" if not line_alerts else "; ".join(line_alerts)
        line_reports.append(f'line {lineno}: note={note!r} instruments={instruments!r} octave={octave!r} -> {status}')

    print(f'Melody report ({len(line_reports)} lines):')
    for report in line_reports:
        print(f'  {report}')

    if alerts:
        print(f'ALERT: {len(alerts)} issue(s) found in melody.txt:', file=sys.stderr)
        for alert in alerts:
            print(f'  - {alert}', file=sys.stderr)

    emit(steps, "score_generated.scd")


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f'Usage: {sys.argv[0]} <harmony.txt> <melody.txt>', file=sys.stderr)
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])
