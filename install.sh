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
    arg="dotfiles bashrc git vim scripts kdb packages htop"
  fi

  arglist="$arglist $arg"
done

for arg in $arglist; do

  case $arg in
    
    htop)
         echo "Installing htop ..."
	 sudo apt install htop  
    ;;

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
      echo "Installation process for bashrc is not defined ..."
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
      echo "Installing kdb ..."
      echo "Make sure to copy *.zip file and kc.lic in $PWD/instaPackages/kdb"
      read -p "Are the required files present? : [Y/N]" answer
      if [[ ! $answer == "Y" ]];then
          echo "Reexecute this file like -> bash install.sh kdb"
          break
      fi
  
      #check if folder kdb exists in instPackages
      if [[ 0 -eq `find $PWD/instPackages/. -type d -name kdb | wc -l` ]];then
           echo "Folder kdb does not exist. Function will be aborted ..."
	   exit 
      fi 

      #check if folder kdb exists in unzipped 
      if [[ 0 -eq `find $PWD/unzipped/. -type d -name q | wc -l` ]];then
           echo "Creating folder in $PWD/unzipped/"
	   mkdir -p $PWD/unzipped/q
      fi 

      echo "Unzipping files present in $PWD/instPackages/kdb ..."
      if [[ 0 -eq `find $PWD/instPackages -name *.zip | wc -l` ]];then 
           echo "There is no zip file in the target directory. Doing nothing"
      else
	 #if folder unzipped/kdb/ is not empty clean and unzip
	 if [[ 0 -ne `ls $PWD/unzipped/q/. | wc -l` ]];then
	      echo "Folder $PWD/unzipped/q/ is not empty. Clearing contents ..."
	      rm -rf $PWD/unzipped/q/* 
	 fi
        
	 unzip $PWD/instPackages/kdb/*.zip -d $PWD/unzipped/q/.
	 cp $PWD/instPackages/kdb/*.lic $PWD/unzipped/q/. 
       fi

       echo "Moving folder from $PWD/unzipped/q to $HOME"
       mv $PWD/unzipped/q $HOME

       echo "Adding necessary variables for kdb to work"
       echo "Attempting to .bashrc_qkdb_aliase.sh which will be source in .bashrc"
       if [[ -f $HOME/.bashrc_qkdb_alias.sh ]];then
            echo "File .bashrc_qkdb_alias.sh already exists"
       else 
            echo "Creating file .bashrc_qkdb_alias.sh in $HOME..."
	    touch $HOME/.bashrc_qkdb_alias.sh
	    echo "#Setting necessary aliases" >> $HOME/.bashrc_qkdb_alias.sh
	    echo "alias q=\"QHOME=$HOME/q rlwrap -r $HOME/q/l64/q\"" >> $HOME/.bashrc_qkdb_alias.sh
	    echo " " >> $HOME/.bashrc_qkdb_alias.sh
	    echo "#Setting necessary environment variables" >> $HOME/.bashrc_qkdb_alias.sh
	    echo "export QLIC $HOME/q" >> $HOME/.bashrc_qkdb_alias.sh
       fi

       echo "Attempting to add file $HOME/.bashrc_qkdb_alias.sh to .bashrc"
       if [[ 0 -eq `cat $HOME/.bashrc | grep .bashrc_qkdb_alias.sh | wc -l` ]];then
            echo "Seems like $HOME/.bashrc_qkdb_alias.sh is not sourced in .bashrc Adding now ..."
	    echo "" >> $HOME/.bashrc
	    echo "#Sourcing variables necessary for kdb/q+"
	    echo "" >> $HOME/.bashrc
	    echo "if [[ -f $HOME/.bashrc_qkdb_alias.sh ]];then" >> $HOME/.bashrc
            echo "  echo \"Sourcing $HOME/.bashrc_qkdb_alias.sh\"" >> $HOME/.bashrc
            echo "  source $HOME/.bashrc_qkdb_alias.sh" >> $HOME/.bashrc
            echo "else" >> $HOME/.bashrc
            echo "  echo \"File .bashrc_qkdb_alias.sh does not exist\"" >> $HOME/.bashrc
            echo "fi" >> $HOME/.bashrc
       fi
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
      sudo apt-get install net-tools                          #install net-tools packages. useful for ifconfig
      echo "installing openssh"
      sudo apt-get -V install openssh-server
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
