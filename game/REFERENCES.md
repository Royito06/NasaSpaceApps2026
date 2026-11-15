# Credits and licenses

Junior Astronaut Mission Trainer is a NASA Space Apps 2026 hackathon project (Hermosillo). It is an independent student project and is **not endorsed by NASA**. The NASA logo and insignia are not used.

Every external resource in this folder is listed here. Only CC0, CC BY, OFL and NASA public-domain material is used.

## 3D models (CC0 1.0, credit optional)

| Asset | Author | License | Source | Files used |
|---|---|---|---|---|
| Space Kit | Kenney (kenney.nl) | CC0 1.0 | https://kenney.nl/assets/space-kit | `assets/kenney_space/`: astronautA, astronautB, machine_generator, satelliteDish_large, rover, hangar_roundGlass, rock_largeA, rock_largeB, rocks_smallA, rocks_smallB, crater, craterLarge, barrels, machine_wireless, desk_computerScreen |
| Space Station Kit | Kenney (kenney.nl) | CC0 1.0 | https://kenney.nl/assets/space-station-kit | `assets/kenney_station/`: floor, wall, wall-banner, wall-window, wall-door, wall-switch, computer-screen, computer-system, display-wall, chair-cushion, table, bed-single, container, container-wide, container-tall, colormap texture |
| Space Base Bits | Kay Lousberg (KayKit) | CC0 1.0 | https://kaylousberg.itch.io/space-base-bits | `assets/kaykit/`: basemodule_A, roofmodule_solarpanels, tunnel_straight_A, solarpanel, lander_A, cargo_A, lights, texture atlas |

## UI and icons

