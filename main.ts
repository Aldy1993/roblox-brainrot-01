// Brainrot Blast hands itself in. This program gathers the pieces of the
// entry that live next to it — the Rojo-built place, the Luau sources, the
// screenshots and the play link — and lays them out in the output folder
// the grader reads, then writes the dossier summary with the vendored
// make.fun Roblox library. It only uses the Node standard library.
//
// The game it hands in: 70 original brainrots on Neon Island — conveyor,
// 8 bases, steal/lock, a tsunami every 3 minutes, a Golden Hour paying x2
// every 5 minutes, 7 missions, a 70-entry Index grid, and rebirths.
//
// Run it the way the grader does, pointing the output somewhere handy:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

// The folder this file sits in, and where the hand-in goes. The grader
// sets MAKEFUN_OUTPUT_DIR to /output; anywhere else it defaults there too.
const repoRoot = fileURLToPath(new URL('.', import.meta.url));
const handInDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

/** True for every path cpSync may copy: names starting with a dot are left out. */
const isPublicName = (path: string): boolean => !basename(path).startsWith('.');

mkdirSync(handInDir, { recursive: true });
copyFileSync(join(repoRoot, 'game.rbxl'), join(handInDir, 'game.rbxl'));
copyFileSync(join(repoRoot, 'PLAY.json'), join(handInDir, 'PLAY.json'));
cpSync(join(repoRoot, 'src'), join(handInDir, 'src'), { recursive: true, filter: isPublicName });
mkdirSync(join(handInDir, 'screenshots'), { recursive: true });
if (existsSync(join(repoRoot, 'screenshots'))) {
	cpSync(join(repoRoot, 'screenshots'), join(handInDir, 'screenshots'), { recursive: true, filter: isPublicName });
}

// The caps come from the competition gate: the text cap shapes the dossier
// bytes, the rest refuse an entry the scorer would refuse anyway, so the
// program fails here exactly where the scorer would fail it there.
const dossierText = buildDossier(handInDir, {
	text_max_bytes: 65536,
	screenshots: { max: 4, max_bytes: 262144 },
	max_instances: 500000,
	scripts_max_source_bytes: 8388608,
	scripts_max_path_chars: 1048576,
});
writeFileSync(join(handInDir, 'dossier.json'), dossierText);
