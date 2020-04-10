# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/bionic64"
  config.disksize.size = '50GB'

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "./", "/src"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false 
    vb.name = "Arrrspace-dev"
    # Customize the amount of memory on the VM:
    vb.memory = "4096"
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # docker
  config.vm.provision "shell", inline: <<-SHELL
    apt update
    apt install dos2unix -y
    apt install gcc -y
    curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
    usermod -aG docker vagrant
  SHELL
  # golang
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz -nv -O go.tar.gz
    sudo tar -C /usr/local -xzf go.tar.gz
    sudo su -c 'echo "export PATH=$PATH:/usr/local/go/bin:/home/vagrant/go/bin" >> /etc/profile'
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
end
