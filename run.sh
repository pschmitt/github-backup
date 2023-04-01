#!/usr/bin/env bash

install_github-backup() {
  if ! command -v github-backup > /dev/null
  then
    if ! command -v pipx > /dev/null
    then
      pip install --user pipx
      export PATH="${HOME}/.local/bin:${PATH}"
    fi

    pipx install github-backup
  fi
}

list_gh_orgs() {
  # curl -fsSL -X GET --header "Authorization: Bearer ${GITHUB_TOKEN}" \
  #   "https://api.github.com/users/${GITHUB_USERNAME}/orgs?per_page=1000" | \
  #   jq -er '.[].login'
  curl -X GET \
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
    date "$DATE_FORMAT" | tee "${DATA_DIR}/${dest}/LAST_UPDATED"
  fi
}

gh_backup_all_orgs() {
  local -a orgs
  mapfile -t orgs < <(list_gh_orgs)

  local org
  for org in "${orgs[@]}"
  do
    gh_backup -o "$org"
  done
}

hc() {
  if [[ -z "$HEALTHCHECK_URL" ]]
  then
    echo "HEALTHCHECK_URL not set, skipping healthcheck"
    return 0
  fi

  curl -fsSL "${HEALTHCHECK_URL}${1}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  cd "$(readlink -f "$(dirname "$0")")" || exit 9

  GITHUB_USERNAME=${GITHUB_USERNAME:-${USER}}
  DATA_DIR="${DATA_DIR:-${PWD}/data}"
  DATE_FORMAT="${DATE_FORMAT:--Iseconds}"

  # shellcheck disable=1091
  source .envrc 2>/dev/null

  {
    if [[ -n "${DEBUG:-}" ]]
      then
      set -x
    fi

    set -e
  }

  install_github-backup

  mkdir -p "$DATA_DIR"

  hc "/start"
  {
    # There should be less org than personal repos. So let's start with those.
    gh_backup_all_orgs
    gh_backup "$GITHUB_USERNAME"
  }
  hc

  date "$DATE_FORMAT" | tee "${DATA_DIR}/LAST_UPDATED"
fi
