RADIUSDesk Installer
====================
## Introduction
RADIUSDesk Installer is an [Ansible](http://www.ansible.com) powered utility that attempts to simplify the process of getting a working installation of [RADIUSDesk](http://www.radiusdesk.com) on a vanilla/minimal installation of RHEL/CentOS 6.X/Ubuntu 14.04/15.04/15.10 servers.

## Prerequisite
#### 1] Install Python 2.7+
Because RADIUDesk Installer uses Ansible, you must ensure that python 2.7+ is installed on both the Control[the server you will be running RADIUSDesk Installer] and Managed [the server you will like to setup RADIUSDesk on] Node(s) to fulfill a requirement for Ansible. As of the time of this writing, Python 3 is not supported by Ansible so please take note. [Managed Node Requirements](http://docs.ansible.com/ansible/intro_installation.html#managed-node-requirements)

To Install Python which should come by default in most Linux distributions, you can use your package manager:

**RHEL/CentOS 6.x/7.x**

`yum install -y python`

**Ubuntu 14.x/15.x**

`apt-get install -y python`

#### 2] Install Ansible 1.9+
RADIUSDesk Installer utilizes the latest version of Ansible and for this you must ensure you have at least **Ansible 1.9** and above for the Installer to work as intended.

To Install Ansible, use your package manager and if your distribution comes with an older version of Ansible check the following steps to install the latest Ansible package:

**RHEL/CentOS 6.x/7.x**

```
yum install -y epel-release
yum install -y ansible
```



**Note:** To Manually install EPEL repositories, Visit the [EPEL Wiki](https://fedoraproject.org/wiki/EPEL) 


**Ubuntu 14.x/15.x**

```
apt-get install -y software-properties-common python-software-properties
apt-add-repository ppa:ansible/ansible
apt-get update
apt-get install -y ansible
```

#### 3] Add Managed Node(s) to SSH Known Hosts list of the Conrol Node
SSH into the local/remote managed node/server at least once to ensure it is added to the control node/server SSH **known_host** file.

`ssh root@localhost` or `ssh root@192.168.23.101`

## Using RADIUSDesk Installer
#### Clone the Installer from [GitHub](https://github.com/muffycompo/radiusdesk-installer)

`git clone https://github.com/muffycompo/radiusdesk-installer`

**Note:** If you don't have git installed, make sure you so before cloning the Installer. Use your package manager to install git; `yum install -y git` on RHEL/CentOS or `apt-get install -y git` on Ubuntu.

#### Run the Installer
1.	By default, the installer will setup RADIUSDesk on the server you are currently running the installer from i.e. `localhost`. To change that and use a remote server (on your network or in the cloud), edit the **`servers`** file in the installer's directory; `cd radiusdesk-installer; vi servers`. You can create a new host group as per [Ansible's guide](http://docs.ansible.com/ansible/intro_inventory.html#hosts-and-groups) or modify the sample groups in the **`servers`** file. If you have modified the **`servers`** file and created a new group, also remember to edit the ** `rd-installer-ansible.yml` ** and ensure the hosts uses your newly created server group from the previous step.

2.	RADIUSDesk Installer requires root privileges to ensure it installs packages and configure your servers properly. Login as the **`root`** user or a user with sudo privileges. Run the installer and select ** I ** or ** 1 ** to start provisioning your server with RADIUSDesk.
`cd radiusdesk-installer; ./rd-installer`

3. Grab yourself a **cup of Coffee** as the installer provisions your server with RADIUSDesk and reboot the server to ensure everything is persistent on reboot **[Optional]**.

## Video Walkthrough
<iframe width="560" height="315" src="https://www.youtube.com/embed/VedzdhcBD5A" frameborder="0" allowfullscreen></iframe>

## Features
1. A very customizable installer (Edit `roles/radiusdesk/vars/Debian.yml` or `roles/radiusdesk/vars/RedHat.yml` depending on your Operating System family like Debian, RedHat etc). **Note:** ensure you use a YAML linter to check your syntax anytime you make any change to the variable file(s).

2. Somewhat modularized, so you can always extend RADIUSDesk installer to support your environment

3. Support for PPTPD **[Optional]**

4. Support for CoovaChilli Captive portal **[Optional]**

5. Support for Dynamic Login Pages **[Optional]**

## Compatibility
1.	** Ansible 1.9+ **
2.	The installer has been tested on the following Linux Operating Systems:
	
    - ** RHEL/CentOS 6.5/6.7 (32/64 bit) **
    - ** Ubuntu 14.04/15.04/15.10 (32/64 bit) **    

## Resources
1. [RADIUSDesk Course/Tutorials](http://www.maomuffy.com/introduction-to-radiusdesk-with-rhelcentos-6-x-mini-course/) by [Mfawa Alfred Onen](http://ng.linkedin.com/in/mfawaalfredonen/)
2. [RADIUSDesk Project](http://www.radiusdesk.com) by [Dirk van der Walt](http://www.linkedin.com/pub/dirk-van-der-walt/11/b64/79a)
3. [RADIUSDesk Installer Videos](http://www.maomuffy.com/radiusdesk-installer-project/)

## Contributions
1. Anyone is welcome to contribute by sending a pull request with your desired feature tested and implemented.
2. If you have tested the installer in a Linux Distribution that is not in the compatibility list, kindly contact send an email to muffycompoqm[at]gmail[dot]com.

## Copyright and License

Copyright (c) 2016 Mfawa Alfred Onen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
