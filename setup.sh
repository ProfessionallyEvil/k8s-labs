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

# Start up a cluster
echo -e "[+] Creating a local cluster...\n"
minikube start --driver=docker --force
## apply kubectl config
#export KUBECONFIG="$(kind get kubeconfig-path --name="arrrspace")"
## need to load images and apply the configurations to the cluster.

echo "[!] Cluster created"

echo "[!] Building Docker images"

for target in "${IMAGES[@]}"; do
  cd $(pwd)/$target
  echo -e "\n[+] ======== Building image $target ========\n"
  cat Dockerfile
  TARGET_LOWER=$(echo "$target" | tr '[:upper:]' '[:lower:]')
  docker build -t arrrspace-$TARGET_LOWER:v1 .
  cd ../
done;

# Enable the insecure docker registry
minikube addons enable docker-registry

#echo "[+] Loading docker images into k8s cluster"
#
#for target in "${IMAGES[@]}"; do
#  TARGET_LOWER=$(echo "$target" | tr '[:upper:]' '[:lower:]')
#  echo -e "[+] Loading arrrspace-${target} image"
#  kind load docker-image arrrspace-$TARGET_LOWER:v1 --name arrrspace
#done

echo "[+] Applying k8s configs"

kubectl apply -f k8s-resources/
kubectl get deployments,services,pods

MASTER_NODE_IP=$(sudo minikube ip)
echo "[!] cluster master node ip: ${MASTER_NODE_IP}"
echo "[!] All done :)"
