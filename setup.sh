#!/bin/bash

sudo apt update && sudo apt install -y util-linux inotify-tools docker.io git

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

git clone https://github.com/jiezhuzzz/Titan.git fuzzers/titan