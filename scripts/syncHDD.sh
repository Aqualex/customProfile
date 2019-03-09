#!/bin/bash
##----------------------------------------------------------------------------------------------------------------------

# - Before you start the program you will have to define HDDTO and HDDFROM.
# - this program will add itself to the crontab and run every day at 23:00 

########################################################################################################################
##     FUNCTIONS DEFINITIONS                                                                                          ##
########################################################################################################################

checkenv(){
  echo "[INFO]|$(gettimestamp)|Checking environment variables ..." >> $SYNCLOG

  __check(){
     local a=$(eval "echo "\$$1"") 
    if [[ -z $a ]];then 
      echo "[ERROR]|$(gettimestamp)|$1 is not set. Program will exit ... " >> $SYNCLOG
      exit 1
    else 
      echo "[INFO]|$(gettimestamp)|$1 is set ... " >> $SYNCLOG
    fi
  }

  __check $1
  __check $2
}

createlog(){
  SYNCLOG="${SYNCLOG:-/tmp/logs/sync/syncHDD_"$(date "+%Y%m%d")"}"
  mkdir -p /tmp/logs/sync

  if [[ ! -f $SYNCLOG ]];then 
    touch $SYNCLOG
  fi
}

monitor(){
  while true 
    do 
      if [[ ! 0 -eq `ps aux|grep "[r]sync -a $HDDFROM $HDDTO"|wc -l` ]];then
        sleep 10;
        total=`du -sh $HDDFROM|awk '{print $1}'`
        sofar=`du -sh $HDDTO|awk '{print $1}'`
        echo "[INFO]|$(gettimestamp)|Process is still running: [TOTAL]: $total; [sofar]: $sofar" >> $SYNCLOG
      else 
        echo "[INFO]|$(gettimestamp)|Process has finshed ..."
        break
      fi
    done  
}

header(){
  echo "" >> $SYNCLOG
  echo "[STARTING SCRIPT]|CRONJOB [...] Syncing HDD |$(date "+%Y.%m.%dD%T")" >> $SYNCLOG                                                         
  echo "" >> $SYNCLOG
}

footer(){
  echo "" >> $SYNCLOG
  echo "[STOPPING SCRIPT]|CRONJOB [...] Syncing HDD |$(date "+%Y.%m.%dD%T")" >> $SYNCLOG
  echo "" >> $SYNCLOG
}

gettimestamp(){
  #get timestamp for adding it to error/info reporting
  date "+%Y.%m.%dD%T.%N"
}

sync(){
  echo "[INFO]|$(gettimestamp)|Sync started ... " >> $SYNCLOG
  ##rsync location 
  if [[ -d $(dirname $HDDTO) ]];then 
    if [[ 0 -eq `ps aux|grep "[r]sync -a $HDDFROM $HDDTO"|wc -l` ]];then
      echo "starting"
      nohup rsync -a $HDDFROM $HDDTO &
      monitor    
    else
      echo "[INFO]|$(gettimestamp)|Process already running..." >> $SYNCLOG
      echo "[INFO]|$(gettimestamp)|Starting to monitor..." >> $SYNCLOG
      monitor 
    fi
  else 
    echo "[ERROR]|$(gettimestamp)|$HDDTO does not exist or HDD not mounted" >> $SYNCLOG
  fi
  echo "[SYNC]|$(gettimestamp)|Sync HDD has finished " >> $SYNCLOG
}

addcronjob(){
  ##check if cronjob already exists if not add it
  echo "[INFO]|$(gettimestamp)|Adding cronjob ..." >> $SYNCLOG
  echo "0 23 * * * bash $HOME/dotfiles/scripts/syncHDD.sh" >> .mycron
  crontab .mycron 
  echo "[INFO]|$(gettimestamp)|Cronjob added" >> $SYNCLOG
  rm .mycron
}

########################################################################################################################
##     MAIN                                                                                                           ##
########################################################################################################################
createlog
checkenv "HDDFROM" "HDDTO"
header
if [[ `crontab -l|grep syncHDD.sh|wc -l` -eq 0 ]];then
  addcronjob
fi
sync
footer
##----------------------------------------------------------------------------------------------------------------------
