#!/bin/bash
sudo su
apt update
apt install -y vim
apt install -y htop
apt install -y git
sudo useradd -m -g users -s /bin/bash -c "Yura Petrenko" yura
git init /home/yura


