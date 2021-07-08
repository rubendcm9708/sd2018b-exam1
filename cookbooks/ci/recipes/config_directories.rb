bash 'install_dependencies' do
  user 'root'
  cwd '/'
  code <<-EOH
  cd var
  mkdir web
  mkdir ngrok
  cd web
  mkdir gm_analytics
  cd gm_analytics
  mkdir swagger
  EOH
end

