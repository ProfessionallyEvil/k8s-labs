#!/usr/bin/env bash 

# Get kind
echo "Installing kind"
GO111MODULE="on" go get -u sigs.k8s.io/kind@master
# Add the go bin dir to bash profile
echo "Adding \$GOPATH/bin to ~/.bash_profile"
echo "PATH=$PATH:$(go env GOPATH)/bin" >> ~/.bash_profile
