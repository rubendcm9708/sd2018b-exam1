bash 'config_ngrok' do
  user 'root'
  cwd '/'
  code <<-EOH
  cd /var/ngrok/
  wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
  unzip ngrok-stable-linux-amd64.zip
  EOH
end

