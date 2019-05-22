#!/usr/bin/env bash 
set -eou pipefail
#set -x
IFS=$'\n\t'

IMAGES=("app" "gateway" "authSvc")
DEPS=()

# has golang?
if [[ ! $(which go 2>/dev/null) ]]; then
  echo "[!] Error: Golang does not appear to be installed."
  exit 1
fi
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

# Get kind
if [[ ! $(which kind 2>/dev/null) ]]; then
  echo "[+] Installing kind..."
  GO111MODULE="on" go get -u sigs.k8s.io/kind@master
  # Add the go bin dir to bash profile
  echo "[+] Adding \$GOPATH/bin to PATH and ~/.bashrc"
  echo "export PATH=\$PATH:\$(go env GOPATH)/bin" >> ~/.bashrc
  echo "[!] $(kind version 2>&1)"
else
  echo "[!] kind installed $(kind version 2>&1)"
fi

# install kubectl
if [[ ! $(which kubectl 2>/dev/null) ]]; then
  echo "[+] Installing kubectl..."
  URL_BASE=https://storage.googleapis.com/kubernetes-release/release/
  VER=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
  # assuming 64 bit linux here.
  # can expand this later to work for other systems, maybe.
  echo "[!] kubectl version: $VER"
  URL="$URL_BASE$VER/bin/linux/amd64/kubectl"
  echo "[!] $URL"
  curl -LO $URL
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  echo "[!] $(kubectl version --short --client)"
  echo "[!] Done!"
else
  echo "[!] kubectl installed"
  echo "    $(kubectl version --short --client)"
fi

# Start up a cluster
echo -e "[+] Creating a local cluster...\n"
if [[ $(kind get clusters | grep "arrrspace") ]]; then
  kind delete cluster --name arrrspace >/dev/null
fi
kind create cluster --name arrrspace
# apply kubectl config
export KUBECONFIG="$(kind get kubeconfig-path --name="arrrspace")"
# need to load images and apply the configurations to the cluster.

echo "[!] Cluster created"

echo "[!] Building Docker images"

for target in "${IMAGES[@]}"; do
  cd ./$target
  echo -e "\n[+] ======== Building image $target ========\n"
  cat Dockerfile
  TARGET_LOWER=$(echo "$target" | tr '[:upper:]' '[:lower:]')
  docker build -t arrrspace-$TARGET_LOWER:v1 .
  cd ../
done;

echo "[!] Loading docker images into k8s cluster"

for target in "${IMAGES[@]}"; do
  TARGET_LOWER=$(echo "$target" | tr '[:upper:]' '[:lower:]')
  echo -e "[+] Loading arrrspace-${target} image"
  kind load docker-image arrrspace-$TARGET_LOWER --name arrrspace
done

echo "[!] Applying k8s configs"

kubectl apply -f k8s-resources/
kubectl get deployments,services,pods

echo "[!] All done :)"
