#!/bin/bash
echo "Installing libgpioid"
sudo cp -r libgpiod/ /usr/src/

echo "Installing mdio"
sudo cp mdio-tools/kernel/mdio-netlink.ko /usr/src/
sudo cp mdio-tools/src/mdio/mdio /usr/src/ 

echo "Installing nru220_startup_script_JP6.sh"
sudo chmod +x nru220_startup_script_JP6.sh
sudo cp nru220_startup_script_JP6.sh /etc/init.d
sudo update-rc.d nru220_startup_script_JP6.sh defaults