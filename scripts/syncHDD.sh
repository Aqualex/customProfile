FROM=/media/alex/ED78-CEE3/ALEXHDD/*
TO=/media/alex/alexhdd/ALEXHDD/.
HDD=/media/alex/alexhdd

sync(){
  echo "Sync started ... " >> /tmp/logs/syncHDD.txt
  ##rsync location 
  if [[ -d $HDD ]];then
    rsync -a $FROM $TO
  fi
  echo "Sync HDD has finished ... " > /tmp/logs/syncHDD.txt
}

addcronjob(){
  ##check if cronjob already exists if not add it
  echo "* 23 * * * bash $HOME/dotfiles/scripts/syncHDD.sh" >> .mycron
  crontab .mycron 
  rm .mycron
}

if [[ `crontab -l|grep syncHDD.sh|wc -l` -eq 0 ]];then
  addcronjob
fi

sync
