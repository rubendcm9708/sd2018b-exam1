cookbook_file '/etc/dhcp/dhcpd.conf' do
  source 'dhcpd.conf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end
