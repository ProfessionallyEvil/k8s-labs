#!/usr/bin/env bash 
set -eo pipefail
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

setup_cluster () {
  minikube start --driver=docker --force
  minikube addons enable registry
}

build_images () {
  for target in "${IMAGES[@]}"; do
    cd $(pwd)/$target
    echo -e "\n[+] ======== Building image $target ========\n"
    cat Dockerfile
    TARGET_LOWER=$(echo "$target" | tr '[:upper:]' '[:lower:]')
    eval $(minikube docker-env)
    docker build -t $(minikube ip):5000/arrrspace-$TARGET_LOWER:v1 .
    #docker push $(minikube ip):5000/arrrspace-$TARGET_LOWER:v1
    cd ../
  done; 
}

push_images () {
  for image in "${IMAGES[@]}"; do
    IMAGE_LOWER=$(echo "$image" || tr '[:upper:]' '[:lower:]')
    docker push $(minikube ip):5000/arrrspace-$IMAGE_LOWER:v1
  done;
}

deploy () {
  kubectl apply -f k8s-resources/
}

if [[ "$#" -eq 0 ]]; then
  exit 1
fi;

opt="$1"
case opt in
  createcluster)
  echo -e "[+] Creating a local cluster...\n"
  setup_cluster
  echo "[!] Cluster created"
  ;;
  buildimages)
  echo "[!] Building Docker images"
  build_images
  ;;
  pushimages)
  echo "[+] Loading docker images into k8s cluster"
  push_images
  ;;
  deployservices)
  echo "[+] Applying K8S configs"
  deploy
  kubectl get deployments,services,pods
  ;;
  all)
  setup_cluster
  build_images
  push_images
  deploy
  ;;
esac

# Start up a cluster
#if [[ "$1" -eq "createcluster" || "$1" -eq "all" ]]; then
#  echo -e "[+] Creating a local cluster...\n"
#  setup_cluster
#  echo "[!] Cluster created"
#fi;
#
#if [[ "$1" -eq "buildimages" || "$1" -eq "all" ]]; then
#  echo "[!] Building Docker images"
#  build_images
#fi;
#
#if [[ "$1" -eq "pushimages" || "$1" -eq "all" ]]; then
#  echo "[+] Loading docker images into k8s cluster"
#  push_images
#fi;
#
#if [[ "$1" -eq "deploy" || "$1" -eq "all" ]]; then
#  echo "[+] Applying k8s configs"
#  deploy
#  kubectl get deployments,services,pods
#fi;

#MASTER_NODE_IP=$(sudo minikube ip)
#echo "[!] cluster master node ip: ${MASTER_NODE_IP}"
#echo "[!] All done :)"
