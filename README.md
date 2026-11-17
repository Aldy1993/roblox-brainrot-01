# Brainrot Blast

[![make.fun bounty](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![make.fun rank](https://make.fun/badge/roblox-brainrot-01/Aldy1993/roblox-brainrot-01/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![make.fun reward](https://make.fun/badge/roblox-brainrot-01/Aldy1993/roblox-brainrot-01/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

A 3D brainrot game for make.fun's "Make the best AI Roblox brainrot game" bounty (roblox-brainrot-01), built by Aldy1993. Brainrots roll down a conveyor belt through the middle of the map — buy them, park them in your base, and they pay you cash every second. Climb from a $10 Noodle Cat to the $5,000,000 Ohio Final Boss, chase Golden, Diamond and Rainbow mutations, steal brainrots out of rival bases (and lock your own against thieves), survive a tsunami wave every 3 minutes, and rebirth for a permanent x2 income multiplier.

All twelve characters are original inventions for this game, built at runtime from plain Roblox Parts — no trademarked names, no external assets, no network calls.

## How to play

- Walk up to the conveyor and hold **E** on a brainrot to buy it (or click one in another player's base to steal it — then sprint home within 15 seconds).
- Brainrots in your base pay $/second automatically. Lock your base ($250, 60s) to keep thieves out.
- When the tsunami warning sounds, get inside your base or get flung across the map.
- Rebirth ($25,000, doubling each time) to reset everything for a permanent x2 income multiplier.

## Run

Build the place with Rojo, then hand it in with the entry program:

```sh
rojo build default.project.json --output game.rbxl
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

- `main.ts` (Node 22+, standard library only) copies `game.rbxl`, `src/`, `screenshots/` and `PLAY.json` to the output folder, skipping every name that starts with a dot, and writes `dossier.json` with `vendor/makefun-roblox.ts` (the kit's copy, unchanged).
- `game.rbxl` is the place Rojo builds from `src/` and `default.project.json`; `screenshots/` holds captures of the game running in Roblox Studio (the first by name is also the game's thumbnail on Roblox); `PLAY.json` names the published place.
- `TOUR.json` is the optional tour: the keys that bring the game to each screenshot.
