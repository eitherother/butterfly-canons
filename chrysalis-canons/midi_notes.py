#!/usr/bin/env python3
import sys

import mido

NOTE_NAMES = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B']

def midi_to_name(note):
    name = NOTE_NAMES[note % 12]
    octave = (note // 12) - 1
    return f'{name}{octave}'

def extract_lines(path):
    mid = mido.MidiFile(path)
    lines = []
    current = []
    for track in mid.tracks:
        for msg in track:
            if msg.type == 'note_on' and msg.velocity > 0:
                name = midi_to_name(msg.note)
                if name == 'A0':
                    if current:
                        lines.append(current)
                        current = []
                else:
                    current.append(name)
    if current:
        lines.append(current)
    return lines

def format_line(line):
    return '[' + ', '.join(f'"{note}"' for note in line) + ']'

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(f'Usage: {sys.argv[0]} <file.mid>', file=sys.stderr)
        sys.exit(1)
    for line in extract_lines(sys.argv[1]):
        print(format_line(line))
