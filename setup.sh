#!/usr/bin/env bash 
set -eo pipefail
set -x
IFS=$'\n\t'

IMAGES=(
  "gateway" 
  "jenkinsSvc" 
  "base"
)
DEPS=()

# has docker?
if [[ ! $(which docker 2>/dev/null) ]]; then
  echo "[!] Error: Docker does not appear to be installed"
  exit 1
fi
# has docker running?
if [[ ! $(pgrep -f docker) ]]; then
  echo "[!] Error: Docker daemon does not appear to be running"
  exit 1
fi
# has minikube?
if [[ ! $(which minikube 2>/dev/null) ]]; then
  echo "[!] Error: Minikube does not appear to be installed"
  exit 1
fi
# has kubectl
if [[ ! $(which kubectl 2>/dev/null) ]]; then
  echo "[!] Error: kubectl does not appear to be installed"
  exit 1
fi

setup_cluster () {
  # todo allow for cli flag specifcation of the driver
  minikube start --driver=docker
  #minikube addons enable registry
}

build_images () {
  eval $(minikube docker-env)
  for target in "${IMAGES[@]}"; do
    cd $(pwd)/$target
    echo -e "\n[+] ======== Building image $target ========\n"
    cat Dockerfile
    TARGET_LOWER=$(echo "$target" | tr '[:upper:]' '[:lower:]')
    minikube image build -t k8s-labs-$TARGET_LOWER .
    cd ../
  done; 
}

deploy () {
  kubectl apply -f k8s-resources/
}

setup_cluster
build_images
deploy
