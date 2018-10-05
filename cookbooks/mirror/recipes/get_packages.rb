bash 'mirror_config' do
  user 'root'
  cwd '/home/vagrant/'
  code <<-EOH
  yum install -y wget
  wget https://raw.githubusercontent.com/rubendcm9708/sd2018b-exam1/rceballos/sd2018b-exam1/packages.json
  EOH
end

