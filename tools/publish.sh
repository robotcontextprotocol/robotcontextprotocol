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

# Get the linux arch info
architecture=$(dpkg --print-architecture)

# Get the linux standard base
lsb_release -a

# Get the version
version=$(grep 'Version:.*"' "../backend/pkg/version/version.go" | awk -F'"' '{print $2}')

# Get the current time
datetime=$(date +%Y%m%d%H%M%S)

# Generate debian package
if [ ! -d "debian" ]; then
    mkdir -p debian
    sudo cp -r ubuntu/* ./debian/
    sudo chmod +x debian/DEBIAN/*
    find ./debian -type f -name ".gitkeep" -exec rm -f {} +
else
    sudo rm -rf debian && sudo rm -rf ./*.deb && mkdir -p debian
    sudo cp -r ubuntu/* ./debian/
    sudo chmod +x debian/DEBIAN/*
    find ./debian -type f -name ".gitkeep" -exec rm -f {} +
fi

# Copy xmake files to debian package
sudo cp /usr/local/bin/xmake ./debian/usr/local/bin/
sudo cp -r /usr/local/share/xmake/* ./debian/usr/local/share/xmake/

# Copy stlink files to debian package
sudo cp -r /usr/local/lib/libstlink* ./debian/usr/local/lib/
sudo cp -r /usr/local/bin/st-* ./debian/usr/local/bin/
sudo cp -r /usr/local/bin/st-* ./debian/usr/local/bin/
sudo cp /etc/modprobe.d/stlink_v1.conf ./debian/etc/modprobe.d/
sudo cp -r /lib/udev/rules.d/49-stlinkv* ./debian/lib/udev/rules.d/
sudo cp -r /usr/local/share/stlink/* ./debian/usr/local/share/stlink/
sudo cp -r /usr/local/include/stlink/* ./debian/usr/local/include/stlink/
sudo cp -r /usr/local/share/man/man1/st-* ./debian/usr/local/share/man/man1/

/usr/local/go/bin/go env -w GOSUMDB=off
/usr/local/go/bin/go env -w GOPATH=/tmp/golang
/usr/local/go/bin/go env -w GOMODCACHE=/tmp/golang/pkg/mod
export GO111MODULE=on && export GOPROXY=https://goproxy.io