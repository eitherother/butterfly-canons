
r0 = [1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0]
r1 = [0,0,1,0,0,0,0,0, 0,0,1,0,0,1,0,0]
r2 = [0,0,0,0,1,0,1,0, 0,0,0,0,1,0,1,0]
r3 = [1,0,0,0,1,1,1,1, 1,0,0,0,1,1,0,1]

r4 = [1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,1,0, 0,0,1,0, 1,0,0,0, 0,0,0,0, 1,0,1,0, 0,0,1,0, 1,0,0,0, 1,0,0,0, 1,0,1,0, 0,0,1,0, 1,0,1,0, 0,0,1,0, 1,0,0,0, 1,0,1,0, 0,0,1,0, 0,0,1,0]
r5 = [1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,1,0, 0,0,1,0, 1,0,0,0, 0,0,0,0, 1,0,1,0, 0,0,1,0, 1,0,0,0, 1,0,0,0, 1,0,1,0, 0,0,1,0, 1,0,1,0, 0,0,1,0, 1,0,0,0, 1,0,1,0, 0,0,1,0, 0,0,1,0, 0,0]
r6 = [1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,1,0, 0,0,1,0, 1,0,0,0, 0,0,0,0, 1,0,1,0, 0,0,1,0, 1,0,0,0, 1,0,0,0, 1,0,1,0, 0,0,1,0, 1,0,1,0, 0,0,1,0, 1,0,0,0, 1,0,1,0, 0,0,1,0, 0,0,1,0, 0,0,0,0]

r7 = [1]

melody_backups_low = ["cl", "marimba", "silence"]
melody_backups_high = ["cl", "marimba", "flt", "silence"]
bass_backups_low = ["vcl", "bsn", "bass", "silence"]
bass_backups_high = ["cl", "silence"]



