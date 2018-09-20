##Vagrant configure
Vagrant.configure("2") do |config|
  ##All machines works with centos1706_v0.2.0
  config.vm.box = "centos1706_v0.2.0"

  ##Deploy and provision dns server
  ##config.vm.define "dhcp_server" do |dhcp_server|
  ##  dhcp_server.vm.network "public_network", bridge: "eno1", ip: "192.168.131.5", netmask: "255.255.255.0"
  ##  config.vm.provision :chef_solo do |chef|
  ##  	chef.install = false
  ##  	chef.cookbooks_path = "cookbooks"
  ##	chef.add_recipe = "dns"
  ##	end
  ##end

  ##Deploy and provision dhcp server
  config.vm.define "dhcp_server" do |dhcp_server|
    dhcp_server.vm.network "public_network", bridge: "eno1", ip: "192.168.131.2", netmask: "255.255.255.0"
    dhcp_server.vm.provision :chef_solo do |chef|
    	chef.install = false
    	chef.cookbooks_path = "cookbooks"
	chef.add_recipe "dhcp"
  	end
  end

  ##Deploy and provision yum mirror server
  config.vm.define "mirror_server" do |mirror_server|
    mirror_server.vm.network "public_network", bridge: "eno1", ip: "192.168.131.3", netmask: "255.255.255.0"
    mirror_server.vm.provision :chef_solo do |chef|
    	chef.install = false
    	chef.cookbooks_path = "cookbooks"
	chef.add_recipe "mirror"
  	end
  end

  ##Deploy and provision continous integration server
  config.vm.define "ci_server" do |ci_server|
    ci_server.vm.network "public_network", bridge: "eno1", ip: "192.168.131.4", netmask: "255.255.255.0"
    ci_server.vm.provision :chef_solo do |chef|
    	chef.install = false
    	chef.cookbooks_path = "cookbooks"
	##chef.add_recipe = "ci"
  	end
  end
  
  ##Deploy and provision client
  config.vm.define "client" do |client|
    client.vm.network "public_network", bridge: "eno1", type: "dhcp"
    client.vm.provision :chef_solo do |chef|
    	chef.install = false
    	chef.cookbooks_path = "cookbooks"
	chef.add_recipe "client"
  	end
  end  

end
