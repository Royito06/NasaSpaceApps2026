# Submission deck: 7 slides, in English

Challenge: *Build a Junior Astronaut Mission Trainer* (NASA Space Apps 2026). Audience of the game: kids ages 7–12.
Written 14 Nov 2026. This is the outline for the **submission demo**, which must be in English and at most 7 slides, title included (`JUDGING.md`). The 3-minute live pitch in Hermosillo can stay in Spanish (`pitch/PITCH.md`).

Fill in the three placeholders before building the slides: `[Game name]`, `[Team name]` and `[play URL]`.

## The seven slides

### 1. Title

- **On the slide:** `[Game name]`: run a base on the Moon, then on Mars. Every choice costs something.
- **Small print:** Challenge: Build a Junior Astronaut Mission Trainer · Ages 7–12 · `[Team name]`, Hermosillo, Mexico · Play it: `[play URL]`
- **Speaker note:** Name the challenge first, then say it runs in a browser with no download and no account.
- **Figure:** title screen of the game with the English interface.

### 2. The problem

- **On the slide:** Kids see posters or jargon. They rarely see the decisions.
- **Support line:** "A choice that saves power today might cost oxygen tomorrow." (official challenge text)
- **Speaker note:** This is the challenge's own problem: space content for kids is either too abstract or too technical, so they see a mission's outcome and never its trade-offs.
- **Figure:** one decision card from the game, showing two options and what each one costs.

### 3. Solution and demo

- **On the slide:** A browser game where kids run a crew.
  - Moon tutorial: Earth answers in about a second.
  - Mars mission: the answer comes minutes late, so the crew decides alone.
  - Three resources on screen (life support, power, shielding) plus one crew meter. No free choices.
- **Speaker note:** Show three screenshots in order and point at the "Advance" button: the player sets the pace, and events change between runs.
- **Figure:** three game screenshots: Moon tutorial, Mars dashboard, a decision screen.

### 4. The trade-offs, with real NASA data

- **On the slide:** a four-row table.

| The choice | What it costs | The real data behind it |
|---|---|---|
| Shelter from a solar storm | Tonight's power | A storm recorded in NASA's DONKI database. Shielding cuts a solar storm's dose by about 50%, but cosmic-ray dose by only about 7% |
| Call Earth or act now | Time | Up to 20 minutes one way to Mars |
| Skip the crew's sleep to finish a repair | Tomorrow's repair | Astronauts are scheduled 8.5 hours of sleep and get about 6 |
| Stretch life support | Oxygen and water | 0.895 kg of oxygen and about 3.2 kg of drinking and food water per crew member per day |

- **Speaker note:** Every physical number is listed on the in-game "NASA data used" screen with its source; how fast a meter drops is our design.
- **Figure:** screenshot of the "NASA data used" screen next to the table.

### 5. Why it's different: the crew and the delay

- **On the slide:** For a Mars mission, NASA gives its highest human-risk rating to only 3 of 21 active risks: teamwork, operating without Earth, and food. All three are playable here.
- **Support line:** Roles with split information, a commander who rotates, and a three-question debrief. We practice, in miniature, what NASA trains its crews to do.
- **Speaker note:** NASA rates these risks for adult astronauts; practicing them in a kids' game is our idea, and NASA does not endorse the game.
- **Figure:** `eda/figures/fig_08_riesgos_hrp.png` redrawn in English, with the three top bars highlighted.

### 6. Impact in Hermosillo

- **On the slide:** In Mexico, only 1 in 3 children ages 10–14 is physically active. The estimate for Sonora is 1 in 4.
- **Support line:** 36.6% of children ages 5–11 have overweight or obesity. So the crew's wellbeing is a resource in the game, and between sols the game invites a one-minute break to move, drink water or rest.
- **Speaker note:** We test with local kids and ask two things: would you play again, and did you notice that every choice costs something? Say "the estimate for Sonora", never "Sonora is worse".
- **Figure:** the left panel of `eda/figures/fig_13_mexico_contexto.png` redrawn in English (the bars with their confidence intervals).

### 7. Team and what's next

- **On the slide:** `[Team name]`: names and roles. Open source, built with Godot. Repository and data sources: `[repo URL]`.
- **Next steps:** playtests in Hermosillo schools, more missions and events, a one-page teacher guide.
- **Speaker note:** Close on the idea in one line: every choice costs something, and the crew is part of the mission.
- **Figure:** team photo and a QR code to `[play URL]`.

## Source for every number on the slides

