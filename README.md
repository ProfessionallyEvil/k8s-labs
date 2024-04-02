# ProfessionallyEvil Kubernetes Labs (k8s-labs) :closed_lock_with_key:

Welcome to the ProfessionallyEvil Kubernetes Labs (k8s-labs) GitHub repository. 
This repository houses a deliberately vulnerable k8s cluster and vulnerable services that aim to emulate a realistic scenario ripe for attacking :mag_right: :bug:

## Getting Started :rocket:
- Setup a cluster locally
  - [kind](https://kind.sigs.k8s.io/) is recommended for this
- Run `setup.sh` which will build the images for this repo, load them into the cluster, and deploy the vulnerable k8s resources
- Access the external API gateway at `localhost:31337/api` and start hacking

## Guide
See [guide.md](/guide.md) for one way to hack the cluster.

## Stay Tuned :satellite:

Keep an eye on this repository for the latest updates and new lab additions. We are continuously evolving our content. :hourglass_flowing_sand:
