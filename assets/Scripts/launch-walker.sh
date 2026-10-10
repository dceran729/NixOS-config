#!/usr/bin/env bash

if ! pgrep -x elephant > /dev/null; then
  setsid elephant &
fi

if ! pgrep -f "walker --gapplication-service" > /dev/null; then
  setsid walker --gapplication-service &
fi

exec walker --width 1400 --maxheight 600 --minheight 600 "$@"
