#!/usr/bin/env bash 
set -eo pipefail
set -x
IFS=$'\n\t'

IMAGES=(
  "gateway"
)
DEPS=()

build_images () {
  for target in "${IMAGES[@]}"; do
    cd $(pwd)/$target
    echo -e "\n[+] ======== Building image $target ========\n"
    cat Dockerfile
    TARGET_LOWER=$(echo "$target" | tr '[:upper:]' '[:lower:]')
    docker build -t ssrf-$TARGET_LOWER:v1 .
    cd ../
  done; 
}

build_images