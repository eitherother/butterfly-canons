"""
Trim silence from the start of audio samples in a folder.

For each .wav/.aif/.aiff file in the given folder, detects the first point
where the signal crosses a threshold fraction of the file's peak amplitude
(the onset), keeps a small pre-roll before it, and trims everything before
that. Originals are backed up to an "originals" subfolder first.

Usage:
    python trim_samples.py [folder] [--threshold FRACTION]

Examples:
    python trim_samples.py ./samples
    python trim_samples.py ./samples --threshold 0.02
"""

import argparse
import os
import shutil

import numpy as np
import soundfile as sf

THRESHOLD = 0.01  # fraction of peak amplitude
PRE_ROLL_MS = 5  # milliseconds to keep before detected onset


def detect_start_frame(audio, sr, threshold):
    mono = np.abs(audio).max(axis=1) if audio.ndim > 1 else np.abs(audio)
    peak = mono.max()
    if peak == 0:
        return 0
    threshold_val = peak * threshold
    onset_indices = np.where(mono >= threshold_val)[0]
    if len(onset_indices) == 0:
        return 0
    pre_roll_frames = int(PRE_ROLL_MS * sr / 1000)
    return max(0, int(onset_indices[0]) - pre_roll_frames)


def parse_args():
    parser = argparse.ArgumentParser(
        description="Trim silence from the start of audio samples in a folder.",
    )
    parser.add_argument(
        "folder",
        nargs="?",
        default=".",
        help="folder containing .wav/.aif/.aiff samples (default: current directory)",
    )
    parser.add_argument(
        "--threshold",
        type=float,
        default=THRESHOLD,
        help=f"onset threshold as a fraction of peak amplitude (default: {THRESHOLD})",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    folder = args.folder
    backup_dir = os.path.join(folder, "originals")
    os.makedirs(backup_dir, exist_ok=True)

    for fname in sorted(os.listdir(folder)):
        if not fname.lower().endswith((".wav", ".aif", ".aiff")):
            continue
        path = os.path.join(folder, fname)

        shutil.copy2(path, os.path.join(backup_dir, fname))

        info = sf.info(path)
        audio, sr = sf.read(path, always_2d=True)
        start = detect_start_frame(audio, sr, args.threshold)
        sf.write(path, audio[start:], sr, subtype=info.subtype, format=info.format)
        print(f"{fname}: trimmed {start} frames ({start / sr:.3f}s)")


if __name__ == "__main__":
    main()
