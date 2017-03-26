RADIUSDesk Installer 1.2.1
===========================
## Introduction
RADIUSDesk Installer is an [Ansible](http://www.ansible.com) powered utility that attempts to simplify the process of getting a working installation of [RADIUSDesk](http://www.radiusdesk.com) on a vanilla/minimal installation of RHEL/CentOS 6.7/7.x and Ubuntu 14.04/15.10/16.04/16.10 servers.

## Prerequisite
#### 1] Install Python
As of the time of this writing, Python 3 is not supported by Ansible so please take note. [Managed Node Requirements](http://docs.ansible.com/ansible/intro_installation.html#managed-node-requirements)

To Install Python which should come by default in most Linux distributions, you can use your package manager:

**RHEL/CentOS 6.7/7.x**

`yum install -y python`

**Ubuntu 14.04/15.10/16.04/16.10**

`apt-get install -y python`

#### 2] Install Ansible 1.9+
RADIUSDesk Installer utilizes the latest version of Ansible and for this you must ensure you have at least **Ansible 1.9** and above for the Installer to work as intended.

To Install Ansible, use your package manager and if your distribution comes with an older version of Ansible check the following steps to install the latest Ansible package:

**RHEL/CentOS 6.7/7.x**

```
yum install -y epel-release
yum install -y ansible
```

**Note:** To Manually install EPEL repositories, Visit the [EPEL Wiki](https://fedoraproject.org/wiki/EPEL) 

**Ubuntu 14.04/15.10/16.04/16.10**

```
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

**Note:** If you don't have git installed, make sure you do so before cloning the Installer. Use your package manager to install git; `yum install -y git` on RHEL/CentOS or `apt-get install -y git` on Ubuntu.

#### Run the Installer
1.	By default, the installer will setup RADIUSDesk on the server you are currently running the installer from i.e. `localhost`. To change that and use a remote server (on your network or in the cloud), edit the **`servers`** file in the installer's directory; `cd radiusdesk-installer; vi servers`. You can create a new host group as per [Ansible's guide](http://docs.ansible.com/ansible/intro_inventory.html#hosts-and-groups) or modify the sample groups in the **`servers`** file. If you have modified the **`servers`** file and created a new group, also remember to edit the **`rd-installer-ansible.yml`** and ensure the hosts uses your newly created server group from the previous step.

2.	RADIUSDesk Installer requires root privileges to ensure it installs packages and configure your servers properly. Login as the **`root`** user or a user with sudo privileges. Run the installer and select **I** or **1** to start provisioning your server with RADIUSDesk.
`cd radiusdesk-installer; ./rd-installer`

3. Grab yourself a **Cup of Coffee** as the installer provisions your server with RADIUSDesk and reboot the server to ensure everything is persistent on reboot **[Optional]**.

#### Installing CoovaChilli [Optional]
RADIUSDesk Installer now has support for [CoovaChilli](https://coova.github.io/) installation. Select option 2 from the Installer menu and enter the LAN, WAN and UAM Secret respectively to Install CoovaChilli together with RADIUSDesk.

#### Note
Ensure you use a [YAML linter](http://www.yamllint.com/) to check your syntax anytime you make any change to the variable file(s).

## Features
1. RADIUSDesk installer is somewhat modularized, so you can always extend RADIUSDesk installer to support your ever growing environments.

2. Support for CoovaChilli Captive portal **[Optional]**

3. Support for Dynamic Login Pages **[Optional]**

## Compatibility
1.	RADIUSDesk Installer is Compatible with Ansible 1.9+
2.	RADIUSDesk Installer has been tested on the following Linux Distros:
	
    - **RHEL/CentOS 6.7/7.x**
    - **Ubuntu 14.04/15.10/16.04/16.10**    

## F.A.Q
1. Why do I get an SSL3 handshake error when running RADIUSDesk Installer on Ubuntu 14.x?
    - Ubuntu 14.x comes with python 2.7.6 and will need to be upgraded to 2.7.9+ as follows:
    ```
    sudo apt-add-repository ppa:fkrull/deadsnakes-python2.7
    sudo apt-get update
    sudo apt-get upgrade
    ```
2. Why does RADIUSDesk Installer fail to start MySQL and FreeRADIUS on CentOS by showing a connection error?
    - Usually, this is caused by having SELinux enabled or iptables running the default rules. Make sure SELinux is set to Permissive (`setenforce 0`) or disabled (`vi /etc/sysconfig/selinux`)

## Resources
1. [RADIUSDesk Mini Course (Old)](http://www.maomuffy.com/introduction-to-radiusdesk-with-rhelcentos-6-x-mini-course/) by [Mfawa Alfred Onen](http://maomuffy.com)
2. [RADIUSDesk Project](http://www.radiusdesk.com) by [Dirk van der Walt](http://www.linkedin.com/pub/dirk-van-der-walt/11/b64/79a)
3. [RADIUSDesk Installer Videos](http://www.maomuffy.com/radiusdesk-installer-project/)

## Contributions
1. Anyone is welcome to contribute by sending a pull request with your desired feature tested and implemented.
2. If you have tested the installer in a Linux Distribution that is not in the compatibility list, kindly send an email to muffycompoqm[at]gmail[dot]com.
