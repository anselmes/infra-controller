#!/usr/bin/env bash
# Load locally built Docker images into an Apple `container` Kubernetes cluster.
set -Eeuo pipefail

TMP_DIR=""

usage() {
  echo "usage: ${0##*/} <cluster> <image>..." >&2
}

cleanup() {
  [[ -n "${TMP_DIR}" ]] && rm -rf "${TMP_DIR}"
}

main() {
  if [[ $# -lt 2 || "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    return 2
  fi
  local cluster="$1"
  shift
  TMP_DIR="$(mktemp -d)"
  trap cleanup EXIT

  local img
  for img in "$@"; do
    echo "Loading ${img} into ${cluster}..."
    docker save -o "${TMP_DIR}/image.tar" "${img}"
    container image load --input "${TMP_DIR}/image.tar"
    container cluster load-image --name "${cluster}" "${img}"
  done
}

main "$@"
