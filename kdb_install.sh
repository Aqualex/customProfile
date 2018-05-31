#!/usr/bin/env bash

echo "checking for kdb+..."
if [ -z `which q` ]; then
  echo "attempting to install kdb+"
else
  echo "kdb+ already installed"
  return 0
fi

sudolist=$(grep '^sudo:.*$' /etc/group | cut -d: -f4 | tr "," " " | grep -x $USER | wc -l)

if [ ! -f ~/linuxx86.zip ]; then
  echo "~/linuxx86.zip not available, aborting operation"
fi

if [ $sudolist -gt 0 ]; then
  echo "$USER in sudolist, installing necessary libraries"
  sudo apt-get install gcc-multilib
  sudo apt install rlwrap
  sudo apt install unzip
fi

echo "installing kdb+"
unzip ~/linuxx86.zip -d /tmp/"$USER"dep
echo "unzipping to /tmp/"$USER"dep"
mkdir -p ~/local/bin/
mv /tmp/"$USER"dep/q/ ~/local/bin/
echo "removing /tmp/"$USER"dep"
rm -rf /tmp/"$USER"dep
export QHOME=~/local/bin/q
export PATH=~/local/bin/q/l32/:$PATH

echo "installation finished"
