#!/usr/bin/env bash

############
# settings #
############

# archive settings
archive=0                                                               # archive if set to 1
archdir=~/.archive                                                      # archive directory
dotdir=$HOME                                                            # install location for dotfiles

# other
arglist=""                                                              # ensure arguments are cleared in case of failure
vimsyntax=yaq-vim

# dotfile locations
rootc=$PWD/$(dirname "${BASH_SOURCE}")                                  # full path dotfiles repo
dfiles=$rootc/dotfiles                                                  # full path to dotfiles sub directory

#######################
# archiving functions #
#######################
recurseFiles () {                                                       # return files form all sub directories
  dir=$(echo "$1" | sed 's|\/*$||g')                                    # trim trailing forward slash
  find $dir -type f | sed "s|^$dir\/||g"                                # return file paths of dotfiles
 }

archiveFile() {                                                         # archive file if it exists
  oldFile=$dotdir/$1
  if [ -f $oldFile ]; then
    echo "archiving $oldFile"
    mkdir -p $archdir/$(dirname $1)
    cp $oldFile $archdir/$1
  fi
 }

archiveAllFiles() {                                                     # archive all dotfiles
  newFiles=($(recurseFiles $dfiles))                                    # store files to install as array

  for file in ${newFiles[@]}; do                                        # iterate over dotfiles
    archiveFile $file                                                   # archive dotfile to $archdir
  done
 }

########################
# command line parsing #
########################

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
  -a|--archive)                                                         # if passed enable archiving
    archive=1
    echo archiving enabled
    shift                                                               # past argument
  ;;
  *)                                                                    # unknown option
    POSITIONAL+=("$1")                                                  # save it in an array for later
    shift                                                               # past argument
  ;;
esac
done

################
# installation #
################

