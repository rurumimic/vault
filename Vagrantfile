# -*- mode: ruby -*-
# vi: set ft=ruby :

$nums = 1
$name = "node"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.synced_folder "share", "/share"

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 1
    vb.memory = "1024"
  end

  (1..$nums).each do |i|
    config.vm.define vm_name = "%s%d" % [$name, i] do |config|
      config.vm.hostname = vm_name
      config.vm.network "private_network", ip: "192.168.33.#{i+100}"
      config.vm.network "forwarded_port", guest: 8020, host: 8020, host_ip: "127.0.0.1", auto_correct: true
    end
  end

  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"

  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
