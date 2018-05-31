# Dotfiles

This repo stores and manages the install of various dotfiles and settings files.

## First time set up

On a new environment initial set up is handled by the standalone file
[`init.sh`](init.sh)
which can be retrieved directly from the master branch.

```
wget https://raw.githubusercontent.com/vibronicshark55/dotfiles/master/init.sh
. init.sh
```

First time running the script will create SSH keys for use with Github. After
the keys are created further running the script will clone this repo, if it
does not already exist.

## Add dotfiles

The addition of dotfiles and other settings is handled by [`install.sh`](install.sh)
which is available upon cloning this repo. This script must then be passed then
name of the settings to install, or all. it is recommended that users use the
`-a` or `--archive` flag on initial install to ensure previous dotfiles are
preserved.

```
. install.sh -a all
```

The following options are available:

- [repos](#repos)
- [bashrc](#bashrc)
- [dotfiles](#dotfiles)
- [git](#git)\*
- [vim](#vim)
- [vundle](#vundle)
- [scripts](#scripts)
- [kdb](#kdb)
- [tldr](#tldr)
- [tmux_install](#tmux_install)
- [libevent](#libevent)\*

> \* Not included in all

## Available Settings

The following are details of the available settings.

### repos

Will clone the repos listed in [`repos.txt`](repos.txt).

### dotfiles

The following files will be softlinked to `$HOME`:

- [`.bash_custom`](dotfiles/.bash_custom) - environment settings
- [`.custom/`](dotfiles/.custom) - bash functions and aliases
- [`.vimrc`](dotfiles/.vimrc) - vim settings
- [`.vim/ftplugin`](.vim/ftplugin) - language specific plugins
- [`.gitconfig`](dotfiles/.gitconfig) - git aliases and settings
- [`.tmux.conf`](dotfiles/.tmux.conf) - custom prefix and bindings

### bashrc

Ensures that [`.bash_custom`](dotfiles/.bash_custom) is sourced in
`.bashrc`, and installs
[`git-prompt.sh`](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh)
which is sourced by the custom bash file.

### git

Adds global git user and email.

### vim

Adds [kdb syntax highlighting](https://github.com/patmok/qvim) from
[patmok](https://github.com/patmok).

### vundle

Adds [Vundle](https://github.com/VundleVim/Vundle.vim) a plugin manager for
vim.

Current plugins:
- [tmux-vim-navigator](https://github.com/christoomey/vim-tmux-navigator) - allows
 for alt+arrow key switching between vim and tmux.

### scripts

Adds:
- [`multigrep.sh`](scripts/multigrep.sh) - simplified multiple word search for grep
- [`tmux_session.sh`](scripts/tmux_session.sh) - basic tmux session template

### kdb

Installs kdb+ if the user has sudo access and `linuxx86.zip` from
[kx](https://kx.com/download/). It is expected that this file is
placed in the users home directory.

### tldr

Retrieves [tldr](https://github.com/raylee/tldr) from
[raylee](https://github.com/raylee) which shows simplified man pages.

### tmux_install

Will install [tmux](https://github.com/tmux/tmux) if it does not already
exist on the host.

### libevent

Installs [libevent](https://github.com/libevent/libevent/releases/tag/release-2.0.19-stable),
can't remember why this was needed.
