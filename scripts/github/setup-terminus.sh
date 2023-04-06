#!/bin/bash

export PROJECT_ROOT="$(pwd)"
. $PROJECT_ROOT/config

printf "[\e[0;34mNOTICE\e[0m] Terminus Setup START!!!.\n"
# mar 2 2023 - ver 3.14 release
# https://github.com/pantheon-systems/terminus/releases
mkdir -p ~/terminus && cd ~/terminus
curl -L https://github.com/pantheon-systems/terminus/releases/download/3.1.4/terminus.phar --output terminus
chmod +x terminus
# this will make sure you get the latest terminus version
./terminus self:update
sudo ln -s ~/terminus/terminus /usr/local/bin/terminus

printf "[\e[0;34mNOTICE\e[0m] Terminus Setup end!!.\n"
terminus auth:login --machine-token="$PANTHEON_TERMINUS_MACHINE_TOKEN"

#debuginfo
#terminus auth:whoami
#terminus self:info
#terminus art