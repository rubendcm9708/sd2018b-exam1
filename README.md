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
 * We don't want the **Client** to search for packages in others YUM Servers, so we must delete all the references in */etc/yum.repos.d/*. Then, we must create a file with the references of our **YUM Mirror Server** that includes *domain* and name.

**DHCP Server**  
 * First, we must install *DHCP* service in our Virtual Machine.
 * To provide IP Addresses that are in our network range, we must edit the */etc/dhcp/dhcpd.conf* file with the desired ip ranges.
 * Finally, we can enable and start the *DHCP* service.  

**Mirror Server**  
 * First, we need to create a packages repository in our Machine. We can do it with *createrepo*, and yum's plugin called *downloadonly* to retrieve all the packages we want without installing them.
 * After installing these, we run createrepo over a directory (I used */var/repo*).

[1]: images/01_diagrama_despliegue.png
