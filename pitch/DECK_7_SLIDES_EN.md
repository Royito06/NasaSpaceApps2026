# Submission deck: 7 slides, in English

Challenge: *Build a Junior Astronaut Mission Trainer* (NASA Space Apps 2026). Audience of the game: kids ages 7–12.
Updated 15 Nov 2026 for the **two-level build** (Moon, then Mars, with sol 31 carry-over), checked against `game/strings.gd` and `game/main.gd`. This is the outline for the **submission demo**: English, at most 7 slides counting the title (`JUDGING.md`). The 3-minute live pitch in Hermosillo can stay in Spanish (`pitch/PITCH.md`).

Fill in before building the slides: `[Team name]`, `[play URL]`, `[repo URL]`, and the team names/roles on slide 7. The title screen currently says "Junior Astronaut Mission Trainer", the challenge's own name. If the team picks a game name, put it on slide 1 and on the title screen together.

## What the demo contains (the slides claim only this)

- **A title screen and a mission select.** "Ages 7 to 12 · about 15 minutes". Level 2 unlocks after the Moon. English by default, with a Spanish toggle. Settings: voice, less motion, number-source tags.
- **A narrator briefing on each level.** Before the players act, it names each thing to manage, one line each, with an arrow on it. On the Moon: oxygen reserve and science. On Mars: power, oxygen and radiation.
- **Level 1, the Moon (a real mission: Apollo 15, 1971):**
  - **The setup.**
    - A "This really happened" card explains the walk-back rule: never drive farther than you could walk back with your suit's oxygen.
    - You drive the rover to one of two rock sites: a close site (2 km) or a far site (5 km), with the 5 km walk-back limit drawn.
  - **Asking Earth.** You ask Mission Control, and **the answer arrives in 2.6 seconds**.
  - **The trade-off.**
    - The far site has a rare white rock "like Apollo 15's Genesis Rock", but leaves **about 1 hour** of spare oxygen instead of **about 3**.
    - You can replay the other site (or skip the replay), then compare both trips. "No trip wins everything."
- **Level 2, Mars (a fictional outpost built on real Mars data):**
  - **Sol 30.**
    - **The roles.** Two roles each report one half of the picture: **Engineering** reports the power fault, **Protection** the storm and the shelter. Both reports appear on one shared screen.
    - **Asking Earth.** The players ask Earth. The answer needs 40 minutes and the storm arrives in 30, so **the crew decides alone**.
    - **The decision.**
      - There is one job: reinforce the shelter or repair the power.
      - The decision cards state the trade-off in words, not the outcome.
      - Both roles must vote for the same job.
      - The job is a short mini-task: stack water bags, or rewire plugs.
    - **The consequences.**
      - The storm hits and night falls.
      - **The oxygen tanks.** The crew breathes 2 tanks a sol. At night the oxygen machine fills 2 tanks with all four units on, 1 with one off, 0 with two off. Tanks are shown as 4 pips and as tanks in the room. Oxygen is **not a goal and cannot run out**; the goals are still power 75%+ and radiation 6 sols or less.
      - The next morning shows power, radiation in **sols of normal radiation**, the oxygen tanks, and the greenhouse lamp. With low power the lamp stays off.
    - **Replay and compare.** The players can replay the other job (after predicting more or less radiation), or skip it. They compare both plans, pick one, and get a crew debrief.
  - **Sol 31 ("Play the next sol").** **The plan the crew picked carries over.**
    - If they reinforced the shelter, the unit is still broken and another fails overnight: 50% power, and **3 oxygen tanks, not 4**.
    - If they repaired the power, one new fault is off: 75% power and 4 full tanks, but sol 30's 12.7 sols of radiation stay with the crew.
    - A small storm comes. The shelter is thin again each morning (game rule).
  - **Harvest day.** Six lettuces planted 28 days earlier. Each of the last 2 nights without the greenhouse lamp leaves 2 plants too small (game rule), so the harvest is 6, 4 or 2. "Power is food, too."
  - **Bonus sol: today's real Sun.**
    - It replays the sol 30 morning, but the terminal asks NASA DONKI again and the answer changes the mission.
    - Game rule: a solar particle event near Earth in the last 7 days counts as a storm today, sized like the biggest surge Curiosity measured. No event means no storm, and then repairing is the better job.
    - If NASA doesn't answer, the game uses the archived 10 Sept 2017 event and says so.
    - On 15 Nov 2026, DONKI listed no events in the last 60 days, so it played calm.
