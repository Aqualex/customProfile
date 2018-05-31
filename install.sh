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
    arg="repos dotfiles bashrc vim vundle scripts kdb tldr tmux_install"
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
      if [ ! "source ~/.bash_custom" = "$(tail -n 1 ~/.bashrc)" ]; then
        echo "adding to bashrc"                                         # add settings
        echo "source ~/.bash_custom" >> ~/.bashrc                       # ensure custom settings are picked up by bashrc
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
