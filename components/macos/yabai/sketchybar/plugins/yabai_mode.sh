#!/usr/bin/env sh
source $HOME/.config/sketchybar/theme.sh
source $HOME/.config/sketchybar/icons.sh

yabai_mode=$(yabai -m query --spaces --display | jq -r 'map(select(."has-focus" == true))[-1].type')

case "$yabai_mode" in
    bsp)
    sketchybar -m --set yabai_mode icon="" label="BSP"
    ;;
    stack)
    sketchybar -m --set yabai_mode icon="﯅" label="STACK"
    ;;
    float)
    sketchybar -m --set yabai_mode icon="" label="FLOAT"
    ;;
esac
