sync(){
  ##rsync location 
  if [[ -d /media/alex/alexhdd/ ]];then
    rsync -a /home/alex/ALEXHDD/* /media/alex/alexhdd/
  fi
}

addcronjob(){
  ##check if cronjob already exists if not add it
  echo "*/30 * * * * bash $HOME/dotfiles/scripts/syncHDD.sh" >> .mycron
  crontab .mycron 
  rm .mycron
}

if [[ `crontab -l|grep syncHDD.sh|wc -l` -eq 0 ]];then
  addcronjob
fi

sync
