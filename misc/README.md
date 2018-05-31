# Notes

## Allow SSH key use with multiple github accounts

To ensure SSH keys work correctly when using multiple Github accounts the
following steps need to be taken.

First `~/.ssh/config` needs to be updated to create two separate hosts for
[Github.com](https://github.com). In this example there is both a work and
a personal account.

```text
Host gh-work
HostName github.com
User git
IdentityFile ~/.ssh/<key>
IdentitiesOnly yes
AddKeysToAgent yes

Host gh-personal
HostName github.com
User git
IdentityFile ~/.ssh/<key>
IdentitiesOnly yes
AddKeysToAgent yes
```

Remote URLs must be updated after the Host configs are set using
`git remote set-url`. For this repo the new URL may look like:

```bash
git remote set-url gh-personal:vibronicshark55/dotfiles.git
```
It may also be required to add the keys to the `ssh-agent`. To automate the
process the following bash function can be added.

```bash
ssha (){
  eval $(ssh-agent -s)
  ssh-add ~/.ssh/<key1>
  ssh-add ~/.ssh/<key2>
 }
```

In this repo `dotfiles/.custom/bash_functions.sh` is a sensible place to add this.
