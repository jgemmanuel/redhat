#!/bin/bash

# --------------------------------------------------------------
#  REQUIRED SOFTWARE
# --------------------------------------------------------------

sudo dnf update
sudo dnf install -y gradle \
     eclipse \
     eclipse-mpc

# MongoDB
sudo dnf config-manager --add-repo https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.0/x86_64/
sudo dnf install -y mongodb-org --nogpgcheck
# sudo dnf install -y \
#      mongodb-org-server-3.0.4 \
#      mongodb-org-shell-3.0.4 \
#      mongodb-org-mongos-3.0.4 \
#      mongodb-org-tools-3.0.4
sudo semanage port -a -t mongod_port_t -p tcp 27017 # configure selinux
sudo service mongod start
sudo chkconfig mongod on	# ensure daemon start on reboot

# --------------------------------------------------------------
#  PERSONIFICATION
# --------------------------------------------------------------

# Bold text by @psmears (http://stackoverflow.com/a/2924755)
bold=`tput bold`
normal=`tput sgr0`

while true; do
    read -p "${bold}Apply customisation${normal}? [${bold}y${normal}/${bold}n${normal}]: " answer
    case $answer in
	[Yy]* ) continue;;
	[Nn]* ) echo "${bold}Init done${normal}."
		break;;
	* ) echo "${bold}Error${normal}: please answer [${bold}y${normal}]es or [${bold}n${normal}]o.";;
    esac
done

sudo locale-gen en_GB.UTF-8

REPO=$HOME/repos
EMACS=$HOME/.emacs.d
PROFILE=$HOME/.bash_profile

git clone https://github.com/mkota/dotfiles.git $REPO/dotfiles

ln -sf $REPO/dotfiles/bashrc_custom $HOME/.bashrc_custom
if [ ! -d "$EMACS" ]; then
    mkdir -p $EMACS
fi
ln -sf $REPO/dotfiles/emacs.d/* $EMACS/

# Environment variables et al
cat<<EOF >> $PROFILE

## Custom

export EDITOR="$(if [[ -n $DISPLAY ]]; then echo 'emacs'; else echo 'emacs -nw'; fi)"
export SUDO_EDITOR=/usr/bin/emacs
export LANG="en_GB.UTF-8"
export LANGUAGE="en_GB:en_US:en"
EOF

cat<<EOF >> $HOME/.bashrc

# Custom
if [ -f $HOME/.bashrc_custom ]; then
    . $HOME/.bashrc_custom
fi
EOF

source $PROFILE
source $HOME/.bashrc

sudo dnf install -y aspell emacs R nodejs npm
# sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g stylus jade


# --------------------------------------------------------------
#  END
# --------------------------------------------------------------
echo "${bold}Init done${normal}."