| Asset | Author | License | Source | Files used |
|---|---|---|---|---|
| UI Pack | Kenney (kenney.nl) | CC0 1.0 | https://kenney.nl/assets/ui-pack | `assets/kenney_ui/PNG/*/Default/`: buttons, slider tracks, arrows, check marks, star |
| Game icons | Lorc; Delapouite | CC BY 3.0 (https://creativecommons.org/licenses/by/3.0/) | https://game-icons.net | `assets/icons/` (see the list below) |

Icons made by Lorc and Delapouite. Available on https://game-icons.net. The icons are recoloured in the game.

- By **Lorc**: `gears`, `energy-shield`, `sun`
- By **Delapouite**: `power-generator`, `radiations`, `habitat-dome`, `astronaut-helmet`, `sandstorm`

## Sound effects (Pixabay Content License: free to use in a game, no attribution required)

Source and author are as given by the downloaded file names (Pixabay user name, title, Pixabay id). Each file was cut to the part the game uses, made mono and saved as Ogg Vorbis. License summary: https://pixabay.com/service/license-summary/

| File in `assets/sounds/` | Original title (Pixabay id) | Author on Pixabay | Used for |
|---|---|---|---|
| `amb_space.ogg` | Spaceship hum low frequency (296518) | audiopapkin | Background in space: title, mission select, rocket trips |
| `amb_base.ogg` | Air conditioner (584740) | dragon-studio | Background in the Mars base: the air system |
| `machine.ogg` | Futuristic factory machine ps 022 (314833) | audiopapkin | The oxygen machine filling tanks at night |
| `gears.ogg` | Ancient mechanical gears (487670) | dragon-studio | Lowering the rover from the lander |
| `rover.ogg` | CNC machine 02 (76600) | freesound_community | The rover driving |
| `steps.ogg` | Robot heavy mechanical footsteps (194039) | daviddumaisaudio | The crew walking on Mars |
| `click.ogg` | Steampunk mechanical gadget (188052) | daviddumaisaudio | A vote, a plug, a rock or a lettuce picked |
| `mech.ogg` | Sound design elements robot mechanism 032 (500870) | audiopapkin | A power unit repaired; the rover on the ground |
| `build.ogg` | Construction (35446) | freesound_community | A water bag or cargo put in place |
| `clang.ogg` | Metal pipe (329305) | u_edtmwfwu7c | The hammer landing when dropped with Earth's air |
| `beam.ogg` | Laser (381976) | u_xg7ssi08yr | The NASA terminal making its request |
| `zap.ogg` | Sci-fi weapon laser shot 04 (316416) | daviddumaisaudio | A message leaving for Earth |

## Fonts (SIL Open Font License 1.1; license texts in `assets/fonts/`)

| Font | Copyright | Source |
|---|---|---|
| Atkinson Hyperlegible (Regular, Bold) | Copyright 2020 Braille Institute of America, Inc. | https://github.com/google/fonts/tree/main/ofl/atkinsonhyperlegible |
| Fredoka | Copyright 2016 The Fredoka Project Authors | https://github.com/google/fonts/tree/main/ofl/fredoka |

## NASA imagery

NASA content is generally not subject to copyright. It is credited here and in the game, and no endorsement is implied. Usage guidelines: https://www.nasa.gov/nasa-brand-center/images-and-media/

| Image | Credit | Source | File |
|---|---|---|---|
| PIA24264, "Mastcam-Z's First 360-Degree Panorama" (Perseverance, Jezero crater) | NASA/JPL-Caltech/MSSS/ASU | https://science.nasa.gov/photojournal/mastcam-zs-first-360-degree-panorama/ | `assets/nasa/PIA24264.jpg` (the game shows the horizon strip) |
| Apollo 11 bootprint, AS11-40-5878 | NASA/JSC | https://science.nasa.gov/3d-resources/moon-apollo-astronaut-bootprint/ | `assets/nasa/apollo11_AS11-40-5878.jpg` |

### NASA 3D models of the worlds

| File | Source | License / terms | Changes |
|---|---|---|---|
| `assets/nasa/models/earth.glb` | NASA/JPL-Caltech, "Earth 3D Model", https://science.nasa.gov/learn/heat/resource/earth-3d-model/ | NASA media: generally not copyrighted; used factually with NASA credited and no endorsement implied (https://www.nasa.gov/nasa-brand-center/images-and-media/) | Colour map reduced to 2048x1536 and brightened; normal map removed |
| `assets/nasa/models/mars.glb` | NASA/JPL-Caltech, "Planet Mars 3D Model", https://science.nasa.gov/resource/planet-mars-3d-model | Same NASA media terms | Colour map reduced to 1536x1152; normal map removed |
| `assets/nasa/models/moon.glb` | NASA's Goddard Space Flight Center, "Moon 3D Models for Web, AR, and Animation" (`moon_small.glb`), https://svs.gsfc.nasa.gov/14959/ | Same NASA media terms; credit requested to NASA's Goddard Space Flight Center | Colour map reduced to 1536x1536; gloss settings removed |

## NASA data

| Data | Source | How the game uses it | File |
|---|---|---|---|
| Coronal mass ejection `2024-05-20T05:36:00-CME-001` (an eruption on the far side of the Sun) | NASA DONKI, Space Weather Database Of Notifications, Knowledge, Information (CCMC, NASA Goddard), https://ccmc.gsfc.nasa.gov/DONKI/view/CME/31034/-1 , retrieved through https://api.nasa.gov | Level 2, Mars, first storm. An **archived** record bundled with the game, never shown as live. DONKI records the eruption, not what reached Mars; linking it to Curiosity's reading is the team's inference, and the game says so. | `data/donki_cme_2024-05-20.json` |
| Curiosity RAD: largest radiation surge measured on the surface of Mars, 8.1 mGy, 20 May 2024 | NASA JPL, "NASA Watches Mars Light Up During Epic Solar Storm", 10 June 2024, https://www.jpl.nasa.gov/news/nasa-watches-mars-light-up-during-epic-solar-storm/ | Level 2, Mars: the size of the big storm. | value in `main.gd` |
| Solar Energetic Particle event `2017-09-10T16:45:00-SEP-001` (GOES, near Earth) | NASA DONKI, retrieved through https://api.nasa.gov | Level 2, Mars, optional second storm. Archived, bundled. | `data/donki_sep_2017-09-10.json` |
| Solar particle events of the last 60 days (**live request**, made when the player opens the terminal on Mars) | NASA DONKI through https://api.nasa.gov/DONKI/SEP | Shown as "live" with the time it was fetched. If NASA does not answer, the terminal says so and shows only archived data. | not stored |
| Apollo 15 photo AS15-86-11603, "Astronaut James Irwin works at Lunar Roving Vehicle during Apollo 15 EVA", and its caption (**live request**, made when the player opens the terminal on the Moon) | NASA Image and Video Library, https://images.nasa.gov/details/as15-86-11603 . NASA photo (JSC), taken by astronaut David R. Scott. | Level 1, the Moon: the mission file. Downloaded at run time, not bundled. | `assets/nasa/as15-86-11603_small.jpg`: the same picture, saved in the game and shown with the label "copy saved inside the game" when NASA's image server does not let the web page download it |
| Apollo 15 (1971) rover distances and speed, walking speed, moonwalk durations | NASA, Apollo 15 Mission Report (NTRS 19720021182), https://ntrs.nasa.gov/api/citations/19720021182/downloads/19720021182.pdf | Level 1, the Moon: the 5 km walk-back line, driving and walking times. | values in `main.gd`, listed on the in-game "NASA data used" screen |
| The walk-back rule (astronaut Jim Irwin), the 7-hour backpack (CapCom Joe Allen), the Genesis Rock (sample 15415) | Apollo Lunar Surface Journal, https://apollojournals.org/alsj/a15/a15.spur.html and https://apollojournals.org/alsj/a15/a15.clsout2.html | Level 1, the Moon: the decision and its story card. | same |
| Curiosity image PIA26302, "Curiosity Sees Streaks and Specks During 2024 Solar Storm" (**live request**, made when the player opens the terminal on Mars) | NASA/JPL-Caltech, NASA Image and Video Library, https://images.nasa.gov/details/PIA26302 | Level 2, Mars: the players tap the marks the storm's particles left in the camera image. Downloaded at run time, not bundled. | `assets/nasa/PIA26302_small.jpg`: the same picture, saved in the game and shown with the label "copy saved inside the game" when NASA's image server does not let the web page download it |
| How the Apollo 15 rover was lowered from the lander (one astronaut released it from the ladder, the other pulled it out with reels and tapes) | NASA NSSDCA, "The Apollo Lunar Roving Vehicle", https://nssdc.gsfc.nasa.gov/planetary/lunar/apollo_lrv.html | Level 1, the Moon: the two-player opening. | text in `strings.gd` |
| The hammer and feather drop (1.32 kg hammer, 0.03 kg falcon feather) | NASA Science, "The Apollo 15 Hammer-Feather Drop", https://science.nasa.gov/resource/the-apollo-15-hammer-feather-drop/ | Level 1, the Moon: the last experiment. | text in `strings.gd` |
| Oxygen a crew member uses in a day (0.895 kg), the reference crew of 4, and days from planting to harvest for lettuce (28, measured in growth chambers on Earth) | NASA, Life Support Baseline Values and Assumptions Document (BVAD), NASA/TP-2015-218570 Rev 2, Tables 3-1, 3-31 and 4-89, https://ntrs.nasa.gov/api/citations/20210024855/downloads/BVAD_2.15.22-final.pdf | Level 2, Mars: the size of one oxygen tank (a calculation) and harvest day. How power changes oxygen production and the harvest is a game rule, and the game says so. | not stored |
| MOXIE made 122 g of oxygen from Mars' air, up to 12 g an hour | NASA, "NASA's Oxygen-Generating Experiment MOXIE Completes Mars Mission", 6 September 2023, https://www.nasa.gov/missions/mars-2020-perseverance/perseverance-rover/nasas-oxygen-generating-experiment-moxie-completes-mars-mission/ | "NASA data used" screen: the real experiment behind the game's much larger oxygen machine. | not stored |
| The Veggie garden on the Space Station typically holds six plants; lettuce has been grown there | NASA, "Growing Plants in Space", https://www.nasa.gov/exploration-research-and-technology/growing-plants-in-space/ | Level 2, Mars: six plants on harvest day. | not stored |
| Solar particle events of the last 60 days, asked again for the bonus sol (**live request**) | NASA DONKI through https://api.nasa.gov/DONKI/SEP | Bonus sol, "today's real Sun": an event in the last 7 days counts as a storm today (game rule). If NASA does not answer, the game says so and uses the archived September 2017 event. | not stored |
| Solar particle events of 7 March 2012, 10 September 2017, 28 October 2021, 11 May 2024 and 11 November 2025 (near Earth), used as storm cards | NASA DONKI (CCMC, NASA Goddard), https://ccmc.gsfc.nasa.gov/DONKI/ ; the team's list is `../eda/tables/donki_mazo.csv` | Free mission: the card shown when a storm is drawn. **Archived**. How often storms come and how much each adds at the base are game rules, and the game says so. | dates only, in `main.gd` |
| Mice that spent 33 days on the Space Station came back with 18% less soleus (calf) muscle than mice on Earth | NASA Open Science Data Repository, study OSD-342, https://osdr.nasa.gov/bio/repo/data/studies/OSD-342 ; Lee et al., PNAS 2020, https://pmc.ncbi.nlm.nih.gov/articles/PMC7519220/ | A "Did you know?" line on the free mission's report and a row on the "NASA data used" screen. It explains microgravity; it is not a game mechanic. | not stored |
The other NASA numbers shown in the game (communication delay, radiation, power) are listed with their sources on the in-game "NASA data used" screen and in `../eda/tables/parametros_juego.csv`.

## Engine

- Godot Engine 4.7.2 (MIT license), https://godotengine.org

## Human-made statement

All third-party art, models, icons and fonts above are human-made, from creators who state that no generative AI was used or from works that predate 2022. The game uses no AI-generated imagery.
