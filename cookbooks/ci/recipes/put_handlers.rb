cookbook_file '/var/web/gm_analytics/handlers.py' do
  source 'handlers.py'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end
