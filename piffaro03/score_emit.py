"""
Reads score_raw.py and emits score_generated.scd.
Outputs all steps repeated through a 15-step transposition cycle:
0 -> +7 semitones (a perfect fifth above), wrapping to -7 semitones
(a perfect fifth below), then ascending back up to -1, before the
cycle repeats from 0. Notes that have no exact match after
transposition are snapped to the nearest available pitch for that
instrument.
"""

from score_raw import (
    bass_backups_high,
    bass_backups_low,
    melody_backups_high,
    melody_backups_low,
    r0,
    r1,
    r2,
    r3,
    r4,
    r5,
    r6,
    r7,
    steps,
)

CHROMATIC = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

RANGES = {
    "cl":      {"Bb6","Ab5","A3","G6","B3","Gb3","B6","E3","Ab3","C6","Eb3","C5","D4","G4","B5","Bb4","E5","F5","Db6","Gb4","Bb3","E6","C4","A5","F6","Db5","F3","Gb5","B4","D3","Bb5","Gb6","A6","Db4","D5","Eb5","D6","G5","A4","E4","Eb4","Eb6","Ab4","F4","G3","Ab6"},
    "flt":     {"F5","A6","Eb5","Db6","Gb4","Ab4","G6","B6","D4","Gb5","C4","Db4","Db5","C7","D5","Bb5","F6","C6","E5","Eb6","Gb6","B4","B3","Db7","C5","Eb4","F4","G5","A5","Ab5","Ab6","D6","B5","G4","E4","A4","E6","Bb4","Bb6"},
    "ob":      {"C5","B4","Ab4","Ab6","C4","A4","Gb5","Db6","Gb4","Gb6","Eb6","D6","Bb3","Db5","C6","G6","Eb5","B3","G4","D5","Bb5","Eb4","E6","B5","G5","D4","A5","F6","F5","E4","E5","Bb4","Ab5","F4","Db4"},
    "bsn":     {"Ab4","Gb4","G3","G4","Bb4","G2","E2","C3","Eb2","E4","Db2","D3","F2","C2","Bb3","Db4","Eb4","Bb1","D4","Ab3","C4","D5","F3","Ab2","F4","B1","C5","B4","Eb3","Db5","A2","Db3","Gb2","A3","E3","D2","Gb3","Bb2","A4","B2"},
    "piano":   {"E7","Db4","B0","A5","Ab7","C7","Db6","Ab2","D5","G6","Ab1","Eb1","C5","Gb6","Gb3","A2","G3","Eb6","B2","Db3","Bb7","D1","C1","B7","F6","Gb2","Gb1","Bb6","D2","Bb5","Bb2","C4","Eb2","E2","C8","E4","B1","Bb1","Eb3","Ab6","A4","Eb5","A0","F7","G1","D6","Eb4","D4","E3","Bb3","A1","Ab4","Db1","Gb4","Ab3","Gb5","Db7","F1","Db2","Eb7","E6","Db5","F5","G7","E5","C2","C6","Bb0","A6","B4","D3","G5","G4","Ab5","D7","C3","Gb7","A7","B5","F4","B6","E1","Bb4","G2","B3","F3","A3","F2"},
    "marimba": {"B4","D4","A4","F6","Bb6","C2","B3","Gb4","Gb2","B6","F2","B5","Db4","Ab2","Bb3","D5","Gb6","C5","C7","Ab5","A3","A2","Bb2","G3","F5","D3","G4","E3","Ab6","Ab4","Ab3","Gb3","Bb5","E2","B2","Db2","E5","E6","G6","F4","C4","Eb5","D2","Db5","Gb5","E4","A6","Bb4","C6","G2","Eb6","A5","Eb2","Eb3","F3","Db6","C3","G5","Db3","D6","Eb4"},
    "bass":    {"G1","A1","Gb3","Db1","A2","Eb3","C1","G3","G2","Gb1","C2","B1","Db3","Gb2","E2","F3","F1","Eb1","Ab1","Ab2","D2","D3","E1","F2","B2","Db2","E3","Bb1","Bb2","D1","Eb2","C3"},
    "vib":     {"Ab3","G3","A5","Eb5","C5","D3","Bb4","D5","Db3","F3","E3","G4","Bb3","Db5","F6","B3","F4","G5","Bb5","Db4","D6","C4","Eb3","E4","Gb3","Gb4","F5","Db6","Ab4","D4","Eb4","C3","A3","A4","Gb5","E5","Ab5","Eb6","B4","B5","C6","E6"},
    "tuba":    {"Ab2", "E3", "E1", "B2", "G1", "Gb1", "Eb2", "Db3", "C1", "Bb1", "F2", "G2", "E2", "Db1", "C2", "G3", "D1", "B3", "Ab1", "Db2", "Eb1", "C4", "A1", "D3", "Eb3", "Bb3", "A3", "F3", "D2", "Gb3", "F1", "B1", "A2", "C3", "Bb2", "Gb2", "Ab3"},
    "vcl":     {"Db4","Gb3","Gb4","A2","Eb3","G3","G2","E4","C2","Bb3","Db3","Eb4","C4","Gb2","E2","F3","A3","Ab2","D2","D3","F4","F2","B2","Db2","E3","Bb2","D4","Ab3","G4","Eb2","C3","B3"},
}

