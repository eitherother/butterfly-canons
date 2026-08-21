#!/usr/bin/env python3
import sys

import mido

NOTE_NAMES = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]


def note_name(n):
    return f"{NOTE_NAMES[n % 12]}{n // 12 - 1}"


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <midi_file>")
        sys.exit(1)

    mid = mido.MidiFile(sys.argv[1])
    notes = []
    for track in mid.tracks:
        for msg in track:
            if msg.type == "note_on" and msg.velocity > 0:
                notes.append(msg.note)

    for i in range(0, len(notes), 4):
        chunk = sorted(notes[i : i + 4])
        bass = f"~bass[\\{note_name(chunk[0] - 12)}]"
        line = ", ".join(f"~pnmf[\\{note_name(n)}]" for n in chunk)
        print(f"{bass}, {line},")


if __name__ == "__main__":
    main()
