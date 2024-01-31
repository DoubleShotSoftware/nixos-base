#!/usr/bin/env sh
space_index=$(echo $NAME  |sed s'/space_//g')
active_space=$(yabai -m query --spaces --space $space_index --display  |jq 'select(."has-focus"==true)')
windows=$(yabai  -m query --windows --space $space_index |jq 'select(.[] | length > 0)')
DRAWING=$([ "$windows" == "" ] && echo "off" || echo "on")
echo $DRAWING

args=()
if [ "$NAME" != "space_template" ]; then
  args+=(--set $NAME label=$NAME \
                     icon.highlight=$SELECTED)
fi

if [ "$SELECTED" = "true" ]; then
  args+=(--set spaces_$space_index.label label=${NAME#"space_$space_index."} \
         --set $NAME icon.background.y_offset=-9              )
else
  args+=(--set $NAME icon.background.y_offset=-20)
fi

sketchybar -m --animate tanh 0 "${args[@]}"
sketchybar --set $NAME \
  icon.highlight=$SELECTED \
