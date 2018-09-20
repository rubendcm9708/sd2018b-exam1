cookbook_file '/etc/yum.repos.d/icesi.repo' do
  source 'icesi.repo'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end