- **Free mission · 3 sols** (a yellow button under Mars, open once Mars is open). Different every time:
  - It follows the team's three-sol model (`eda/11_simulacion_balance.py`). It starts with all 4 units on and 4 tanks. Each sol one more unit may fail.
  - Each sol has a storm card: none, a small storm, or the big 20 May 2024 eruption. The storm cards are **real archived DONKI events, shown by date** (7 Mar 2012, 10 Sep 2017, 28 Oct 2021, 11 May 2024, 11 Nov 2025, 20 May 2024). The card says "Archived data. How much it adds at our base is a game rule."
  - There are three jobs: reinforce the shelter, repair the power, or **go out for the rock sample** (science on Mars: it costs 1 extra oxygen tank and gives no shielding).
  - There are three goals: the sample on board, radiation of 12 sols or less across the mission, and oxygen never below 1 tank.
  - A **mission report** ends the run: "Mission goals met" or "Mission strained" (never "you lose"), a log of the three sols, a tip, and "New mission". Oxygen can run short here: "the crew opened its emergency supply", and the oxygen goal is missed. Nobody dies.
  - A self-test of 300 free missions played with a simple rule a child can say ("Storm coming: shelter. Something broken: repair. Quiet sol: science.") met the goals in 274 (91%), close to the model's 89.3%.
- **An OSDR finding** on the mission report and the NASA data screen: mice that spent 33 days on the Space Station came back with 18% less of a calf muscle (NASA OSDR, study OSD-342). The data screen adds "These are mice, not astronauts." It also explains "microgravity".
- **The NASA terminal** (Moon and Mars):
  - In a browser, only the DONKI request is live: it shows the solar-particle events from the last 60 days. The Apollo 15 photo and the Curiosity image are saved NASA copies labelled "ARCHIVED", because NASA's image server blocks browser downloads, labelled "Fetched from NASA just now" with the time.
  - When it fails, it shows a labelled archived note. There is no saved photo offline.
  - The storm the crew trains with is always the **archived** 20 May 2024 event.
- **The "NASA data used" screen.** Every number carries a tag: Measurement, Calculation or Game rule.

**Never shown as done:**
- a crew wellbeing meter
- a classroom teacher card

**Never claim:**
- that each role sees private information (the reports are on one shared screen)
- that the game shows an Apollo photo offline
- that oxygen is a goal or can run out (it cannot fail in the game)
- that the bonus sol's storm size is real (it is a game rule)
- that DONKI events near Earth are storms at Mars (a game rule, and the game says so)
- that storm frequency or size at the Mars base is real (storms come about 26 times more often than in reality: a game rule, stated in the game)
- that the mice finding is about astronauts
- that every free mission can be won (about 1 in 10 cannot, and the game says so)

**No testing with children has happened.** Slide 6 says so and gives the plan. The build passes automated playthrough tests but has not yet been played by a person in a real browser, so play it yourselves before recording.

## The seven slides

### 1. Title

- **On the slide:** `[Game name]`. Drive on the Moon like Apollo 15, then survive a solar storm on Mars. Decide as a crew, before Earth's answer arrives.
- **Small print:** Challenge: Build a Junior Astronaut Mission Trainer · Ages 7–12 · `[Team name]`, Hermosillo, Mexico · Play it in the browser: `[play URL]`
- **Speaker note:** Name the challenge first. It runs in a browser, with no download and no account.
- **Figure:** the title screen (English), or the mission select with both levels.

### 2. The problem

- **On the slide:** Kids see posters and jargon. They rarely see the decisions.
- **Support line:** "A choice that saves power today might cost oxygen tomorrow." (official challenge text)
- **Speaker note:** Kids see a mission's outcome but never its trade-offs. The challenge asks for that, and both our levels are built on it. On Mars it plays out literally: a job that keeps power off today leaves fewer oxygen tanks tomorrow, and fewer lettuces at harvest.
- **Figure:** the Mars decision screen: two jobs, each with what it gains and what it costs.

### 3. One real mission, then one built on real Mars data

- **On the slide:** a two-column layout.

| Level 1 · The Moon (Apollo 15, 1971) | Level 2 · A Mars outpost (sols 30–31) |
|---|---|
| Drive the rover: close rocks, or the rare white rock far away | One job before the storm: reinforce the shelter, or repair the power |
| Watch two things: oxygen reserve and science | Watch three things: power, oxygen tanks and radiation |
| The far rock costs most of your spare oxygen | Each role reports half the picture, and both must agree |
| Mission Control answers in **2.6 seconds** | Earth's answer needs **40 minutes**, and the storm arrives in 30 |
| Compare both trips | Yesterday's plan carries into sol 31, then a harvest day |

