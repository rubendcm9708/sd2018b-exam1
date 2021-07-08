cookbook_file '/var/web/gm_analytics/swagger/indexer.yaml' do
  source 'indexer.yaml'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end
