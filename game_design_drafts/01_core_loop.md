# 01 · Core loop: the minimal demo (we're building this first)

Decided 14 Nov after an outside critique: **one clear trade-off that works beats six mechanics that don't.** Everything else waits until this plays end to end in a browser.

## The scene

One room in a Mars habitat. A 10-second card first sets the stakes:

> On the Moon, a message to Earth takes about **1.3 seconds each way**.
> On Mars, it takes **3 to 22 minutes each way** (6 to 44 minutes there and back).
> On Mars, the crew decides on its own.

## Two roles, split information

| Role | Sees | Doesn't see |
|---|---|---|
| **Engineering** | The power equipment is damaged; how much power is left tonight | The storm |
| **Protection** | A solar storm is coming; how strong the shelter is | The power problem |

Neither can decide well alone, so they **have to tell each other** what they see. With one kid, they switch seats between the two roles.

## One decision, one work slot

There's time for **one** job before the storm hits:

| Choice | Saves | Costs |
|---|---|---|
| **Reinforce the shelter** | Less radiation exposure during the storm | Power stays low tonight (dim lights, fewer systems) |
| **Repair the power** | Lights and systems back on | More radiation exposure in the existing shelter |

**Neither always wins.** Earth's advice arrives *after* the decision window, which is the delay in action.

## What happens next

1. **Advance one sol** (a Mars day, 24 h 39 min) at the player's pace.
2. **Show the consequences** on two bars: **Power** and **Radiation exposure** (its own bar; higher is worse).
3. **Retry the other choice** from the same starting point, and show both results side by side.
4. **Debrief, three questions:** What did we give up? What did each of us know? What would we change?
5. **"NASA data used" screen:** where every number came from.

## The storm is real

A real solar event recorded by **NASA's DONKI** space-weather database, bundled in the game and labelled *"Archived NASA data: recorded <date>"*, never "live".

Be honest about one point: DONKI records storms near Earth. The exposure at our Mars base is **our game model**, not a NASA forecast.

## Still to define (help wanted)

- The exact starting values, costs and outcomes for both branches, so neither choice is free and neither always wins. See `03_real_numbers.md`.
- What the screen looks like for a 7-year-old who reads slowly: icons, very short text, optional voice.
