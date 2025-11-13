#!/usr/bin/env bash
set -euo pipefail

# Find every package.json in the current repo (or cwd if not in a git repo).

if ! command -v rg >/dev/null 2>&1; then
  printf "rg (ripgrep) is required to run this script.\n" >&2
  exit 1
fi

target_dir="${1:-}"

if [[ -n "${target_dir}" ]]; then
  if [[ -d "${target_dir}" ]]; then
    search_root="$(cd "${target_dir}" && pwd -P)"
  else
    printf "Provided path is not a directory: %s\n" "${target_dir}" >&2
    exit 1
  fi
elif git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  search_root="${git_root}"
else
  search_root="$(pwd -P)"
fi

cd "${search_root}"

matches="$(rg --files -g 'package.json' || true)"

if [[ -n "${matches}" ]]; then
  printf "%s\n" "${matches}"
else
  printf "No package.json files found in %s\n" "${search_root}" >&2
fi
