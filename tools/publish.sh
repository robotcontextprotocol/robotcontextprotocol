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

# Configure the Go runtime environment
/usr/local/go/bin/go env -w GOSUMDB=off
/usr/local/go/bin/go env -w GOPATH=/tmp/golang
/usr/local/go/bin/go env -w GOMODCACHE=/tmp/golang/pkg/mod
export GO111MODULE=on && export GOPROXY=https://goproxy.io

# Build the backend
cd ../backend/cmd && /usr/local/go/bin/go mod tidy && /usr/local/go/bin/go build -o ../release/main main.go
sudo cp ../release/main ../../tools/debian/opt/rcp/backend/release/
sudo rm -rf ../release/main && cd ../../tools

# Copy frontend files to debian package
sudo cp -r ../frontend/release/* ./debian/opt/rcp/frontend/release/

# Configure the debian package
sudo touch debian/DEBIAN/conffiles && sudo chmod +x debian/DEBIAN/conffiles
sudo touch debian/DEBIAN/control && sudo chmod +x debian/DEBIAN/control

sudo sh -c "echo 'Package: rcp' >> debian/DEBIAN/control"
sudo sh -c "echo 'Version: $version-$datetime' >> debian/DEBIAN/control"
sudo sh -c "echo 'Maintainer: GEEKROS <admin@geekros.com>' >> debian/DEBIAN/control"
sudo sh -c "echo 'Homepage: https://www.robotcontextprotocol.com' >> debian/DEBIAN/control"
sudo sh -c "echo 'Architecture: $architecture' >> debian/DEBIAN/control"
sudo sh -c "echo 'Installed-Size: 1048576' >> debian/DEBIAN/control"
sudo sh -c "echo 'Section: utils' >> debian/DEBIAN/control"
sudo sh -c "echo 'Depends: $depends' >> debian/DEBIAN/control"
sudo sh -c "echo 'Recommends:' >> debian/DEBIAN/control"
sudo sh -c "echo 'Suggests:' >> debian/DEBIAN/control"
sudo sh -c "echo 'Description: Robot Context Protocol For Multimodal LLM' >> debian/DEBIAN/control"

sudo dpkg --build debian && dpkg-name debian.deb

echo "sudo scp rcp_*.deb root@ip:/data/wwwroot/mirrors.com/ubuntu/pool/main/jammy/ && sudo rm -rf *.deb && sudo rm -rf debian"

exit 0