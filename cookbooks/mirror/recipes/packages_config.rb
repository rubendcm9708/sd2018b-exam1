cookbook_file '/etc/yum.repos.d/packages.json' do
  source 'packages.json'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end
