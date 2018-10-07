# Exam 1
**ICESI University**  
**Student name:**  Ruben Dario Ceballos  
**Student ID:** A00054636  
**Email:** rubendcm9708@gmail.com  
**Repository:** https://github.com/rubendcm9708/sd2018b-exam1/tree/rceballos/sd2018b-exam1  
**Subject:** Distributed systems    
**Professor:** Daniel Barragán C.  
**Topic:** Continuous Integration Infrastructure automation  


### Objectives
* Implement autonomically the automatic provisioning of the infrastructure  
* Diagnose and execute autonomically all the actions necessaries for stabilize the infrastructure  

### Implemented Technologies
* Vagrant  
* CentOS7 (Operative System Box)  
* Chef provisioning
* Github Repository
* Python3  
* Python3 libraries: Flask, Connexion, Fabric, Requests  
* Ngrok  

### Infrastructure Description  
For this project, we are going to implement the automatic provisioning of the infrastructure for a Continuous Integration Environment. The purpose of this project, is to have a repository on a local Yum Mirror Server with all the libraries, packages and dependencies that our terminals or virtual machines needs to work, and when we need to update the repository, we can do it by a pull request.

To start with, we are going to see the four virtual machines in the infrastructure and how they interact:  

**Client:**  

* Represents a terminal or workstation.  
* It needs to be provisioned with a valid IPv4 Address by a **DHCP Server** to work correctly.  
* It needs to be provisioned with packages by the **Yum Mirror Server** to work correctly.  

**DHCP Server:**    

* Server that provision valid IPv4 Addresses to the **Clients**.  
* IP Addresses must be in a valid network range.  

**Yum Mirror Server:**  

* Contains a repository with all the packages that the **Clients** needs to work correctly.  
* Should to be provisioned with new packages by the **CI Server** when a Pull Request is made   

**CI Server:**  

* Should have a *Connexion* application with an Endpoint service designed with RESTful architecture. This endpoint works as follow:
  * When a Pull request with a new list of packages for the **Yum Mirror Server** is made, a Webhook attached to the Github repository will trigger the endpoint with a POST request.
  * The request contains all the information about the Pull request, that helps the endpoint to retrieve the new list of packages.
  * The endpoint read the list, and by a *SSH* session provides the **YUM Mirror Server** with the new packages.

In the **Figure 1**, we can appreciate the infrastructure used in this project.  
  
![][1]  
**Figure 1:** Deployment Diagram

### Machines Provisioning ###  
Next, we are going to see how we must provide our Virtual Machines to deploy our infrastructure.

**Client**  
 * To be provided with an IPv4 Address by the **DHCP Server**, one of the network interfaces must be configured as DHCP type.
 * To interact with the packages repository, the */etc/hosts* file must contains the **Yum Mirror Server** Domain and IP Address.  
 * Also, we don't want the **Client** to search for packages in others YUM Servers, so we must delete all the references in */etc/yum.repos.d/*. Then, we must create a file with the references of our **YUM Mirror Server** that includes *domain* and name.

**DHCP Server**  
 * First, we must install *DHCP* service in our Virtual Machine.
 ```
 yum install dhcp -y
 ```
 
 * To provide IP Addresses that are in our network range, we must edit the */etc/dhcp/dhcpd.conf* file with the desired ip ranges.
```
subnet 192.168.131.0 netmask 255.255.255.0 {
range 192.168.131.21 192.168.131.200;
option domain-name-servers 8.8.8.8;
option routers 192.168.130.1;
default-lease-time 600;
max-lease-time 7200;}
```
 * Finally, we can enable and start the *DHCP* service.  
```
systemctl enable dhcpd.service
systemctl start dhcpd.service
```
**Mirror Server**  
 * First, we need to create a packages repository in our Machine. We can do it with *createrepo*, and yum's plugin called *downloadonly* to retrieve all the packages we want without installing them. Also, we need httpd to list all the packages for our **Clients**.  
```
 yum update
 yum install -y httpd
 systemctl start httpd
 systemctl enable httpd
 yum install -y createrepo
 yum install -y yum-plugin-downloadonly 
```
 * After installing these, we run createrepo over a directory (I used */var/repo*).
```
 mkdir /var/repo
 createrepo /var/repo/
```
 * Now we update all the policies to make public our repository. We can use *semanage* from *policycoreutils-python* utilities.
```  
 ln -s /var/repo /var/www/html/repo
 yum install -y policycoreutils-python
 semanage fcontext -a -t httpd_sys_content_t "/var/repo(/.*)?" && restorecon -rv /var/repo
```
 * To allow the **CI Server** to connect using a *ssh* session, we must edit */etc/ssh/sshd.conf* allowing port 22, listen all IP addresses, and allow root logging. Then, restart the *ssh* service to apply changes.
```
Port 22
AddressFamily any
ListenAddress 0.0.0.0
PermitRootLogin yes
```
 * Finally, need to provide all the packages that the **Clients** needs, so we must retrieve a packages list. In this case, I used *packages.json* file from a Github repository. To retrieve, read, and provide the repo with this file, I used a *python* script and *requests*, *os* and *json* libraries. 
```
import json
import os
import requests
pr_url = 'https://raw.githubusercontent.com/rubendcm9708/sd2018b-exam1/rceballos/sd2018b-exam1/packages.json'
get_data = requests.get(pr_url)
pr_packages_json = json.loads(get_data.content)    
packages_query = ' '.join(pr_packages_json["packages"])
provision_query = 'yum install --downloadonly --downloaddir=/var/repo '+packages_query
os.system(provision_query)
os.system('createrepo --update /var/repo')
```

