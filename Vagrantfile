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
    mkdir -p /opt/arrrspace/
    sudo cp -r /vagrant/ /opt/arrrspace/
    #cd /home/vagrant/src/ && ./setup.sh
  SHELL
  # grab ssh key for pushing to github
  config.vm.provision "file", source: opts["sshKeyFile"], destination: "$HOME/.ssh/id_rsa"
  config.vm.provision "file", source: opts["sshKeyFile"] + ".pub", destination: "$HOME/.ssh/id_rsa.pub"
end
