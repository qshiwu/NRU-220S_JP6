#!/bin/bash
echo "Installing libgpioid"
sudo cp -r tools/libgpiod_tools/ /usr/src/

echo "Installing mdio"
sudo cp -r tools/mdio_tools/ /usr/src/

# echo "Installing nru220_startup_script_JP6.sh"
# sudo chmod +x nru220_startup_script_JP6.sh
# sudo cp nru220_startup_script_JP6.sh /etc/init.d
# sudo update-rc.d nru220_startup_script_JP6.sh defaults