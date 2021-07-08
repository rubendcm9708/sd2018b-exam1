import logging
import requests
import json
from flask import request
from fabric import Connection
def updatepackages():

    #Post recieved
    logging.info("Service has been requested")

    #Get post request body and convert to String
    post_body = request.get_data()
    body_toString = str(post_body, 'utf-8')

    #load Json file with body and get Pull request id
    json_file = json.loads(body_toString)
    pr_id = json_file["pull_request"]["head"]["sha"]

    #Get packages.json URL and get data
    pr_url = 'https://raw.githubusercontent.com/rubendcm9708/sd2018b-exam1/'+pr_id+'/packages.json'
    get_data = requests.get(pr_url)

    #Load data to package.json file
    pr_packages_json = json.loads(get_data.content)
    
    #Put packages into a single bash query
    packages_query = ' '.join(pr_packages_json["packages"])
    provision_query = 'yum install --downloadonly --downloaddir=/var/repo '+packages_query
    
    #Instance connection with yum mirror server and run query
    mirror_connection = Connection(host='root@192.168.131.3', connect_kwargs={"password":"vagrant"})
    output = mirror_connection.run(provision_query)
    mirror_connection.run('createrepo --update /var/repo')
    logging.debug(output)
    return{"Status":"Requested"}