if [ 0 -eq ${#POSITIONAL[@]} ]; then
  echo no arguments passed, exiting...
  return 0
fi

for arg in ${POSITIONAL[@]}; do
  if [ "all" = $arg ]; then
    arg="repos dotfiles bashrc git vim vundle scripts kdb packages"
  fi

  arglist="$arglist $arg"
done

for arg in $arglist; do

  case $arg in

    repos )
      echo "cloning repos"                                              # clone necessary repos
      while read line; do
        gf=$(basename $line)                                            # return *.git file
        gn=$HOME/git/${gf%$".git"}                                      # drop .git to return directory name
        if [ ! -d $gn ]; then                                           # check if repo has been cloned
          echo "cloning $gf"
          mkdir -p $gn                                                  # create directory to store repo
          git clone $line $gn                                           # clone repo
        fi
      done < $rootc/repos.txt                                           # file contains list of repos to clone
    ;;

    dotfiles )
      if [ 1 -ne $archive ]; then                                       # archive dotfiles if enabled
        echo "archiving not enabled"
      else
        echo "archiving enabled"
        archiveAllFiles
      fi

      echo "adding dotfiles"                                            # add dotfiles
      cp -rsf $dfiles/. $HOME                                           # symlink dotfiles to homedir
    ;;

    bashrc )
      #this will create the .bash_aliases
      if [[ 0 -eq `ls -la $HOME|grep .bash_aliases|wc -l` ]];then 
        echo "bash_aliases does not exist in $HOME"
        touch $HOME/.bash_aliases
        if [[ -f bash_utils/aliases.txt ]];then
          cat bash_utils/aliases.txt >> $HOME/.bash_aliases
        else
          echo "aliases.txt does not exist"
        fi
      elif [[ 0 -eq `cat $HOME/.bash_aliases|wc -l` ]];then
        echo ".bash_aliases does exist but it is empty"
        if [[ -f bash_utils/aliases.txt ]];then
          cat bash_utils/aliases.txt >> $HOME/.bash_aliases
        else
          echo "aliases.txt does not exist" 
        fi
      else  
        echo ".bash_aliases exists and not empty"
         if [[ -f bash_utils/aliases.txt ]];then
          echo "#USER DEFINED - USER:$USER DATE:`date`" >> $HOME/.bash_aliases
          cat bash_utils/aliases.txt >> $HOME/.bash_aliases
        else
          echo "aliases.txt does not exist"
        fi
      fi 
     
      # 
      if [[ 0 -eq `ls -la $HOME|grep .bash_envvar|wc -l` ]];then                                    #check if bash_envvar exists 
        echo "bash_envvar does not exist in $HOME"
        touch $HOME/.bash_envvar                                                                    #create bash_envvar if not 
        if [[ -f bash_utils/envvariables.txt ]];then                                                #check if envvariables.txt exists 
          cat bash_utils/envvariables.txt >> $HOME/.bash_envvar                                     #copy the envvariables to bash_envvar
        else 
          echo "envvariables.txt does not exist"
        fi                   
      elif [[ 0 -eq `cat $HOME/.bash_envvar|wc -l` ]];then                                          #check if bash_envvar is empty 
        echo ".bash_envvar does exist but it is empty"                
        if [[ -f bash_utils/envvariables.txt ]];then                                                #if bash_envvar exist but empty  
          cat bash_utils/envvariables.txt >> $HOME/.bash_envvar                                     #copy contents from envvariables.txt
        else
          echo "envvariables.txt does not exist"
        fi
      else
        echo ".bash_envvar exists and not empty"                                                    #if bash_envvar exist and not empty
         if [[ -f bash_utils/envvariables.txt ]];then                                               #if bash_envvar exist but empty
           echo "#USER DEFINED - USER:$USER DATE:`date`" >> $HOME/.bash_envvar                      #add title if bash_envvar already exists
           cat bash_utils/envvariables.txt >> $HOME/.bash_envvar                                    #copy contents from envvariables.txt
         fi
      fi
 
      #checking if the bash_envvar is sourced   
      if [[ 0 -eq `cat $HOME/.bashrc|grep ".bash_envvar"|wc -l` ]];then 
        echo "adding to .bashrc"
        echo "" >> $HOME/.bashrc
        echo "#USER DEFINED" >>$HOME/.bashrc
        echo "if [[ -f $HOME/.bash_envvar ]];then" >> $HOME/.bashrc
        echo "  . $HOME/.bash_envvar">>$HOME/.bashrc
        echo "fi" >> $HOME/.bashrc
      fi

      if [ ! -f $HOME/.git-prompt.sh ]; then                            # check for existence of git-prompt.sh
        echo "fetching git-prompt.sh"                                   # get git prompt script
        wget -O $HOME/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
      fi
    ;;

    git )
      echo "input git name"                                             # set git name
      read gitname
      echo "setting name to $gitname"
      git config --global user.name "$gitname"

      echo "input git email"                                            # set git email
      read gitemail
      echo "setting email to $gitemail"
      git config --global user.email "$gitemail"
 
      echo "input comment character"
      read commentchar
      echo "setting comment character to $commentchar"
      git config core.commentchar $commentchar
    ;;

    vim )
      echo "adding kdb syntax highlighting from $vimsyntax"             # vim kdb syntax highlighting
      if [ -d $HOME/git/$vimsyntax ]; then
        cp -rsf $HOME/git/${vimsyntax}/.vim/* $HOME/.vim
      else
        echo "$vimsyntax not cloned"
      fi
    ;;

    vundle )
      echo "cloning Vundle"
      if [ ! -d $HOME/.vim/bundle/Vundle.vim ]; then
        git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
        vim +PluginInstall +qall                                        # ensure plugins are installed
        echo "Vundle cloned"
      else
        echo "Vundle already installed"
      fi
    ;;

    scripts )
      echo "copying scripts"
      mkdir -p $HOME/scripts                                            # custom scripts
      cp -rsf $rootc/scripts/* $HOME/scripts/
    ;;

    kdb )
      source $rootc/kdb_install.sh
    ;;

    tldr )
      if [ ! -f $HOME/local/bin/tldr ]; then                            # check if tld has been installed
        echo "adding tldr"                                              # install tldr
        mkdir -p $HOME/local/bin
        curl -o $HOME/local/bin/tldr https://raw.githubusercontent.com/raylee/tldr/master/tldr
        chmod +x $HOME/local/bin/tldr
      fi
    ;;

    tmux_install )
      if [ -z `which tmux` ]; then
        echo "installing tmux"
        cd $HOME/git/tmux
        ./configure --prefix $HOME/local
        make
        make install
        cd -
      fi
    ;;

    libevent )
      echo "getting libevent"
      mkdir -p /tmp/"$USER"dep/
      wget -O /tmp/"$USER"dep/libevent-2.0.19-stable.tar.gz https://github.com/downloads/libevent/libevent/libevent-2.0.19-stable.tar.gz
      tar -xvzf /tmp/"$USER"dep/libevent-2.0.19-stable.tar.gz -C /tmp/"$USER"dep/
      cd /tmp/"$USER"dep/libevent-2.0.19-stable
      ./configure --prefix=$HOME/local
      make
      make install
      cd -
      rm -rf /tmp/"$USER"dep/
    ;;

    #add check to see if the package is already installed
    #add error handling in case package fails
    packages)
      echo "installing necessary packages..."
      echo "installing net-tools"
      `sudo apt-get install net-tools`                          #install net-tools packages. useful for ifconfig
      echo "installing openssh"
      `sudo apt-get -V install openssh-server`
    ;;

    * )
      echo "Invalid option: $arg"
    ;;

  esac

done

##############
# post steps #
##############

arglist=""

echo "sourcing $HOME/.bashrc"                                           # wrapping up
source $HOME/.bashrc

echo "setup complete"
