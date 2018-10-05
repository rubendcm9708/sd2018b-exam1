bash 'mirror_config' do
  user 'root'
  cwd '/etc/yum.repos.d/'
  code <<-EOH
  yum update
  mkdir /var/repo
  cd /var/repo
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  yum install -y createrepo
  yum install -y yum-plugin-downloadonly
  createrepo /var/repo/
  ln -s /var/repo /var/www/html/repo
  yum install -y policycoreutils-python
  semanage fcontext -a -t httpd_sys_content_t "/var/repo(/.*)?" && restorecon -rv /var/repo
  EOH
end

