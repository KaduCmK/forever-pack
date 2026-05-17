#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

remove_if_exists() {
  local file="$1"
  if [[ -f "$file" ]]; then
    rm -f "$file"
  fi
}

set_side() {
  local file="$1"
  local side="$2"
  local tmp
  tmp="$(mktemp)"

  awk -v side="$side" '
    BEGIN { replaced = 0 }
    /^side = "/ {
      print "side = \"" side "\""
      replaced = 1
      next
    }
    { print }
    END {
      if (!replaced) {
        print "side = \"" side "\""
      }
    }
  ' "$file" > "$tmp"

  mv "$tmp" "$file"
}

remove_if_exists "mods/alexandria.pw.toml"
remove_if_exists "mods/creeper-confetti-plus.pw.toml"
remove_if_exists "mods/playeranimatorapi.pw.toml"
remove_if_exists "mods/create-industry.pw.toml"
remove_if_exists "mods/jade-addons-forge.pw.toml"
remove_if_exists "resourcepacks/capybaras.pw.toml"

set_side "mods/c2me-neoforge.pw.toml" "server"
set_side "mods/camera-utils.pw.toml" "client"
set_side "mods/cit-resewn.pw.toml" "client"
set_side "mods/gravestone-x-curios-api-compat.pw.toml" "server"
set_side "mods/highlighter.pw.toml" "client"
set_side "mods/jade.pw.toml" "client"
set_side "mods/jade-addons.pw.toml" "client"
set_side "mods/jade-addons-tfmg-multimeter-support.pw.toml" "client"
set_side "mods/respackopts.pw.toml" "client"

packwiz refresh