- **Bottom line:** On the Moon, Earth can still help. On Mars, the crew decides alone.
- **Speaker note:** The Moon level teaches the trade-off with help close by. Mars takes the help away. That jump is the lesson.
- **Figure:** one screenshot per column: the rover with the 5 km walk-back line, and the two Mars roles at their consoles.

### 4. Every number is tagged: NASA measurement, calculation, or game rule

- **On the slide:** a four-row table.

| In the game | Where it comes from | Tag in the game |
|---|---|---|
| The 5 km line; 7 hours of suit oxygen | Apollo 15 Mission Report and Apollo Lunar Surface Journal: 5 km is the farthest Apollo 15 drove from its lander. Using it as the walk-back limit is a game rule | Measurement, and Game rule |
| The Mars storm | An eruption recorded by NASA DONKI on 20 May 2024, on the far side of the Sun. That day Curiosity measured its largest radiation surge on Mars (NASA JPL) | Measurement, archived |
| Radiation in "sols of normal radiation" | Curiosity RAD: one normal sol on Mars ≈ 0.69 mSv | Measurement |
| Earth's answer is too late | NASA NSSDCA Moon and Mars fact sheets, distance ÷ speed of light: 3 to 22 minutes each way to Mars; about 1.3 seconds each way to the Moon. The game's 40 minutes (2 × 20) is a game rule inside that range | Calculation, and Game rule |

