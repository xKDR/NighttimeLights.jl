# JOSS paper: *Foundations for nighttime lights data analysis*

Submission materials for the JOSS paper describing
[`NighttimeLights.jl`](https://github.com/xKDR/NighttimeLights.jl).

## Directory structure

Standard five-part layout. Each of `DATA`, `SRC`, `DOC` has its own
`Makefile`; the top-level `Makefile` recurses into them in
dependency order.

| Path | Contents |
|---|---|
| `Makefile` | Recurses `all` / `clean` / `squeaky` into `DATA`, `SRC`, `DOC`. |
| `DATA/` | Mumbai VIIRS dataset (monthly rasters from Google Earth Engine). |
| `SRC/` | `replication.ipynb` — cleans the cube and generates the paper's tables and figure (colab only). |
| `DOC/` | `paper.md`, `paper.bib`, figures, and the paper build (`make joss`). |
| `RESOURCES/` | `additional.bib` (symlink to `DOC/paper.bib`), `notes`, and `<key>.pdf` literature. |

## Build

```
make            # recurse DATA -> SRC -> DOC
make clean      # drop cheap intermediates
make squeaky    # drop everything except human-written files
```

The analysis (`SRC/replication.ipynb`) runs on **Google Colab** — two kernels
(Python for the Earth Engine download, Julia 1.12 for the cleaning) bridged
by Google Drive, with interactive Google auth and a manual runtime switch.

The part that actually builds from `make` is the paper:

```
cd DOC && make joss    # exact JOSS PDF via openjournals/inara (needs podman,
                       # or: make joss ENGINE=docker)
```

Results in the paper were produced with Julia 1.12.6 and
`NighttimeLights.jl` 0.9.1.
