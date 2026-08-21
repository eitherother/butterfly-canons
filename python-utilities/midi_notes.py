#!/usr/bin/env python3
"""Transcribe a MIDI file into melody.txt-style lines: extracts note-ons,
splits them into groups on a delimiter note (default A0, used as a manual
"next line" marker while playing), and prints each group as a
`["C4", "E4", ...]` array."""

import argparse

import mido

NOTE_NAMES = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]


def note_name(n):
    return f"{NOTE_NAMES[n % 12]}{n // 12 - 1}"


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("midi_file")
    parser.add_argument(
        "--delimiter",
        default="A0",
        help="note name that marks the end of a line (default: A0)",
    )
    return parser.parse_args()


def extract_lines(path, delimiter):
    mid = mido.MidiFile(path)
    lines = []
    current = []
    for track in mid.tracks:
        for msg in track:
            if msg.type == "note_on" and msg.velocity > 0:
                name = note_name(msg.note)
                if name == delimiter:
                    if current:
                        lines.append(current)
                        current = []
                else:
                    current.append(name)
    if current:
        lines.append(current)
    return lines


def format_line(line):
    return "[" + ", ".join(f'"{note}"' for note in line) + "]"


def main():
    args = parse_args()
    for line in extract_lines(args.midi_file, args.delimiter):
        print(format_line(line))


if __name__ == "__main__":
    main()
