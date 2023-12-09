#!/usr/bin/env bash

mkdir -p ~/.ssh

if [[ -d /ssh ]]
then
  echo "Copying SSH keys from /ssh to ~/.ssh" >&2

  cp /ssh/id_* ~/.ssh
  chmod 700 ~/.ssh
  chmod 400 ~/.ssh/id_*

  eval "$(ssh-agent)"
  find ~/.ssh -iname 'id_*' -not -iname '*.pub' -exec ssh-add {} \;
fi

touch ~/.ssh/known_hosts
ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2>/dev/null

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
