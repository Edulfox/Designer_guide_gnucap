#!/usr/bin/env python3
"""
Plot gnucap transient output (.txt) files with matplotlib.

The files written by the testbenches look like::

    #Time       v(inp)     v(clk)     v(outp)    v(outn)
     0.         0.45       0.         1.2        1.2
     ...

Usage::

    ./plot.py behavioral/comp_std_tran.txt behavioral/comp_reg_tran.txt
    ./plot.py device/CMP7345_tran.txt --layout stacked
    ./plot.py file.txt --out svg --show

By default the panels are laid out horizontally (one column per signal
group).  ``--layout stacked`` gives horizontally oriented strips stacked
vertically, which is what the original gnuplot decks did with
``set multiplot layout 3,1``.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import matplotlib

if not __import__("os").environ.get("DISPLAY"):
    matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np

GROUPS = ("inputs", "clock", "outputs", "other")
GROUP_TITLE = {
    "inputs": "Inputs",
    "clock": "Clock / control",
    "outputs": "Outputs",
    "other": "Other",
}


def read_txt(path: Path):
    """Return (names, data) for a gnucap output file."""
    names = None
    with path.open() as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            if line.startswith("#"):
                names = line.lstrip("#").split()
                continue
            break

    if not names:
        raise SystemExit(f"{path}: no '#Time ...' header found")

    data = np.genfromtxt(
        path,
        comments="#",
        missing_values="??",
        filling_values=np.nan,
        ndmin=2,
    )
    if data.size == 0:
        raise SystemExit(f"{path}: no data rows")

    if data.shape[1] != len(names):
        raise SystemExit(
            f"{path}: header has {len(names)} columns, data has {data.shape[1]}"
        )
    return names, data


def classify(name: str) -> str:
    low = name.lower()
    if "clk" in low or low in ("v(en)", "v(enable)"):
        return "clock"
    if "out" in low:
        return "outputs"
    if "inp" in low or "inn" in low or low.startswith("v(v+") or low.startswith("v(v-"):
        return "inputs"
    if low.startswith("i(") or low.startswith("l("):
        return "outputs"
    return "other"


def group_columns(names):
    """Group signal columns, preserving order inside each group."""
    groups = {g: [] for g in GROUPS}
    for i, name in enumerate(names):
        if i == 0:
            continue
        groups[classify(name)].append(i)
    return [(g, idx) for g, idx in groups.items() if idx]


def time_scale(t):
    span = np.nanmax(t) - np.nanmin(t)
    if span < 1e-6:
        return 1e9, "ns"
    if span < 1e-3:
        return 1e6, "us"
    return 1.0, "s"


def plot_file(path: Path, layout: str, outfmt: str, show: bool, dpi: int):
    names, data = read_txt(path)
    t = data[:, 0]
    scale, unit = time_scale(t)
    t = t * scale

    grouped = group_columns(names)
    if not grouped:  # only a time column
        raise SystemExit(f"{path}: nothing to plot")

    n = len(grouped)
    if layout == "horizontal":
        fig, axes = plt.subplots(1, n, figsize=(4.6 * n, 3.8), squeeze=False)
        axes = axes[0]
        sharex = False
    else:
        fig, axes = plt.subplots(
            n, 1, figsize=(9.0, 2.6 * n), sharex=True, squeeze=False
        )
        axes = axes[:, 0]
        sharex = True

    colors = plt.rcParams["axes.prop_cycle"].by_key()["color"]

    for ax, (group, idx) in zip(axes, grouped):
        for k, i in enumerate(idx):
            ax.plot(t, data[:, i], lw=1.4, color=colors[k % len(colors)],
                    label=names[i])
        ax.set_title(GROUP_TITLE[group])
        ax.grid(True, alpha=0.4)
        ax.set_ylabel("V" if group != "other" else "")
        if not sharex:
            ax.set_xlabel(f"time ({unit})")
        if len(idx) > 1 or group == "outputs":
            ax.legend(loc="best", fontsize=9)

    if sharex:
        axes[-1].set_xlabel(f"time ({unit})")

    fig.suptitle(path.name)
    fig.tight_layout(rect=(0, 0, 1, 0.96))

    suffix = f".{outfmt}"
    outfile = path.with_suffix(suffix)
    fig.savefig(outfile, dpi=dpi)
    print(f"wrote {outfile}")

    if show:
        plt.show()
    plt.close(fig)
    return outfile


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Plot gnucap .txt transient output with matplotlib",
    )
    ap.add_argument("files", nargs="*", type=Path,
                    help="gnucap output file(s) with a '#Time ...' header")
    ap.add_argument("--layout", choices=("horizontal", "stacked"),
                    default="horizontal",
                    help="horizontal: panels side by side (default); "
                         "stacked: horizontal strips sharing the time axis")
    ap.add_argument("--out", choices=("png", "pdf", "svg"), default="png",
                    help="output format next to each input file (default png)")
    ap.add_argument("--dpi", type=int, default=150)
    ap.add_argument("--show", action="store_true",
                    help="open an interactive window (default: save only)")
    ap.add_argument("--groups", action="store_true",
                    help="print how the signals are grouped into panels and exit")
    args = ap.parse_args(argv)

    if not args.files:
        ap.error("at least one input file is required")

    missing = [str(p) for p in args.files if not p.is_file()]
    if missing:
        raise SystemExit("no such file: " + ", ".join(missing))

    if args.groups:
        for path in args.files:
            names, _ = read_txt(path)
            print(path)
            for group, idx in group_columns(names):
                print(f"  {group}: " + " ".join(names[i] for i in idx))
        return 0

    for path in args.files:
        plot_file(path, args.layout, args.out, args.show, args.dpi)
    return 0


if __name__ == "__main__":
    sys.exit(main())
