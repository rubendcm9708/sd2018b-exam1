bash 'install_py_libraries' do
  user 'root'
  cwd '/'
  code <<-EOH
  pip3.6 install connexion==1.5.2
  EOH
end

