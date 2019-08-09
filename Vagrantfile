# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# Load settings from vagrant.yml or vagrant.yml.dist
current_dir = File.dirname(File.expand_path(__FILE__))
if File.file?("#{current_dir}/vagrant.yml")
  config_file = YAML.load_file("#{current_dir}/vagrant.yml")
elsif
  config_file = YAML.load_file("#{current_dir}/vagrant.yml.dist")
else
  exit(1)
end

base_settings = config_file['configs'][config_file['configs']['use']]
puts "%s" % base_settings

ansible_node_settings = config_file['ansible_node']
proxy_node_settings = config_file['proxy_node']
remote_node_settings = config_file['remote_node']


# define scripts
def generate_node_ip(base_settings, id)
  node_ip_range = base_settings['ip_range']
  node_ip_id = Integer(id)
  node_ip = [ node_ip_range, node_ip_id ].join('.')
end

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
  #config.vm.box = "centos/7"
  #config.vm.box = "bento/ubuntu-16.04"
  #config.vm.box = "bento/debian-10"
  config.vm.box = "ubuntu/xenial64"

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
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  config.vm.provider "virtualbox" do |v|
    v.gui = false
  end

  # Create a remote node
  remote_node_name = remote_node_settings['name']
  config.vm.define remote_node_name do |remote_node|

    remote_node.vm.network remote_node_settings['external_network'], ip: remote_node_settings['external_ip'], netmask: base_settings["external_netmask"]
    remote_node.vm.provider "virtualbox" do |vb|
      vb.name = remote_node_name
      vb.memory = remote_node_settings['memory']
      vb.cpus = remote_node_settings['cpus']
      vb.linked_clone = true
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      # Enable NAT hosts DNS resolver
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end
    remote_node.vm.post_up_message = "Remote node spun up!"

  end

  # Create a proxy node
  proxy_node_name = proxy_node_settings['name']
  config.vm.define proxy_node_name do |proxy_node|

    proxy_node.vm.network proxy_node_settings['external_network'], ip: proxy_node_settings['external_ip'], netmask: base_settings["external_netmask"]
    proxy_node.vm.provider "virtualbox" do |vb|
      vb.name = proxy_node_name
      vb.memory = proxy_node_settings['memory']
      vb.cpus = proxy_node_settings['cpus']
      vb.linked_clone = true
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      # Enable NAT hosts DNS resolver
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end
    proxy_node.vm.post_up_message = "Proxy node spun up!"

  end

  # Create a machine to run ansible
  ansible_node_name = ansible_node_settings['name']
  config.vm.define ansible_node_name do |ansible_node|

    ansible_node.vm.network ansible_node_settings['external_network'], ip: ansible_node_settings['external_ip'], netmask: base_settings["external_netmask"]
    ansible_node.vm.provider "virtualbox" do |vb|
      vb.name = ansible_node_name
      vb.memory = ansible_node_settings['memory']
      vb.cpus = ansible_node_settings['cpus']
      vb.linked_clone = true
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      # Enable NAT hosts DNS resolver
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end
    ansible_node.vm.post_up_message = "Ansible node spun up!"

    # Enable provisioning with a shell script. Additional provisioners such as
    # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
    # documentation for more information about their specific syntax and use.
    # config.vm.provision "shell", inline: <<-SHELL
    #   apt-get update
    #   apt-get install -y apache2
    # SHELL
    if Vagrant::Util::Platform.windows?
  #    config.vm.provision :guest_ansible do |ansible|
      ansible_node.vm.provision :ansible_local do |ansible|

        ansible_node.vm.synced_folder ".", "/vagrant",
          owner: "vagrant",
          mount_options: ["dmode=775,fmode=600"]

        # ansible.install_mode = "pip"
        # ansible.version = "2.8.3"
        ansible.compatibility_mode = "2.0"
        ansible.install = true
        ansible.limit = "all"
        ansible.verbose = "v"

        ansible.config_file = "ansible.cfg"
        ansible.inventory_path = "hosts-vagrant.yml"
        ansible.playbook = "test-proxy.yml"

        ansible.galaxy_role_file = "requirements.yml"
        ansible.galaxy_roles_path = "roles"
      end
    else
      config.vm.provision :ansible do |ansible|
        ansible.playbook = "test-proxy.yml"
      end
    end

  end

end
