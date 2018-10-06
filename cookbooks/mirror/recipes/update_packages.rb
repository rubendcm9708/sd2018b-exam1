python 'update_packages' do
  user 'root'
  code <<-EOH
import json
import os
import requests

pr_url = 'https://raw.githubusercontent.com/rubendcm9708/sd2018b-exam1/rceballos/sd2018b-exam1/packages.json'
get_data = requests.get(pr_url)
pr_packages_json = json.loads(get_data.content)    
packages_query = ' '.join(pr_packages_json["packages"])
provision_query = 'yum install --downloadonly --downloaddir=/var/repo '+packages_query
os.system(provision_query)
  EOH
end

