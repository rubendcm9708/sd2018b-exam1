bash 'repos_update' do
  user 'root'
  cwd '/'
  code <<-EOH
  yum repolist
  yum update -y
  EOH
end
