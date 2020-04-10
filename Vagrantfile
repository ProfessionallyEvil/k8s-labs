# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
# config file
opts = YAML.load(File.read("./opts.yml"))
# p opts

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false 
    vb.name = "Arrrspace-dev"
    # Customize the amount of memory on the VM:
    vb.memory = "4096"
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end

  # docker
  config.vm.provision "shell", inline: <<-SHELL
    apt update
    apt install dos2unix -y
    apt install gcc -y
    curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
    usermod -aG docker vagrant
  SHELL
  # golang
  config.vm.provision "shell", inline: <<-SHELL
    wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz -nv -O go.tar.gz
    tar -C /usr/local -xzf go.tar.gz
    echo "export PATH=$PATH:/usr/local/go/bin:/home/vagrant/go/bin" >> /etc/profile
    source /etc/profile
    
  SHELL
  # minikube
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt install conntrack
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
      && chmod +x minikube
    sudo install ./minikube /usr/local/bin
    rm ./minikube
  SHELL
  # kubectl
  config.vm.provision "shell", inline: <<-SHELL
    echo "[+] Installing kubectl..."
    export URL_BASE=https://storage.googleapis.com/kubernetes-release/release/
    export VER=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
    # assuming 64 bit linux here.
    # can expand this later to work for other systems, maybe.
    echo "[!] kubectl version: $VER"
    export URL="$URL_BASE$VER/bin/linux/amd64/kubectl"
    echo "[!] $URL"
    curl -LO $URL
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    echo "[!] $(kubectl version --short --client)"
    echo "[!] Done!"
  SHELL
  # arrrspace
  config.vm.provision "shell", inline: <<-SHELL
    sudo su - vagrant -c "cd /src && ./setup.sh"
  SHELL
  # grab ssh key for pushing to github
  config.vm.provision "file", source: opts["sshKeyFile"], destination: "$HOME/.ssh/id_rsa"
  config.vm.provision "file", source: opts["sshKeyFile"] + ".pub", destination: "$HOME/.ssh/id_rsa.pub"
end
