RADIUSdesk Installer
====================
## Overview
This project tries to simplify or ease the process of getting a working installation of [RADIUSdesk](http://www.radiusdesk.com) on a vanilla/minimal installation of RHEL/CentOS 6.X/Ubuntu 13.10/14.04 (64 bit). This will be an ongoing effort and there is plans to support more Distros (like openSUSE etc) and so please feel free to contribute by sending a pull request.

## Installation & Usage
1. Clone or download the project.

   a) If you have git already installed, just use `git clone https://github.com/muffycompo/radiusdesk-installer.git`. **Note:** you can install git on RHEL/CentOS 6.x via yum (`yum install -y git`)
   
   b) If you prefer to download the zip file `wget -cL https://github.com/muffycompo/radiusdesk-installer/archive/master.zip`. **Note:** just make sure you have **wget** and **unzip** installed (`yum install -y wget unzip`)
2. Run/execute the Installer script as **root** `cd radiusdesk-installer; ./rd-installer` and walk through the wizard.
3. Grab yourself a **cup of Coffee** as the installer provisions your server with RADIUSdesk.
4. When the script is done installing and configuring your system, we recommend rebooting your machine/server to ensure everything is persistent on reboot.

## Features
1. A wizard for customizing Web server, Database Credentials (Host, User, Password & DB Name) and FreeRADIUS secret 
2. Installer downloads latest copy of RADIUSdesk so that you are always on edge
3. Somewhat modularized, so you can always extend RADIUSdesk installer to support your environment
4. Setup Captive Portal with CoovaChilli

## Compatibility
The installer has been tested on the following Linux Operating Systems
 
1. CentOS 6.4/6.5 (64 bit)  
2. Red Hat Enterprise Linux 6.4/6.5 (64 bit) 
3. Ubuntu 13.10/14.04 (64 bit) 

## Resources
1. [RADIUSdesk Course/Tutorials](http://www.maomuffy.com/introduction-to-radiusdesk-with-rhelcentos-6-x-mini-course/) by [Mfawa Alfred Onen](http://ng.linkedin.com/in/mfawaalfredonen/)
2. [RADIUSdesk Project](http://www.radiusdesk.com) by [Dirk van der Walt](http://www.linkedin.com/pub/dirk-van-der-walt/11/b64/79a)
3. [RADIUSdesk Installer Videos](http://www.maomuffy.com/radiusdesk-installer-project/)

## Contributors
- Dirk van der Walt
- Kenneth Peter S. Bongolan

## Contributions
1. Anyone is welcome to contribute by sending a pull request with your desired feature tested and implemented.
2. If you have tested the installer in a Linux Distribution that is not in the compatibility list, kindly contact send an email to muffycompoqm[at]gmail[dot]com.

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
