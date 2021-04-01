#!/bin/bash

# Update AmpliPi's configuration on a raspberry pi.
# This script should install and configure everything necessary

# TODO: many of the checks here depend on apt, if something is manually installed this script will not detect it yet. Please fix.

# get directory that the script exists in
cd "$( dirname "$0" )"

# fix the line endings of the scripts copied over (thanks windows) (NOTE: we need to force LF line endings on this file)
d2u_installed=$(sudo apt list --installed 2> /dev/null | grep dos2unix -c)
if [ 0 -eq "${d2u_installed}" ]; then
  echo "installing dos2unix"
  sudo apt update && sudo apt install -y dos2unix
fi
dos2unix ${SCRIPT_DIR}/*
dos2unix ${SCRIPT_DIR}/../scripts/*

# make some stream scripts executable
pushd ../streams
chmod +x eventcmd.sh shairport_metadata.bash dlna_metadata.bash use_ram.py
popd

# configure shairport-sync on pi for multi instance support and disable its daemon
sp_installed=$(sudo apt list --installed 2> /dev/null | grep shairport-sync -c)
if [ 0 -eq "${sp_installed}" ]; then
  echo "installing shairport-sync"
  sudo apt update && sudo apt install -y shairport-sync
  # disable and stop its daemon
  sudo systemctl stop shairport-sync.service
  sudo systemctl disable shairport-sync.service
fi

# rough configuration of shairport-sync-metadata-reader
# TODO: we need to build this and install it as a binary


cd /home/pi/config/
ssmr_installed=$(sudo ls | grep shairport-sync-metadata-reader -c)
if [ 0 -eq "${ssmr_installed}" ]; then
  git clone https://github.com/micronova-jb/shairport-sync-metadata-reader.git
  cd shairport-sync-metadata-reader
  autoreconf -i -f
  ./configure
  make
  sudo make install # This will fail if it has already been installed elsewhere
else
  echo "metadata reader already installed... attempting to update"
  cd shairport-sync-metadata-reader
  git pull
  make
  sudo make install
fi

# configure pianobar on pi
pb_installed=$(sudo apt list --installed 2> /dev/null | grep pianobar -c)
if [ 0 -eq "${pb_installed}" ]; then
  echo "installing pianobar"
  sudo apt update && sudo apt install -y pianobar
else
  echo "pianobar already installed"
fi

# configure raspotify on pi and disable its daemon
rs_installed=$(sudo apt list --installed 2> /dev/null | grep raspotify -c)
if [ 0 -eq "${rs_installed}" ]; then
  echo "installing raspotify"
  curl -sL https://dtcooper.github.io/raspotify/install.sh | sh
  # disable and stop its daemon
  sudo systemctl stop raspotify.service
  sudo systemctl disable raspotify.service
else
  echo "raspotify already installed"
fi

# configure vlc for internet radio on pi
ir_installed=$(sudo apt list --installed 2> /dev/null | grep vlc -c)
if [ 0 -eq "${ir_installed}" ]; then
  echo "installing vlc"
  sudo apt update && sudo apt install -y vlc
else
  echo "vlc already installed"
fi

# configure python3 on pi
rs_installed=$(sudo apt list --installed 2> /dev/null | grep python3-pip -c)
if [ 0 -eq "${rs_installed}" ]; then
  echo "installing pip"
  sudo apt update && sudo apt install -y python3-pip
else
  echo "pip already installed"
fi

# create a virtual environment and install all of our packages (needed by nginx, but we should use this anyway)
venv_installed=$(sudo apt list --installed 2> /dev/null | grep python3-venv -c)
if [ 0 -eq "${venv_installed}" ]; then
  echo "installing venv"
  sudo apt update && sudo apt install -y python3-venv
else
  echo "venv already installed"
fi
echo "updating virtual environment"
python3 -m venv ${SCRIPT_DIR}/../venv
source ${SCRIPT_DIR}/../venv/bin/activate
pip3 install -r ${SCRIPT_DIR}/../requirements.txt
deactivate

# install nginx unit from debians built on the pi and configure its service
unit_installed=$(sudo apt list --installed 2> /dev/null | grep unit-python -c)
if [ 0 -eq "${unit_installed}" ]; then
  echo "installing unit"
  sudo apt update && sudo apt install -y ../debs/unit_*.deb ../debs/unit-python3.7_*.deb
else
  echo "unit already installed"
fi
bash ${SCRIPT_DIR}/update_web.bash

# TODO: add other dependencies?
# TODO: check if boot config changed, copy over if necessary and ask user to restart

echo "updating system alsa config"
sudo cp ${SCRIPT_DIR}/asound.conf /etc/asound.conf

echo "updating RAM disks"
sudo cp ${SCRIPT_DIR}/use_ram.py /etc/init.d
sudo update-rc.d use_ram.py defaults
# TODO: Reboot required to get 'use_ram.py' working. Prompt?

# webserver
