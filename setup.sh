#!/usr/bin/env bash 
set -eou pipefail
set -x
IFS=$'\n\t'

IMAGES=(
  "app" 
  "gateway" 
  "authSvc" 
  "jenkinsSvc" 
  "feedSvc" 
  "profileSvc"
  "simpleStorage"
  "dbaseSvc"
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

echo "[!] Building Docker images"

for target in "${IMAGES[@]}"; do
  cd ./$target
  echo -e "\n[+] ======== Building image $target ========\n"
  cat Dockerfile
  TARGET_LOWER=$(echo "$target" | tr '[:upper:]' '[:lower:]')
  docker build -t arrrspace-$TARGET_LOWER:v1 .
  cd ../
done;

echo "[!] All done :)"