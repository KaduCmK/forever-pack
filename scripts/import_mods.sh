#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

mkdir -p .import-log mods

find_mod_file_by_name() {
  local target_name="$1"
  while IFS= read -r file; do
    if grep -Fqx "name = \"$target_name\"" "$file"; then
      printf '%s\n' "$file"
      return 0
    fi
  done < <(find mods -name '*.pw.toml' -type f | sort)
  return 1
}

set_side() {
  local file="$1"
  local side="$2"
  local tmp
  tmp="$(mktemp)"

  if grep -q '^side = "' "$file"; then
    sed "s/^side = \".*\"/side = \"$side\"/" "$file" > "$tmp"
  else
    awk -v side="$side" '
      {
        print
        if (!done && /^filename = "/) {
          print "side = \"" side "\""
          done = 1
        }
      }
      END {
        if (!done) {
          print "side = \"" side "\""
        }
      }
    ' "$file" > "$tmp"
  fi

  mv "$tmp" "$file"
}

add_mod() {
  local side="$1"
  local source="$2"
  local name="$3"
  local new_file=""
  local candidate=""

  printf '[%s][%s] %s\n' "$side" "$source" "$name"
  find mods -name '*.pw.toml' -type f | sort > .import-log/before.txt

  if [[ "$source" == "Modrinth" ]]; then
    if ! packwiz modrinth add -y "$name" >> .import-log/run.log 2>&1; then
      printf 'FAILED\t%s\t%s\t%s\n' "$side" "$source" "$name" >> .import-log/failures.tsv
      return 0
    fi
  else
    if ! packwiz curseforge add -y "$name" >> .import-log/run.log 2>&1; then
      printf 'FAILED\t%s\t%s\t%s\n' "$side" "$source" "$name" >> .import-log/failures.tsv
      return 0
    fi
  fi

  find mods -name '*.pw.toml' -type f | sort > .import-log/after.txt

  while IFS= read -r candidate; do
    if grep -Fqx "name = \"$name\"" "$candidate"; then
      new_file="$candidate"
      break
    fi
  done < <(comm -13 .import-log/before.txt .import-log/after.txt)

  if [[ -z "$new_file" ]]; then
    new_file="$(find_mod_file_by_name "$name" || true)"
  fi

  if [[ -z "$new_file" ]]; then
    printf 'MISSING_FILE\t%s\t%s\t%s\n' "$side" "$source" "$name" >> .import-log/failures.tsv
    return 0
  fi

  set_side "$new_file" "$side"
}

: > .import-log/run.log
: > .import-log/failures.tsv

while IFS=$'\t' read -r side source name; do
  [[ -z "${side:-}" ]] && continue
  add_mod "$side" "$source" "$name"
