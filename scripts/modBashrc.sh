#!/bin/bash

BRC=~/.bashrc;
path=`pwd`;  

if [[ ! -f $BRC ]]; then 
  echo "bashrc is not in the usual location"; 
else
  if [[ -z `cat $BRC|grep "source "$path"/modBashrc.sh"` ]]; then 
    echo "adding to .bashrc...";
    if [[ -z `cat $BRC|grep "#USER SCRIPTS"` ]];then 
      echo "#USER SCRIPTS" >> $BRC; 
    fi
    echo "source "$path"/modBashrc.sh" >> $BRC; 
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



