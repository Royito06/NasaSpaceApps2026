# Data analysis

Scripts, tables and figures behind the game's numbers. The game uses the results; the per-number sources are in [`../game/REFERENCES.md`](../game/REFERENCES.md) and [`../pitch/DECK_7_SLIDES_EN.md`](../pitch/DECK_7_SLIDES_EN.md) (section "Source for every number on the slides").

## Figures (English)

| Figure | What it shows |
|---|---|
| `figures/fig_14_donki_storms.png` | Solar particle storms recorded by NASA DONKI, 2010–2026, and the chance of at least one storm in a stay on Mars |
| `figures/fig_15_mars_delay_timeline.png` | Earth–Mars one-way signal delay, 2026–2035 (JPL Horizons) |
| `figures/fig_16_radiation_budget.png` | Radiation over a short stay: normal sols vs one storm, with and without a shelter |
| `figures/fig_17_power_vs_dust.png` | Base power vs dust (design model) |
| `figures/fig_18_no_dominant_choice.png` | 20,000 simulated three-sol missions: no fixed plan meets the goals; sharing both roles' information does in 89.3% |

## Key numbers

- **NASA DONKI:** 103 solar particle storms, 2010–2026. Over 30 sols, the chance of at least one is about 60% in an active solar year and 8% in a quiet one.
- **Signal delay:** 11.0 minutes each way to Mars today; 3.2 to 22.2 minutes over 2026–2035.
- **NASA Human Research Program:** of 21 active risks, three are rated highest (5×5) for Mars: team, Earth-independent operations, and food and nutrition.
- **NASA OSDR:** of 577 studies, the most-studied topics are immune system (213), bone (115) and muscle (105). Study OSD-342: mice lost 18% of a calf muscle after 33 days on the Space Station.
- **Mexico:** 34.6% of kids aged 10–14 are physically active and 80.5% spend more than 2 hours a day on screens (ENSANUT 2022–2024); 30% of students reach basic level in PISA 2025 mathematics vs 65% in the OECD.

## Scripts and tables

`00_`–`07_*.py` download the data and build every table in `tables/` (`common.py` holds shared helpers; `../scripts/fetch_data.py` re-downloads the raw files). Some file and column names are short Spanish abbreviations from the team's working notes; for example `astro_` = astronauts, `mexico_` = Mexico context, `osdr_` = OSDR studies, `hrp_` = NASA Human Research Program risks, `parametros_juego` = game parameters. Every value in `tables/parametros_juego.csv` carries its source URL.
