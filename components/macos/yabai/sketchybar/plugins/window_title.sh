#!/usr/bin/env sh

update() {
  sketchybar --set $NAME label="$INFO"
}

WINDOW_APP=$(yabai -m query --windows --window | jq -r '.app' | sed 's/\(.\{68\}\).*/\1.../')
WINDOW_TITLE=$(yabai -m query --windows --window | jq -r '.title' | sed 's/\(.\{68\}\).*/\1.../')
TITLE="$WINDOW_APP › ${WINDOW_TITLE:0:24}"
sketchybar --set $NAME label="$TITLE"
