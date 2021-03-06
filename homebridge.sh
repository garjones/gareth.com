#!/bin/bash
# //----------------------------------------------------------------------------------------------------------
# // homebridge.sh
# //----------------------------------------------------------------------------------------------------------
# // homebridge installation script
# //----------------------------------------------------------------------------------------------------------
# // To run this script remotely:
# //   apt update && apt -y install curl sudo
# //   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/garjones/gareth.com/master/homebridge.sh)"
# //
# // Based on - https://github.com/homebridge/homebridge/wiki/Install-Homebridge-on-Debian-or-Ubuntu-Linux
# //----------------------------------------------------------------------------------------------------------
# // Gareth Jones - gareth@gareth.com
# //----------------------------------------------------------------------------------------------------------

# upgrade
apt -y upgrade

# setup repo
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -

# install Node.js
sudo apt-get install -y nodejs gcc g++ make python net-tools

# test node is working
node -v

# install homebridge and homebridge ui
npm install -g --unsafe-perm homebridge homebridge-config-ui-x

# setup Homebridge as a service, create homebridge user and config.json
hb-service install --user homebridge

# done
