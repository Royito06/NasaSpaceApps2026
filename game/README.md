# Game: Junior Astronaut Mission Trainer (minimal demo)

A browser game for ages 7–12, made with Godot 4.7.2. Two levels, each built around one decision. Level 1, the Moon (Apollo 15): drive the rover to the close rock site or the far one, with Mission Control answering in seconds. Level 2, Mars: two crew roles and one job before a solar storm, with Earth too far away to help.

- It opens in deep space. After "solo or co-op", a mission select shows the Moon, Mars (locked until the Moon is played) and worlds still to come.
- A "NASA terminal" in each level makes a real request to NASA while you play: an Apollo 15 photo from the NASA Image and Video Library on the Moon, and the solar particle events of the last 60 days from DONKI on Mars. Live data is labelled live; if NASA does not answer, the game says so and uses the archived copies in `data/`.
- The narrator names what the players have to manage before they act, one line each, with an arrow on the thing it names: oxygen reserve and science on the Moon; power, oxygen tanks and radiation on Mars.
- Mars has three things to manage. Power runs the oxygen machine and the greenhouse lamp, so a power unit left broken means fewer oxygen tanks the next morning and plants without light.
- After sol 31 comes harvest day: the players pick the lettuce, and how many of the six plants are ready depends on the nights the lamp was on.
- A bonus sol replays the sol 30 morning with today's real Sun: the terminal asks NASA DONKI again, and an event in the last 7 days means a storm today. With a calm Sun the better job is a different one.
- A free mission (three sols) is different every time: each sol a power unit may fail and a storm card is drawn from real events in NASA DONKI's records. There is a third job, going out for a rock sample, which uses an extra oxygen tank. A mission report at the end checks three goals (sample, radiation, oxygen) and says what decided it. The rules are the team's own, tested on 20,000 simulated missions; `-- --demo=f_sim` plays 300 missions with a simple rule and prints how many met the goals.
- In the free mission the two role reports are closed until someone taps them: reading both before choosing is the crew's job, and the mission report says so when a sol was decided without them.
- A crew logbook, on the mission select, shows what the crew has done so far: missions played, free missions with goals met, predictions that came true, and how often both reports were read first. It is saved only on the device (`user://logbook.json`, the browser's own storage on the web); the game sends it nowhere, and it can be cleared or copied as text.
- After two free missions in a row that end "Mission strained", the Commander offers a hint, once. The hint never changes the odds.
- English by default, with a Spanish toggle.
- One or two players. With two, Engineering moves with W A S D and Protection with the arrow keys. With one, both key sets move the selected astronaut; Space (or a tap on an astronaut) switches. Everything also works by tapping the yellow arrows.
- The players do each job with their hands, in a small game that shows the idea: on the Moon the oxygen reserve drops as the rover drives away and they choose which rocks to bring back; on Mars they rewire a power unit by matching plugs, or stop the storm's rays with water bags and watch "storm getting through" fall. The next sol on Mars starts from what the crew chose: whatever they did not fix is still broken, a second and smaller storm arrives, and the mini-games give no hints.
- More moments from the real missions are played, not read: two players lower the rover from the lander together (Apollo 15's reels and tapes), the rare rock is photographed where it lies before it is bagged (as the Genesis Rock was), the Moon level ends with the hammer and feather drop, and on Mars the players tap the marks a real solar storm left in the Curiosity rover's camera image.
- After each level the game offers to replay the other choice from the same morning and compares both. The replay can be skipped.
- In the crew debrief the Commander asks why, the players type an answer, and the Commander replies to what they said. This is plain word matching written by the team: no AI model, and nothing typed leaves the device.
- "Settings" holds the voice, a less-motion mode, and a switch that shows where each number comes from (Measurement, Calculation or Game rule) during play. The full list is always on the "NASA data" screen.
- A narrator (the crew's commander) guides the players in a dialogue box with a live 3D portrait. An optional "Voice" button reads the lines aloud with the device's own speech voices; it is off by default.
- 2.5D: low-poly models under a fixed camera. The crew walks to its stations as the players choose.
- Runs on Godot's Compatibility renderer, so the web build looks the same as the desktop build.

## Files

| File | What it is |
|---|---|
| `main.gd`, `main.tscn` | Entry point, game flow, narrator dialogue and every screen |
| `world.gd` | The Mars scene, built in code: room, shelter corner, power units, crew, storm and lighting |
| `space.gd` | Deep space, built in code: the title screen and the mission select |
| `moon.gd` | The Moon scene, built in code: lander, drivable rover, two rock sites and the walk-back line |
| `ui_kit.gd` | Buttons, panels and bars built from the Kenney UI Pack |
| `strings.gd` | Every on-screen text, in English and Spanish |
| `data/` | Archived NASA data bundled with the game |
| `assets/` | Third-party models, icons, fonts and NASA images (see `REFERENCES.md`) |
| `tools/` | Development helpers, not part of the game |

## Play it

In a browser, with nothing to install and no account: https://royito06.github.io/NasaSpaceApps2026/play/

## Run it

1. Open this folder in Godot 4.7.2 and press Play, or
2. Export for the web: `godot --headless --import` and then `godot --headless --export-release Web build/web/index.html`, and serve `build/web` with any static web server.

## NASA API key (optional)

The Mars terminal asks NASA DONKI through api.nasa.gov. Without a key the game uses NASA's public `DEMO_KEY`, which allows only about 10 requests an hour from one network. To lift that, get a free key at https://api.nasa.gov and put it, alone on one line, in a file called `nasa_key.txt` in this folder before exporting. The file is ignored by git, so the key is never committed; it does travel inside the exported build. If the key is missing or the limit is reached, the game says NASA did not answer and shows the archived data, labelled as archived.

## Credits

See `REFERENCES.md`. This is an independent student project and is not endorsed by NASA.
