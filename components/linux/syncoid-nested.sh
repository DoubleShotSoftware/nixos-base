#!/usr/bin/env bash
if grep -q "@" <<< "$1"; then
  echo "Building child hierarchy for $1";
  TARGET_BASE="$(echo $1 |sed s'/.*:.*$//g')"
  TARGET_HOST="$(echo $1 |sed s'/:.*$//g')"
  readarray -d ' ' arr <<< "$(echo $1 |sed s'/.*@.*://g'| sed s'/\// /g')"
  for CHILD in "${arr[@]}"
  do
    TARGET_BASE=$(echo $TARGET_BASE/$CHILD| sed s'/ //g' |sed s'/^\///g')
    echo "Creating child data set at target: $TARGET_BASE"
    ssh $TARGET_HOST "zfs create $TARGET_BASE"
  done
fi
