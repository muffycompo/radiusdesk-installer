RADIUSdesk Installer
====================
## Overview
This project tries to simplify or ease the process of getting a working installation of [RADIUSdesk](http://www.radiusdesk.com) on a vanilla/minimal installation of RHEL/CentOS 6.X (32 bit/64 bit). This will be an ongoing effort and there is plans to support more Distros (Fedora,Debian,Ubuntu etc) and so please feel free to contribute by sending a pull request.

## Installation & Usage
1. Clone or download the project.

   a) If you have git already installed, just use `git clone git clone https://github.com/muffycompo/radiusdesk-installer.git`. **Note:** you can install git on RHEL/CentOS 6.x via yum (`yum install -y git`)
   
   b) If you prefer to download the zip file `wget -cL https://github.com/muffycompo/radiusdesk-installer/archive/master.zip`. **Note:** just make sure you have **wget** and **unzip** installed (`yum install -y wget unzip`)
2. Run/execute the Installer script as **root** `cd radiusdesk-installer; ./rd_installer.sh` and choose your preferred web server (**Nginx** or **Apache**)
3. Grab yourself a cup of Coffee as the installer installs all the components required to have a working RADIUSdesk server.
4. When the script is done installing and configuring your system, we recommend rebooting your machine/server to ensure everything is persistent on reboot.

## Limitations
1. The installer only works RADIUSdesk on a RHEL/CentOS 6.x machines/servers
2. Installer assumes default installation values (Database passwords, FreeRADIUS secrets etc)
3. The installer does not install CoovaChilli for captive portal/ hotspot

## Resources
1. [RADIUSdesk Course/Tutorials](http://www.maomuffy.com/introduction-to-radiusdesk-with-rhelcentos-6-x-mini-course/) by [Mfawa Alfred Onen](http://ng.linkedin.com/in/mfawaalfredonen/)
2. [RADIUSdesk Project](http://www.radiusdesk.com) by [Dirk van der Walt](http://www.linkedin.com/pub/dirk-van-der-walt/11/b64/79a)

## TODO
1. Make the installer Operating System agnostic (Support multiple Linux OS)
2. Make installer to prompt users for Database user, password, RADIUS secret
3. Allow users to optionally opt for CoovaChilli installation


## Contributions
1. Anyone is welcome to contribute by sending a pull request with your desired feature tested and implemented.

## Copyright and License

Copyright (c) 2014 Mfawa Alfred Onen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.