steps = [
    [
        {"instrument": "bass", "buffers": ["Eb3"]},
        {"instrument": "tuba", "buffers": ["Bb3"]},
        {"instrument": "vcl", "buffers": ["C4", "C4", "F4"]},
        {"instrument": "bsn", "buffers": ["F4", "F4", "C4"]},
        {"instrument": "marimba", "buffers": ["A5", "D5", "Gb5", "C5", "E5", "Bb4", "G4", "D5", "A4", "E5", "Gb5", "C5", "G5", "Bb4", "C5", "Gb5", "Bb5"]},
        {"instrument": "cl", "buffers": ["A5", "D5", "Gb5", "C5", "E5", "Bb4", "G4", "D5", "A4", "E5", "Gb5", "C5", "G5", "Bb4", "C5", "Gb5", "Bb5"]},
        {"instrument": "ob", "buffers": ["A5", "D5", "Gb5", "C5", "E5", "Bb4", "G4", "D5", "A4", "E5", "Gb5", "C5", "G5", "Bb4", "C5", "Gb5", "Bb5"]},
        {"instrument": "flt", "buffers": ["A5", "Bb5", "C6", "silence"], "repeats": [12, 15]},
    ],
    [
        {"instrument": "bass", "buffers": ["D3"]},
        {"instrument": "tuba", "buffers": ["Bb3"]},
        {"instrument": "vcl", "buffers": ["C4", "C4", "F4"]},
        {"instrument": "bsn", "buffers": ["F4", "F4", "C4"]},
        {"instrument": "marimba", "buffers": ["A5", "D5", "F5", "C5", "E5", "Bb4", "G4", "D5", "A4", "E5", "F5", "Bb4", "G5", "D5", "E5", "C5", "Bb5"]},
        {"instrument": "cl", "buffers": ["A5", "D5", "F5", "C5", "E5", "Bb4", "G4", "D5", "A4", "E5", "F5", "Bb4", "G5", "D5", "E5", "C5", "Bb5"]},
        {"instrument": "ob", "buffers": ["A5", "D5", "F5", "C5", "E5", "Bb4", "G4", "D5", "A4", "E5", "F5", "Bb4", "G5", "D5", "E5", "C5", "Bb5"]},
        {"instrument": "flt", "buffers": ["A5", "B5", "C6", "silence"], "repeats": [12, 15]},
    ],

    [
        {"instrument": "bass", "buffers": ["Db3"]},
        {"instrument": "tuba", "buffers": ["Ab3"]},
        {"instrument": "vcl", "buffers": ["Bb3", "Bb3", "E4"]},
        {"instrument": "bsn", "buffers": ["E4", "E4", "Bb3"]},
        {"instrument": "marimba", "buffers": ["A5", "Db5", "E5", "Bb4", "G5", "A4", "E5", "G4", "D5", "A4", "E5", "Bb4", "F5", "G4", "A4", "Bb4", "Bb5"]},
        {"instrument": "cl", "buffers": ["A5", "Db5", "E5", "Bb4", "G5", "A4", "E5", "G4", "D5", "A4", "E5", "Bb4", "F5", "G4", "A4", "Bb4", "Bb5"]},
        {"instrument": "ob", "buffers": ["A5", "Db5", "E5", "Bb4", "G5", "A4", "E5", "G4", "D5", "A4", "E5", "Bb4", "F5", "G4", "A4", "Bb4", "Bb5"]},
        {"instrument": "flt", "buffers": ["E5", "A5", "B5", "silence"], "repeats": [12, 15]},
    ],
    [
        {"instrument": "bass", "buffers": ["C3"]},
        {"instrument": "tuba", "buffers": ["G3"]},
        {"instrument": "vcl", "buffers": ["A3", "A3", "E4"]},
        {"instrument": "bsn", "buffers": ["E4", "E4", "A3"]},
        {"instrument": "marimba", "buffers": ["A5", "E5", "G5", "Eb5", "C5", "G4", "C5", "A4", "Eb5", "E5", "C5", "G4", "A4"]},
        {"instrument": "cl", "buffers": ["A5", "E5", "G5", "Eb5", "C5", "G4", "C5", "A4", "Eb5", "E5", "C5", "G4", "A4"]},
        {"instrument": "ob", "buffers": ["A5", "E5", "G5", "Eb5", "C5", "G4", "C5", "A4", "Eb5", "E5", "C5", "G4", "A4"]},
        {"instrument": "flt", "buffers": ["Eb5", "A5", "B5", "silence"], "repeats": [11, 14]},
    ],
    [
        {"instrument": "bass", "buffers": ["B2"]},
        {"instrument": "tuba", "buffers": ["Gb3"]},
        {"instrument": "vcl", "buffers": ["A3", "A3", "D4"]},
        {"instrument": "bsn", "buffers": ["D4", "D4", "A3"]},
        {"instrument": "marimba", "buffers": ["Gb5", "B4", "D5", "A4", "E5", "G4", "D5", "Gb4", "E4", "B4", "Db5", "A4", "D5"]},
        {"instrument": "cl", "buffers": ["Gb5", "B4", "D5", "A4", "E5", "G4", "D5", "Gb4", "E4", "B4", "Db5", "A4", "D5"]},
        {"instrument": "ob", "buffers": ["Gb5", "B4", "D5", "A4", "E5", "G4", "D5", "Gb4", "E4", "B4", "Db5", "A4", "D5"]},
        {"instrument": "flt", "buffers": ["Gb5", "G5", "A5", "silence"], "repeats": [10, 13]},
    ],
    [
        {"instrument": "bass", "buffers": ["E3"]},
        {"instrument": "tuba", "buffers": ["E3"]},
        {"instrument": "vcl", "buffers": ["B3", "B3", "E4"]},
        {"instrument": "bsn", "buffers": ["E4", "E4", "B3"]},
        {"instrument": "marimba", "buffers": ["Gb5", "B4", "D5", "A4", "E5", "G4", "D5", "Gb4", "E4", "B4", "Db5", "A4", "D5"]},
        {"instrument": "cl", "buffers": ["Gb5", "B4", "D5", "A4", "E5", "G4", "D5", "Gb4", "E4", "B4", "Db5", "A4", "D5"]},
        {"instrument": "ob", "buffers": ["Gb5", "B4", "D5", "A4", "E5", "G4", "D5", "Gb4", "E4", "B4", "Db5", "A4", "D5"]},
        {"instrument": "flt", "buffers": ["Gb5", "G5", "A5", "silence"], "repeats": [9, 10]},
    ],
    [
        {"instrument": "bass", "buffers": ["A2"]},
        {"instrument": "tuba", "buffers": ["A2"]},
        {"instrument": "vcl", "buffers": ["E3", "E3", "B3"]},
        {"instrument": "bsn", "buffers": ["B3", "B3", "E3"]},
        {"instrument": "marimba", "buffers": ["Gb5", "B4", "D5", "A4", "E5", "G4", "D5", "Gb4", "E4", "B4", "Db5", "A4", "D5"]},
        {"instrument": "cl", "buffers": ["Gb5", "B4", "D5", "A4", "E5", "G4", "D5", "Gb4", "E4", "B4", "Db5", "A4", "D5"]},
        {"instrument": "ob", "buffers": ["Gb5", "B4", "D5", "A4", "E5", "G4", "D5", "Gb4", "E4", "B4", "Db5", "A4", "D5"]},
        {"instrument": "flt", "buffers":  ["Gb5", "G5", "A5", "silence"], "repeats": [8, 10]},
    ],
    [
        {"instrument": "bass", "buffers": ["D3"]},
        {"instrument": "tuba", "buffers": ["D3"]},
        {"instrument": "vcl", "buffers": ["A3", "A3", "D4"]},
        {"instrument": "bsn", "buffers": ["D4", "D4", "A3"]},
        {"instrument": "marimba", "buffers": ["E5", "B4", "Db5", "Gb4", "D5", "E4", "A4"]},
        {"instrument": "cl", "buffers": ["E5", "B4", "Db5", "Gb4", "D5", "E4", "A4"]},
        {"instrument": "ob", "buffers": ["E5", "B4", "Db5", "Gb4", "D5", "E4", "A4"]},
        {"instrument": "flt", "buffers": ["D5", "E5", "Gb5", "silence"], "repeats": [7, 11]},
    ],
    [
        {"instrument": "bass", "buffers": ["G2"]},
        {"instrument": "tuba", "buffers": ["G2"]},
        {"instrument": "vcl", "buffers": ["D3", "D3", "B3"]},
        {"instrument": "bsn", "buffers": ["B3", "B3", "D3"]},
        {"instrument": "marimba", "buffers": ["E5", "B4", "Db5", "G4", "D5", "F4", "E4", "B4", "A4", "Db5", "D4", "F4", "A4", "B4", "G4", "F4", "Db5"]},
        {"instrument": "cl", "buffers": ["E5", "B4", "Db5", "G4", "D5", "F4", "E4", "B4", "A4", "Db5", "D4", "F4", "A4", "B4", "G4", "F4", "Db5"]},
        {"instrument": "ob", "buffers": ["E5", "B4", "Db5", "G4", "D5", "F4", "E4", "B4", "A4", "Db5", "D4", "F4", "A4", "B4", "G4", "F4", "Db5"]},
        {"instrument": "flt", "buffers": ["Db5", "D5", "E5", "silence"], "repeats": [8, 12]},
    ],
    [
        {"instrument": "bass", "buffers": ["Db3"]},
        {"instrument": "tuba", "buffers": ["Db3"]},
        {"instrument": "vcl", "buffers": ["Ab3", "Ab3", "Db4"]},
        {"instrument": "bsn", "buffers": ["Db4", "Db4", "Ab3"]},
        {"instrument": "marimba", "buffers": ["Db5", "Gb4", "Ab4", "Db4", "B4", "Eb4", "E4", "Db4", "Ab4", "Gb4", "Db4"]},
        {"instrument": "cl", "buffers": ["Db5", "Gb4", "Ab4", "Db4", "B4", "Eb4", "E4", "Db4", "Ab4", "Gb4", "Db4"]},
        {"instrument": "ob", "buffers": ["Db5", "Gb4", "Ab4", "Db4", "B4", "Eb4", "E4", "Db4", "Ab4", "Gb4", "Db4"]},
        {"instrument": "flt", "buffers": ["Db5", "Eb5", "E5", "silence"], "repeats": [9, 14]},
    ],
    [
        {"instrument": "bass", "buffers": ["Gb2"]},
        {"instrument": "tuba", "buffers": ["Gb2"]},
        {"instrument": "vcl", "buffers": ["Db3", "Db3", "Bb3"]},
        {"instrument": "bsn", "buffers": ["Bb3", "Bb3", "Db3"]},
        {"instrument": "marimba", "buffers": ["Db5", "Gb4", "Ab4", "Db4", "B4", "Eb4", "E4", "Db5", "Eb5", "C5", "Ab4", "Gb4", "E4"]},
        {"instrument": "cl", "buffers": ["Db5", "Gb4", "Ab4", "Db4", "B4", "Eb4", "E4", "Db5", "Eb5", "C5", "Ab4", "Gb4", "E4"]},
        {"instrument": "ob", "buffers": ["Db5", "Gb4", "Ab4", "Db4", "B4", "Eb4", "E4", "Db5", "Eb5", "C5", "Ab4", "Gb4", "E4"]},
        {"instrument": "flt", "buffers": ["Db5", "Eb5", "E5", "silence"], "repeats": [10, 15]},
    ],
    [
        {"instrument": "bass", "buffers": ["B2"]},
        {"instrument": "tuba", "buffers": ["B2"]},
        {"instrument": "vcl", "buffers": ["Gb3", "Gb3", "Bb3"]},
        {"instrument": "bsn", "buffers": ["Bb3", "Bb3", "Gb3"]},
        {"instrument": "marimba", "buffers": ["Db5", "Gb4", "A4", "D4", "B4", "E4", "Gb4", "Db4", "D4", "A4", "B4"]},
        {"instrument": "cl", "buffers": ["Db5", "Gb4", "A4", "D4", "B4", "E4", "Gb4", "Db4", "D4", "A4", "B4"]},
        {"instrument": "ob", "buffers": ["Db5", "Gb4", "A4", "D4", "B4", "E4", "Gb4", "Db4", "D4", "A4", "B4"]},
        {"instrument": "flt", "buffers": ["B4", "Db5", "D5", "silence"], "repeats": [12, 16]},
    ],
    [
        {"instrument": "bass", "buffers": ["E2"]},
        {"instrument": "tuba", "buffers": ["E2"]},
        {"instrument": "vcl", "buffers": ["B2", "B2", "Ab3"]},
        {"instrument": "bsn", "buffers": ["Ab3", "Ab3", "B2"]},
        {"instrument": "marimba", "buffers": ["Db5", "Gb4", "Bb4", "D4", "Ab4", "E4", "Bb4", "B4", "Eb5", "Db5", "Ab4", "E4", "Bb4"]},
        {"instrument": "cl", "buffers": ["Db5", "Gb4", "Bb4", "D4", "Ab4", "E4", "Bb4", "B4", "Eb5", "Db5", "Ab4", "E4", "Bb4"]},
        {"instrument": "ob", "buffers": ["Db5", "Gb4", "Bb4", "D4", "Ab4", "E4", "Bb4", "B4", "Eb5", "Db5", "Ab4", "E4", "Bb4"]},
        {"instrument": "flt", "buffers": ["Bb4", "Db5", "D5", "silence"], "repeats": [13, 17]},
    ],
    [
        {"instrument": "bass", "buffers": ["Ab2"]},
        {"instrument": "tuba", "buffers": ["Ab2"]},
        {"instrument": "vcl", "buffers": ["Eb3", "Eb3", "Ab3"]},
        {"instrument": "bsn", "buffers": ["Ab3", "Ab3", "Eb3"]},
        {"instrument": "marimba", "buffers": ["Bb4", "Eb4", "Gb4", "C4", "Ab4", "Eb4", "Gb4", "Bb3", "Db4", "Eb4", "Gb4", "C4", "C4", "Ab4"]},
        {"instrument": "cl", "buffers": ["Bb4", "Eb4", "Gb4", "C4", "Ab4", "Eb4", "Gb4", "Bb3", "Db4", "Eb4", "Gb4", "C4", "C4", "Ab4"]},
        {"instrument": "ob", "buffers": ["Bb4", "Eb4", "Gb4", "C4", "Ab4", "Eb4", "Gb4", "Bb3", "Db4", "Eb4", "Gb4", "C4", "C4", "Ab4"]},
        {"instrument": "flt", "buffers": ["Ab4", "Bb4", "C5", "silence"], "repeats": [11, 16]},
    ],
    [
        {"instrument": "bass", "buffers": ["A2"]},
        {"instrument": "tuba", "buffers": ["A2"]},
        {"instrument": "vcl", "buffers": ["E3", "E3", "A3"]},
        {"instrument": "bsn", "buffers": ["A3", "A3", "E3"]},
        {"instrument": "marimba", "buffers": ["Gb4", "D4", "E4", "B3", "D4", "A3", "B3"]},
        {"instrument": "cl", "buffers": ["Gb4", "D4", "E4", "B3", "D4", "A3", "B3"]},
        {"instrument": "ob", "buffers": ["Gb4", "D4", "E4", "B3", "D4", "A3", "B3"]},
        {"instrument": "flt", "buffers": ["Ab4", "A4", "B4", "silence"], "repeats": [12, 15]},
    ],
    [
        {"instrument": "bass", "buffers": ["Bb2"]},
        {"instrument": "tuba", "buffers": ["Bb2"]},
        {"instrument": "vcl", "buffers": ["Eb3", "Eb3", "Ab3"]},
        {"instrument": "bsn", "buffers": ["Ab3", "Ab3", "Eb3"]},
        {"instrument": "marimba", "buffers": ["Gb4", "D4", "Eb4", "C4", "D4", "Bb3", "Ab3", "D4", "Eb4", "C4", "Bb3"]},
        {"instrument": "cl", "buffers": ["Gb4", "D4", "Eb4", "C4", "D4", "Bb3", "Ab3", "D4", "Eb4", "C4", "Bb3"]},
        {"instrument": "ob", "buffers": ["Gb4", "D4", "Eb4", "C4", "D4", "Bb3", "Ab3", "D4", "Eb4", "C4", "Bb3"]},
        {"instrument": "flt", "buffers": ["Gb4", "Ab4", "Bb4", "silence"], "repeats": [10, 13]},
    ],
    [
        {"instrument": "bass", "buffers": ["Eb2"]},
        {"instrument": "tuba", "buffers": ["Eb2"]},
        {"instrument": "vcl", "buffers": ["Bb2", "Bb2", "Eb3"]},
        {"instrument": "bsn", "buffers": ["Eb3", "Eb3", "Bb2"]},
        {"instrument": "marimba", "buffers": ["F4", "C4", "Eb4", "Bb3", "C4", "Eb4", "C4"]},
        {"instrument": "cl", "buffers": ["F4", "C4", "Eb4", "Bb3", "C4", "Eb4", "C4"]},
        {"instrument": "ob", "buffers": ["F4", "C4", "Eb4", "Bb3", "C4", "Eb4", "C4"]},
        {"instrument": "flt", "buffers": ["F4", "G4", "A4", "silence"], "repeats": [11, 14]},
    ],
    [
        {"instrument": "bass", "buffers": ["G2"]},
        {"instrument": "tuba", "buffers": ["G2"]},
        {"instrument": "vcl", "buffers": ["D3", "D3", "G3"]},
        {"instrument": "bsn", "buffers": ["G3", "G3", "D3"]},
        {"instrument": "marimba", "buffers": ["D4", "Bb3", "A3", "Bb3", "C4"]},
        {"instrument": "cl", "buffers": ["D4", "Bb3", "A3", "Bb3", "C4"]},
        {"instrument": "ob", "buffers": ["D4", "Bb3", "A3", "Bb3", "C4"]},
        {"instrument": "flt", "buffers": ["D4", "E4", "F4", "silence"], "repeats": [12, 15]},
    ],
    [
        {"instrument": "bass", "buffers": ["C2"]},
        {"instrument": "tuba", "buffers": ["C2"]},
        {"instrument": "vcl", "buffers": ["G2", "G2", "E3"]},
        {"instrument": "bsn", "buffers": ["E3", "E3", "G2"]},
        {"instrument": "marimba", "buffers": ["G4", "D4", "C4"]},
        {"instrument": "cl", "buffers": ["G4", "D4", "C4"]},
        {"instrument": "ob", "buffers": ["G4", "D4", "C4"]},
        {"instrument": "flt", "buffers": ["D5", "E5", "F5", "silence"], "repeats": [13, 16]},
    ],
    [
        {"instrument": "bass", "buffers": ["Gb2"]},
        {"instrument": "tuba", "buffers": ["D3"]},
        {"instrument": "vcl", "buffers": ["Gb3", "Gb3", "A3"]},
        {"instrument": "bsn", "buffers": ["A3", "A3", "Gb3"]},
        {"instrument": "marimba", "buffers": ["Gb4", "E4", "D4"]},
        {"instrument": "cl", "buffers": ["Gb4", "E4", "D4"]},
        {"instrument": "ob", "buffers": ["Gb4", "E4", "D4"]},
        {"instrument": "flt", "buffers": ["D4", "E4", "Gb4", "silence"], "repeats": [14, 18]},
    ],
    [
        {"instrument": "bass", "buffers": ["B2"]},
        {"instrument": "tuba", "buffers": ["Gb3"]},
        {"instrument": "vcl", "buffers": ["B3", "B3", "D4"]},
        {"instrument": "bsn", "buffers": ["D4", "D4", "B3"]},
        {"instrument": "marimba", "buffers": ["Gb4", "E4", "D4"]},
        {"instrument": "cl", "buffers": ["Gb4", "E4", "D4"]},
        {"instrument": "ob", "buffers": ["Gb4", "E4", "D4"]},
        {"instrument": "flt", "buffers": ["D5", "E5", "Gb5", "silence"], "repeats": [13, 65]},
    ],
    [
        {"instrument": "bass", "buffers": ["Db3"]},
        {"instrument": "tuba", "buffers": ["Ab3"]},
        {"instrument": "vcl", "buffers": ["Db4", "Db4", "F4"]},
        {"instrument": "bsn", "buffers": ["F4", "F4", "Db4"]},
        {"instrument": "marimba", "buffers": ["Ab4", "Gb4", "F4"]},
        {"instrument": "cl", "buffers": ["Ab4", "Gb4", "F4"]},
        {"instrument": "ob", "buffers": ["Ab4", "Gb4", "F4"]},
        {"instrument": "flt", "buffers": ["F5", "Gb5", "Ab5", "silence"], "repeats": [11, 14]},
    ],
    [
        {"instrument": "bass", "buffers": ["D3"]},
        {"instrument": "tuba", "buffers": ["A3"]},
        {"instrument": "vcl", "buffers": ["D4", "D4", "Gb4"]},
        {"instrument": "bsn", "buffers": ["Gb4", "Gb4", "D4"]},
        {"instrument": "marimba", "buffers": ["A4", "Ab4", "Gb4"]},
        {"instrument": "cl", "buffers": ["A4", "Ab4", "Gb4"]},
        {"instrument": "ob", "buffers": ["A4", "Ab4", "Gb4"]},
        {"instrument": "flt", "buffers": ["Gb5", "Ab5", "A5", "silence"], "repeats": [8, 12]},
    ],
]







