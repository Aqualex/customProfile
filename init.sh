#!/usr/bin/env bash

# this script should only be used on first install

hn=$(echo $(basename $HOSTNAME) | cut -d"." -f1)

if [ ! -f $HOME/.ssh/"$hn"_key ]; then                                  # check SSH exists for current host, creating of necessary
  echo "Creating SSH keys, enter email used with Github"
  read gitemail
  mkdir -p $HOME/.ssh                                                   # create ssh dir
  ssh-keygen -N '' -t rsa -b 4096 -C "$gitemail" -f $HOME/.ssh/${HOSTNAME}_key
  echo "Host github.com" >> $HOME/.ssh/config
  echo "IdentityFile $HOME/.ssh/${HOSTNAME}_key" >> $HOME/.ssh/config
  echo "Add key to github before proceeding"
  return 0
fi

if [ ! -d $HOME/git/dotfiles ]; then
  git clone git@github.com:vibronicshark55/dotfiles.git $HOME/git/dotfiles # clone dotfiles repo if it does not exist
fi
