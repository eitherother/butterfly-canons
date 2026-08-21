#!/usr/bin/env python3
"""Transcribe a MIDI file into melody.txt-style lines: extracts note-ons
and splits them into fixed-size groups (instead of on a delimiter note, see
midi_notes.py), printing each group as a `["C4", "E4", ...]` array."""

import argparse

import mido

NOTE_NAMES = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]


def note_name(n):
    return f"{NOTE_NAMES[n % 12]}{n // 12 - 1}"


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("midi_file")
    parser.add_argument(
        "--chunk-size", type=int, default=4, help="notes per printed line (default: 4)"
    )
    return parser.parse_args()


def extract_lines(path, chunk_size):
    mid = mido.MidiFile(path)
    notes = []
    for track in mid.tracks:
        for msg in track:
            if msg.type == "note_on" and msg.velocity > 0:
                notes.append(note_name(msg.note))
    return [notes[i : i + chunk_size] for i in range(0, len(notes), chunk_size)]


def format_line(line):
    return "[" + ", ".join(f'"{note}"' for note in line) + "]"


def main():
    args = parse_args()
    for line in extract_lines(args.midi_file, args.chunk_size):
        print(format_line(line))


if __name__ == "__main__":
    main()