# 0-indexed flow positions within a step: 0-3 are the bass/harmony
# register (bass, bsn, vcl, bsn), 4-7 are the melody register
# (marimba, cl, ob, flt). Used to pick which backup list applies
# when a transposed note falls outside an instrument's range.
BASS_FLOWS = {0, 1, 2, 3}

def note_to_midi(note):
    octave = int(note[-1])
    pc     = CHROMATIC.index(note[:-1])
    return (octave + 1) * 12 + pc


def midi_to_note(midi):
    return CHROMATIC[midi % 12] + str((midi // 12) - 1)


def backups_for(flow_index, too_low):
    if flow_index in BASS_FLOWS:
        return bass_backups_low if too_low else bass_backups_high
    return melody_backups_low if too_low else melody_backups_high


def resolve_via_backups(target, backups):
    for backup in backups:
        if backup == "silence":
            return "silence", "silence"
        backup_range = RANGES.get(backup)
        if not backup_range:
            continue
        backup_map = {note_to_midi(n): n for n in backup_range}
        if target in backup_map:
            return backup, backup_map[target]
    return "silence", "silence"


def transpose_note(note, semitones, instrument, flow_index):
    if note == "silence" or semitones == 0:
        return instrument, note
    target    = note_to_midi(note) + semitones
    available = RANGES.get(instrument)
    if not available:
        return instrument, midi_to_note(target)
    midi_map = {note_to_midi(n): n for n in available}
    if target in midi_map:
        return instrument, midi_map[target]
    min_midi, max_midi = min(midi_map), max(midi_map)
    if min_midi <= target <= max_midi:
        octave_down = target - 12
        if octave_down in midi_map:
            return instrument, midi_map[octave_down]
        closest = min(midi_map, key=lambda m: abs(m - target))
        return instrument, midi_map[closest]
    return resolve_via_backups(target, backups_for(flow_index, target < min_midi))


def transpose_step_entry(entry, semitones, flow_index):
    instrument  = entry["instrument"]
    new_buffers = [transpose_note(b, semitones, instrument, flow_index) for b in entry["buffers"]]
    return {**entry, "buffers": new_buffers}


def buf_ref(instrument, note):
    if note == "silence":
        return "~silence"
    return f"~{instrument}[\\{note}]"


def fmt_flow(entry):
    buffers = entry["buffers"]
    repeats = entry.get("repeats", [1])
    buf_str = ", ".join(buf_ref(instrument, note) for instrument, note in buffers)
    rep_str = ", ".join(str(r) for r in repeats)
    return f"(buffers: [{buf_str}], repeats: [{rep_str}])"


def rotate(rhythm, amount):
    """Rotate a rhythm array by `amount` steps before encoding.
    Positive amounts rotate forward (values move to higher indices,
    e.g. [1,0,0,0] -> [0,1,0,0] for amount=1). Negative amounts
    rotate backward (values move to lower indices, e.g.
    [1,0,0,0] -> [0,0,0,1] for amount=-1)."""
    n = len(rhythm)
    if n == 0:
        return list(rhythm)
    amount %= n
    return rhythm[-amount:] + rhythm[:-amount] if amount else list(rhythm)


class Rest:
    """Marker for a leading silence before a pattern's first onset.
    Rendered as SuperCollider's Rest(n) wrapper so Pbind advances
    time without triggering a grain."""
    def __init__(self, length):
        self.length = length

    def __repr__(self):
        return f"Rest({self.length})"


def onset_durations(rhythm):
    """Convert a 1/0 sixteenth-note gate pattern into a single,
    non-wrapping playthrough: a leading Rest if the pattern doesn't
    start on a 1, then each onset's duration up to the next onset,
    with the final onset simply running to the end of the array (no
    wraparound back to the first onset)."""
    n      = len(rhythm)
    onsets = [i for i, v in enumerate(rhythm) if v == 1]
    durs   = []
    if onsets[0] > 0:
        durs.append(Rest(onsets[0]))
    for idx, onset in enumerate(onsets):
        if idx < len(onsets) - 1:
            durs.append(onsets[idx + 1] - onset)
        else:
            durs.append(n - onset)
    return durs


def rotation_period(rhythm, amount):
    """Number of successive `amount`-rotations needed to return to
    the starting pattern (can be shorter than len(rhythm) if the
    pattern has internal symmetry)."""
    original = list(rhythm)
    current  = list(rhythm)
    period   = 0
    while True:
        current = rotate(current, amount)
        period += 1
        if current == original:
            return period


def full_cycle_durs(rhythm, amount):
    """Walk one full rotation cycle of `rhythm` (starting unrotated),
    stepping by `amount` each turn. Each rotation is its own dur
    step, kept as a separate sub-array, so the returned list has one
    entry per rotation. By construction it cycles back to its own
    start once exhausted."""
    period = rotation_period(rhythm, amount)
    return [onset_durations(rotate(rhythm, amount * k)) for k in range(period)]


# Flows 0-3 (bass register): r0 is the fixed reference beat and never
# rotates. r1/r2/r3 each walk their own full rotation cycle
# (staggered round-robin turn order during playback, but each flow's
# generated dur array only depends on its own rotation history).
# Flows 4-6 (melody register) rotate every step (not staggered),
# each at its own fixed rate; different pattern lengths are fine
# since the conductor wraps each flow's dur array independently.
RHYTHMS    = [r0, r1, r2, r3, r4, r5, r6, r7]
dur_steps  = [
    [onset_durations(r0)],
    full_cycle_durs(r1, -1),
    full_cycle_durs(r2, 1),
    full_cycle_durs(r3, 1),
    full_cycle_durs(r4, 2),
    full_cycle_durs(r5, 4),
    full_cycle_durs(r6, 6),
    [onset_durations(r7)],
]
flow_names = [entry["instrument"] for entry in steps[0]]


TRANSPOSITIONS = [0, 1, 2, 3, 4, 5, 6, 7, -7, -6, -5, -4, -3, -2, -1]


def label_for(semitones):
    if semitones == 0:
        return "// === Original pitch ==="
    sign = "+" if semitones > 0 else "-"
    plural = "" if abs(semitones) == 1 else "s"
    return f"// === {sign}{abs(semitones)} semitone{plural} ==="


n = len(steps)
labels = {i * n: label_for(semitones) for i, semitones in enumerate(TRANSPOSITIONS)}

all_steps = []
for semitones in TRANSPOSITIONS:
    for step in steps:
        all_steps.append([transpose_step_entry(entry, semitones, fi) for fi, entry in enumerate(step)])

lines = ["// Auto-generated from score_raw.py — do not edit by hand.", "("]
lines.append("~rawSteps = [")

for si, step in enumerate(all_steps):
    if si in labels:
        lines.append(f"\t{labels[si]}")
    lines.append(f"\t// Step {si}")
    lines.append("\t[")
    for fi, entry in enumerate(step):
        comma = "," if fi < len(step) - 1 else ""
        lines.append(f"\t\t{fmt_flow(entry)}{comma}")
    step_comma = "," if si < len(all_steps) - 1 else ""
    lines.append(f"\t]{step_comma}")

lines.append("];")
lines.append('"Raw steps loaded: % harmony steps.".format(~rawSteps.size).postln;')

lines.append("")
lines.append("~durSteps = [")
for fi, dur_cycle in enumerate(dur_steps):
    flow_comma = "," if fi < len(dur_steps) - 1 else ""
    lines.append(f"\t// Flow {fi} ({flow_names[fi]})")
    lines.append("\t[")
    for di, durs in enumerate(dur_cycle):
        dur_str  = ", ".join(str(d) for d in durs)
        dur_comma = "," if di < len(dur_cycle) - 1 else ""
        lines.append(f"\t\t[{dur_str}]{dur_comma}")
    lines.append(f"\t]{flow_comma}")
lines.append("];")
lines.append('"Dur steps loaded: % flow rhythms.".format(~durSteps.size).postln;')

lines.append(")")

out_path = "score_generated.scd"
with open(out_path, "w") as f:
    f.write("\n".join(lines) + "\n")

print(f"Wrote {len(all_steps)} steps ({n} × {len(TRANSPOSITIONS)} transpositions) to {out_path}")
