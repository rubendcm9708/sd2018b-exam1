bash 'python_libraries' do
  user 'root'
  cwd '/'
  code <<-EOH
  yum install -y https://centos7.iuscommunity.org/ius-release.rpm
  yum install -y python-pip
  pip install requests
  EOH
end