- **Support line:** During play, the NASA terminal asks NASA DONKI live and labels the answer "Fetched from NASA just now". The Apollo 15 and Curiosity photos are saved NASA copies labelled "ARCHIVED" (browsers block live downloads from NASA's image server). On the bonus sol, today's DONKI answer decides whether a storm comes (game rule).
- **Optional fifth row** (if space allows): oxygen tanks · NASA BVAD: 0.895 kg of oxygen per crew member per day; one tank = half a sol for a crew of 4. The real oxygen machine is MOXIE, which made 122 g on Mars · Measurement and Calculation; the machine's fill rate is a game rule.
- **Speaker note:** Several numbers are game rules, and the game tags them that way: the shelter share, the goals (75% power, 6 sols), 50 minutes per rock, the science points, and counting Curiosity's 8.1 mGy as 8.1 mSv. The goals are not health limits.
- **Figure:** the "NASA data used" screen, or the terminal showing "Fetched from NASA just now". Optional inset: `eda/figures/fig_14_donki_storms.png` (English).

### 5. Why it's different: no answer always wins

- **On the slide:** The best choice depends on what both roles know, and on yesterday.
  - **Sol 30 (big storm, one unit off):** reinforcing the shelter meets both goals. Repairing leaves 12.7 sols of radiation against a goal of 6.
  - **Sol 31, after reinforcing (small storm, now two units off):** the unrepaired unit left the crew 3 oxygen tanks, not 4. Reinforcing again leaves power at 50% against a goal of 75%. Repairing meets both goals.
  - **Bonus sol, today's real Sun:** the same morning as sol 30, but NASA DONKI's answer today decides whether a storm comes (game rule). With no event, repairing wins.
  - **Free mission:** three sols, different every time, with storm cards from real DONKI events. A simple rule a child can say meets the goals about 9 times in 10.
- **Support line:** In NASA's Human Research Program ratings for Mars mission operations, **teamwork** and **operating without Earth** are two of the three human risks rated highest. This is an independent educational game inspired by NASA's expeditionary skills.
- **Speaker note:**
  - NASA rates these risks for adult astronauts. Practicing them in a kids' game is our idea, and NASA does not endorse the game.
  - Sol 30's winning job is sol 31's losing one. If the crew repaired on sol 30 instead, sol 31 starts at 75% and either job meets both goals.
  - The free mission plays the team's three-sol model. In 20,000 simulated missions of that model, no fixed plan wins (`eda/figures/fig_18`). The game's own self-test agrees: 274 of 300 missions met the goals with the child's rule.
  - About 1 in 10 free missions can't be won, and the game says so. Storms come about 26 times more often than in reality (game rule).
- **Figure:** a free-mission report (`deck_free_report`), or the sol 31 compare screen.

### 6. Impact in Hermosillo

- **On the slide:** Built in Hermosillo, in English and Spanish, with voice, touch controls and a less-motion setting. Testing with children is pending.
- **Support line:** The plan is to test in Hermosillo schools. The game already has the four steps:
  1. predict (more or less radiation?)
  2. choose together
  3. explain what you gave up
  4. live with it the next sol, and at the harvest
- **Speaker note:** We have no results yet and we say so. The test checks whether a child can explain the sacrifice, not whether they liked the game.
- **Figure:** a four-step strip using game screenshots: the predict prompt, the vote, the "What it cost" line, and sol 31's "Yesterday's choice is still with us".

### 7. Team and what's next

- **On the slide:** `[Team name]`: names and roles. Open source, built with Godot. Code and every data source: `[repo URL]`.
- **Next version:**
  - a longer campaign of sols
  - a crew wellbeing meter
  - a one-page teacher card
  - testing in Hermosillo schools
- **Speaker note:** Close on one sentence: on Mars, protecting your crew costs resources, so learn to decide as a team before Earth's answer arrives.
- **Figure:** a team photo and a QR code to `[play URL]`.

## Source for every number on the slides

| Slide | Number | Source | Status |
|---|---|---|---|
| 1, 3 | Ages 7–12 | Official challenge text (`CHALLENGE.md`) | Pasted from the challenge page |
| 2 | "A choice that saves power today might cost oxygen tomorrow" | Official challenge text | `CHALLENGE.md` |
| 3, 4 | 5 km walk-back limit (the farthest Apollo 15 drove from the lander); 7 h suit oxygen; ~10 km/h rover | Apollo 15 Mission Report; Apollo Lunar Surface Journal | `eda/tables/parametros_luna_apolo.csv`. The 2 km site, the 50 min per rock and the science points are game rules |
| 3 | Spare oxygen: about 3 h at the close site (3.1 h computed), about 1 h at the far site | Calculated in the game from the values above plus game rules | Calculation |
| 3 | Mission Control answers in 2.6 s | NASA NSSDCA Moon fact sheet: 1.21–1.35 s each way | Calculation |
| 3, 4 | Earth's answer in 40 min, storm in 30 | Game rule: 20 min each way, inside the real range of 3.04–22.32 min (NASA NSSDCA Mars fact sheet) | Game rule. Today it is about 11 min each way (JPL Horizons, `eda/tables/retraso_*`; not on the game's screen) |
| 4 | The 20 May 2024 eruption and Curiosity's surge | NASA DONKI (`game/data/donki_cme_2024-05-20.json`); NASA JPL news on Curiosity RAD and the May 2024 storms (image PIA26302) | Archived in the game |
| 4 | 0.69 mSv per normal sol on Mars | Curiosity RAD (NASA/JPL, 2013) | Measurement |
| 5 | Sol 30: 12.7 vs 4.5 sols; power 75 vs 100%. Sol 31 after reinforcing: 3.0 vs 1.6 sols; power 50 vs 75% | Calculated in the game: (0.69 + storm × shelter share) / 0.69. The sol 30 storm is 8.1 mGy measured by Curiosity on 20 May 2024; counting it as 8.1 mSv is a game rule. The sol 31 storm (1.38) is a game rule. The shelter share 0.3 is a game assumption | `game/main.gd` |
| 2, 4, 5 | 2 oxygen tanks breathed per sol; one tank = 1.79 kg = half a sol for 4 | NASA BVAD (NASA/TP-2015-218570 Rev 2), 0.895 kg O₂ per crew member per day, reference crew of 4 (Tables 3-1, 3-31) | Measurement and Calculation. The machine's fill rate (2/1/0 tanks) is a game rule |
| 4 | The real oxygen machine | NASA, "NASA's Oxygen-Generating Experiment MOXIE Completes Mars Mission", 6 Sept 2023: 122 g in total, up to 12 g/hour | Measurement; the game's production numbers are a game rule |
| 2, 6 | Lettuce: 28 days to harvest; six plants | NASA BVAD Table 4-89 (ground chambers); NASA, "Growing Plants in Space" (Veggie typically holds six plants) | Measurement. "2 plants too small per dark night" is a game rule |
| 5 | Two of the three risks rated highest | NASA Human Research Roadmap, Mars mission operations: team, Earth-independent operations, and food and nutrition, out of 21 active risks | `eda/tables/hrp_riesgos_clasificados.csv` |
| 5 | No fixed plan wins in 20,000 simulated missions; the child's rule meets the goals in 89.3% | The team's three-sol model, `eda/tables/balance.md`; the free mission implements it | Calculation. The game's self-test gave 274 of 300 (91%). Storm frequency is a game rule (~26× reality) |
| 5 | Free-mission storm cards | NASA DONKI events of 7 Mar 2012, 10 Sep 2017, 28 Oct 2021, 11 May 2024, 11 Nov 2025 and 20 May 2024 (`eda/tables/donki_mazo.csv`) | Archived measurement. What each adds at the base is a game rule |
| 4, 5 | Mice lost 18% of a calf muscle after 33 days on the Space Station | NASA Open Science Data Repository, study OSD-342 (`eda/tables/osdr_hallazgos.*`) | Measurement, in mice, not astronauts. A fact shown to the player, not a mechanic |
| 5 | NASA's expeditionary skills | R. Passmore, *Operational Psychology in Practice*, NTRS 20250011491 | A presentation, not a standard |

