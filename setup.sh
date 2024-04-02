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

setup_cluster () {
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 8080
    hostPort: 31337 
    protocol: TCP
EOF

  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
}

build_images () {
  eval $(minikube docker-env)
  for target in "${IMAGES[@]}"; do
    cd $(pwd)/$target
    echo -e "\n[+] ======== Building image $target ========\n"
    cat Dockerfile
    TARGET_LOWER=$(echo "$target" | tr '[:upper:]' '[:lower:]')
    docker image build -t k8s-labs-$TARGET_LOWER:v1 .
    kind load docker-image k8s-labs-$TARGET_LOWER:v1
    cd ../
  done; 
}

deploy () {
  kubectl apply -f k8s-resources/
}

setup_cluster
build_images
deploy
