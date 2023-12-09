#!/usr/bin/env bash

if [[ -d /ssh ]]
then
  echo "Copying SSH keys from /ssh to ~/.ssh" >&2
  mkdir -p ~/.ssh
  cp /ssh/id_* ~/.ssh
  chmod 700 ~/.ssh
  chmod 400 ~/.ssh/id_*

  eval "$(ssh-agent)"
  find ~/.ssh -iname 'id_*' -not -iname '*.pub' -exec ssh-add {} \;
fi

while true
do
  /run.sh

  echo "Aight. I sleep now." >&2

  if ! sleep "${INTERVAL:-1d}"
  then
    break
  fi
done

# vim: set ft=sh et ts=21 sw=2 sts=2:
