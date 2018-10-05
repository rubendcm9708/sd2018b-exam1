bash 'install_dependencies' do
  user 'root'
  cwd '/'
  code <<-EOH
  yum install -y wget unzip https://centos7.iuscommunity.org/ius-release.rpm
  yum install -y python36u python36u-pip
  EOH
end

