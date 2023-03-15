# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Set SSH forwarding, as we may need it for git repos
  config.ssh.forward_agent = true

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "geerlingguy/centos7"

  config.vm.hostname = "vagrant-phantom"

  config.vm.network "forwarded_port", guest: 443, host: 9999, host_ip: "127.0.0.1", auto_connect: true
  config.vm.network "forwarded_port", guest: 8443, host: 9998, host_ip: "127.0.0.1", auto_connect: true

  # VM configuration details. You can adjust it if you need so
  config.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "6096"
      vb.cpus = "2"
   end

   # Provisioning script and some params
   config.vm.provision "shell" do |s|
      s.privileged = false
      s.path = "provisioning/provision.sh"
      s.env = {"PHANTOM_VERSION" => ENV["PHANTOM_VERSION"]}
   end

   # Backup the instance when destroying... 
   # Maybe we need a better trigger, as this can take a lot of time
   config.trigger.before :destroy do |trigger|
     trigger.warn = "TODO: Dumping current backup to /vagrant/backup"
     trigger.run_remote = {path: "provisioning/backup.sh"}
   end

end
