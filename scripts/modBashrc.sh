#!/bin/bash

BRC=~/.bashrc; 

if [[ ! -f $BRC ]]; then 
  echo "bashrc is not in the usual location"; 
  exit 1; 
else
  if [[ -z `cat $BRC|grep ". ./dotfiles/scripts/modBashrc.sh"` ]]; then 
    echo "adding to .bashrc...";
    echo ". ./dotfiles/scripts/modBashrc.sh" >> $BRC;
  else 
    exit 1 
  fi
fi 

#USER DEFINED ALIASES
alias q='rlwrap -r ~/q/l32/q'
alias NUKETOR='ps -aux | grep $USER | grep torq | awk '\''{print $2}'\'' | xargs kill -9'

#USER DEFINED ENV VARIABLES
export QHOME=~/q
export R_HOME=/usr/lib/R
export EDITOR='vim'
export VISUAL='vim'



