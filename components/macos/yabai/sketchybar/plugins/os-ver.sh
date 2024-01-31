#!/usr/bin/env sh

TOPPROC=$(sw_vers -productVersion; echo " ("; uname -r; echo ")")

sketchybar --set $NAME label="$TOPPROC"
