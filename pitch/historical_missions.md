# Real missions behind the Junior Astronaut Mission Trainer

A verified list of missions for the English video, not a script. Every mission below was checked on 14 Nov 2026 against the sources listed under it. Each source was actually opened. The target audience is kids aged **7 to 12** (official challenge text: [`../CHALLENGE.md`](../CHALLENGE.md)).

- **Mechanics** use the names in [`eda/riesgos_a_mecanicas.md`](../eda/riesgos_a_mecanicas.md):
  - **M1**: Earth–Mars delay and procedure card
  - **M2**: roles and debrief
  - **M3**: menu and greenhouse
  - **M4**: crew meters (rest, mood, fitness) and sol planner
  - **M5**: solar storm (shielding and dose)
  - **M6**: crew pause
  - **Moon tutorial**: the practice level on the Moon
  - **Base power**: the challenge's power resource
- **⚠ UNVERIFIED** marks anything we could not confirm in a source we opened. Do not say it on camera without checking it first.
- **Quotes** in "quotation marks" are copied from the source.

## Video spine (30 s)

The judging guide caps the demo video at **30 seconds** (`JUDGING.md`). It has to be in English, or spoken in Spanish **with English subtitles**. Two missions, each followed right away by the gameplay moment it inspires. Everything after this section is background.

| Time | On screen | Voice-over or caption |
|---|---|---|
| 0–4 s | Title card | "Real missions give us the constraints." |
| 4–14 s | **NASA CHAPEA** footage or still, labeled *"Year-long Mars simulation, on Earth (NASA Johnson)"* → **gameplay:** Earth's advice arrives after the decision window, so Engineering (sees the power repair) and Protection (sees the storm and shelter) combine what each one sees and agree on the one shared work slot. | "In NASA's year-long Mars simulation on Earth, messages took up to 22 minutes each way. In our game, Earth's advice arrives too late, so two crew members must agree on their own." |
| 14–24 s | **Curiosity RAD** still, labeled *"Curiosity measured radiation on the way to Mars"* → **gameplay:** an archived NASA DONKI solar storm (label it "archived", never "live"); reinforcing the shelter costs tonight's power, and the exposure bar rises less than with the other choice. | "Curiosity measured the radiation a Mars crew would face. In our game, protecting the crew costs tonight's power, and players see their exposure change." |
| 24–30 s | Gameplay montage, end card with the game URL | "Our game turns them into decisions children can explain." |

