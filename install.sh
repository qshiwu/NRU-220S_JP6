#!/bin/bash
echo "Installing libgpioid"

sudo apt-get install automake
sudo apt-get install autoconf-archive

git clone git://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git
cd libgpiod
sudo ./autogen.sh --enable-tools=yes
sudo make
sudo make install
sudo cp -r tools/ /usr/src/libgpiod_tools/
cd ..

echo "Installing mdio"
sudo cp -r tools/mdio_tools/ /usr/src/

echo "Installing nru220_startup_script_JP6.sh"
sudo chmod +x nru220_startup_script_JP6.sh
sudo cp nru220_startup_script_JP6.sh /etc/init.d
sudo update-rc.d nru220_startup_script_JP6.sh defaults
