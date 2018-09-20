bash 'dhcp_start' do
  user 'root'
  cwd '/'
  code <<-EOH
  systemctl enable dhcpd.service
  systemctl start dhcpd.service
  EOH
end
