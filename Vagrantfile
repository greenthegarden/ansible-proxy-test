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
service_node_settings = config_file['service_node']

# define scripts
def generate_node_ip(base_settings, id)
  node_ip_range = base_settings['ip_range']
  node_ip_id = Integer(id)
  node_ip = [ node_ip_range, node_ip_id ].join('.')
end

Vagrant.configure("2") do |config|
  #config.vm.box = "centos/7"
  #config.vm.box = "bento/ubuntu-16.04"
  #config.vm.box = "bento/debian-10"
  config.vm.box = "ubuntu/xenial64"

  config.vm.provider "virtualbox" do |v|
    v.gui = false
  end

  # Create a proxy node
  proxy_node_name = proxy_node_settings['name']
  config.vm.define proxy_node_name do |proxy_node|

    proxy_node.vm.network proxy_node_settings['cluster_network'], ip: proxy_node_settings['cluster_ip'], netmask: base_settings["cluster_netmask"]
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

  # Create a service node
  service_node_name = service_node_settings['name']
  config.vm.define service_node_name do |service_node|

    service_node.vm.post_up_message = "Remote node spun up!"
    service_node.vm.network service_node_settings['cluster_network'], ip: service_node_settings['cluster_ip'], netmask: base_settings["cluster_netmask"]
    service_node.vm.provider "virtualbox" do |vb|
      vb.name = service_node_name
      vb.memory = service_node_settings['memory']
      vb.cpus = service_node_settings['cpus']
      vb.linked_clone = true
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      # Enable NAT hosts DNS resolver
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end

  end

  # Create a machine to run ansible
  ansible_node_name = ansible_node_settings['name']
  config.vm.define ansible_node_name do |ansible_node|

    ansible_node.vm.post_up_message = "Ansible node spun up!"
    ansible_node.vm.network ansible_node_settings['cluster_network'], ip: ansible_node_settings['cluster_ip'], netmask: base_settings["cluster_netmask"]
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

      ansible.config_file = "ansible/ansible.cfg"
      ansible.inventory_path = "hosts-vagrant.yml"
      ansible.playbook = "ansible/test-proxy.yml"

      ansible.galaxy_role_file = "ansible/requirements.yml"
      ansible.galaxy_roles_path = "ansible/roles"
    end

  end

end
