#!/usr/bin/env sh

ACTIVE_SPACES=$(yabai -m query --spaces |jq -r '.[] | @base64'); 

for raw_space in $ACTIVE_SPACES 
do
  space=$(echo $raw_space |base64 -d)
  index=$(echo $space|jq .index)
sketchybar --add   space space_$index left         \
    --set space_$index                 \
    position=left                      \
    drawing=on                         \
    associated_space=$index            \
    icon=$index                        \
    icon.padding_right=$ICON_PADDING   \
    icon.padding_left=$ICON_PADDING   \
    label.color=$ICON_COLOR             \
    icon.color=$INACTIVE_ICON_COLOR             \
    icon.highlight_color=$ICON_COLOR             \
    icon.highlight=false               \
    label.drawing=off                  \
    # script="$PLUGIN_DIR/space.sh"      \
    click_script="$SPACE_CLICK_SCRIPT" \
    ignore_association=on             
done

sketchybar   --add item  space_seperator left                          \
             --set space_seperator  icon=┃                                  \
                              icon.font="$FONT:Regular:9.0" \
                              background.padding_left=$PADDING              \
                              background.padding_right=$PADDING             \
                              icon.y_offset=1                         \
                              label.drawing=off                       \
                              icon.color=$ICON_COLOR

sketchybar -m --add item yabai_mode left \
              --set yabai_mode \
                update_freq=3 \
                script="~/.config/sketchybar/plugins/yabai_mode.sh" \
                click_script="~/.config/sketchybar/plugins/yabai_mode_click.sh" \
                icon.font="Hack Nerd Font:Regular:9.0" \
              --subscribe yabai_mode space_change
sketchybar --add bracket spaces_bracket \
  space_1 \
  space_2 \
  space_3 \
  space_4 \
  space_5 \
  space_6 \
  space_7 \
  space_8 \
  space_9 \
  space_10 \
  space_11 \
  space_seperator \
  yabai_mode \
  --set spaces_bracket \
      background.color=$BACKGROUND \
      background.height=$BAR_HEIGHT \
      background.corner_radius=$BRACKET_RADIUS \
      background.border_color=$BORDER_COLOR \
      background.border_width=$BORDER_SIZE