| Slide | Number | Source | Status |
|---|---|---|---|
| 1, 3 | Ages 7–12 | Official challenge text (`CHALLENGE.md`) | Pasted by the team from the challenge page |
| 2 | "A choice that saves power today might cost oxygen tomorrow" | Official challenge text | `CHALLENGE.md` |
| 3 | Earth answers the Moon in about a second (1.2 to 1.4 s) | Calculated from the Earth–Moon distance in NASA's Moon Fact Sheet | `eda/tables/parametros_juego.csv` |
| 4 | Shielding: about 50% for solar-storm particles, about 7% for cosmic rays | NASA OCHMO Technical Brief OCHMO-TB-020, Rev E | Opened 14 Nov 2026 |
| 4 | Up to 20 minutes one way to Mars | NASA Human Research Program, "Hazard: Distance from Earth" | Opened 14 Nov 2026 |
| 4 | 8.5 hours scheduled, about 6 slept | Barger et al. 2014, *Lancet Neurology* 13(9):904–912 (study of shuttle and ISS crews) | Opened 14 Nov 2026 |
| 4 | 0.895 kg oxygen and 3.2 kg potable water per crew member per day | NASA Life Support Baseline Values and Assumptions Document, NASA/TP-2015-218570 Rev 2, Table 3-31 | Opened 14 Nov 2026. Values are for an 82 kg adult astronaut |
| 5 | 3 of 21 active risks rated 5×5 for Mars | NASA Human Research Roadmap, read 14 Nov 2026 | Team table `eda/tables/hrp_riesgos_clasificados.csv` |
| 5 | "What NASA trains its crews to do" | R. Passmore, *Operational Psychology in Practice: NASA's Behavioral Health and Performance Operations Overview*, NTRS 20250011491 | Opened 14 Nov 2026. A presentation, not a standard |
| 6 | 1 in 3 physically active (34.6%), ages 10–14; Sonora estimate 25.5% | ENSANUT Continua 2022–2024, Shamah-Levy et al., *Salud Pública de México* 2025;67(suppl 1):s3–s219 | Checked by the team against the INSP PDF. Sonora's interval (18.1 to 34.7, 77 children) overlaps the national one |
| 6 | 36.6% with overweight or obesity, ages 5–11 | ENSANUT Continua 2020–2024, Shamah-Levy et al., *Salud Pública de México* 2025;67(6):609–621 | Checked by the team |

Extra numbers for questions, all from NASA missions:

| Number | Source | Status |
|---|---|---|
| Radiation on Mars: 0.67 mSv per day on the surface, 1.8 in transit | NASA/JPL releases of 9 Dec 2013 and 30 May 2013 (Curiosity's RAD instrument) | Opened 14 Nov 2026 |
| Around the Moon, inside Orion: 0.96 to 1.24 mSv per day | NASA's Artemis I mission (2022), HERA sensors. George et al. 2024, *Nature* 634:48–52 | Opened 14 Nov 2026. Measured inside the spacecraft, not on the surface |
| NASA's career radiation limit: 600 mSv | NASA OCHMO Technical Brief OCHMO-TB-020 | Opened 14 Nov 2026 |

## Which award each slide serves

| Slide | Judging criterion | Award |
|---|---|---|
| 2 | Relevance | — |
| 3 | Validity (usable and user-friendly), Presentation | Art & Technology |
| 4 | Relevance (NASA data as a core component) | Best Use of Data |
| 2 to 5, as one story from the Moon to Mars | Presentation | Best Storytelling |
| 5 | Creativity | Most Inspirational |
| 6 | Impact | Local Impact |

## Before submitting

- **English everywhere.** The figures in `eda/figures/` have Spanish text and must be redrawn in English. Game screenshots need the English interface. Any Spanish file linked from the submission page breaks the rule.
- **Seven slides at most**, counting the title. The tables above are notes, not slides.
- **Say only what the build does.** The DONKI storm, the replay variety and the "NASA data used" screen stay on the slides only if they are in the playable build.
- **Archived, not live.** If the game uses the bundled storm data, the slide says "a storm recorded in NASA's DONKI database", never "live".
- **Balance is ours.** The slides say "the physical numbers are real NASA data", not "everything is NASA data".
- **No endorsement.** NASA's name appears only as the source of data and of the challenge.
- **References field.** Every source in the tables above goes into the submission's References field, together with the game's code libraries, art and sound.
- **Still to confirm by the team:** NASA's DONKI database is named on slide 4 because the build plan uses it; this outline's author did not open DONKI.

## If the team submits a 30-second video instead

About 75 words, in English:

> Kids learn about space from posters. They rarely see the hard choices. In `[Game name]`, children ages seven to twelve run a base, first on the Moon, then on Mars, where Earth takes up to twenty minutes to answer. Every choice costs something: sheltering from a solar storm costs tonight's power. The physical numbers are real NASA data. And the crew is a resource too: it has to sleep, eat well and decide together.
