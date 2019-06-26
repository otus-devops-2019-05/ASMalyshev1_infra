#!/bin/bash

mkdir /home/userapp/
cd /home/userapp
git clone -b monolith https://github.com/express42/reddit.git
#cd reddit && bundle install && puma -d && ps aux | grep puma > puma_state.txt
cd reddit && bundle install
