bash 'dhcp_init' do
  user 'root'
  cwd '/'
  code <<-EOH
  yum install dhcp -y
  EOH
end
