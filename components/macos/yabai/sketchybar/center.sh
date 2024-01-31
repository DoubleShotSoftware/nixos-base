#!/usr/bin/env sh
source "$HOME/.config/sketchybar/theme.sh" # Loads all defined colors
source "$HOME/.config/sketchybar/icons.sh" # Loads all defined icons

# Curent procces name
sketchybar --add       event        window_focus                         \
           --add       event        title_change                         \
           --add       item         window_title left                    \
           --set       window_title  \
              script="$PLUGIN_DIR/window_title.sh" \
              label.font="$PRIMARY_FONT:Italic:14"        \
              label.y_offset=2                    \
              label.padding_left=-0               \
              label.color=0xffd5d9dd              \
              icon=""                                                  \
              icon.padding_right=5                                          \
              icon.color=$ICON_COLOR                                        \
              icon.y_offset=2                                          \
              icon.font="Hack Nerd Font:Regular:14" \
               background.padding_right=$PADDING                                          \
               background.padding_left=$PADDING \
           --subscribe window_title window_focus title_change           \

# Time Widget
sketchybar --add item clock right                                                \
           --set clock update_freq=5                                             \
                       icon=""                                                  \
                       icon.font="Font Awesome 6 Free:Solid:13.3"                 \
                       icon.color=0xff55d0f0                                        \
                       icon.y_offset=2                                          \
                       label.y_offset=2                                          \
                       label.font="$PRIMARY_FONT:BoldItalic:16"                           \
                       label.color=0xff55d0f0                                       \
                       label.padding_right=5                                      \
                       background.color=0xff55f0f0                            \
                       background.height=2                                       \
                       background.padding_right=3                                \
                       background.y_offset=-9                                       \
                       background.padding_right=$PADDING                                          \
                       background.padding_left=$PADDING \
                       script="$PLUGIN_DIR/clock.sh"                              


# Combine Center
sketchybar --add bracket center_left \
  window_title \
  --set center_left \
      background.color=$BACKGROUND \
      background.height=$BAR_HEIGHT \
      background.corner_radius=$BRACKET_RADIUS \
      background.border_color=$BORDER_COLOR \
      background.border_width=$BORDER_SIZE
sketchybar --add bracket center_right \
  clock \
  --set center_right \
      background.color=$BACKGROUND \
      background.height=$BAR_HEIGHT \
      background.corner_radius=$BRACKET_RADIUS \
      background.border_color=$BORDER_COLOR \
      background.border_width=$BORDER_SIZE
