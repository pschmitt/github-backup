#!/usr/bin/env bash

while true
do
  /run.sh

  echo "Aight. I sleep now."

  if ! sleep "${INTERVAL:-1d}"
  then
    break
  fi
done

# vim: set ft=sh et ts=21 sw=2 sts=2:
