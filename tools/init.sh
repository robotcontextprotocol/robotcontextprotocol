#!/bin/bash
# Copyright 2024 GEEKROS, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

# Install dependencie
sudo apt install -y vim git curl wget gcc make cmake gcc-arm-none-eabi libusb-1.0-0-dev openssl portaudio19-dev

# Install dpkg dependencie
sudo apt install -y dpkg-dev gpg

# Get the linux arch info
architecture=$(dpkg --print-architecture)

# Get the linux standard base
lsb_release -a

# Install golang
if [ ! -d "/usr/local/go/bin/" ]; then
    golang="1.22.0"
    sudo wget -q https://studygolang.com/dl/golang/go"${golang}".linux-"${architecture}".tar.gz && sudo tar -C /usr/local -xzf go"${golang}".linux-"${architecture}".tar.gz
    touch /etc/profile.d/geekros-golang.sh
    sudo sh -c 'echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile.d/geekros-golang.sh'
    source /etc/profile.d/geekros-golang.sh
    sudo rm -rf go"${golang}".linux-"${architecture}".tar.gz
fi

# Install xmake
if [ ! -f "/usr/local/bin/xmake" ]; then
    git clone --recursive git@github.com:xmake-io/xmake.git
    cd ./xmake && git checkout tags/v2.9.4 && ./configure && make && sudo make install PREFIX=/usr/local
    cd ../ && sudo rm -rf xmake
fi

# Install stlink
if [ ! -f "/usr/local/bin/st-info" ]; then
    git clone git@github.com:stlink-org/stlink.git
    cd ./stlink && git checkout tags/v1.8.0 && make release && sudo make install && sudo ldconfig
    cd ../ && sudo rm -rf stlink
fi

exit 0