done <<'EOF'
server	Modrinth	BaguetteLib
server	Modrinth	ChoiceTheorem's Overhauled Village
server	Modrinth	Chunky
server	Modrinth	Clumps
server	Modrinth	Concurrent Chunk Management Engine
server	Modrinth	Gravestone Curios Compatibility
server	Modrinth	Incendium
server	Modrinth	Lithosphere
server	Modrinth	Right Click Harvest
server	Modrinth	Sable-Collision damage
server	Modrinth	SparseStructures
server	Modrinth	Stellarity
server	Modrinth	Still Life
client	Modrinth	3d-Skin-Layers
client	Modrinth	Advancement Plaques
client	Modrinth	Antique Atlas
client	Modrinth	AppleSkin
client	Modrinth	Barebones McQoy
client	Modrinth	Better Third Person
client	Modrinth	BetterF3
client	Modrinth	Camera Utils
client	Modrinth	Chunks Fade In
client	Modrinth	CIT Resewn
client	Modrinth	CITResewnNeoPatcher
client	Modrinth	Create: EMI Schematics
client	Modrinth	Distant Horizons
client	Modrinth	Do a Barrel Roll
client	Modrinth	EMI
client	Modrinth	EMIffect
client	Modrinth	Entity Model Features
client	Modrinth	Entity Texture Features
client	Modrinth	EntityCulling
client	Modrinth	Highlighter
client	Modrinth	Iceberg
client	Modrinth	ImmediatelyFast
client	Modrinth	Inventory Profiles Next
client	Modrinth	InvMove
client	Modrinth	InvMoveCompats
client	Modrinth	Iris
client	Modrinth	Item Borders
client	Modrinth	Jade
client	Modrinth	Jade Addon: TFMG Compat
client	Modrinth	Jade Addons
client	Modrinth	Jade Sable Compat
client	Modrinth	LambDynamicLights
client	Modrinth	libIPN
client	Modrinth	More Culling
client	Modrinth	Mouse Tweaks
client	Modrinth	Prism
client	Modrinth	Punchy
client	Modrinth	Resource Pack Options
client	Modrinth	Rolling Down in the Deep
client	Modrinth	Sodium
client	Modrinth	Traveler's Titles
client	Modrinth	Vista Aeronautics Fix
both	Modrinth	AA4 Atlas
both	Modrinth	aero_copycats
both	Modrinth	Aeronautics Camera Sync
both	CurseForge	All The Leaks
both	Modrinth	Antique Transport
both	CurseForge	Architectury
both	Modrinth	Bad Packets
both	Modrinth	Better Archeology
both	Modrinth	Better Tridents
both	CurseForge	Capybara
both	Modrinth	Carry On
both	Modrinth	Cloth Config v15 API
both	Modrinth	Cold Sweat
both	Modrinth	Cold Sweat x Create Aeronautics Compat
both	Modrinth	CoroUtil
both	Modrinth	Create
both	Modrinth	Create Aeronautics
both	Modrinth	Create Auto Track
both	Modrinth	Create Big Cannons
both	Modrinth	Create Deco
both	Modrinth	Create Hypertube
both	CurseForge	Create Tracks
both	Modrinth	Create: Copycats+
both	Modrinth	Create: Deep Dark
both	Modrinth	Create: Dragons Plus
both	Modrinth	Create: Enchantment Industry
both	Modrinth	Create: Sound of Steam
both	Modrinth	Create: Sound of Steam: Tuning Wrench
both	Modrinth	Create: Steam 'n' Rails 1.21.1
both	Modrinth	Create: The Factory Must Grow
both	Modrinth	create: things and misc
both	Modrinth	Create: Towed
both	Modrinth	Curios API
both	CurseForge	Domum Ornamentum
both	Modrinth	Dynamic Trees
both	Modrinth	Dynamic Trees Plus
both	Modrinth	Easy Anvils
both	Modrinth	Enderman Overhaul
both	Modrinth	Etched
both	Modrinth	Exposure
both	Modrinth	Exposure Polaroid
both	Modrinth	Ferrite Core
both	Modrinth	Forgified Fabric API
both	Modrinth	GeckoLib 4
both	Modrinth	Gravestone Mod
both	Modrinth	Immersive Armors
both	Modrinth	Immersive Enchanting
both	Modrinth	Immersive Melodies
both	Modrinth	JamLib
both	Modrinth	Kotlin for Forge
both	Modrinth	LibJF
both	Modrinth	Lithium
both	CurseForge	MineColonies
both	Modrinth	ModernFix
both	Modrinth	Moonlight Lib
both	CurseForge	Multi-Piston
both	Modrinth	Naturalist
both	CurseForge	OctoLib
both	Modrinth	Open Parties and Claims
both	CurseForge	Pathfinding Edition For Minecolonies
both	Modrinth	Ping Wheel
both	Modrinth	Player Animator
both	Modrinth	Polymorph
both	Modrinth	Puzzles Lib
both	Modrinth	Resourceful Lib
both	Modrinth	Resourcefulconfig
both	Modrinth	Ritchie's Projectile Library
both	Modrinth	Sable
both	Modrinth	Sinytra Connector
both	Modrinth	Sleep Tight
both	CurseForge	Structurize
both	CurseForge	Stylecolonies
both	Modrinth	Supplementaries
both	Modrinth	Surveyor Map Framework
both	Modrinth	Thick Air
both	CurseForge	Towntalk
both	Modrinth	Traveler's Backpack
both	CurseForge	UI Library Mod
both	Modrinth	Vista
both	Modrinth	Vista: All The Tapes
both	Modrinth	Wakes
both	Modrinth	Wayfinder
both	Modrinth	What Are They Up To
both	Modrinth	YetAnotherConfigLib
both	Modrinth	YUNG's API
EOF

packwiz refresh >> .import-log/run.log 2>&1

if [[ -s .import-log/failures.tsv ]]; then
  printf '\nFailures recorded in .import-log/failures.tsv\n'
  exit 1
fi

printf '\nImport finished successfully.\n'
