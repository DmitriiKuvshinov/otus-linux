#!/bin/bash

cd /tmp/
sudo yum install -y wget bzip2
sudo wget -c http://download.virtualbox.org/virtualbox/6.0.0_RC1/VBoxGuestAdditions_6.0.0_RC1.iso
sudo mount VBoxGuestAdditions_6.0.0_RC1.iso -o loop /mnt
sudo sh /mnt/VBoxLinuxAdditions.run
