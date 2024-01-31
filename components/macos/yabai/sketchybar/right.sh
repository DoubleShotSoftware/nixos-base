#!/usr/bin/env sh
source "$HOME/.config/sketchybar/theme.sh" # Loads all defined colors
source "$HOME/.config/sketchybar/icons.sh" # Loads all defined icons


source $HOME/.config/sketchybar/plugins/upcoming/plugin.sh

# # Updates Widget
# sketchybar --add item updates right                                                 \
#            --set updates update_freq=1800                                             \
#                        icon=""                                                  \
#                        icon.font="Font Awesome 6 Free:Solid:13.3"                     \
#                        icon.padding_right=7                                          \
#                        icon.color=0xffc382db                                        \
#                        icon.y_offset=2                                          \
#                        label.y_offset=2                                          \
#                        label.font="$FONT:Bold:10.6"                           \
#                        label.color=0xffc382db                                       \
#                        label.padding_right=8                                      \
#                        background.color=0xffc382db                            \
#                        background.height=2                                       \
#                        background.y_offset=-9                                       \
#                        background.padding_right=7                                \
#                        script="$PLUGIN_DIR/package_monitor.sh"                              \
#                        icon.padding_left=0 label.padding_right=2                  \
sketchybar --add item  cpu right                                                 \
           --set cpu   update_freq=10                                             \
                       icon.font="Font Awesome 6 Free:Solid:13.3"                      \
                       icon.padding_right=$ICON_PADDING                                          \
                       icon.color=0xffe3c392                                        \
                       icon.y_offset=2                                          \
                       label.y_offset=2                                          \
                       label.font="$FONT:Bold:10.6"                                  \
                       label.color=0xffe3c392                                   \
                       label.padding_right=$ICON_PADDING                                      \
                       background.color=0xffe3c392                            \
                       background.height=2                                       \
                       background.y_offset=-9                                       \
                       background.padding_right=$PADDING                                          \
                       background.padding_left=$PADDING \
                       script="$PLUGIN_DIR/cpu.sh"                              \
                       icon.padding_left=0 label.padding_right=2                  \
# mem Widget
sketchybar --add item  mem right                                                 \
           --set mem   update_freq=10                                             \
                       icon.font="Font Awesome 6 Free:Solid:13.3"                      \
                       icon.padding_right=4                                          \
                       icon.color=0xffcf6d72                                        \
                       icon.y_offset=2                                          \
                       label.y_offset=2                                          \
                       label.font="$FONT:Bold:10.6"                                  \
                       label.color=0xfff0767b                                   \
                       label.padding_right=8                                      \
                       background.color=0xfff0767b                            \
                       background.height=2                                       \
                       background.y_offset=-9                                       \
                       background.padding_right=$PADDING                                          \
                       background.padding_left=$PADDING \
                       script="$PLUGIN_DIR/mem.sh"                              \
                       icon.padding_left=0 label.padding_right=2                  \
# ssd Widget
sketchybar --add item  ssd right                                                 \
           --set ssd   update_freq=10                                             \
                       icon.font="Font Awesome 6 Free:Solid:13.3"                      \
                       icon.padding_left=$ICON_PADDING                                          \
                       icon.color=$ICON_SSD_COLOR                                        \
                       icon.y_offset=2                                          \
                       label.y_offset=2                                          \
                       label.font="$FONT:Bold:10.6"                                  \
                       label.color=$ICON_SSD_COLOR                                   \
                       label.padding_right=$ICON_PADDING                                      \
                       background.color=$BACKGROUND                            \
                       background.height=2                                       \
                       background.y_offset=-9                                       \
                       script="$PLUGIN_DIR/disk.sh"                              \
                       icon.padding_left=0 label.padding_right=2                  \
# Battery Widget
sketchybar --add item battery right                                                 \
           --set battery update_freq=10                                             \
                       icon.font="Font Awesome 6 Free:Solid:13.3"                      \
                       icon.padding_left=$OUTER_PADDING                                          \
                       icon.color=$ICON_BATTERY_COLOR                                        \
                       icon.y_offset=2                                          \
                       label.y_offset=2                                          \
                       label.font="$FONT:Bold:10.6"                           \
                       label.color=$ICON_BATTERY_COLOR                                       \
                       label.padding_right=$ICON_PADDING                                      \
                       background.color=$BACKGROUND                            \
                       background.height=2                                       \
                       background.y_offset=-9                                       \
                       script="$PLUGIN_DIR/battery.sh"                              

# Combine Right
sketchybar --add bracket right_items \
  cpu \
  mem \
  ssd \
  battery \
  --set right_items \
      background.color=$BACKGROUND \
      background.height=$BAR_HEIGHT \
      background.corner_radius=$BRACKET_RADIUS \
      background.border_color=$BORDER_COLOR \
      background.border_width=$BORDER_SIZE 