- **Alternative closing line:** "Real missions set the limits. Our game turns them into choices kids can explain."
- **What the build is.** A minimal demo: one Mars room, two roles with split information (Engineering: power repair; Protection: storm and shelter), one decision for one shared work slot (reinforce shelter or repair power), one archived DONKI storm, a power bar and an exposure bar, a retry with the other choice, a debrief, and a "NASA data used" screen. The Moon appears only as a 10-second comparison card. There is no food production and no separate "Call Earth" button, so the video shows neither.
- **No kid testing has happened before submission.** The video must not show or imply children playing it or say "kids learned". Use "players", and keep "children can explain" as the design goal, not a result.
- **Say "simulation on Earth" for CHAPEA every time.** Nobody has been to Mars; CHAPEA volunteers lived in a habitat in Houston.
- **Only show or claim what is implemented in the build.** If the late advice, the two roles or the exposure bar are not working yet, cut that beat; don't mock it up as gameplay.
- **Delay wording.** Always say "each way" (one-way) or "round trip". Moon: about 1.2 to 1.4 seconds each way (~2.6 s round trip). Mars: about 3 to 22 minutes each way (~6 to 45 minutes round trip; NASA's CHAPEA used "up to 44 minutes round trip"). NASA's own short phrase is "up to 20 minutes one way".

## Story order (background, not the 30-second video)

1. **The Moon, then and now:** Apollo 13 (1970), then Artemis I (2022) and Artemis II (2026).
2. **Learning to live in space:** Skylab 4 (1973–74), Rodolfo Neri Vela (1985), José Hernández (2009), the Twins Study (one-year mission) and Veggie (ISS gardens).
3. **Getting ready for Mars:** Curiosity's radiation detector (2011–12), Opportunity and the 2018 dust storm, Mars-500 (520 days on the ground) and NASA's CHAPEA missions (2023–24 and 2025–26).
4. **Closing:** what comes next for Artemis.

A natural bridge from part 1 into part 2 is the dummy in Artemis I's commander's seat. It was named after Arturo Campos, an engineer who helped bring the Apollo 13 crew home.

---

## Part 1. The Moon, then and now

### 1. Apollo 13

- **Dates.** Launched 11 April 1970; splashed down 17 April 1970.
- **What happened.** After an oxygen tank exploded on the way to the Moon, the crew used the lunar module as a lifeboat. When its CO2 filters began to run out, they built a makeshift CO2 filter: they sealed square command-module cartridges with a plastic bag and tape and connected them to hoses. The ground team "assembled and tested" the setup on Earth before the crew used it.
- **Game mechanic.** M1, the procedure card: the crew follows a tested, step-by-step fix under pressure. M2: the solution came from crew and ground working together. Contrast for a longer video: Apollo 13 could talk to Houston in near real time. On Mars, each message takes up to 20 minutes one way (NASA), which is exactly what M1 teaches.
- **Why it matters for kids' skills.** Staying calm, reading every instruction, and solving a problem as a team with what you have.
- **Sources.**
  - NASA, *Apollo 13 Mission Report*, MSC-02680 (Sept 1970), section on CO2 removal: https://ntrs.nasa.gov/api/citations/19710003598/downloads/19710003598.pdf
  - NASA mission page: https://www.nasa.gov/mission/apollo-13/
  - NASA NTRS, "13 Things That Saved Apollo 13" (2012): https://ntrs.nasa.gov/api/citations/20120008636/downloads/20120008636.pdf
- **Careful.** The report describes the setup, not the famous "square peg in a round hole" line. Don't quote that line as if NASA said it.

### 2. Artemis I

- **Dates.** Launched 16 November 2022; splashed down 11 December 2022 (25 days, 10 hours, 53 minutes).
- **What happened.** An uncrewed Orion spacecraft flew around the Moon and back, carrying radiation detectors and stand-in "crew". "Commander Moonikin Campos" was a dummy in a spacesuit, named after Arturo Campos, an engineer whose work helped save Apollo 13. Two dummy torsos, Helga and Zohar, flew for the Matroshka AstroRad Radiation Experiment: Zohar wore a radiation-protection vest and Helga did not. Orion carried 5,600 passive sensors and 34 active radiation detectors.
- **Findings we can cite.**
  - *Nature* (2024): dose rates differed fourfold between more and less shielded spots inside the capsule. Turning the spacecraft during a radiation-belt pass cut dose rates by about 50%.
  - *Science Advances* (2026): the AstroRad vest was estimated to reduce effective dose by about 60% for a storm like the one in August 1972.
- **Game mechanic.** M5: where you shelter and how much shielding you build changes your dose. Moon tutorial: the first test flight around the Moon.
- **Why it matters for kids' skills.** Protecting yourself from something you cannot feel. That links to the shade-and-sunscreen analogy in M5. Keep the caveat: UV light and space radiation are different things.
- **Sources.**
  - NASA mission page: https://www.nasa.gov/mission/artemis-i/
  - George et al., "Space radiation measurements during the Artemis I lunar mission", *Nature* 634:48–52 (2024), doi:10.1038/s41586-024-07927-7 (abstract via PubMed 39294379)
  - Houri et al., "First evaluation of wearable radiation protection for human deep space exploration, as flown on Artemis I", *Science Advances* 12(33):eadz1892 (2026), doi:10.1126/sciadv.adz1892 (abstract via PubMed 42585337)
- **Careful.** The vest result is extrapolated from radiation-belt measurements, not measured during a real solar storm. Several authors work for StemRad, the company that makes the vest; the paper declares this conflict of interest.

### 3. Artemis II

- **Dates.** Launched 1 April 2026; splashed down 10 April 2026 off San Diego.
- **What happened.** NASA astronauts Reid Wiseman, Victor Glover and Christina Koch, with Canadian Space Agency astronaut Jeremy Hansen, flew around the Moon. NASA calls it its "first crewed lunar flyby in 50 years" and says the crew set the record for the farthest humans have traveled from Earth. It was the first time astronauts flew aboard Orion.
- **Game mechanic.** Moon comparison card (10 s in the minimal demo): on the Moon, Earth answers almost instantly, about 1.2 to 1.4 seconds each way (~2.6 s round trip) per `parametros_juego.csv`, unlike Mars.
- **Why it matters for kids' skills.** Today's 7- to 12-year-olds are the first generation to grow up while people are going back to the Moon.
- **Sources.**
  - NASA mission page: https://www.nasa.gov/mission/artemis-ii/
  - NASA, "Rigorous Analysis Confirms NASA's Artemis II Heat Shield Performance" (15 Oct 2026), for the splashdown date: https://www.nasa.gov/missions/artemis/artemis-2/rigorous-analysis-confirms-nasas-artemis-ii-heat-shield-performance/
  - NASA, "CHAPEA Mission 2 Crew Reflects After 378 Days on Simulated Mars" (Nov 2026), for the distance record: https://www.nasa.gov/centers-and-facilities/johnson/chapea-mission-2-crew-reflects-after-378-days-on-simulated-mars/
- **Careful.** We did not open a page giving the record distance in miles. Say "farthest humans have ever traveled", without a number.

---

## Part 2. Learning to live in space

### 4. Skylab 4

- **Dates.** Launched 16 November 1973; undocked and splashed down 8 February 1974 (84 days, a record at the time).
- **What happened.** Gerald Carr, Edward Gibson and William Pogue reported making mistakes and feeling rushed by a packed schedule. Planners kept trying to bring them up to the previous crew's pace. On 28 December Carr recorded a message asking Mission Control for "straight words". On 30 December crew and ground held an open discussion about exercise time, free time and the workload. Carr later said: "We swallowed a lot of problems for a lot of days because we were reluctant to admit publicly that we were not getting things done right… That's ridiculous, [but] that's human behavior."
- **Game mechanic.** M4, the sol planner: an overloaded schedule raises errors, and the crew needs exercise, rest and free time. M2, the debrief: say early and honestly what isn't working. M6: protected downtime.
- **Why it matters for kids' skills.** Asking for help early and planning rest are skills, not weaknesses.
- **Sources.**
  - NASA mission page: https://www.nasa.gov/mission/skylab-4/
  - Compton and Benson, *Living and Working in Space: A History of Skylab*, NASA SP-4208 (1983), chapter "The Last Mission": https://ntrs.nasa.gov/citations/19840017669 (PDF: https://ntrs.nasa.gov/api/citations/19840017669/downloads/19840017669.pdf)
- **Careful.** This is often called the "Skylab strike" or "mutiny". The NASA history we read describes complaints and a frank discussion, not a strike. Don't use those words.

### 5. STS-61-B: Rodolfo Neri Vela (not in main video)

- **Dates.** Launched 26 November 1985 aboard Space Shuttle Atlantis (6 days, 21 hours).
- **What happened.** Neri Vela flew as a payload specialist on a mission that deployed Mexico's MORELOS-B communications satellite. NASA history pages say he asked for tortillas in his food supply, "introduced tortillas to space menus, and they have remained favorites among astronauts ever since". He also shared the first Thanksgiving dinner aboard a space shuttle.
- **Game mechanic.** M3, menu: the food you bring matters for morale and practicality. Also a Mexican role model for the crew characters.
- **Why it matters for kids' skills.** Someone from Mexico has already flown, and brought a bit of home with him.
- **Sources.**
  - NASA mission page: https://www.nasa.gov/mission/sts-61b/
  - NASA, "Thanksgiving Celebrations in Space": https://www.nasa.gov/history/thanksgiving-celebrations-in-space/
  - NASA, "Estación Espacial 20th: Mes del Patrimonio Hispano": https://www.nasa.gov/history/estaci%c3%b3n-espacial-20th-mes-del-patrimonio-hispano/
- **Context from our EDA.** In our astronaut dataset (flights 1961–2019), Neri Vela is the only person listed with a Mexican flag (`eda/FINDINGS.md`, finding 7).

### 6. STS-128: José Hernández (not in main video)

- **Dates.** Launched 28 August 2009 aboard Space Shuttle Discovery (13 days, 20 hours, 53 minutes).
- **What happened.** Hernández flew as a mission specialist on a space-station assembly flight. Discovery carried the Leonardo module with life-support and science racks.
- **Game mechanic.** Role model for the crew characters. Life-support racks are a nice link to the challenge's life-support resource.
- **Why it matters for kids' skills.** Persistence. ⚠ UNVERIFIED: his personal story, a Mexican-American son of migrant farmworkers who applied many times before being selected, is widely told, but we did not open a source for it. Confirm on NASA's biography page before saying it.
- **Sources.** NASA mission page (crew list, dates, payload): https://www.nasa.gov/mission/sts-128/
- **Careful.** Our dataset lists him under the U.S. flag. Describe him as "Mexican-American" only after confirming it.

### 7. The Twins Study (Scott Kelly's year in space) (not in main video)

- **Dates.** A one-year mission aboard the International Space Station. ⚠ UNVERIFIED: the exact dates (commonly given as March 2015 – March 2016) were not on the pages we opened. The main paper was published 12 April 2019.
- **What happened.** NASA compared astronaut Scott Kelly in space with his identical twin, Mark Kelly, on Earth, using ten research teams. Changes seen with spaceflight included lower body mass, telomere changes, eye-structure changes, gut-microbe changes and "some cognitive decline postflight". Most measures returned to near pre-flight levels within 6 months, but some did not. NASA notes that for nearly a year Scott Kelly came into contact with only 12 people.
- **Game mechanic.** M4, crew meters: a long stay changes the body and the mind, and a crew's condition is a resource you manage.
- **Why it matters for kids' skills.** Health is something you look after every day, and recovery takes time.
- **Sources.**
  - NASA Twins Study page: https://www.nasa.gov/humans-in-space/twins-study/
  - Garrett-Bakelman et al., "The NASA Twins Study: A multidimensional analysis of a year-long human spaceflight", *Science* 364(6436):eaau8650 (2019), doi:10.1126/science.aau8650 (abstract via PubMed 30975860)
- **Careful.** The study had one person in space. It shows what can change, not what happens to everyone.

### 8. Veggie: growing lettuce on the space station

- **Dates.** ⚠ UNVERIFIED: the first time astronauts ate Veggie-grown lettuce, often given as August 2015, was not in any source we opened. Verified: NASA reported a third red romaine lettuce crop (Veg-03) planted by astronaut Shane Kimbrough in October 2016.
- **What happened.** Veggie is "a simple, low-power chamber that can hold six plants". Seeds grow in small fabric "pillows" that crew members water by hand. A peer-reviewed analysis of red romaine lettuce grown in Veggie on the ISS found the plants were "safe, edible, fresh food to supplement" astronauts' diets. NASA has since grown other lettuces, mizuna mustard, tomatoes and radishes.
- **Game mechanic.** M3, greenhouse: fresh food takes time to grow, so you plant early.
- **Why it matters for kids' skills.** Planning ahead, caring for something living, and trying new vegetables.
- **Sources.**
  - NASA, "Station Science 101: Plant Research" (Oct 2023): https://www.nasa.gov/missions/station/ways-the-international-space-station-helps-us-study-plant-growth-in-space/
  - NASA, "Third Lettuce Crop Begins Growing Aboard Station" (Oct 2016): https://www.nasa.gov/missions/station/third-lettuce-crop-begins-growing-aboard-station/
  - Khodadad et al., "Microbiological and Nutritional Analysis of Lettuce Crops Grown on the International Space Station", *Frontiers in Plant Science* 11:199 (2020), doi:10.3389/fpls.2020.00199 (abstract via PubMed 32210992)
- **Bonus.** The NASA plant page mentions "Growing Beyond Earth" (with Fairchild Botanical Garden, started 2015), in which middle- and high-school classes grow test crops for NASA. It's a good "kids already help NASA" line.

---

## Part 3. Getting ready for Mars

### 9. Curiosity's Radiation Assessment Detector (RAD)

- **Dates.** Launched 26 November 2011; RAD measured radiation during most of the 253-day, 560-million-km cruise, then on the surface of Mars.
- **What happened.** For the first time, an instrument measured radiation inside a spacecraft on the way to Mars. The cruise data found that even the shortest round trip with current propulsion and similar shielding would give a dose equivalent of about 0.66 sievert. A 2014 paper reported the first measurements of Mars' surface radiation environment.
- **Game mechanic.** M5, dose bar: radiation adds up slowly every day, with spikes during solar storms.
- **Why it matters for kids' skills.** Long-term thinking: small daily amounts add up.
- **Sources.**
  - Zeitlin et al., "Measurements of energetic particle radiation in transit to Mars on the Mars Science Laboratory", *Science* 340(6136):1080–1084 (2013), doi:10.1126/science.1235989 (abstract via PubMed 23723233)
  - Hassler et al., "Mars' surface radiation environment measured with the Mars Science Laboratory's Curiosity rover", *Science* 343(6169):1244797 (2014), doi:10.1126/science.1244797 (PubMed 24324275; we read the metadata, not the full abstract)
- **Careful.** The JPL press releases cited in `parametros_juego.csv` returned "403 Forbidden" when we tried to reopen them, so we cite the papers here. Don't put 0.66 Sv on screen without explaining what a sievert is; better to show the game's dose bar.

### 10. Opportunity and the 2018 dust storm

- **Dates.** Landed January 2004; last communication 10 June 2018; NASA declared the end of the mission on 13 February 2019.
- **What happened.** The solar-powered rover worked on Mars for almost 15 years and drove 28.06 miles (45.16 km). That was an off-world record until Perseverance passed it on 11 October 2026. Then "a severe Mars-wide dust storm blanketed its location in June 2018" and it never called home again.
- **Game mechanic.** Base power: solar panels alone are risky on Mars, which is why the game base has a backup power source. `parametros_juego.csv` has the matching numbers (Mars gets 43% of Earth's sunlight).
- **Why it matters for kids' skills.** Having a backup plan, and being proud of work that lasts.
- **Sources.** NASA Science mission page: https://science.nasa.gov/mission/mer-opportunity/
- **Careful.** The landing date appears as both 24 and 25 January 2004 on the same page (different time zones). Say "January 2004".

### 11. Mars-500 (not in main video)

- **Dates.** A 520-day ground simulation of a Mars mission ("17 mo of mission confinement"). ⚠ UNVERIFIED: the exact start and end dates were not in the paper or pages we opened; the paper was published February 2013.
- **What happened.** A multinational crew of six lived sealed inside a mock spacecraft. Wrist monitors recorded 4.396 million minutes of activity and light. Over time the crew moved less while awake and spent more time sleeping and resting, and their light exposure dropped. Most crew members had at least one problem with sleep quality, alertness or sleep timing.
- **Game mechanic.** M4, rest and fitness meters, plus the sol planner: without a daily rhythm of light, meals and exercise, a crew drifts. M2: a crew stuck together for a long time.
- **Why it matters for kids' skills.** A steady routine of daylight, movement and sleep keeps you sharp.
- **Sources.** Basner et al., "Mars 520-d mission simulation reveals protracted crew hypokinesis and alterations of sleep duration and timing", *PNAS* 110(7):2635–2640 (2013), doi:10.1073/pnas.1212646110 (abstract via PubMed 23297197; full text PMC3574912)

### 12. NASA CHAPEA, Missions 1 and 2

- **Dates.**
  - Mission 1: 25 June 2023 – 6 July 2024 (378 days).
  - Mission 2: 19 October 2025 – 31 October 2026 (378 days), ending two weeks before this event.
- **What happened.** Four volunteers per mission lived in Mars Dune Alpha, a roughly 1,700-square-foot 3D-printed habitat at NASA Johnson, simulating a year on the surface of Mars. They did simulated "marswalks", operated robots (in Mission 2, a drone and a rover), maintained the habitat, exercised and grew crops, with limited resources.
- **Communication delays.**
  - Mission 1: "Mars-realistic time delays of communicating to Earth – up to 44-minutes roundtrip".
  - Mission 2: "up to 22 minutes each way", plus a simulated two-week communication blackout.
  - Mission 2 crew: "378 days without windows, the sounds of the outside world, or real-time calls with family and friends".
- **Game mechanic.** This is the closest real thing to our game.
  - M1: delay and blackout.
  - M2: a crew of four with roles, such as commander and medical officer.
  - M3: crop growth.
  - M4: exercise and routines.
  - M6: the human side of a year in isolation.
- **Why it matters for kids' skills.** Teamwork, patience and keeping your mood up while far from home: what NASA is practicing right now for Mars.
- **Sources.**
  - NASA, "First Mars Crew Completes Yearlong Simulated Red Planet NASA Mission" (July 2024): https://www.nasa.gov/missions/analog-field-testing/chapea/first-mars-crew-completes-yearlong-simulated-red-planet-nasa-mission/
  - NASA, "CHAPEA Mission 2 Crew Reflects After 378 Days on Simulated Mars" (Nov 2026): https://www.nasa.gov/centers-and-facilities/johnson/chapea-mission-2-crew-reflects-after-378-days-on-simulated-mars/
  - NASA CHAPEA hub page (Mission 2 updates, including the podcast "Crew Members Discuss Loss of Communication With Earth"): https://www.nasa.gov/humans-in-space/chapea/
- **Careful.** The two-week blackout comes from a podcast summary on the hub page; we did not listen to the episode.

---

## Part 4. Closing: what comes next (not in main video)

- NASA's Artemis I page (as of 14 Nov 2026) says Artemis III, in 2027, will test docking with lander test hardware in Earth orbit, "before NASA returns humans to the Moon's surface in 2028". Source: https://www.nasa.gov/mission/artemis-i/
- **Careful.** Artemis dates have changed many times. On camera, say "NASA plans…", not "will".

---

## Dropped or not verified

| Candidate | Status |
|---|---|
| Katya Echazarreta (Blue Origin NS-21, 2022) | **Not verified.** Blue Origin's site returned "429 Too Many Requests" twice, and NASA's site search found nothing. Our dataset ends in 2019, so it does not include her. Verify on blueorigin.com before using; if confirmed, she fits next to Neri Vela and Hernández. |
| HI-SEAS (Hawaiʻi Mars simulations) | **Not checked.** CHAPEA covers the same story with a NASA source and more recent dates, so we left HI-SEAS out. |
| First crew-eaten Veggie lettuce (Aug 2015) | Kept the Veggie entry; the "first meal" date is ⚠ UNVERIFIED (see #8). |
| Twins Study exact dates; Mars-500 exact dates | Kept the entries; the exact dates are ⚠ UNVERIFIED (see #7 and #11). |

## Datasets the game uses

The challenge names three kinds of NASA data: **DONKI** (space weather), **OSDR** (astronaut health and biology research) and **Artemis and Mars surface mission data**. The table maps each mission above to the dataset behind it.

**Status column:**
- **In the table:** the value is already in `eda/tables/parametros_juego.csv`, with its source and URL. That means it is sourced and ready, **not** that the build uses it. **Only claim a dataset on camera if it is implemented in the build.**
- **Planned:** in the game plan (las notas de construcción) but not confirmed as built yet. Check with the game team before saying "the game uses it" on camera.
- **Story only:** the mission explains a mechanic, but no number from it goes into the game.

| Mission | NASA dataset behind it | What the game takes from it | Status |
|---|---|---|---|
| Artemis I (#2), Curiosity RAD (#9) | **DONKI**, NASA's Space Weather Database (api.nasa.gov): solar energetic particle (SEP) events and geomagnetic storms | M5: real past solar storms for the event deck, and today's space weather tied to the radiation shielding decision (the "stand out" idea in the challenge text) | Planned. The GST and SEP endpoints answered when tested on 14 Nov 2026; the flare (FLR) endpoint returned 404. |
| Twins Study (#7), Veggie (#8), Mars-500 (#11) | **OSDR**, NASA's Open Science Data Repository: 577 studies counted in our EDA (immune 213, bone 115, muscle 105, plants 107) | Real health findings behind the crew meter (M4) and food production (M3): without exercise, crews lose muscle and bone | Story only. We counted OSDR studies by topic (`eda/FINDINGS.md`, finding 5) but did not confirm that the Twins, Veggie or Mars-500 data sit in OSDR. |
| Curiosity RAD (#9) | **Mars surface data**: Curiosity's Radiation Assessment Detector (NASA/JPL) | M5: daily radiation dose on the way to Mars and on its surface | In the table (`dosis_diaria_transito_marte`, `dosis_diaria_superficie_marte`) |
| Opportunity (#10) | **Mars surface data**: Opportunity's dust-storm log and the NSSDCA Mars Fact Sheet | Power: how dark a dust storm gets (`tormenta_polvo_opacidad_tau_2018`) and how much sunlight Mars gets (`irradiancia_solar_marte`) | In the table. The power left during a storm is still `[DATO PENDIENTE]`. |
| CHAPEA (#12), Mars-500 (#11) | **Mars data**: NSSDCA Mars Fact Sheet (Earth–Mars distance, length of a sol) and NASA's "Hazard: Distance from Earth" | M1 communication delay (about 3 to 22 minutes each way, ~6 to 45 minutes round trip; NASA's phrase is "up to 20 minutes one way") and the length of each sol | In the table (`retraso_tierra_marte_*`, `duracion_sol_marte`) |
| Artemis I (#2) | **Artemis data**: Orion radiation measurements (*Nature* 2024) and the AstroRad vest test (*Science Advances* 2026) | M5 and the Moon tutorial: daily dose inside Orion, total mission dose, how much extra shielding helps (a "modest" ~30% for cosmic rays), the 4× difference between shielded and exposed spots, the ~50% drop from turning the ship, and the Moon blocking about a third of cosmic rays | In the table: the HERA-instrument rows from George et al. 2024 and NASA's Oct 2024 release (`dosis_diaria_orion_artemis_i_*`, `dosis_total_mision_artemis_i_*`, `blindaje_orion_*`, `refugio_orion_tormenta_solar_max`, `orion_cambio_de_orientacion`, `luna_bloquea_rayos_cosmicos`). The AstroRad vest result is still story only. |
| Artemis II (#3) | **Artemis data** for the Moon tutorial: NSSDCA Moon Fact Sheet | Moon tutorial: Earth answers in about 1.2 to 1.4 seconds each way (~2.6 s round trip) | In the table (`retraso_tierra_luna_*`). For Moon radiation, use the Artemis I Orion rows. **Do not use** `dosis_diaria_superficie_luna`: it comes from China's Chang'E 4 lander, and the table marks it "NO USAR EN JUEGO NI PITCH" because of the China eligibility rule in `JUDGING.md`. |
| Apollo 13 (#1), Skylab 4 (#4), CHAPEA (#12) | **NASA Life Support Baseline Values (BVAD)** and the **Human Research Roadmap** | Life support values (oxygen, CO2, water, food) and the risk ratings behind M1-M4 | In the table (BVAD rows). These are NASA data but not one of the three kinds the challenge names. |
| Skylab 4 (#4), STS-61-B (#5), STS-128 (#6) | None | Story and role models only | Story only |

**For the video.** The honest one-liner: "The numbers in our game come from NASA's own fact sheets, life-support baselines, and radiation measured by Curiosity and Artemis I, with real solar storms from NASA's DONKI space weather database." Only say each part if the build actually uses it; drop the DONKI clause until it is built.

## How this was checked

The pages were downloaded and converted to plain text on a team computer, and papers were looked up through the PubMed E-utilities API. Paper findings come from the abstracts, except Mars-500, whose full text was also downloaded (it did not include exact mission dates). Nothing here was written from memory, except the items marked ⚠ UNVERIFIED, which are labeled as such.