**CI Server**  
 * To start, we need to install wget, unzip,*Python3* and *Pip3*. Also, we need to install *Connexion* and *Fabric* python's libraries, I'm going to explain these later.  
 ```
 yum install -y wget unzip https://centos7.iuscommunity.org/ius-release.rpm
 yum install -y python36u python36u-pip
 pip3.6 install connexion==1.5.2.
 pip3.6 install fabric
 ```
 * Then, we need to download *Ngrok*, because we need to expose our endpoint private domain to a Github Webhook, by creating a localhost tunnel that provides us a public domain.  
 ```
 mkdir /home/vagrant/ngrok
 cd /home/vagrant/ngrok
 wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
 unzip ngrok-stable-linux-amd64.zip
 ```
 * Now, we can deploy our endpoint. With a *indexer.yaml* file, we define the path, input data and response of our endpoint. For all the logic that we explained before, we need a *handler.py* file. In this script I used *request* from *flask*  to read the payload from the webhook request, *requests* to retrieve the *package.json* file from the Pull request, *json* to read the file, and *fabric* to init a *ssh* session and provision the **Yum Mirror Server** with the new packages.
  
* indexer.yaml
```
swagger: '2.0'

info:
  title: CI API
  version: "0.1.0"

paths:
  /pullrequest/apply:
    post:
      x-swagger-router-controller: gm_analytics
      operationId: handlers.updatepackages
      summary: Update packages in mirror server.
      responses:
        200:
          description: Successful response.
          schema:
            type: object
            properties:
              response:
                type: string
                description: Pull request status

```
* handlers.py:
```
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
```

 ### Deployment ###  
 For the deployment of the infrastructure, I used Vagrant for virtualization and Chef for privision automation. In the **figure 2**, we can see the four virtual machines defined in the vagrantfile. Every machine has a cookbook for the provisioning. In the recipes I defined all the steps presented before.  
  
![][2]  
  
Next, I executed *vagrant up* to deploy all my virtual machines. In the **figure 3**, we can see that the four virtual machines are running and provisioned.  
  
![][3]  
  
First, we check if our **Client** has been provisioned with a IP address.  
  
![][4]  
  
Next, let's check the **Yum Mirror Server**. The next *packages.json*, are the currently packages used by **Clients**.  
  
![][5]  
  
When the provisioning is finished, all the packages are now in our repo.  
  
![][6]  
  
Now the **Clients** can see all these packages running *yum list all*  
  
![][7]  
  
  
To deploy our *Connexion* app, first, we need to run *ngrok*. Our endpoint is going to in the port 8088 and use *HTTP* protocol.  
```
cd /home/vagrant/ngrok
./ngrok http 8088
```
  
After running these commands, we can see that *ngrok* has provisioned us a public domain.  
  
![][8]  
  
Next, we need to attach a new webhook to our repository. We use the *webhook* manager in the settings tab in our repository. In the **Payload URL** we specify the public domain + endpoint path, and in **Content type** we specify the type of content we want to recieve. 
  
![][9]  
  
Now, to deploy our endpoint in the port 8088, we execute these commands.  
  
```
export PYTHONPATH=$PYTHONPATH:`pwd`
export FLASK_ENV=development
connexion run gm_analytics/swagger/indexer.yaml --debug -p 8088 -H 127.0.0.1
```  
  
At this moment, we have our endpoint running and attached to a webhook in our repository. To check if all is working correctly, we are going to edit *packages.json* adding *nano* package.  
  
![][10]  
  
And we create a pull request.  
  
![][11]  
  
In the ngrok and connexion consoles, we should see that a POST request has been recieved and processed succesfully.  
![][12]  
  
![][13]  
  
Now, we can check if the *nano* package has been downloaded in **Yum Mirror Server** repo.  
  
![][14]  
  
Finally, we can see the *nano* package when we execut *yum list all*  
  
![][15]  
  
### Problems and Issues ###  
Thoughout all the project, I found many several problems and issues. 
 * First, sometimes when I executed *vagrant up*, my **Client** could be provisioned by another student's **DHCP Server**. To solve this, I should ask them to turn off temporarily their **DHCP Server**.  
 * Second, I tried to use *knife solo* to provision my **Yum Mirror Server** with the packages. I had many problems with libraries and permissions, and in the end, I gave up and tried another solution.  
 * Third, when all the packages were downloaded in the repo, my **Client** couldn't see the new packages. I solved this running *yum clean all* and *yum update*.
 * Finnaly, It was hard to read the payload (json file) that the webhook deliver to the endpoint. With the help of the professor and the students, it was possible to figure it out.  
  
### References ###  
* https://docs.chef.io/  
* https://github.com/ICESI/ds-vagrant/tree/master/centos7/05_chef_load_balancer_example  
* https://developer.github.com/v3/guides/building-a-ci-server/  
* http://www.fabfile.org/  
* http://flask.pocoo.org/  
* https://connexion.readthedocs.io/en/latest/  
  
[1]: images/01_diagrama_despliegue.png
[2]: images/vagrantfile.png
[3]: images/vagrant_up.png
[4]: images/client_dhcp_provision.png
[5]: images/json_vagrant_up.png
[6]: images/mirror_packages_list.png
[7]: images/packages_list.png  
[8]: images/ngrok_domain.png  
[9]: images/webhook.png
[10]: images/packages_pull_request.PNG
[11]: images/create_pullrequest.png
[12]: images/ngrok_request.png
[13]: images/ci_server_request.png
[14]: images/mirror_packages_list_2.png
[15]: images/client_packages_list_2.png
