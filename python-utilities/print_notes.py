#!/usr/bin/env python3
"""Chunk a MIDI file's note-ons and print them as SuperCollider buffer
references, e.g. `~bass[\\C3], ~pnmf[\\E4], ~pnmf[\\G4], ~pnmf[\\C5],`."""

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
    parser.add_argument(
        "--bass-tag",
        default="bass",
        help="buffer name for each chunk's lowest note (default: bass)",
    )
    parser.add_argument(
        "--other-tag",
        default="pnmf",
        help="buffer name for the rest of each chunk's notes (default: pnmf)",
    )
    parser.add_argument(
        "--bass-shift",
        type=int,
        default=-12,
        help="semitones to shift the lowest note by before naming it (default: -12)",
    )
    return parser.parse_args()


def main():
    args = parse_args()

    mid = mido.MidiFile(args.midi_file)
    notes = []
    for track in mid.tracks:
        for msg in track:
            if msg.type == "note_on" and msg.velocity > 0:
                notes.append(msg.note)

    for i in range(0, len(notes), args.chunk_size):
        chunk = sorted(notes[i : i + args.chunk_size])
        bass = f"~{args.bass_tag}[\\{note_name(chunk[0] + args.bass_shift)}]"
        line = ", ".join(f"~{args.other_tag}[\\{note_name(n)}]" for n in chunk)
        print(f"{bass}, {line},")


if __name__ == "__main__":
    main()
