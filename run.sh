#!/usr/bin/env bash

cd "$(readlink -f "$(dirname "$0")")" || exit 9

GITHUB_USERNAME=${GITHUB_USERNAME:-${USER}}
DATA_DIR="${DATA_DIR:-${PWD}/data}"
DATE_FORMAT="${DATE_FORMAT:--Iseconds}"

# shellcheck disable=1091
source .envrc 2>/dev/null

set -e
# set -x

export PATH=$PATH:/home/pschmitt/.local/bin/github-backup

install_github-backup() {
  if ! command -v github-backup > /dev/null
  then
    pip3 install --user github-backup
  fi
}

list_gh_orgs() {
  curl -fsSL -X GET --header "Authorization: Bearer ${GITHUB_TOKEN}" \
    "https://api.github.com/users/${GITHUB_USERNAME}/orgs?per_page=1000" | \
    jq -r '.[].login'
}

gh_backup() {
  local args=()

  case "$1" in
    org|--org|-o)
      args=(-O)
      shift
      ;;
  esac

  local dest="${1:$GITHUB_USERNAME}"

  if github-backup -i \
    -t "$GITHUB_TOKEN" \
    --all \
    --private \
    --assets \
    --prefer-ssh \
    "${args[@]}" \
    -o "${DATA_DIR}/${dest}" \
    "$dest"
  then
    date "$DATE_FORMAT" | sudo tee "${DATA_DIR}/${dest}/LAST_UPDATED"
  fi
}

gh_backup_all_orgs() {
  local org

  for org in $(list_gh_orgs)
  do
    gh_backup -o "$org"
  done
}

install_github-backup

mkdir -p "$DATA_DIR"

# There are less orgs than personal repos. So let's start with those.
gh_backup_all_orgs
gh_backup "$GITHUB_USERNAME"
date "$DATE_FORMAT" | sudo tee "${DATA_DIR}/LAST_UPDATED"
