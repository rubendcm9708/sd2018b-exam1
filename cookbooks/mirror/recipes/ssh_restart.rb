bash 'mirror_config' do
  user 'root'
  cwd '/'
  code <<-EOH
  systemctl restart sshd.service
  EOH
end

