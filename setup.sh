#!/usr/bin/env bash 
set -eo pipefail
set -x
IFS=$'\n\t'

IMAGES=(
  "gateway"
)
DEPS=()

build_images () {
  eval $(minikube docker-env)
  for target in "${IMAGES[@]}"; do
    cd $(pwd)/$target
    echo -e "\n[+] ======== Building image $target ========\n"
    cat Dockerfile
    TARGET_LOWER=$(echo "$target" | tr '[:upper:]' '[:lower:]')
    docker build -t arrrspace-$TARGET_LOWER:v1 .
    cd ../
  done; 
}

build_images