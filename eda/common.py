"""Shared helpers for the EDA scripts (stdlib + numpy + matplotlib only, no pandas needed).

Run any script with system python3 or nasa/.venv/bin/python:
    python3 eda/01_astronautas.py
"""
import csv, statistics
from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "data" / "raw"
TABLES = ROOT / "eda" / "tables"
FIGS = ROOT / "eda" / "figures"
TABLES.mkdir(parents=True, exist_ok=True)
FIGS.mkdir(parents=True, exist_ok=True)

# Palette (validated categorical order: blue, orange, aqua, yellow, magenta, green, violet, red)
SURFACE = "#fcfcfb"
INK = "#0b0b0b"
INK2 = "#52514e"
MUTED = "#8a8983"
GRID = "#e4e3df"
C = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300", "#6250d6", "#e34948"]
BLUE, ORANGE, AQUA, YELLOW, MAGENTA, GREEN, VIOLET, RED = C
GRAY = "#b5b4ae"

plt.rcParams.update({
    "figure.facecolor": SURFACE, "axes.facecolor": SURFACE, "savefig.facecolor": SURFACE,
    "font.family": "DejaVu Sans", "font.size": 13,
    "text.color": INK, "axes.labelcolor": INK2, "xtick.color": INK2, "ytick.color": INK2,
    "axes.edgecolor": GRID, "axes.spines.top": False, "axes.spines.right": False,
    "axes.grid": True, "grid.color": GRID, "grid.linewidth": 0.8, "axes.axisbelow": True,
    "axes.titlesize": 13, "axes.titleweight": "bold", "axes.titlelocation": "left",
    "legend.frameon": False, "lines.linewidth": 2.2, "lines.markersize": 7,
})


def read_csv(path):
    with open(path, newline="", encoding="utf-8", errors="replace") as f:
        return list(csv.DictReader(f))


def write_csv(name, rows, fields=None):
    """Write a list of dicts to eda/tables/<name>."""
    p = TABLES / name
    if not rows:
        p.write_text("")
        return p
    fields = fields or list(rows[0].keys())
    with open(p, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)
    return p


def fig_ax(ncols=1, nrows=1, figsize=(12, 6.75), **kw):
    """16:9 figure; at dpi=160 this is 1920x1080 px."""
    fig, ax = plt.subplots(nrows, ncols, figsize=figsize, **kw)
    return fig, ax


def finish(fig, name, title, subtitle=None, source=None, top=None, bottom=0.13, left=0.07, right=0.97, **adj):
    """Takeaway title (bold, left, wrapped), subtitle, source line; save PNG 1920 px wide."""
    import textwrap
    tl = textwrap.wrap(title, 70)
    sl = textwrap.wrap(subtitle, 128) if subtitle else []
    y = 0.972
    fig.text(0.03, y, "\n".join(tl), fontsize=19, fontweight="bold", color=INK, va="top", ha="left", linespacing=1.15)
    y -= 0.052 * len(tl) + 0.012
    if sl:
        fig.text(0.03, y, "\n".join(sl), fontsize=12, color=INK2, va="top", ha="left", linespacing=1.25)
        y -= 0.033 * len(sl) + 0.012
    fig.subplots_adjust(top=(top if top is not None else y - 0.07), bottom=bottom, left=left, right=right, **adj)
    if source:
        fig.text(0.03, 0.022, "Fuente: " + source, fontsize=9.5, color=MUTED, va="bottom", ha="left")
    p = FIGS / name
    fig.savefig(p, dpi=160)
    plt.close(fig)
    print("  figura:", p.relative_to(ROOT))
    return p


def median(xs):
    return statistics.median(xs) if xs else float("nan")


def quantile(xs, q):
    xs = sorted(xs)
    if not xs:
        return float("nan")
    k = (len(xs) - 1) * q
    f = int(k)
    c = min(f + 1, len(xs) - 1)
    return xs[f] + (xs[c] - xs[f]) * (k - f)


def pct(a, b):
    return 100.0 * a / b if b else float("nan")


def es(x, nd=1):
    """Number formatted the Mexican way (decimal point, thousands comma)."""
    return f"{x:,.{nd}f}"
