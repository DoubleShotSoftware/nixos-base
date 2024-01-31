#!/usr/bin/env bash

source $HOME/.config/sketchybar/theme.sh
source $HOME/.config/sketchybar/icons.sh

sketchybar -m --add item upcoming right \
  --set upcoming popup.background.color=0xff000000 \
  --set upcoming popup.height=20 \
	--set upcoming click_script="sketchybar -m --set upcoming popup.drawing=toggle" \
  --set upcoming update_freq=20 \
      updates=on \
      script="~/.config/sketchybar/plugins/upcoming/script.py" \
      icon=""                                                  \
      icon.padding_left=5                                          \
      icon.color=$ICON_COLOR                                        \
      icon.y_offset=2                                          \
      icon.font="Hack Nerd Font:Regular:14" 

sketchybar --add bracket upcoming_bracket \
  upcoming \
  --set upcoming_bracket \
      background.color=$BACKGROUND \
      background.height=$BAR_HEIGHT \
      background.corner_radius=$BRACKET_RADIUS \
      background.border_color=$BORDER_COLOR \
      background.border_width=$BORDER_SIZE \