Extra numbers for questions only:

| Number | Source | Note |
|---|---|---|
| A shelter helps far more against solar-storm particles than against cosmic rays | NASA OCHMO-TB-020 Rev E (about 50% vs 7% on average) | The game's 0.3 share is simplified |
| NASA's career radiation limit is 600 mSv | NASA OCHMO-TB-020 | A career limit for adults; the game's bar shows exposure, not health |
| Real storm odds: ~3% per sol in an active solar year, 0.4% in a quiet one; 103 storms recorded since 2010 | NASA DONKI, `eda/tables/donki_*`, `fig_14` | Measurement and calculation |
| In Mexico, 34.6% of kids aged 10–14 are physically active (Sonora: 25.5%) | ENSANUT Continua 2022–2024 | Context only. It does not show the game improves health |

## Which award each slide serves

| Slide | Judging criterion | Award |
|---|---|---|
| 2 | Relevance | — |
| 3 | Validity (usable, user-friendly), Creativity | Art & Technology, Best Mission Concept |
| 4 | Relevance (NASA data as a core component) | Best Use of Data |
| 2 to 5, told as Moon → Mars | Presentation | Best Storytelling |
| 5 | Creativity | Most Inspirational |
| 6 | Impact | Local Impact |

## Before submitting

- **English everywhere.** Use only the English figures (fig_14–18), and English game screenshots. Don't link Spanish files from the submission page.
- **Seven slides at most,** counting the title. The tables above are notes, not slides.
- **Claim only what the demo has.** Check against the list at the top of this file, including the "Never claim" lines.
- **Don't call the data "live".**
  - Say "fetched from NASA during play" only for what the terminal shows.
  - The training storm is always "recorded by NASA DONKI on 20 May 2024, archived".
  - Use a terminal screenshot only if the request actually succeeded.
- **Each way vs round trip.** "3 to 22 minutes each way". The 40 minutes in the game is a round trip at 20 minutes each way, and it's a game rule.
- **A real mission vs real data.** Only the Moon level is a real mission. The Mars outpost is fictional, built on real Mars data.
- **Simplified, and said so.** The shelter share, the goals, and mGy counted as mSv are game rules. The bar shows exposure, not health.
- **No test results.** Slide 6 says testing is pending.
- **No endorsement.** The title screen already says "Independent student project. Not endorsed by NASA." No NASA logo.
- **Don't present a DONKI storm survival game as new.** PureFlow won with one in 2025 (`proyectos_similares_2025.md`). Lead with the Moon-to-Mars jump, the shared decision and the carry-over.
- **References field.** List every source above, plus:
  - Godot
  - the Kenney and KayKit kits
  - game-icons.net (CC BY 3.0)
  - the Atkinson Hyperlegible and Fredoka fonts (OFL)
  - NASA images PIA24264, PIA26302 and AS15-86-11603

  See `game/REFERENCES.md`.

## If the team submits a 30-second video instead

About 75 words of English voice-over, over a screen recording of the browser build:

| Time | On screen | Voice-over |
|---|---|---|
| 0–3 s | Title screen → mission select | "First the Moon, then Mars. Decide as a crew." |
| 3–11 s | The rover at the 5 km line; the "Earth answered in 2.6 seconds" note; the white rock | "On the Moon, like Apollo 15: the far rock is rare, but it costs your spare oxygen. Earth answers in seconds." |
| 11–22 s | Mars: the two consoles, the 40 vs 30 minute timeline, the vote, the storm | "On Mars, one job before a real solar storm. Each of you knows half the picture. Earth's answer comes too late." |
| 22–27 s | Sol 31: "Yesterday's choice is still with us"; then the "NASA data used" screen | "Yesterday's choice follows you. Every number says where it comes from." |
| 27–30 s | Title and `[play URL]` | "No answer always wins. Learn to decide as a team." |
