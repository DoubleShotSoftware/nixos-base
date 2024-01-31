#!/usr/bin/env bash
ACTIVE_SPACE=$1
MODE=$2
if [ "$MODE" == "switch" ]
then
  yabai -m space --focus $ACTIVE_SPACE || true
else
  yabai -m window --space $ACTIVE_SPACE || true
fi
sleep 0.250
ACTIVE_SPACES=$(yabai -m query --spaces --display |jq -r '.[] | @base64'); 
ACTIVE_WINDOWS=$(yabai  -m query --windows --display)

for raw_space in $ACTIVE_SPACES 
do
  space=$(echo $raw_space |base64 -d)
  index=$(echo $space|jq .index)
  hasFocus=$(echo $space |jq '."has-focus"')
  windows=$(echo $ACTIVE_WINDOWS |jq --argjson space $index '.[] | select(.space == $space)')
  if [ "$windows" == "" ] && [ "$hasFocus" == "false" ]
  then
    DRAWING="off" 
  else 
    DRAWING="on"
  fi
  HIGHLIGHT=$([ "$hasFocus" == "true" ] && echo true || echo false)
  sketchybar --set space_$index  drawing=$DRAWING icon.highlight=$HIGHLIGHT
done


