bash 'repo_delete' do
  user 'root'
  cwd '/etc/yum.repos.d/'
  code <<-EOH
  rm -rf *
  EOH
end

