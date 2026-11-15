# 03 · Real numbers cheat sheet

Use these instead of made-up numbers. The full table, with a source URL per row, is `../eda/tables/parametros_juego.csv`.

**Label every number in the game as one of:** **measurement** (from a NASA source), **calculation** (our math on a NASA source), or **game rule** (our design choice, e.g. how many points a choice costs).

## Communication delay

| What | Value | Source |
|---|---|---|
| Earth–Moon | 1.21–1.35 s **each way** (~2.6 s round trip) | Calculated from NASA NSSDCA Moon fact sheet |
| Earth–Mars | 3.04–22.32 min **each way** (~6–44 min round trip) | Calculated from NASA NSSDCA Mars fact sheet |
| NASA's own phrase | "up to 20 minutes one way" | NASA Human Research Program |

## Radiation (NASA sources only)

| What | Value | Source |
|---|---|---|
| Mars surface, daily | 0.67 mSv/day | Curiosity RAD (NASA/JPL, 2013) |
| Trip to Mars, daily | 1.8 mSv/day | Curiosity RAD, in transit |
| Around the Moon, inside Orion | 0.96–1.24 mSv/day | Artemis I, HERA (NASA; *Nature* 2024) |
| Orion storm shelter design cap | 150 mSv per event | Artemis I paper |
| NASA's storm example | 210–259 mSv without shelter, 65–68 mSv behind water bags and cargo | NASA OCHMO technical brief |
| Career limit | 600 mSv (a limit for a whole career, **not** a health bar) | NASA OCHMO |
| Scale for kids | 1 day on Mars ≈ 33 chest X-rays (0.02 mSv each) | NASA/JPL, 2013 |

**Careful:**
- Shielding works well against solar storms but barely against cosmic rays. Treat any percentage in the game as a **simplified game assumption**.
- A solar storm can harm people quickly, so never say radiation "isn't dangerous".

## Life support (per astronaut per day, NASA BVAD)

- **Oxygen:** 0.895 kg
- **Drinking water:** 2.0 kg (3.2 kg including food prep and exercise)
- **Food:** 0.8 kg dry, about 3,050 kcal

These are for an adult astronaut. Use them for the game's crew, **never as targets for the kids playing**.

## Mars and the Moon

- **Day length:** a Mars sol is 24 h 39 min, and a lunar day (sunrise to sunrise) is 29.5 Earth days.
- **Gravity:** Mars is 0.38 g and the Moon 0.165 g.
- **Sunlight:** Mars gets 43% of the sunlight Earth gets (586 vs 1,361 W/m²), so solar panels make less power.
- **Dust storms:** the 2018 global dust storm reached an opacity (tau) of 10.8 at Opportunity's site.
- **Power:** a Kilopower fission unit makes up to 10 kW of electricity.

## Crops (days from planting to harvest, NASA BVAD)

Radish 25 · lettuce 28 · spinach 30 · tomato 85 · beans 85 · chili 85 · potato 132.

## Crew health

- **Exercise:** ISS crews exercise about 2 hours a day (NASA).
- **Sleep:** 8.5 h scheduled, about 6.1 h actually slept on the ISS (Barger et al., *Lancet Neurology*, 2014).
- **Muscle (NASA OSDR, study OSD-342):** mice that spent ~33 days on the ISS came back with 18% less of a leg muscle (Lee et al., *PNAS* 2020). Mice don't exercise, so this isn't what a training crew loses.
- **Recovery is slow (OSDR, study OSD-540):** muscle lost in 10 days took 21 days of exercise to recover (young men on Earth, one leg rested).
- **Spacewalks:** ISS spacewalks last 5–8 hours, with at least 2 crew members.
